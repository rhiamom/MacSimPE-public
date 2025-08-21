//
//  ResourceListViewExt.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/29/25.
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

#import "ResourceListViewExt.h"
#import "ResourceViewManager.h"
#import "NamedPackedFileDescriptor.h"
#import "IResourceViewFilter.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import "FileTable.h"
#import "Registry.h"
#import "ExpansionItem.h"
#import "TypeAlias.h"


@interface ResourceListViewExt ()
@property (nonatomic, strong) id selectionChangedEvent;
@property (nonatomic, strong) id selectedResourceEvent;
@end

@implementation ResourceListViewExt

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.noSelectEvent = 0;
        self.lastResources = nil;
        self.sortTicket = 0;
        self.sortColumn = SortColumnOffset;
        self.ascending = YES;
        self.names = [[ResourceNameList alloc] init];
        
        [self setupUI];
        [self setupColumns];
        [self setupTimer];
    }
    return self;
}

- (void)dealloc {
    [self cancelThreads];
    [self.selectionTimer invalidate];
}

- (void)setupUI {
    // Create table view
    self.tableView = [[NSTableView alloc] init];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setUsesAlternatingRowBackgroundColors:YES];
    [self.tableView setAllowsMultipleSelection:YES];
    [self.tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(tableViewDoubleClicked:)];
    
    // Create scroll view
    self.scrollView = [[NSScrollView alloc] init];
    [self.scrollView setDocumentView:self.tableView];
    [self.scrollView setHasVerticalScroller:YES];
    [self.scrollView setHasHorizontalScroller:YES];
    [self.scrollView setAutohidesScrollers:YES];
    
    [self addSubview:self.scrollView];
    
    // Setup constraints
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
}

- (void)setupColumns {
    // Create table columns with appropriate sizing
    self.typeColumn = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
    [[self.typeColumn headerCell] setStringValue:@"Type"];
    [self.typeColumn setMinWidth:60];
    [self.typeColumn setMaxWidth:120];
    [self.typeColumn setResizingMask:NSTableColumnAutoresizingMask];
    
    self.nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
    [[self.nameColumn headerCell] setStringValue:@"Name"];
    [self.nameColumn setMinWidth:150];
    [self.nameColumn setResizingMask:NSTableColumnUserResizingMask];
    
    self.groupColumn = [[NSTableColumn alloc] initWithIdentifier:@"Group"];
    [[self.groupColumn headerCell] setStringValue:@"Group"];
    [self.groupColumn setMinWidth:80];
    [self.groupColumn setMaxWidth:100];
    [self.groupColumn setResizingMask:NSTableColumnNoResizing];
    
    self.instanceHiColumn = [[NSTableColumn alloc] initWithIdentifier:@"InstanceHi"];
    [[self.instanceHiColumn headerCell] setStringValue:@"Inst Hi"];
    [self.instanceHiColumn setMinWidth:80];
    [self.instanceHiColumn setMaxWidth:100];
    [self.instanceHiColumn setResizingMask:NSTableColumnNoResizing];
    
    self.instanceColumn = [[NSTableColumn alloc] initWithIdentifier:@"Instance"];
    [[self.instanceColumn headerCell] setStringValue:@"Instance"];
    [self.instanceColumn setMinWidth:80];
    [self.instanceColumn setMaxWidth:100];
    [self.instanceColumn setResizingMask:NSTableColumnNoResizing];
    
    self.offsetColumn = [[NSTableColumn alloc] initWithIdentifier:@"Offset"];
    [[self.offsetColumn headerCell] setStringValue:@"Offset"];
    [self.offsetColumn setMinWidth:80];
    [self.offsetColumn setMaxWidth:100];
    [self.offsetColumn setResizingMask:NSTableColumnNoResizing];
    
    self.sizeColumn = [[NSTableColumn alloc] initWithIdentifier:@"Size"];
    [[self.sizeColumn headerCell] setStringValue:@"Size"];
    [self.sizeColumn setMinWidth:60];
    [self.sizeColumn setMaxWidth:80];
    [self.sizeColumn setResizingMask:NSTableColumnNoResizing];
    
    // Add columns to table view
    [self.tableView addTableColumn:self.typeColumn];
    [self.tableView addTableColumn:self.nameColumn];
    [self.tableView addTableColumn:self.groupColumn];
    [self.tableView addTableColumn:self.instanceHiColumn];
    [self.tableView addTableColumn:self.instanceColumn];
    
    // Conditionally add debug columns
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ResourceListShowExtensions"]) {
        [self.tableView removeTableColumn:self.nameColumn];
    }
    
    if (![AppPreferences hiddenMode]) {
        if ([self.tableView.tableColumns containsObject:self.offsetColumn]) {
            [self.tableView removeTableColumn:self.offsetColumn];
        }
        if ([self.tableView.tableColumns containsObject:self.sizeColumn]) {
            [self.tableView removeTableColumn:self.sizeColumn];
        }
    }
    
    // Conditionally hide type extension column
    if (![Registry.windowsRegistry resourceListShowExtensions]) {
        [self.tableView removeTableColumn:self.nameColumn];
    }
    
    // Set up automatic column sizing - Name column gets remaining space
    [self.tableView setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
    [self.tableView sizeToFit];
    }

- (void)setupTimer {
    // Selection timer setup
    self.selectionTimer = [NSTimer timerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(selectionTimerCallback:)
                                                userInfo:nil
                                                 repeats:NO];
}

// MARK: - ResourceViewManager Integration

- (void)setManager:(ResourceViewManager *)manager {
    if (self.manager != manager) {
        self.manager = manager;
    }
}

- (void)setResources:(ResourceNameList *)resources {
    ResourceNameList *selectedItems = [self selectedItems];
    [self clear];
    [self.selectionTimer invalidate];
    [self cancelThreads];
    
    @synchronized (self.names) {
        [self.names removeAllObjects];
        
        [self clear];
        
        for (NamedPackedFileDescriptor *pfd in resources) {
            BOOL add = YES;
            if (self.filter != nil && [self.filter active]) {
                add = ![self.filter isFiltered:[pfd descriptor]];
            }
            
            if (add) {
                [self.names addObject:pfd];
            }
        }
        
        [self.tableView reloadData];
        [self sortResources];
        
        // Restore selection
        for (NamedPackedFileDescriptor *selectedItem in selectedItems) {
            for (NSInteger i = 0; i < [self.names count]; i++) {
                if ([[self.names objectAtIndex:i] descriptor] == [selectedItem descriptor]) {
                    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:i]
                                byExtendingSelection:YES];
                    break;
                }
            }
        }
        
        self.lastResources = resources;
        [self performSelector:@selector(onResourceSelectionChanged) withObject:nil afterDelay:0.0];
    }
}

- (void)setResourceList:(ResourceList *)resources package:(id<IPackageFile>)package {
    ResourceNameList *namedList = [[ResourceNameList alloc] init];
    for (id<IPackedFileDescriptor> pfd in resources) {
        NamedPackedFileDescriptor *npfd = [[NamedPackedFileDescriptor alloc] initWithDescriptor:pfd
                                                                                         package:package];
        [namedList addObject:npfd];
    }
    [self setResources:namedList];
}

// MARK: - Drag & Drop Support

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    if ([rowIndexes count] == 0) return NO;
    
    NSInteger row = [rowIndexes firstIndex];
    if (row >= [self.names count]) return NO;
    NamedPackedFileDescriptor *namedResource = [self.names objectAtIndex:row];
    id<IPackedFileDescriptor> pfd = [namedResource descriptor];
    
    // Create pasteboard representation
    NSString *description = [namedResource getRealName];
    if (description == nil || [description length] == 0) {
        description = [NSString stringWithFormat:@"Resource %08X", [pfd type]];
    }
    
    [pboard declareTypes:@[NSPasteboardTypeString] owner:self];
    [pboard setString:description forType:NSPasteboardTypeString];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy | NSDragOperationLink;
}
// MARK: - Update Management

- (void)beginUpdate {
    self.noSelectEvent++;
    self.selectionChangedEvent = nil;
    self.selectedResourceEvent = nil;
}

- (void)endUpdate {
    [self endUpdateWithFireEvents:YES];
}

- (void)endUpdateWithFireEvents:(BOOL)fireEvents {
    self.noSelectEvent--;
    self.noSelectEvent = MAX(0, self.noSelectEvent);
    
    if (self.noSelectEvent <= 0 && fireEvents) {
        if (self.selectionChangedEvent != nil && self.selectionChangedBlock) {
            self.selectionChangedBlock();
        }
        if (self.selectedResourceEvent != nil && self.selectedResourceBlock) {
            self.selectedResourceBlock(self.selectedResourceEvent);
        }
        self.selectionChangedEvent = nil;
        self.selectedResourceEvent = nil;
    }
}

- (void)refresh {
    [self.tableView reloadData];
}

// MARK: - Resource Management

- (void)clear {
    // Clear table selection
    [self.tableView deselectAll:nil];
}

- (void)sortResources {
    self.sortTicket++;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronSort"]) {
        [self performSelectorInBackground:@selector(doAsyncSorting) withObject:nil];
    } else {
        [self doTheSorting];
    }
}

- (void)doTheSorting {
    [self.names sortByColumn:self.sortColumn ascending:self.ascending];
    [self.tableView reloadData];
}

- (void)doAsyncSorting {
    // Background sorting implementation
    [self.names sortByColumn:self.sortColumn ascending:self.ascending];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self refresh];
    });
}

- (void)replaySetResources {
    if (self.lastResources != nil) {
        [self setResources:self.lastResources];
    }
}

// MARK: - Threading

- (void)cancelThreads {
    if (self.sortingThread != nil) {
        [self.sortingThread cancel];
        self.sortingThread = nil;
    }
}

// MARK: - Timer Callbacks

- (void)selectionTimerCallback:(NSTimer *)timer {
    [self onResourceSelectionChanged];
}

// MARK: - Filter Management

- (void)setFilter:(id<IResourceViewFilter>)filter {
    if (_filter != filter) {
        if (_filter != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:IResourceViewFilterChangedFilterNotification
                                                          object:_filter];
        }
        _filter = filter;
        if (_filter != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(filterChangedFilter)
                                                         name:IResourceViewFilterChangedFilterNotification
                                                       object:_filter];
        }
    }
}

- (void)filterChangedFilter {
    [self replaySetResources];
}

// MARK: - Selection Management

- (ResourceNameList *)selectedItems {
    ResourceNameList *selectedList = [[ResourceNameList alloc] init];
    NSIndexSet *selectedRows = [self.tableView selectedRowIndexes];
    
    [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx < [self.names count]) {
            [selectedList addObject:[self.names objectAtIndex:idx]];
        }
    }];
    
    return selectedList;
}

- (BOOL)selectResource:(id<IScenegraphFileIndexItem>)resource {
    for (NSInteger i = 0; i < [self.names count]; i++) {
        NamedPackedFileDescriptor *namedResource = [self.names objectAtIndex:i];
        
        // Compare the descriptor directly with the resource's fileDescriptor
        if ([namedResource descriptor] == [resource fileDescriptor]) {
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:i]
                        byExtendingSelection:NO];
            [self.tableView scrollRowToVisible:i];
            return YES;
        }
    }
    return NO;
}

// MARK: - Events

- (void)onResourceSelectionChanged {
    if (self.noSelectEvent > 0) return;
    
    if (self.selectionChangedBlock) {
        self.selectionChangedBlock();
    }
}

- (void)tableViewDoubleClicked:(id)sender {
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0 && selectedRow < [self.names count]) {
        NamedPackedFileDescriptor *namedResource = [self.names objectAtIndex:selectedRow];
        if (self.selectedResourceBlock) {
            self.selectedResourceBlock(namedResource);
        }
    }
}

// MARK: - Layout Management (Simplified for macOS)

- (void)storeLayout {
    // On macOS, column layouts are typically handled automatically
    // or stored in user defaults by the system if needed
    // We only store the visibility preferences
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[Registry.windowsRegistry resourceListShowExtensions] forKey:@"ResourceListShowExtensions"];
    [defaults setBool:[Registry.windowsRegistry hiddenMode] forKey:@"ResourceListHiddenMode"];
}

- (void)restoreLayout {
    // Restore visibility settings and let NSTableView handle sizing
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL showExtensions = [defaults boolForKey:@"ResourceListShowExtensions"];
    BOOL hiddenMode = [AppPreferences hiddenMode];
    
    // Apply visibility settings
    if (!showExtensions && [self.tableView.tableColumns containsObject:self.nameColumn]) {
        [self.tableView removeTableColumn:self.nameColumn];
    } else if (showExtensions && ![self.tableView.tableColumns containsObject:self.nameColumn]) {
        [self.tableView addTableColumn:self.nameColumn];
    }
    
    if (!hiddenMode) {
        if ([self.tableView.tableColumns containsObject:self.sizeColumn]) {
            [self.tableView removeTableColumn:self.sizeColumn];
        }
        if ([self.tableView.tableColumns containsObject:self.offsetColumn]) {
            [self.tableView removeTableColumn:self.offsetColumn];
        }
    } else {
        if (![self.tableView.tableColumns containsObject:self.offsetColumn]) {
            [self.tableView addTableColumn:self.offsetColumn];
        }
        if (![self.tableView.tableColumns containsObject:self.sizeColumn]) {
            [self.tableView addTableColumn:self.sizeColumn];
        }
    }
    
    // Let the table view handle column sizing automatically
    [self.tableView sizeToFit];
}

// MARK: - NSTableViewDataSource

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.names count];
}

// MARK: - NSTableViewDelegate (View-Based)

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < [self.names count]) {
        NamedPackedFileDescriptor *namedResource = [self.names objectAtIndex:row];
        
        // Get or create cell view
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
        if (cellView == nil) {
            cellView = [[NSTableCellView alloc] init];
            [cellView setIdentifier:[tableColumn identifier]];
            
            NSTextField *textField = [[NSTextField alloc] init];
            [textField setBezeled:NO];
            [textField setDrawsBackground:NO];
            [textField setEditable:NO];
            [textField setSelectable:NO];
            [cellView addSubview:textField];
            [cellView setTextField:textField];
            
            // Set up constraints for text field
            [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
            [NSLayoutConstraint activateConstraints:@[
                [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:2],
                [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-2],
                [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
            ]];
        }
        
        // Set cell content based on column
        NSString *content = @"";
        if (tableColumn == self.typeColumn) {
            content = [[[namedResource descriptor] pfdTypeName] shortName];
        } else if (tableColumn == self.nameColumn) {
            content = [namedResource getRealName];
        } else if (tableColumn == self.groupColumn) {
            content = [NSString stringWithFormat:@"0x%08X", [[namedResource descriptor] group]];
        } else if (tableColumn == self.instanceHiColumn) {
            content = [NSString stringWithFormat:@"0x%08X", [[namedResource descriptor] subtype]];
        } else if (tableColumn == self.instanceColumn) {
            content = [NSString stringWithFormat:@"0x%08X", [[namedResource descriptor] instance]];
        } else if (tableColumn == self.offsetColumn) {
            content = [NSString stringWithFormat:@"0x%08lX", (long)[[namedResource descriptor] offset]];
        } else if (tableColumn == self.sizeColumn) {
            content = [NSString stringWithFormat:@"%ld", (long)[[namedResource descriptor] size]];
        }
        
        [[cellView textField] setStringValue:content];
        
        // Apply styling based on resource state
        NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
        NSColor *textColor = [NSColor controlTextColor];
        
        if ([[namedResource descriptor] markForDelete]) {
            textColor = [NSColor secondaryLabelColor];
            NSFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitBold];
            font = [NSFont fontWithDescriptor:descriptor size:font.pointSize];
        }
        
        if ([[namedResource descriptor] changed]) {
            NSFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitItalic];
            font = [NSFont fontWithDescriptor:descriptor size:font.pointSize];
        }
        
        [[cellView textField] setFont:font];
        [[cellView textField] setTextColor:textColor];
        
        return cellView;
    }
    
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.noSelectEvent > 0) return;
    
    // Delay selection change notification to avoid rapid fire events
    [self.selectionTimer invalidate];
    self.selectionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(selectionTimerCallback:)
                                                         userInfo:nil
                                                          repeats:NO];
}

@end
