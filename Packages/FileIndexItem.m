//
//  FileIndexItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "FileIndexItem.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "MetaData.h"
#import "PackedFileDescriptor.h"
#import "GeneratableFile.h"

@interface FileIndexItem ()
@property (nonatomic, assign) uint32_t localGr;
@property (nonatomic, strong, readwrite) id<IPackageFile> package;
@end

@implementation FileIndexItem

// MARK: - Initialization

- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)descriptor
                           package:(id<IPackageFile>)package {
    self = [super init];
    if (self) {
        if (descriptor != nil) {
            _fileDescriptor = descriptor;
        } else {
            _fileDescriptor = [[PackedFileDescriptor alloc] init];
        }
        
        if (package != nil) {
            _package = package;
        } else {
            _package = [GeneratableFile loadFromStream:nil];
        }
        
        _localGr = [FileIndexItem getLocalGroup:_package];
        _resource = self;
    }
    return self;
}

// MARK: - IScenegraphFileIndexItem Protocol Properties

- (uint32_t)type {
    return [self.fileDescriptor type];
}

- (uint32_t)group {
    return [self.fileDescriptor group];
}

- (uint32_t)instance {
    return [self.fileDescriptor instance];
}

- (uint64_t)longInstance {
    return [self.fileDescriptor longInstance];
}

- (NSString *)filename {
    return [self.fileDescriptor filename];
}

// MARK: - Properties

- (uint32_t)localGroup {
    if ([self.fileDescriptor group] == [MetaData localGroup]) {
        return self.localGr;
    } else {
        return [self.fileDescriptor group];
    }
}

- (NSString *)fiiDescription {
    return [self.fileDescriptor filename];
}

// MARK: - Methods

- (id<IPackedFileDescriptor>)getLocalFileDescriptor {
    id<IPackedFileDescriptor> p = [self.fileDescriptor clone];
    [p setGroup:self.localGroup];
    return p;
}

- (NSString *)getLongHashCode {
    NSString *filename = [self.package fileName];
    return [NSString stringWithFormat:@"%@-%@", self.fileDescriptor, filename];
}

// MARK: - NSObject Overrides

- (NSUInteger)hash {
    return [self.fileDescriptor type] ^ [self.fileDescriptor group] ^ (NSUInteger)[self.fileDescriptor longInstance];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[FileIndexItem class]]) {
        return NO;
    }
    
    FileIndexItem *other = (FileIndexItem *)object;
    
    if (self.localGroup != other.localGroup) {
        return NO;
    }
    
    BOOL descriptorEqual = [self.fileDescriptor isEqualTo:other.fileDescriptor];
    BOOL packageEqual = (self.package == other.package);
    
    return descriptorEqual && packageEqual;
}

- (NSComparisonResult)compare:(FileIndexItem *)other {
    if (![other isKindOfClass:[FileIndexItem class]]) {
        return NSOrderedSame;
    }
    
    uint64_t thisInstance = [self.fileDescriptor instance];
    uint64_t otherInstance = [other.fileDescriptor instance];
    
    if (thisInstance < otherInstance) {
        return NSOrderedAscending;
    } else if (thisInstance > otherInstance) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"FileIndexItem: %@", [self.fileDescriptor filename]];
}

// MARK: - Static Methods

+ (uint32_t)getLocalGroup:(id<IPackageFile>)package {
    NSString *filename = [package saveFileName];
    return [FileIndexItem getLocalGroupForFilename:filename];
}

+ (uint32_t)getLocalGroupForFilename:(NSString *)filename {
    // TODO: Implement when FileTable.GroupCache is translated
    // For now, return a default local group
    if (filename == nil) {
        filename = @"memoryfile";
    }
    filename = [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    // This will need to be implemented when GroupCache is translated:
    // if ([FileTable groupCache] == nil) [ScenegraphWrapperFactory loadGroupCache];
    // id<IGroupCacheItem> gci = [[FileTable groupCache] getItem:filename];
    // return [gci localGroup];
    
    // Default local group for now
    return 0x7F000000;
}

@end

// MARK: - FileIndexItems Implementation

@implementation FileIndexItems

- (FileIndexItem *)objectAtIndexedSubscript:(NSUInteger)index {
    return [self objectAtIndex:index];
}

- (void)setObject:(FileIndexItem *)object atIndexedSubscript:(NSUInteger)index {
    [self replaceObjectAtIndex:index withObject:object];
}

- (NSInteger)addItem:(FileIndexItem *)item {
    [self addObject:item];
    return [self count] - 1;
}

- (void)insertItem:(FileIndexItem *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeItem:(FileIndexItem *)item {
    [self removeObject:item];
}

- (BOOL)containsItem:(FileIndexItem *)item {
    return [self containsObject:item];
}

- (void)sortItems {
    [self sortUsingComparator:^NSComparisonResult(FileIndexItem *obj1, FileIndexItem *obj2) {
        return [obj1 compare:obj2];
    }];
}

- (NSInteger)length {
    return [self count];
}

@end
