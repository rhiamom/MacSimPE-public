//
//  ResourceViewManager.h
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

#import <Foundation/Foundation.h>
#import "ResourceMaps.h"
#import "ResourceListViewExt.h"
#import "ResourceTreeViewExt.h"

@protocol IPackageFile;
@protocol IScenegraphFileIndexItem;

@interface ResourceViewManager : NSObject

// MARK: - Properties

@property (nonatomic, strong, readonly) ResourceMaps *maps;
@property (nonatomic, weak) ResourceListViewExt *listView;
@property (nonatomic, weak) ResourceTreeViewExt *treeView;
@property (nonatomic, readonly) BOOL available;
@property (nonatomic, readonly) ResourceNameList *everything;
@property (nonatomic, strong) id<IPackageFile> package;

// MARK: - Initialization

- (instancetype)init;

// MARK: - Package Management

- (void)onChangedPackage:(id<IPackageFile>)oldPackage
              newPackage:(id<IPackageFile>)newPackage
       letTreeViewSelect:(BOOL)letTreeViewSelect;

- (void)updateTree;
- (void)fakeSave;

// MARK: - Resource Management

- (void)updateContentWithLetTreeViewSelect:(BOOL)letTreeViewSelect;
- (void)addResourceToMaps:(NamedPackedFileDescriptor *)namedDescriptor;
- (void)addToTypeMap:(NamedPackedFileDescriptor *)namedDescriptor;
- (void)addToGroupMap:(NamedPackedFileDescriptor *)namedDescriptor;
- (void)addToInstMap:(NamedPackedFileDescriptor *)namedDescriptor;

// MARK: - Static Methods

+ (NSInteger)getIndexForResourceType:(uint32_t)type;

// MARK: - Threading

- (void)cancelThreads;

// MARK: - Layout Management

- (void)storeLayout;
- (void)restoreLayout;

// MARK: - Drag & Drop Support (PackageSelectorForm functionality)
- (void)enableDragDropForPackage:(id<IPackageFile>)package;
- (void)configureDragDropForListView;
- (void)configureDragDropForTreeView;

// MARK: - Selection

- (BOOL)selectResource:(id<IScenegraphFileIndexItem>)resource;

@end
