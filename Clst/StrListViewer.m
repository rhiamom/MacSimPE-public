//
//  StrListViewer.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
//
//***************************************************************************
//*   Copyright (C) 2005 by Peter L Jones                                   *
//*   pljones@users.sf.net                                                  *
//*                                                                         *
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************/

#import "StrListViewer.h"
#import "StrWrapper.h"
#import "StrItem.h"

@implementation StrListViewer

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithFrame:NSMakeRect(0, 0, 840, 144)];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupUI];
        [self setupContextMenus];
    }
    return self;
}

- (void)dealloc {
    // Clean up any resources being used
}

#pragma mark - UI Setup

- (void)setupUI {
    // Create split view
    self.splitView = [[NSSplitView alloc] initWithFrame:self.bounds];
    self.splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.splitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.splitView.vertical = YES;
    [self addSubview:self.splitView];
    
    // Create tree view (outline view) for languages
    NSScrollView *treeScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 216, 144)];
    treeScrollView.hasVerticalScroller = YES;
    treeScrollView.hasHorizontalScroller = YES;
    treeScrollView.autohidesScrollers = YES;
    
    self.treeView1 = [[NSOutlineView alloc] initWithFrame:treeScrollView.contentView.bounds];
    self.treeView1.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.treeView1.headerView = nil;
    self.treeView1.dataSource = self;
    self.treeView1.delegate = self;
    
    // Add single column for tree view
    NSTableColumn *treeColumn = [[NSTableColumn alloc] initWithIdentifier:@"Language"];
    treeColumn.width = 200;
    [self.treeView1 addTableColumn:treeColumn];
    self.treeView1.outlineTableColumn = treeColumn;
    
    treeScrollView.documentView = self.treeView1;
    [self.splitView addSubview:treeScrollView];
    
    // Create table view for string items
    NSScrollView *listScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(219, 0, 621, 144)];
    listScrollView.hasVerticalScroller = YES;
    listScrollView.hasHorizontalScroller = YES;
    listScrollView.autohidesScrollers = YES;
    
    self.listView1 = [[NSTableView alloc] initWithFrame:listScrollView.contentView.bounds];
    self.listView1.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.listView1.dataSource = self;
    self.listView1.delegate = self;
    self.listView1.allowsMultipleSelection = NO;
    self.listView1.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;
    
    // Create columns for table view
    self.colLine = [[NSTableColumn alloc] initWithIdentifier:@"Line"];
    self.colLine.headerCell.stringValue = @"Line";
    self.colLine.width = 36;
    [self.listView1 addTableColumn:self.colLine];
    
    self.colTitle = [[NSTableColumn alloc] initWithIdentifier:@"Title"];
    self.colTitle.headerCell.stringValue = @"Title";
    self.colTitle.width = 246;
    [self.listView1 addTableColumn:self.colTitle];
    
    self.colDesc = [[NSTableColumn alloc] initWithIdentifier:@"Description"];
    self.colDesc.headerCell.stringValue = @"Description";
    self.colDesc.width = 307;
    [self.listView1 addTableColumn:self.colDesc];
    
    listScrollView.documentView = self.listView1;
    [self.splitView addSubview:listScrollView];
    
    // Set split view proportions
    [self.splitView setPosition:216 ofDividerAtIndex:0];
}

- (void)setupContextMenus {
    // Language context menu
    self.cmLangList = [[NSMenu alloc] init];
    
    self.menuItem1 = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(menuCopyLanguage:) keyEquivalent:@"c"];
    self.menuItem1.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    [self.cmLangList addItem:self.menuItem1];
    
    self.menuItem2 = [[NSMenuItem alloc] initWithTitle:@"Paste" action:@selector(menuPasteLanguage:) keyEquivalent:@"v"];
    self.menuItem2.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    [self.cmLangList addItem:self.menuItem2];
    
    self.menuItem7 = [[NSMenuItem alloc] initWithTitle:@"Paste As..." action:@selector(menuPasteAsLanguage:) keyEquivalent:@""];
    [self.cmLangList addItem:self.menuItem7];
    
    self.menuItem3 = [[NSMenuItem alloc] initWithTitle:@"Set all to these" action:@selector(menuSetAllToThese:) keyEquivalent:@""];
    [self.cmLangList addItem:self.menuItem3];
    
    [self.cmLangList addItem:[NSMenuItem separatorItem]];
    
    self.menuItem8 = [[NSMenuItem alloc] initWithTitle:@"Add" action:@selector(menuAddLanguage:) keyEquivalent:@""];
    self.menuItem8.keyEquivalent = @"\r"; // Insert key equivalent
    [self.cmLangList addItem:self.menuItem8];
    
    self.menuItem9 = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuDeleteLanguage:) keyEquivalent:@""];
    self.menuItem9.keyEquivalent = @"\x7F"; // Delete key equivalent
    [self.cmLangList addItem:self.menuItem9];
    
    self.treeView1.menu = self.cmLangList;
    
    // String context menu
    self.cmStrList = [[NSMenu alloc] init];
    
    self.menuItem10 = [[NSMenuItem alloc] initWithTitle:@"Edit" action:@selector(menuEditString:) keyEquivalent:@""];
    [self.cmStrList addItem:self.menuItem10];
    
    [self.cmStrList addItem:[NSMenuItem separatorItem]];
    
    self.menuItem4 = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(menuCopyString:) keyEquivalent:@"c"];
    self.menuItem4.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    [self.cmStrList addItem:self.menuItem4];
    
    self.menuItem5 = [[NSMenuItem alloc] initWithTitle:@"Paste" action:@selector(menuPasteString:) keyEquivalent:@"v"];
    self.menuItem5.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    [self.cmStrList addItem:self.menuItem5];
    
    self.menuItem6 = [[NSMenuItem alloc] initWithTitle:@"Set in all languages" action:@selector(menuSetInAllLanguages:) keyEquivalent:@""];
    [self.cmStrList addItem:self.menuItem6];
    
    [self.cmStrList addItem:[NSMenuItem separatorItem]];
    
    self.menuItem11 = [[NSMenuItem alloc] initWithTitle:@"Add" action:@selector(menuAddString:) keyEquivalent:@""];
    self.menuItem11.keyEquivalent = @"\r"; // Insert key equivalent
    [self.cmStrList addItem:self.menuItem11];
    
    self.menuItem12 = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuDeleteString:) keyEquivalent:@""];
    self.menuItem12.keyEquivalent = @"\x7F"; // Delete key equivalent
    [self.cmStrList addItem:self.menuItem12];
    
    self.listView1.menu = self.cmStrList;
}

#pragma mark - Public Methods

- (void)updateGUI:(StrWrapper *)wrp {
    self.wrapper = wrp;
    self.languages = [wrp.languages copy];
    self.currentLang = nil;
    self.currentItems = nil;
    
    [self.treeView1 reloadData];
    [self.listView1 reloadData];
}
#pragma mark - NSOutlineView DataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return self.languages.count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil && index < self.languages.count) {
        return self.languages[index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

#pragma mark - NSOutlineView Delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"LanguageCell" owner:self];
    if (!cellView) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = @"LanguageCell";
        
        NSTextField *textField = [[NSTextField alloc] init];
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
        textField.editable = NO;
        [cellView addSubview:textField];
        cellView.textField = textField;
        
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:2],
            [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-2],
            [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
        ]];
    }
    
    if ([item isKindOfClass:[StrLanguage class]]) {
        StrLanguage *lang = (StrLanguage *)item;
        cellView.textField.stringValue = [lang description]; // Assuming StrLanguage has description method
    }
    
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.treeView1.selectedRow;
    if (selectedRow >= 0) {
        StrLanguage *selectedLanguage = [self.treeView1 itemAtRow:selectedRow];
        if ([selectedLanguage isKindOfClass:[StrLanguage class]]) {
            self.currentLang = selectedLanguage;
            self.currentItems = [self.wrapper languageItemsForStrLanguage:selectedLanguage]; // Fixed type and API for wrapper
            [self.listView1 reloadData];
        }
    }
}

#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.currentItems ? self.currentItems.length : 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (!self.currentItems || row >= self.currentItems.length) {
        return @"";
    }
    
    StrToken *token = self.currentItems[row];
    
    if ([tableColumn.identifier isEqualToString:@"Line"]) {
        return @(row);
    } else if ([tableColumn.identifier isEqualToString:@"Title"]) {
        return token.title ?: @"";
    } else if ([tableColumn.identifier isEqualToString:@"Description"]) {
        return token.strDescription ?: @""; // Use strDescription property from StrToken
    }
    
    return @"";
}

#pragma mark - Action Methods

- (IBAction)menuCopyLanguage:(id)sender {
    // TODO: Implement copy language functionality
}

- (IBAction)menuPasteLanguage:(id)sender {
    // TODO: Implement paste language functionality
}

- (IBAction)menuPasteAsLanguage:(id)sender {
    // TODO: Implement paste as language functionality
}

- (IBAction)menuSetAllToThese:(id)sender {
    // TODO: Implement set all to these functionality
}

- (IBAction)menuAddLanguage:(id)sender {
    // TODO: Implement add language functionality
}

- (IBAction)menuDeleteLanguage:(id)sender {
    // TODO: Implement delete language functionality
}

- (IBAction)menuEditString:(id)sender {
    // TODO: Implement edit string functionality
}

- (IBAction)menuCopyString:(id)sender {
    // TODO: Implement copy string functionality
}

- (IBAction)menuPasteString:(id)sender {
    // TODO: Implement paste string functionality
}

- (IBAction)menuSetInAllLanguages:(id)sender {
    // TODO: Implement set in all languages functionality
}

- (IBAction)menuAddString:(id)sender {
    // TODO: Implement add string functionality
}

- (IBAction)menuDeleteString:(id)sender {
    // TODO: Implement delete string functionality
}

@end
