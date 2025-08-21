//
//  ClstForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/17/25.
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

#import "ClstForm.h"
#import "CompressedFileList.h"
#import "ClstItem.h"

@interface ClstForm () <NSTableViewDataSource, NSTableViewDelegate>
@end

@implementation ClstForm

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupDataSource];
}

- (void)setupUI {
    // Configure table view
    if (self.lbclst) {
        [self.lbclst setDataSource:self];
        [self.lbclst setDelegate:self];
        
        // Create single column for the list
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"ClstItemColumn"];
        [column setTitle:@"Items"];
        [column setMinWidth:200];
        [self.lbclst addTableColumn:column];
    }
    
    // Set initial label values
    if (self.label9) {
        [self.label9 setStringValue:@"Format:"];
        [self.label9 setFont:[NSFont boldSystemFontOfSize:13]];
    }
    
    if (self.label12) {
        [self.label12 setStringValue:@"Compressed File Directory"];
        [self.label12 setFont:[NSFont boldSystemFontOfSize:15]];
    }
    
    if (self.lbformat) {
        [self.lbformat setStringValue:@"---"];
    }
    
    // Configure panel backgrounds
    if (self.panel4) {
        [self.panel4 setWantsLayer:YES];
        [self.panel4.layer setBackgroundColor:[[NSColor controlBackgroundColor] CGColor]];
    }
}

- (void)setupDataSource {
    self.clstDataSource = [[NSMutableArray alloc] init];
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.clstPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrp {
    self.wrapper = (CompressedFileList *)wrp;
    
    if (self.wrapper) {
        // Update format label
        [self.lbformat setStringValue:[NSString stringWithFormat:@"%ld", (long)[self.wrapper indexType]]];
        
        // Clear and rebuild data source
        [self.clstDataSource removeAllObjects];
        
        NSArray *items = [self.wrapper items];
        for (id item in items) {
            if (item != nil && [item isKindOfClass:[ClstItem class]]) {
                [self.clstDataSource addObject:item];
            } else {
                // Add error placeholder for nil items
                [self.clstDataSource addObject:@"Error"];
            }
        }
        
        // Reload table
        [self.lbclst reloadData];
    }
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.clstDataSource count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < 0 || row >= [self.clstDataSource count]) {
        return @"";
    }
    
    id item = [self.clstDataSource objectAtIndex:row];
    
    if ([item isKindOfClass:[ClstItem class]]) {
        // Return the string representation of the ClstItem
        return [item description];
    } else if ([item isKindOfClass:[NSString class]]) {
        // Return error strings directly
        return item;
    }
    
    return @"Unknown Item";
}

// MARK: - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    // Handle selection changes if needed
    NSInteger selectedRow = [self.lbclst selectedRow];
    if (selectedRow >= 0 && selectedRow < [self.clstDataSource count]) {
        id selectedItem = [self.clstDataSource objectAtIndex:selectedRow];
        NSLog(@"Selected CLST item: %@", selectedItem);
    }
}

// MARK: - Memory Management

- (void)dealloc {
    // Cleanup if needed
}

@end
