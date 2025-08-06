//
//  ResourceIndex.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
// *   rhiamom@mac.com                                                       *
// *                                                                         *
// *   This program is free software; you can redistribute it and/or modify  *
// *   it under the terms of the GNU General Public License as published by  *
// *   the Free Software Foundation; either version 2 of the License, or     *
// *   (at your option) any later version.                                   *
// *                                                                         *
// *   This program is distributed in the hope that it will be useful,       *
// *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
// *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
// *   GNU General Public License for more details.                          *
// *                                                                         *
// *   You should have received a copy of the GNU General Public License     *
// *   along with this program; if not, write to the                         *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "ResourceIndex.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "PackedFileDescriptors.h"
#import "PackedFileDescriptor.h"
#import "Wait.h"

@interface ResourceIndex ()

// Hierarchical index: Type -> Group -> Instance -> Files
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary *> *index;
@property (nonatomic, weak) id<IPackageFile> packageFile;
@property (nonatomic, assign) uint32_t highestOffset;
@property (nonatomic, strong) PackedFileDescriptors *pfds;
@property (nonatomic, assign, readwrite) BOOL flat;

@end

@implementation ResourceIndex

// MARK: - Initialization

- (instancetype)initWithPackageFile:(id<IPackageFile>)packageFile capacity:(NSInteger)capacity {
    return [self initWithPackageFile:packageFile flat:NO capacity:capacity];
}

- (instancetype)initWithPackageFile:(id<IPackageFile>)packageFile
                               flat:(BOOL)flat
                           capacity:(NSInteger)capacity {
    self = [super init];
    if (self) {
        _packageFile = packageFile;
        _pfds = [[PackedFileDescriptors alloc] initWithCapacity:capacity];
        _flat = flat;
        _highestOffset = 0;
        [self loadIndex];
    }
    return self;
}

// MARK: - Properties

- (uint32_t)nextFreeOffset {
    return self.highestOffset;
}

- (NSInteger)count {
    return [[self flatten] length];
}

// MARK: - Index Management

- (ResourceIndex *)clone {
    ResourceIndex *clone = [[ResourceIndex alloc] initWithPackageFile:self.packageFile
                                                                 flat:self.flat
                                                             capacity:[self.pfds length]];
    clone.index = [self.index mutableCopy];
    return clone;
}

- (void)loadIndex {
    [self loadIndexWithPfds:nil];
}

- (void)loadIndexWithPfds:(PackedFileDescriptors *)pfds {
    self.index = [[NSMutableDictionary alloc] init];
    
    [Wait subStart];
    
    [self.index removeAllObjects];
    if (pfds != nil) {
        [self addIndexFromPfds:pfds];
    }
    
    [Wait subStop];
}

// MARK: - Adding to Index

- (void)addIndexFromPfds:(PackedFileDescriptors *)pfds {
    for (id<IPackedFileDescriptor> pfd in pfds) {
        [self addIndexFromPfd:pfd];
    }
}

- (void)addIndexFromPfd:(id<IPackedFileDescriptor>)pfd {
    // Set up event handling if not flat
    if (!self.flat) {
        // Note: Event handling would need to be implemented when IPackedFileDescriptor protocol is defined
        // [pfd addObserver:self forKeyPath:@"description" options:0 context:nil];
    }
    
    // Update highest offset
    if ([pfd offset] + [pfd size] > self.highestOffset) {
        self.highestOffset = (uint32_t)([pfd offset] + [pfd size]);
    }
    
    // Add to hierarchical index if not flat
    if (!self.flat) {
        NSNumber *typeKey = @([pfd type]);
        NSNumber *groupKey = @([pfd group]);
        NSNumber *instanceKey = @([pfd longInstance]);
        
        // Get or create type dictionary
        NSMutableDictionary *groups = self.index[typeKey];
        if (!groups) {
            groups = [[NSMutableDictionary alloc] init];
            self.index[typeKey] = groups;
        }
        
        // Get or create group dictionary
        NSMutableDictionary *instances = groups[groupKey];
        if (!instances) {
            instances = [[NSMutableDictionary alloc] init];
            groups[groupKey] = instances;
        }
        
        // Get or create instance array
        PackedFileDescriptors *files = instances[instanceKey];
        if (!files) {
            files = [[PackedFileDescriptors alloc] init];
            instances[instanceKey] = files;
        }
        
        [files add:pfd];
    }
    
    // Always add to flat list
    [self.pfds add:pfd];
}

// MARK: - Removing from Index

- (void)removeFromList:(PackedFileDescriptors *)list pfd:(id<IPackedFileDescriptor>)pfd {
    BOOL removed = NO;
    for (NSInteger i = [list count] - 1; i >= 0; i--) {
        id<IPackedFileDescriptor> p = [list objectAtIndex:i];
        if ([p isEqual:pfd]) {
            [list removeAtIndex:i];
            removed = YES;
        }
    }
    
    if (!removed) {
        @throw [NSException exceptionWithName:@"RemovalError"
                                       reason:@"Failed to remove descriptor from list"
                                     userInfo:nil];
    }
}

- (void)removeChanged:(id<IPackedFileDescriptor>)pfd {
    if (!self.flat) {
        for (NSNumber *typeKey in [self.index allKeys]) {
            NSMutableDictionary *groups = self.index[typeKey];
            for (NSNumber *groupKey in [groups allKeys]) {
                NSMutableDictionary *instances = groups[groupKey];
                for (NSNumber *instanceKey in [instances allKeys]) {
                    PackedFileDescriptors *list = instances[instanceKey];
                    for (NSInteger i = [list count] - 1; i >= 0; i--) {
                        if ([list objectAtIndex:i] == pfd) {
                            [self removeFromList:self.pfds pfd:[list objectAtIndex:i]];
                            [list removeAtIndex:i];
                        }
                    }
                }
            }
        }
    } else {
        [self removeFromList:self.pfds pfd:pfd];
    }
}

- (void)removeItem:(id<IPackedFileDescriptor>)pfd {
    if (!self.flat) {
        NSNumber *typeKey = @([pfd type]);
        NSNumber *groupKey = @([pfd group]);
        NSNumber *instanceKey = @([pfd longInstance]);
        
        NSMutableDictionary *groups = self.index[typeKey];
        if (groups) {
            NSMutableDictionary *instances = groups[groupKey];
            if (instances) {
                PackedFileDescriptors *list = instances[instanceKey];
                if (list) {
                    [list remove:pfd];
                    [self.pfds remove:pfd];
                }
            }
        }
    } else {
        [self.pfds remove:pfd];
    }
}

- (PackedFileDescriptors *)removeDeleteMarkedItems {
    PackedFileDescriptors *removed = [[PackedFileDescriptors alloc] init];
    
    if (!self.flat) {
        for (NSNumber *typeKey in [self.index allKeys]) {
            NSMutableDictionary *groups = self.index[typeKey];
            for (NSNumber *groupKey in [groups allKeys]) {
                NSMutableDictionary *instances = groups[groupKey];
                for (NSNumber *instanceKey in [instances allKeys]) {
                    PackedFileDescriptors *list = instances[instanceKey];
                    for (NSInteger i = [list count] - 1; i >= 0; i--) {
                        id<IPackedFileDescriptor> pfd = [list objectAtIndex:i];
                        if ([pfd markForDelete]) {
                            [self.pfds remove:pfd];
                            [removed add:pfd];
                            [list removeAtIndex:i];
                        }
                    }
                }
            }
        }
    } else {
        for (NSInteger i = [self.pfds count] - 1; i >= 0; i--) {
            id<IPackedFileDescriptor> pfd = [self.pfds objectAtIndex:i];
            if ([pfd markForDelete]) {
                [self.pfds removeAtIndex:i];
            }
        }
    }
    
    return removed;
}

// MARK: - Finding Files

- (PackedFileDescriptors *)findFile:(id<IPackedFileDescriptor>)pfd {
    if (!self.flat) {
        NSNumber *typeKey = @([pfd type]);
        NSNumber *groupKey = @([pfd group]);
        NSNumber *instanceKey = @([pfd longInstance]);
        
        NSMutableDictionary *groups = self.index[typeKey];
        if (groups) {
            NSMutableDictionary *instances = groups[groupKey];
            if (instances) {
                PackedFileDescriptors *files = instances[instanceKey];
                if (files) {
                    return files;
                }
            }
        }
        
        return [[PackedFileDescriptors alloc] init];
    } else {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor isEqual:pfd]) {
                [result add:descriptor];
            }
        }
        return result;
    }
}

- (PackedFileDescriptors *)findFileByType:(uint32_t)type {
    PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
    
    if (!self.flat) {
        NSNumber *typeKey = @(type);
        NSMutableDictionary *groups = self.index[typeKey];
        if (groups) {
            for (NSNumber *groupKey in [groups allKeys]) {
                NSMutableDictionary *instances = groups[groupKey];
                for (NSNumber *instanceKey in [instances allKeys]) {
                    PackedFileDescriptors *files = instances[instanceKey];
                    [result addRange:files];
                }
            }
        }
    } else {
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor type] == type) {
                [result add:descriptor];
            }
        }
    }
    
    return result;
}

- (PackedFileDescriptors *)findFileByType:(uint32_t)type group:(uint32_t)group {
    PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
    
    if (!self.flat) {
        NSNumber *typeKey = @(type);
        NSNumber *groupKey = @(group);
        
        NSMutableDictionary *groups = self.index[typeKey];
        if (groups) {
            NSMutableDictionary *instances = groups[groupKey];
            if (instances) {
                for (NSNumber *instanceKey in [instances allKeys]) {
                    PackedFileDescriptors *files = instances[instanceKey];
                    [result addRange:files];
                }
            }
        }
    } else {
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor type] == type && [descriptor group] == group) {
                [result add:descriptor];
            }
        }
    }
    
    return result;
}

- (PackedFileDescriptors *)findFileByType:(uint32_t)type
                                    group:(uint32_t)group
                                 instance:(uint64_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    [pfd setGroup:group];
    [pfd setType:type];
    [pfd setLongInstance:instance];
    
    return [self findFile:pfd];
}

- (PackedFileDescriptors *)findFileByType:(uint32_t)type
                                    group:(uint32_t)group
                                  subtype:(uint32_t)subtype
                                 instance:(uint32_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    [pfd setGroup:group];
    [pfd setType:type];
    [pfd setSubType:subtype];
    [pfd setInstance:instance];
    
    return [self findFile:pfd];
}

- (PackedFileDescriptors *)findFileDiscardingGroup:(id<IPackedFileDescriptor>)pfd {
    return [self findFileDiscardingGroupByType:[pfd type] instance:[pfd longInstance]];
}

- (PackedFileDescriptors *)findFileDiscardingGroupByType:(uint32_t)type instance:(uint64_t)instance {
    PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
    
    if (!self.flat) {
        NSNumber *typeKey = @(type);
        NSNumber *instanceKey = @(instance);
        
        NSMutableDictionary *groups = self.index[typeKey];
        if (groups) {
            for (NSNumber *groupKey in [groups allKeys]) {
                NSMutableDictionary *instances = groups[groupKey];
                PackedFileDescriptors *files = instances[instanceKey];
                if (files) {
                    [result addRange:files];
                }
            }
        }
    } else {
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor type] == type && [descriptor longInstance] == instance) {
                [result add:descriptor];
            }
        }
    }
    
    return result;
}

- (PackedFileDescriptors *)findFileByInstance:(uint64_t)instance {
    if (!self.flat) {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        NSNumber *instanceKey = @(instance);
        
        for (NSNumber *typeKey in [self.index allKeys]) {
            NSMutableDictionary *groups = self.index[typeKey];
            for (NSNumber *groupKey in [groups allKeys]) {
                NSMutableDictionary *instances = groups[groupKey];
                PackedFileDescriptors *files = instances[instanceKey];
                if (files) {
                    [result addRange:files];
                }
            }
        }
        
        return result;
    } else {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor longInstance] == instance) {
                [result add:descriptor];
            }
        }
        return result;
    }
}

- (PackedFileDescriptors *)findFileBySubtype:(uint32_t)subtype instance:(uint32_t)instance {
    uint64_t longInstance = (((uint64_t)subtype << 32) & 0xffffffff00000000ULL) | (uint64_t)instance;
    return [self findFileByInstance:longInstance];
}

- (PackedFileDescriptors *)findFileByType:(uint32_t)type instance:(uint64_t)instance {
    return [self findFileDiscardingGroupByType:type instance:instance];
}

- (PackedFileDescriptors *)findFileByType:(uint32_t)type subtype:(uint32_t)subtype instance:(uint32_t)instance {
    uint64_t longInstance = (((uint64_t)subtype << 32) & 0xffffffff00000000ULL) | (uint64_t)instance;
    return [self findFileDiscardingGroupByType:type instance:longInstance];
}

- (PackedFileDescriptors *)findFileByGroup:(uint32_t)group instance:(uint64_t)instance {
    if (!self.flat) {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        NSNumber *groupKey = @(group);
        NSNumber *instanceKey = @(instance);
        
        for (NSNumber *typeKey in [self.index allKeys]) {
            NSMutableDictionary *groups = self.index[typeKey];
            NSMutableDictionary *instances = groups[groupKey];
            if (instances) {
                PackedFileDescriptors *files = instances[instanceKey];
                if (files) {
                    [result addRange:files];
                }
            }
        }
        
        return result;
    } else {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor longInstance] == instance && [descriptor group] == group) {
                [result add:descriptor];
            }
        }
        return result;
    }
}

- (PackedFileDescriptors *)findFileByGroup:(uint32_t)group {
    if (!self.flat) {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        NSNumber *groupKey = @(group);
        
        for (NSNumber *typeKey in [self.index allKeys]) {
            NSMutableDictionary *groups = self.index[typeKey];
            NSMutableDictionary *instances = groups[groupKey];
            if (instances) {
                for (NSNumber *instanceKey in [instances allKeys]) {
                    PackedFileDescriptors *files = instances[instanceKey];
                    [result addRange:files];
                }
            }
        }
        
        return result;
    } else {
        PackedFileDescriptors *result = [[PackedFileDescriptors alloc] init];
        for (id<IPackedFileDescriptor> descriptor in self.pfds) {
            if ([descriptor group] == group) {
                [result add:descriptor];
            }
        }
        return result;
    }
}

- (id<IPackedFileDescriptor>)findSingleFile:(id<IPackedFileDescriptor>)pfd beTolerant:(BOOL)beTolerant {
    PackedFileDescriptors *list = [self findFile:pfd];
    
    if ([list length] > 0) {
        return [list objectAtIndex:0];
    }
    
    return nil;
}

// MARK: - Utility Methods

- (PackedFileDescriptors *)flatten {
    if (self.pfds == nil) {
        self.pfds = [[PackedFileDescriptors alloc] init];
    }
    return self.pfds;
}

- (void)clear {
    [self clearWithFull:YES];
}

- (void)clearWithFull:(BOOL)full {
    if (self.index == nil) return;
    
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = self.index[typeKey];
        for (NSNumber *groupKey in [groups allKeys]) {
            NSMutableDictionary *instances = groups[groupKey];
            for (NSNumber *instanceKey in [instances allKeys]) {
                PackedFileDescriptors *list = instances[instanceKey];
                [list clear];
            }
            [instances removeAllObjects];
        }
        [groups removeAllObjects];
    }
    [self.index removeAllObjects];
    
    if (full) {
        [self.pfds clear];
    }
}

@end
