//
//  ResourceTreeViewExt.m
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

#import "ResourceTreeViewExt.h"
#import "ResourceViewManager.h"
#import "ResourceTreeNodesByType.h"
#import "ResourceTreeNodesByGroup.h"
#import "ResourceTreeNodesByInstance.h"
#import "ResourceTreeNodeExt.h"
#import "IResourceTreeNodeBuilder.h"
#import "FileTable.h"
#import "Helper.h"
#import "Registry.h"
#import "ResourceListViewExt.h"

@implementation ResourceTreeViewExt

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allowSelectEvent = YES;
        
        // Initialize node builders
        self.typeBuilder = [[ResourceTreeNodesByType alloc] init];
        self.groupBuilder = [[ResourceTreeNodesByGroup alloc] init];
        self.instBuilder = [[ResourceTreeNodesByInstance alloc] init];
        
        // Set default builder
        self.builder = self.typeBuilder;
        self.last = nil;
        
        [self setupUI];
        [self setupToolbar];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)setupUI {
    // Create and configure outline view
    self.treeView = [[NSOutlineView alloc] init];
    [self.treeView setDelegate:self];
    [self.treeView setDataSource:self];
    [self.treeView setHeaderView:nil];
    [self.treeView setUsesAlternatingRowBackgroundColors:YES];
    
    // Create scroll view
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    [scrollView setDocumentView:self.treeView];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutohidesScrollers:YES];
    
    [self addSubview:scrollView];
    
    // Setup constraints
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
}

- (void)setupToolbar {
    // Create toolbar
    self.toolbar = [[NSToolbar alloc] initWithIdentifier:@"ResourceTreeToolbar"];
    
    // Create toolbar items
    self.tbType = [[NSToolbarItem alloc] initWithItemIdentifier:@"Type"];
    [self.tbType setLabel:@"Type"];
    [self.tbType setTarget:self];
    [self.tbType setAction:@selector(selectTreeBuilder:)];
    
    self.tbGroup = [[NSToolbarItem alloc] initWithItemIdentifier:@"Group"];
    [self.tbGroup setLabel:@"Group"];
    [self.tbGroup setTarget:self];
    [self.tbGroup setAction:@selector(selectTreeBuilder:)];
    
    self.tbInst = [[NSToolbarItem alloc] initWithItemIdentifier:@"Instance"];
    [self.tbInst setLabel:@"Instance"];
    [self.tbInst setTarget:self];
    [self.tbInst setAction:@selector(selectTreeBuilder:)];
    
    // Set default selection
    // tbType.Checked = true equivalent would be handled in UI state
    
}

// MARK: - ResourceViewManager Integration

- (void)setManager:(ResourceViewManager *)manager {
    self.last = nil;
    if (self.manager != manager) {
        self.manager = manager;
    }
}

- (BOOL)setResourceMaps:(ResourceMaps *)maps
      letTreeViewSelect:(BOOL)selectEvent
            doNotSelect:(BOOL)dontSelect {
    return [self setResourceMaps:maps
                letTreeViewSelect:selectEvent
                      doNotSelect:dontSelect
                           noSave:NO];
}

- (BOOL)setResourceMaps:(ResourceMaps *)maps
      letTreeViewSelect:(BOOL)selectEvent
            doNotSelect:(BOOL)dontSelect
                 noSave:(BOOL)noSave {
    
    self.last = maps;
    
    // Set up image list if available
    if ([FileTable.wrapperRegistry] != nil) {
        // TODO: Set up image list equivalent
        // tv.ImageList = FileTable.WrapperRegistry.WrapperImageList;
    }
    
    if (!noSave) {
        [self saveLastSelection];
    }
    
    [self clear];
    self.firstNode = [self.builder buildNodes:maps];
    
    // Add root node and expand it
    [self.treeView reloadData];
    [self.treeView expandItem:self.firstNode];
    
    self.allowSelectEvent = selectEvent;
    
    if (!dontSelect &&
        ([[maps everything] count] <= [[Registry windowsRegistry] bigPackageResourceCount] ||
         [[Registry windowsRegistry] resourceTreeAlwaysAutoselect])) {
        
        if (![self selectID:self.firstNode withID:[self.builder lastSelectedId]]) {
            [self selectAll];
            self.allowSelectEvent = YES;
            return NO;
        }
    }
    
    self.allowSelectEvent = YES;
    return YES;
}

// MARK: - Tree Management

- (void)clear {
    // Clear the outline view
    [self.treeView reloadData];
}

- (void)setResourceMapsNoSave:(BOOL)noSave {
    if (self.last != nil) {
        [self setResourceMaps:self.last letTreeViewSelect:YES doNotSelect:noSave];
    }
}

// MARK: - Selection Management

- (void)selectAll {
    if (self.firstNode != nil) {
        NSInteger row = [self.treeView rowForItem:self.firstNode];
        if (row >= 0) {
            [self.treeView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                       byExtendingSelection:NO];
        }
    }
}

- (void)restoreLayout {
    [self selectTreeBuilder:self.tbType];
}

- (BOOL)selectID:(id)node withID:(uint64_t)nodeID {
    if ([node isKindOfClass:[ResourceTreeNodeExt class]]) {
        ResourceTreeNodeExt *rn = (ResourceTreeNodeExt *)node;
        if ([rn nodeID] == nodeID) {
            NSInteger row = [self.treeView rowForItem:rn];
            if (row >= 0) {
                [self.treeView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                           byExtendingSelection:NO];
                [self.treeView scrollRowToVisible:row];
                return YES;
            }
        }
    }
    
    // Check child nodes
    NSInteger childCount = [self.treeView numberOfChildrenOfItem:node];
    for (NSInteger i = 0; i < childCount; i++) {
        id child = [self.treeView child:i ofItem:node];
        if ([self selectID:child withID:nodeID]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)saveLastSelection {
    id selectedItem = [self.treeView itemAtRow:[self.treeView selectedRow]];
    if ([selectedItem isKindOfClass:[ResourceTreeNodeExt class]]) {
        ResourceTreeNodeExt *node = (ResourceTreeNodeExt *)selectedItem;
        [self.builder setLastSelectedId:[node nodeID]];
    } else {
        [self.builder setLastSelectedId:0];
    }
}

// MARK: - Toolbar Actions

- (IBAction)selectTreeBuilder:(id)sender {
    // Toolbar items handle their own visual state
    [self saveLastSelection];
    
    id<IResourceTreeNodeBuilder> old = self.builder;
    if (sender == self.tbInst) {
        self.builder = self.instBuilder;
    } else if (sender == self.tbGroup) {
        self.builder = self.groupBuilder;
    } else {
        self.builder = self.typeBuilder;
    }
    
    if (old != self.builder) {
        [self setResourceMapsNoSave:YES];
    }
}

// MARK: - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        // Root level
        return (self.firstNode != nil) ? 1 : 0;
    }
    
    if ([item respondsToSelector:@selector(numberOfChildren)]) {
        return [item numberOfChildren];
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        // Root level
        return (index == 0) ? self.firstNode : nil;
    }
    
    if ([item respondsToSelector:@selector(childAtIndex:)]) {
        return [item childAtIndex:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item respondsToSelector:@selector(numberOfChildren)]) {
        return [item numberOfChildren] > 0;
    }
    return NO;
}

// MARK: - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] init];
        [cellView setIdentifier:@"DataCell"];
        
        NSTextField *textField = [[NSTextField alloc] init];
        [textField setBezeled:NO];
        [textField setDrawsBackground:NO];
        [textField setEditable:NO];
        [textField setSelectable:NO];
        [cellView addSubview:textField];
        [cellView setTextField:textField];
    }
    
    if ([item respondsToSelector:@selector(displayName)]) {
        [[cellView textField] setStringValue:[item displayName]];
    }
    
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if (!self.allowSelectEvent) return;
    
    id selectedItem = [self.treeView itemAtRow:[self.treeView selectedRow]];
    if (selectedItem == nil) return;
    
    if ([selectedItem isKindOfClass:[ResourceTreeNodeExt class]]) {
        ResourceTreeNodeExt *node = (ResourceTreeNodeExt *)selectedItem;
        
        if (self.manager != nil && [self.manager listView] != nil) {
            [[self.manager listView] setResources:[node resources]];
        }
    }
}
// MARK: - Drag & Drop Support

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
    if ([items count] == 0) return NO;
    
    id item = [items firstObject];
    
    // Handle different item types
    NSString *description = nil;
    if ([item isKindOfClass:[NamedPackedFileDescriptor class]]) {
        NamedPackedFileDescriptor *namedResource = (NamedPackedFileDescriptor *)item;
        description = [namedResource getRealName];
        if (description == nil || [description length] == 0) {
            description = [NSString stringWithFormat:@"Resource %08X", [[namedResource descriptor] type]];
        }
    } else if ([item isKindOfClass:[ResourceGroup class]]) {
        ResourceGroup *group = (ResourceGroup *)item;
        description = [NSString stringWithFormat:@"Resource Group %08X (%ld items)",
                      [group type], (long)[group count]];
    } else {
        description = [item description];
    }
    
    [pboard declareTypes:@[NSPasteboardTypeString] owner:self];
    [pboard setString:description forType:NSPasteboardTypeString];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy | NSDragOperationLink;
}

@end
