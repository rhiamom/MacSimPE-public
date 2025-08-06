//
//  ResourceViewManager.m
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
// ***************************************************************************/
#import "IScenegraphFileIndexItem.h"
#import "ResourceViewManager.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "NamedPackedFileDescriptor.h"
#import "PackedFileDescriptors.h"
#import "Helper.h"
#import "FileTable.h"
#import "Wait.h"
#import "Localization.h"
#import "Registry.h"
#import "IScenegraphFileIndexItem.h"

@protocol IScenegraphFileIndexItem;

@interface ResourceViewManager ()

@property (nonatomic, strong, readwrite) ResourceMaps *maps;
@property (nonatomic, strong) id<IPackageFile> pkg;

// ADD THESE MISSING METHOD DECLARATIONS:
- (void)updateContentWithLetTreeViewSelect:(BOOL)letTreeViewSelect;
- (void)newPackageSavedIndex:(NSNotification *)notification;
- (void)newPackageRemovedResource:(NSNotification *)notification;
- (void)newPackageAddedResource:(NSNotification *)notification;
@end

@implementation ResourceViewManager

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _maps = [[ResourceMaps alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self cancelThreads];
}

// MARK: - Properties

- (void)setListView:(ResourceListViewExt *)listView {
    if (_listView != listView) {
        if (_listView != nil) {
            [_listView setManager:nil];
        }
        _listView = listView;
        if (_listView != nil) {
            [_listView setManager:self];
        }
    }
}

- (void)setTreeView:(ResourceTreeViewExt *)treeView {
    if (_treeView != treeView) {
        if (_treeView != nil) {
            [_treeView setManager:nil];
        }
        _treeView = treeView;
        if (_treeView != nil) {
            [_treeView setManager:self];
        }
    }
}

- (BOOL)available {
    return (self.treeView != nil && self.listView != nil);
}

- (ResourceNameList *)everything {
    return self.maps.everything;
}

- (id<IPackageFile>)package {
    return self.pkg;
}

- (void)setPackage:(id<IPackageFile>)package {
    if (self.pkg != package) {
        id<IPackageFile> old = self.pkg;
        self.pkg = package;
        [self onChangedPackage:old newPackage:self.pkg letTreeViewSelect:YES];
    }
}

// MARK: - Package Management

- (void)onChangedPackage:(id<IPackageFile>)oldPackage
              newPackage:(id<IPackageFile>)newPackage
       letTreeViewSelect:(BOOL)letTreeViewSelect {
    
    @synchronized (self.maps) {
        if (self.listView != nil) {
            [self.listView beginUpdate];
        }
        
        if (oldPackage != nil) {
            // Remove event handlers from old package
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"SavedIndex"
                                                          object:oldPackage];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"RemovedResource"
                                                          object:oldPackage];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"AddedResource"
                                                          object:oldPackage];
        }
        
        [self.maps clear];
        
        if (newPackage != nil) {
            PackedFileDescriptors *index = [newPackage index];
            
            if ([[Registry windowsRegistry] showProgressWhenPackageLoads] ||
                ![[Registry windowsRegistry] asynchronSort]) {
                [Wait startWithCount:(NSInteger)[index count]];
            } else {
                [Wait start];
            }
            
            [Wait setMessage:[Localization getString:@"Loading package..."]];
            
            NSInteger ct = 0;
            for (id<IPackedFileDescriptor> pfd in index) {
                NamedPackedFileDescriptor *npfd =
                    [[NamedPackedFileDescriptor alloc] initWithDescriptor:pfd
                                                                  package:newPackage];
                
                if (![[Registry windowsRegistry] asynchronSort]) {
                    [npfd getRealName];
                }
                
                [self.maps.everything addObject:npfd];
                [self addResourceToMaps:npfd];
                
                if ([[Registry windowsRegistry] showProgressWhenPackageLoads] ||
                    ![[Registry windowsRegistry] asynchronSort]) {
                    [Wait setProgress:ct++];
                }
            }
            [Wait stop]; // <- ADD THIS LINE
        }

        
        [self updateContentWithLetTreeViewSelect:letTreeViewSelect];
        
        if (newPackage != nil) {
            // Add event handlers for new package
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newPackageSavedIndex:)
                                                         name:@"SavedIndex"
                                                       object:newPackage];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newPackageRemovedResource:)
                                                         name:@"RemovedResource"
                                                       object:newPackage];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newPackageAddedResource:)
                                                         name:@"AddedResource"
                                                       object:newPackage];
        }
        
        if (self.listView != nil) {
            [self.listView endUpdate];
        }
    }
}

- (void)updateTree {
    [self.maps clearKeepEverything:NO];
    
    for (NamedPackedFileDescriptor *npfd in self.maps.everything) {
        if (![[Registry windowsRegistry] asynchronSort]) {
            [npfd getRealName];
        }
        [self addResourceToMaps:npfd];
    }
    
    if (self.treeView != nil) {
        [self.treeView setResourceMaps:self.maps
                     letTreeViewSelect:NO
                           doNotSelect:NO];
    }
}

- (void)updateContentWithLetTreeViewSelect:(BOOL)letTreeViewSelect {
    BOOL doNotSelect = NO;
    
    if ([self.maps.everything count] > [[Registry windowsRegistry] bigPackageResourceCount] &&
        ![[Registry windowsRegistry] resourceTreeAlwaysAutoselect]) {
        doNotSelect = YES;
    }
    
    if (self.listView != nil && !letTreeViewSelect) {
        if (doNotSelect) {
            [self.listView setResources:[[ResourceNameList alloc] init]];
        } else {
            [self.listView setResources:self.maps.everything];
        }
    }
    
    if (self.treeView != nil) {
        [self.treeView setResourceMaps:self.maps
                     letTreeViewSelect:letTreeViewSelect
                           doNotSelect:doNotSelect];
    }
}

- (void)fakeSave {
    [self newPackageSavedIndex:nil];
}

// MARK: - Event Handlers

- (void)newPackageSavedIndex:(NSNotification *)notification {
    [self onChangedPackage:self.pkg newPackage:self.pkg letTreeViewSelect:YES];
}

- (void)newPackageRemovedResource:(NSNotification *)notification {
    if (self.listView != nil) {
        [self.listView refresh];
    }
}

- (void)newPackageAddedResource:(NSNotification *)notification {
    [self onChangedPackage:self.pkg newPackage:self.pkg letTreeViewSelect:YES];
}

// MARK: - Resource Management

- (void)addResourceToMaps:(NamedPackedFileDescriptor *)namedDescriptor {
    [self addToTypeMap:namedDescriptor];
    [self addToGroupMap:namedDescriptor];
    [self addToInstMap:namedDescriptor];
}

- (void)addToTypeMap:(NamedPackedFileDescriptor *)namedDescriptor {
    uint32_t type = [[namedDescriptor descriptor] type];
    
    ResourceNameList *pfdList = [self.maps.byType objectForKey:@(type)];
    
    if (pfdList == nil) {
        pfdList = [[ResourceNameList alloc] init];
        [self.maps.byType setObject:pfdList forKey:@(type)];
    }
    
    [pfdList addObject:namedDescriptor];
}

- (void)addToGroupMap:(NamedPackedFileDescriptor *)namedDescriptor {
    uint32_t group = [[namedDescriptor descriptor] group];
    ResourceNameList *pfdList = [self.maps.byGroup objectForKey:@(group)];
    
    if (pfdList == nil) {
        pfdList = [[ResourceNameList alloc] init];
        [self.maps.byGroup setObject:pfdList forKey:@(group)];
    }
    
    [pfdList addObject:namedDescriptor];
}

- (void)addToInstMap:(NamedPackedFileDescriptor *)namedDescriptor {
    uint64_t longInstance = [[namedDescriptor descriptor] longInstance];
    ResourceNameList *pfdList = [self.maps.byInstance objectForKey:@(longInstance)];
    
    if (pfdList == nil) {
        pfdList = [[ResourceNameList alloc] init];
        [self.maps.byInstance setObject:pfdList forKey:@(longInstance)];
    }
    
    [pfdList addObject:namedDescriptor];
}

// MARK: - Static Methods

+ (NSInteger)getIndexForResourceType:(uint32_t)type {
    if ([[Registry windowsRegistry] decodeFilenamesState]) {
        // Get the wrapper registry from FileTableBase
        id<IWrapperRegistry> registry = [FileTableBase wrapperRegistry];
        if (registry != nil) {
            // This will work once TypeRegistry is translated with findHandler: method
            // For now, return a default value to avoid compilation errors
            
            // TODO: When TypeRegistry is translated, uncomment this:
            /*
            id<IPackedFileWrapper> wrapper = [registry findHandler:type];
            if (wrapper != nil) {
                id wrapperDescription = [wrapper wrapperDescription];
                if (wrapperDescription != nil) {
                    return [wrapperDescription iconIndex];
                }
            }
            */
        }
    }
    
    // Default icon index - return different values for common types for now
    switch (type) {
        case 0x42464B53: // TXTR
            return 1;
        case 0x4D4D4154: // MMAT
            return 2;
        case 0x54584D54: // TXMT
            return 3;
        default:
            return 0;
    }
}

// MARK: - Threading

- (void)cancelThreads {
    if (self.listView != nil) {
        [self.listView cancelThreads];
    }
}

// MARK: - Layout Management

- (void)storeLayout {
    if (self.listView != nil) {
        [self.listView storeLayout];
    }
}

- (void)restoreLayout {
    if (self.listView != nil) {
        [self.listView restoreLayout];
    }
    if (self.treeView != nil) {
        [self.treeView restoreLayout];
    }
}

// MARK: - Selection

- (BOOL)selectResource:(id<IScenegraphFileIndexItem>)resource {
    BOOL result = NO;
    
    if (self.listView != nil) {
        result = [self.listView selectResource:resource];
    }
    
    if (!result && self.treeView != nil && self.listView != nil) {
        [self.treeView selectAll];
        result = [self.listView selectResource:resource];
    }
    
    return result;
}

@end
