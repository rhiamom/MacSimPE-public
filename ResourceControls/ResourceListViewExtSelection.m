//
//  ResourceListViewExtSelection.m
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

#import "ResourceListViewExtSelection.h"
#import "ResourceListViewExt.h"
#import "NamedPackedFileDescriptor.h"
#import "FileIndexItem.h"
#import "IScenegraphFileIndexItem.h"
#import "IPackedFileDescriptor.h"

// MARK: - Constants

const NSTimeInterval WAIT_SELECT_INTERVAL = 0.4;

// MARK: - SelectResourceEventArgs Implementation

@implementation SelectResourceEventArgs

- (instancetype)initWithCtrlDown:(BOOL)ctrlDown {
    self = [super init];
    if (self) {
        _ctrlDown = ctrlDown;
    }
    return self;
}

@end

// MARK: - ResourceListViewExtSelection Implementation

@implementation ResourceListViewExtSelection

// MARK: - Initialization

- (instancetype)initWithListView:(ResourceListViewExt *)listView {
    self = [super init];
    if (self) {
        _listView = listView;
        _ctrlDown = NO;
    }
    return self;
}

// MARK: - Selection Change Handling

- (void)signalSelectionChanged {
    if (self.listView.noSelectEvent > 0) {
        [self doSignalSelectionChanged];
    } else {
        [self.listView.selectionTimer invalidate];
        self.listView.selectionTimer = [NSTimer scheduledTimerWithTimeInterval:WAIT_SELECT_INTERVAL
                                                                        target:self
                                                                      selector:@selector(selectionTimerCallback:)
                                                                      userInfo:nil
                                                                       repeats:NO];
    }
}

- (void)doSignalSelectionChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self onResourceSelectionChanged];
    });
}

- (void)selectionTimerCallback:(NSTimer *)timer {
    [self doSignalSelectionChanged];
}

// MARK: - Event Handling (for integration into main delegate methods)

- (void)handleSelectionChanged {
    [self signalSelectionChanged];
}

- (void)handleTableViewClick {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimpleResourceSelect"]) {
        [self onSelectResource];
    }
}

- (void)handleTableViewDoubleClick {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SimpleResourceSelect"]) {
        [self onSelectResource];
    }
}

- (void)handleMouseUpWithEvent:(NSEvent *)event {
    if ([event type] == NSEventTypeOtherMouseUp && [event buttonNumber] == 2) { // Middle mouse button
        BOOL oldCtrl = self.ctrlDown;
        self.ctrlDown = YES;
        
        NSPoint point = [self.listView.tableView convertPoint:[event locationInWindow] fromView:nil];
        NSInteger row = [self.listView.tableView rowAtPoint:point];
        
        if (row >= 0 && row < [self.listView.names count]) {
            [self.listView beginUpdate];
            [self.listView.tableView scrollRowToVisible:row];
            [self.listView.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                 byExtendingSelection:NO];
            [self onSelectResource];
            [self.listView endUpdate];
        }
        
        self.ctrlDown = oldCtrl;
    }
}

- (void)handleKeyDownWithEvent:(NSEvent *)event {
    self.ctrlDown = ([event modifierFlags] & NSEventModifierFlagOption) != 0;
}

- (void)handleKeyUpWithEvent:(NSEvent *)event {
    self.ctrlDown = ([event modifierFlags] & NSEventModifierFlagOption) != 0;
    
    NSUInteger keyCode = [event keyCode];
    
    // Arrow keys, page up/down, home/end
    if (!self.ctrlDown && (keyCode == 126 || // Up arrow
                          keyCode == 125 || // Down arrow
                          keyCode == 116 || // Page up
                          keyCode == 121 || // Page down
                          keyCode == 115 || // Home
                          keyCode == 119)) { // End
        [self onSelectResource];
    }
    
    // Enter key
    if (keyCode == 36) { // Return/Enter
        [self onSelectResource];
    }
    
    // Cmd+A for select all
    if (keyCode == 0 && ([event modifierFlags] & NSEventModifierFlagCommand)) { // 'A' key
        [self selectAllResources];
    }
}

// MARK: - Event Handlers

- (void)onResourceSelectionChanged {
    if (self.listView.selectionChangedBlock) {
        self.listView.selectionChangedBlock();
    }
}

- (void)onSelectResource {
    BOOL rctrl = self.ctrlDown;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirefoxTabbing"]) {
        rctrl = NO;
    }
    
    SelectResourceEventArgs *args = [[SelectResourceEventArgs alloc] initWithCtrlDown:rctrl];
    
    // Call the new args-based block if set
    if (self.selectedResourceWithArgsBlock && self.listView.noSelectEvent == 0) {
        self.selectedResourceWithArgsBlock(args);
    }
    
    // Also call the existing resource block for compatibility
    if (self.listView.selectedResourceBlock && self.listView.noSelectEvent == 0) {
        NSIndexSet *selectedRows = [self.listView.tableView selectedRowIndexes];
        if ([selectedRows count] > 0) {
            NSUInteger firstIndex = [selectedRows firstIndex];
            if (firstIndex < [self.listView.names count]) {
                NamedPackedFileDescriptor *selectedResource = [self.listView.names objectAtIndex:firstIndex];
                self.listView.selectedResourceBlock(selectedResource);
            }
        }
    }
}

// MARK: - Public Methods

- (void)selectAllResources {
    @synchronized (self.listView.names) {
        [self.listView beginUpdate];
        [self.listView.tableView deselectAll:nil];
        NSMutableIndexSet *allIndexes = [[NSMutableIndexSet alloc] init];
        for (NSUInteger i = 0; i < [self.listView.names count]; i++) {
            [allIndexes addIndex:i];
        }
        [self.listView.tableView selectRowIndexes:allIndexes byExtendingSelection:NO];
        [self.listView endUpdate];
    }
}

- (FileIndexItem *)selectedItem {
    @synchronized (self.listView.names) {
        NSIndexSet *selectedRows = [self.listView.tableView selectedRowIndexes];
        if ([selectedRows count] == 0) return nil;
        
        NSUInteger firstIndex = [selectedRows firstIndex];
        if (firstIndex < [self.listView.names count]) {
            NamedPackedFileDescriptor *namedResource = [self.listView.names objectAtIndex:firstIndex];
            return [namedResource resource];
        }
        
        return nil;
    }
}

@end
