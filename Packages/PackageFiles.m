//
//  PackageFiles.m
//  MacSimpe
//
//  Translated from C# by Catherine Gramze on 8/7/25.
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

#import "PackageFiles.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "PackedFileDescriptors.h"

@interface PackageSelectorForm () <NSTableViewDataSource, NSTableViewDelegate, NSDraggingSource>
@end

@implementation PackageSelectorForm

- (instancetype)init {
    self = [super initWithWindowNibName:@"PackageSelectorForm"];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setupUI];
    [self setupTableView];
}

- (void)setupUI {
    // Configure labels
    [self.label1 setStringValue:@"You can use this Helper to Drag & Drop the Files from the current Package to any Reference List. The Item will be added to the List."];
    [self.label1 setTextColor:[NSColor controlTextColor]];
    
    [self.lbfile setFont:[NSFont boldSystemFontOfSize:12]];
    
    // Configure window
    [self.window setTitle:@"Package File Selector"];
    [self.window setMinSize:NSMakeSize(440, 232)];
}

- (void)setupTableView {
    // Configure table view
    [self.lbfiles setDataSource:self];
    [self.lbfiles setDelegate:self];
    [self.lbfiles setAllowsMultipleSelection:NO];
    
    // Enable drag and drop
    [self.lbfiles registerForDraggedTypes:@[NSPasteboardTypeString]];
    [self.lbfiles setDraggingSourceOperationMask:NSDragOperationCopy | NSDragOperationLink forLocal:NO];
}

- (void)executeWithPackage:(id<IPackageFile>)package {
    [self.items removeAllObjects];
    [self.lbfile setStringValue:[package fileName]];
    
    for (id<IPackedFileDescriptor> pfd in [package index]) {
        [self.items addObject:pfd];
    }
    
    // Sort items
    [self.items sortUsingComparator:^NSComparisonResult(id<IPackedFileDescriptor> obj1, id<IPackedFileDescriptor> obj2) {
        NSString *name1 = [obj1 respondsToSelector:@selector(description)] ? [obj1 description] : @"";
        NSString *name2 = [obj2 respondsToSelector:@selector(description)] ? [obj2 description] : @"";
        return [name1 compare:name2];
    }];
    
    [self.lbfiles reloadData];
    [self showWindow:nil];
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.items count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < [self.items count]) {
        id<IPackedFileDescriptor> pfd = [self.items objectAtIndex:row];
        return [pfd respondsToSelector:@selector(description)] ? [pfd description] : @"Unknown";
    }
    return @"";
}

// MARK: - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView mouseDownInRow:(NSInteger)row {
    if (row >= 0) {
        NSEvent *event = [NSApp currentEvent];
        if ([event type] == NSEventTypeLeftMouseDown) {
            [self startDragFromRow:row withEvent:event];
        }
    }
}

- (void)startDragFromRow:(NSInteger)row withEvent:(NSEvent *)event {
    if (row < 0 || row >= [self.items count]) {
        return;
    }
    
    id<IPackedFileDescriptor> pfd = [self.items objectAtIndex:row];
    
    // Create pasteboard item
    NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
    [pbItem setString:[pfd description] forType:NSPasteboardTypeString];
    
    // Create dragging item
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    
    // Set the dragging frame
    NSRect dragFrame = [self.lbfiles rectOfRow:row];
    dragFrame.size.height = 20;
    
    // Create drag image
    NSImage *dragImage = [[NSImage alloc] initWithSize:dragFrame.size];
    [dragImage lockFocus];
    [[NSColor controlBackgroundColor] set];
    NSRectFill(NSMakeRect(0, 0, dragFrame.size.width, dragFrame.size.height));
    
    NSString *title = [pfd description];
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:12]};
    [title drawInRect:NSMakeRect(5, 2, dragFrame.size.width - 10, 16) withAttributes:attributes];
    [dragImage unlockFocus];
    
    [dragItem setDraggingFrame:dragFrame contents:dragImage];
    
    // Begin dragging session
    NSDraggingSession *session = [self.lbfiles beginDraggingSessionWithItems:@[dragItem]
                                                                       event:event
                                                                      source:self];
    session.animatesToStartingPositionsOnCancelOrFail = YES;
}

// MARK: - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy | NSDragOperationLink;
}

// Optional but commonly implemented
- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // Handle drag end if needed
}
@end
