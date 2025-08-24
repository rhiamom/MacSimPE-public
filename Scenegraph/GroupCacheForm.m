//
//  GroupCacheForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "GroupCacheForm.h"

@implementation GroupCacheForm

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _groupItems = [[NSMutableArray alloc] init];
        _arrayController = [[NSArrayController alloc] init];
    }
    return self;
}

- (void)loadView {
    // Create the main view
    NSView *mainView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 292, 266)];
    
    // Create group panel (equivalent to GropPanel)
    self.groupPanel = [[NSView alloc] initWithFrame:NSMakeRect(14, 29, 264, 208)];
    
    // Create header panel (equivalent to panel4)
    self.headerPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 184, 264, 24)];
    self.headerPanel.wantsLayer = YES;
    self.headerPanel.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    
    // Create title label (equivalent to label12)
    self.titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 2, 248, 20)];
    self.titleLabel.stringValue = @"Group Cache Viewer";
    self.titleLabel.font = [NSFont boldSystemFontOfSize:13];
    self.titleLabel.textColor = [NSColor controlTextColor];
    self.titleLabel.backgroundColor = [NSColor clearColor];
    self.titleLabel.bordered = NO;
    self.titleLabel.editable = NO;
    
    // Create scroll view for the table
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(8, 8, 248, 168)];
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    scrollView.autohidesScrollers = NO;
    
    // Create table view (equivalent to lbgroup ListBox)
    self.groupListView = [[NSTableView alloc] init];
    
    // Create table column
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"groupItem"];
    column.title = @"Group Items";
    column.width = 200;
    [self.groupListView addTableColumn:column];
    
    // Configure table view
    self.groupListView.headerView = nil; // Hide header for list-like appearance
    self.groupListView.intercellSpacing = NSMakeSize(0, 1);
    self.groupListView.rowHeight = 18;
    
    // Set up array controller
    [self.arrayController bind:NSContentArrayBinding
                      toObject:self
                   withKeyPath:@"groupItems"
                       options:nil];
    
    // Bind table view to array controller
    [column bind:NSValueBinding
        toObject:self.arrayController
     withKeyPath:@"arrangedObjects.description"
         options:nil];
    
    [self.groupListView bind:NSContentBinding
                    toObject:self.arrayController
                 withKeyPath:@"arrangedObjects"
                     options:nil];
    
    [self.groupListView bind:NSSelectionIndexesBinding
                    toObject:self.arrayController
                 withKeyPath:@"selectionIndexes"
                     options:nil];
    
    scrollView.documentView = self.groupListView;
    
    // Add subviews
    [self.headerPanel addSubview:self.titleLabel];
    [self.groupPanel addSubview:scrollView];
    [self.groupPanel addSubview:self.headerPanel];
    [mainView addSubview:self.groupPanel];
    
    self.view = mainView;
    
    [self setupUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Additional setup after view loading
}

// MARK: - UI Setup

- (void)setupUI {
    // Configure the main view appearance
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor windowBackgroundColor].CGColor;
    
    // Set fonts to match Windows Forms appearance
    self.groupPanel.wantsLayer = YES;
    
    // Configure auto-resizing for responsive layout
    self.groupPanel.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.headerPanel.autoresizingMask = NSViewWidthSizable;
    self.titleLabel.autoresizingMask = NSViewWidthSizable;
    
    // Configure scroll view auto-resizing
    NSScrollView *scrollView = (NSScrollView *)self.groupPanel.subviews.firstObject;
    if ([scrollView isKindOfClass:[NSScrollView class]]) {
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
}

// MARK: - Data Management

- (void)loadData:(NSArray *)items {
    [self.groupItems removeAllObjects];
    if (items) {
        [self.groupItems addObjectsFromArray:items];
    }
    
    // Refresh the array controller
    [self.arrayController rearrangeObjects];
}

// MARK: - Accessor Methods

- (NSMutableArray *)groupItems {
    if (!_groupItems) {
        _groupItems = [[NSMutableArray alloc] init];
    }
    return _groupItems;
}

@end

