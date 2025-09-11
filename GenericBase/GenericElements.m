//
//  GenericElements.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/2/25.
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

#import "GenericElements.h"
#import "IFileWrapperSaveExtension.h"
#import "GenericFileItem.h"

@interface GenericElements () <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *listData;
@property (nonatomic, strong) NSMutableArray<GenericItem *> *treeData;

@end

@implementation GenericElements

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _listData = [[NSMutableArray alloc] init];
        _treeData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupTableView];
    [self setupOutlineView];
}

- (void)dealloc {
    // Clean up any resources
    self.wrapper = nil;
}

// MARK: - UI Setup

- (void)setupUI {
    // Configure list banner
    self.listBanner.stringValue = @"Items";
    self.listBanner.font = [NSFont boldSystemFontOfSize:12];
    
    // Configure tree banner
    self.treeBanner.stringValue = @"Tree";
    self.treeBanner.font = [NSFont boldSystemFontOfSize:12];
    
    // Configure commit button
    self.lllvcommit.title = @"commit";
    self.lllvcommit.target = self;
    self.lllvcommit.action = @selector(commitListViewClick:);
    
    // Setup panel backgrounds
    self.itemPanel.wantsLayer = YES;
    self.itemPanel.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    
    self.treeItemPanel.wantsLayer = YES;
    self.treeItemPanel.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
}

- (void)setupTableView {
    if (!self.listList) return;
    
    self.listList.dataSource = self;
    self.listList.delegate = self;
    
    // Configure table view appearance
    self.listList.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;
    self.listList.allowsMultipleSelection = NO;
    self.listList.allowsEmptySelection = YES;
    self.listList.usesAlternatingRowBackgroundColors = YES;
    
    // Font similar to original Courier New
    self.listList.font = [NSFont fontWithName:@"Menlo" size:11] ?: [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
}

- (void)setupOutlineView {
    if (!self.mytree) return;
    
    self.mytree.dataSource = self;
    self.mytree.delegate = self;
    
    // Configure outline view
    self.mytree.indentationPerLevel = 19.0;
    self.mytree.allowsMultipleSelection = NO;
    self.mytree.allowsEmptySelection = YES;
}

// MARK: - Data Management

- (void)refresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listList reloadData];
        [self.mytree reloadData];
    });
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.listData.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= self.listData.count) return nil;
    
    NSMutableDictionary *rowData = self.listData[row];
    return rowData[tableColumn.identifier] ?: @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= self.listData.count) return;
    
    NSMutableDictionary *rowData = self.listData[row];
    if (object) {
        rowData[tableColumn.identifier] = object;
    } else {
        [rowData removeObjectForKey:tableColumn.identifier];
    }
}

// MARK: - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    @try {
        NSTableView *tableView = notification.object;
        NSInteger selectedRow = tableView.selectedRow;
        
        if (selectedRow == -1 || selectedRow >= self.listData.count) {
            [self clearItemPanel];
            return;
        }
        
        NSDictionary *rowData = self.listData[selectedRow];
        [self updateItemPanelWithData:rowData];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception in tableViewSelectionDidChange: %@", exception.reason);
        self.view.window.title = exception.reason;
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return YES;
}

// MARK: - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!item) {
        return self.treeData.count;
    }
    
    if ([item isKindOfClass:[GenericItem class]]) {
        GenericItem *genericItem = (GenericItem *)item;
        return genericItem.children.count;
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (!item) {
        if (index < self.treeData.count) {
            return self.treeData[index];
        }
        return nil;
    }
    
    if ([item isKindOfClass:[GenericItem class]]) {
        GenericItem *genericItem = (GenericItem *)item;
        if (index < genericItem.children.count) {
            return genericItem.children[index];
        }
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[GenericItem class]]) {
        GenericItem *genericItem = (GenericItem *)item;
        return genericItem.children.count > 0;
    }
    return NO;
}

- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    if ([item isKindOfClass:[GenericItem class]]) {
        GenericItem *genericItem = (GenericItem *)item;
        
        if ([tableColumn.identifier isEqualToString:@"name"]) {
            return genericItem.names ?: @"";
        }
        
        // Return property value if available
        NSString *columnId = tableColumn.identifier;
        if (genericItem.properties[columnId]) {
            return [genericItem.properties[columnId] description];
        }
    }
    
    return @"";
}

// MARK: - NSOutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    @try {
        NSOutlineView *outlineView = notification.object;
        id selectedItem = [outlineView itemAtRow:outlineView.selectedRow];
        
        if (!selectedItem || ![selectedItem isKindOfClass:[GenericItem class]]) {
            [self clearTreeItemPanel];
            return;
        }
        
        GenericItem *genericItem = (GenericItem *)selectedItem;
        [self updateTreeItemPanelWithItem:genericItem];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception in outlineViewSelectionDidChange: %@", exception.reason);
        self.view.window.title = exception.reason;
    }
}

// MARK: - Item Panel Management

- (void)updateItemPanelWithData:(NSDictionary *)data {
    // Clear existing controls
    [self clearItemPanel];
    
    // Create text fields for each data column
    NSInteger index = 0;
    for (NSString *key in data.allKeys) {
        NSTextField *textField = [[NSTextField alloc] init];
        textField.stringValue = [data[key] description] ?: @"";
        textField.tag = index;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSTextField *label = [[NSTextField alloc] init];
        label.stringValue = [NSString stringWithFormat:@"%@:", key];
        label.editable = NO;
        label.bordered = NO;
        label.backgroundColor = [NSColor clearColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.itemPanel addSubview:label];
        [self.itemPanel addSubview:textField];
        
        // Layout constraints
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:self.itemPanel.leadingAnchor constant:8],
            [label.topAnchor constraintEqualToAnchor:self.itemPanel.topAnchor constant:8 + (index * 30)],
            [label.widthAnchor constraintEqualToConstant:80],
            
            [textField.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:8],
            [textField.trailingAnchor constraintEqualToAnchor:self.itemPanel.trailingAnchor constant:-8],
            [textField.centerYAnchor constraintEqualToAnchor:label.centerYAnchor]
        ]];
        
        index++;
    }
}

- (void)clearItemPanel {
    for (NSView *subview in [self.itemPanel.subviews copy]) {
        [subview removeFromSuperview];
    }
}

- (void)updateTreeItemPanelWithItem:(GenericItem *)item {
    // Clear existing controls
    [self clearTreeItemPanel];
    
    if (!item.names || !item.properties) return;
    
    // Create text fields for each property
    for (NSInteger i = 0; i < item.names.count; i++) {
        NSString *name = item.names[i];
        
        NSTextField *textField = [[NSTextField alloc] init];
        id value = item.properties[name];
        textField.stringValue = value ? [value description] : @"";
        textField.tag = i;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSTextField *label = [[NSTextField alloc] init];
        label.stringValue = [NSString stringWithFormat:@"%@:", name];
        label.editable = NO;
        label.bordered = NO;
        label.backgroundColor = [NSColor clearColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.treeItemPanel addSubview:label];
        [self.treeItemPanel addSubview:textField];
        
        // Layout constraints
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:self.treeItemPanel.leadingAnchor constant:8],
            [label.topAnchor constraintEqualToAnchor:self.treeItemPanel.topAnchor constant:8 + (i * 30)],
            [label.widthAnchor constraintEqualToConstant:80],
            
            [textField.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:8],
            [textField.trailingAnchor constraintEqualToAnchor:self.treeItemPanel.trailingAnchor constant:-8],
            [textField.centerYAnchor constraintEqualToAnchor:label.centerYAnchor]
        ]];
    }
}

- (void)clearTreeItemPanel {
    for (NSView *subview in [self.treeItemPanel.subviews copy]) {
        [subview removeFromSuperview];
    }
}

// MARK: - IBActions

- (IBAction)commitListViewClick:(id)sender {
    if (self.listList.selectedRow == -1) return;
    if (!self.wrapper) return;
    
    @try {
        NSInteger selectedRow = self.listList.selectedRow;
        if (selectedRow >= self.listData.count) return;
        
        NSMutableDictionary *rowData = self.listData[selectedRow];
        
        // Update row data from item panel controls
        for (NSView *control in self.itemPanel.subviews) {
            if ([control isKindOfClass:[NSTextField class]] && control.tag >= 0) {
                NSTextField *textField = (NSTextField *)control;
                NSInteger columnIndex = textField.tag;
                
                // Find corresponding column
                if (columnIndex < self.listList.tableColumns.count) {
                    NSTableColumn *column = self.listList.tableColumns[columnIndex];
                    rowData[column.identifier] = textField.stringValue;
                    
                    // Update table view
                    [self.listList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow]
                                             columnIndexes:[NSIndexSet indexSetWithIndex:columnIndex]];
                }
                
                // Update associated GenericItem if present
                // This would need to be implemented based on the specific data structure
                // used by each wrapper type
            }
        }
        
        // Save changes through wrapper
        [self.wrapper synchronizeUserData];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception in commitListViewClick: %@", exception.reason);
        self.view.window.title = exception.reason;
    }
}

@end
