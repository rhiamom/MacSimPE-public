//
//  ResourceTreeViewExt.h
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

#import <Cocoa/Cocoa.h>
#import "ResourceMaps.h"

@class ResourceViewManager;
@class ResourceTreeNodesByType;
@class ResourceTreeNodesByGroup;
@class ResourceTreeNodesByInstance;
@class ResourceTreeNodeExt;
@protocol IResourceTreeNodeBuilder;

/**
 * Extended tree view for displaying resource hierarchies
 * This is the left panel in Object Workshop mode showing resource types
 */
@interface ResourceTreeViewExt : NSView <NSOutlineViewDataSource, NSOutlineViewDelegate>

// MARK: - Properties
@property (nonatomic, weak) ResourceViewManager *manager;
@property (nonatomic, strong) ResourceMaps *last;
@property (nonatomic, assign) BOOL allowSelectEvent;
@property (nonatomic, strong) id firstNode;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSOutlineView *treeView;
@property (nonatomic, strong) IBOutlet NSToolbar *toolbar;
@property (nonatomic, strong) IBOutlet NSToolbarItem *tbType;
@property (nonatomic, strong) IBOutlet NSToolbarItem *tbGroup;
@property (nonatomic, strong) IBOutlet NSToolbarItem *tbInst;
@property (nonatomic, strong) IBOutlet NSOutlineView *outlineView;

// MARK: - Node Builders
@property (nonatomic, strong) ResourceTreeNodesByType *typeBuilder;
@property (nonatomic, strong) ResourceTreeNodesByGroup *groupBuilder;
@property (nonatomic, strong) ResourceTreeNodesByInstance *instBuilder;
@property (nonatomic, strong) id<IResourceTreeNodeBuilder> builder;

// MARK: - Initialization
- (instancetype)init;

// MARK: - ResourceViewManager Integration
- (void)setManager:(ResourceViewManager *)manager;
- (BOOL)setResourceMaps:(ResourceMaps *)maps
      letTreeViewSelect:(BOOL)selectEvent
            doNotSelect:(BOOL)dontSelect;

// MARK: - Tree Management
- (void)clear;
- (void)setResourceMapsNoSave:(BOOL)noSave;

// MARK: - Selection Management
- (void)selectAll;
- (void)restoreLayout;
- (BOOL)selectID:(id)node withID:(uint64_t)nodeID;
- (void)saveLastSelection;

// MARK: - Toolbar Actions
- (IBAction)selectTreeBuilder:(id)sender;

// MARK: - Drag & Drop Support
- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                draggingSession:(NSDraggingSession *)session
sourceOperationMaskForDraggingContext:(NSDraggingContext)context;

@end
