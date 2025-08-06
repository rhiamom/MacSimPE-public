//
//  ResourceListView.m
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

#import "ResourceListViewExt.h"
#import "ResourceViewManager.h"
#import "NamedPackedFileDescriptor.h"
#import "ResourceListItemExt.h"
#import "IResourceViewFilter.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import "FileTable.h"
#import "Helper.h"
#import "WindowsRegistry.h"

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
        self.cache = [[NSMutableDictionary alloc] init];
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
    // Create table columns
    self.typeColumn = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
    [[self.typeColumn headerCell] setStringValue:@"Type"];
    [self.typeColumn setMinWidth:80];
    [self.typeColumn setWidth:100];
    
    self.nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
    [[self.nameColumn headerCell] setStringValue:@"Name"];
    [self.nameColumn setMinWidth:120];
    [self.nameColumn setWidth:200];
    
    self.groupColumn = [[NSTableColumn alloc] initWithIdentifier:@"Group"];
    [[self.groupColumn headerCell] setStringValue:@"Group"];
    [self.groupColumn setMinWidth:80];
    [self.groupColumn setWidth:100];
    
    self.instanceHiColumn = [[NSTableColumn alloc] initWithIdentifier:@"InstanceHi"];
    [[self.instanceHiColumn headerCell] setStringValue:@"Inst Hi"];
    [self.instanceHiColumn setMinWidth:80];
    [self.instanceHiColumn setWidth:100];
    
    self.instanceColumn = [[NSTableColumn alloc] initWithIdentifier:@"Instance"];
    [[self.instanceColumn headerCell] setStringValue:@"Instance"];
    [self.instanceColumn setMinWidth:80];
    [self.instanceColumn setWidth:100];
    
    self.offsetColumn = [[NSTableColumn alloc] initWithIdentifier:@"Offset"];
    [[self.offsetColumn headerCell] setStringValue:@"Offset"];
    [self.offsetColumn setMinWidth:80];
    [self.offsetColumn setWidth:100];
    
    self.sizeColumn = [[NSTableColumn alloc] initWithIdentifier:@"Size"];
    [[self.sizeColumn headerCell] setStringValue:@"Size"];
    [self.sizeColumn setMinWidth:80];
    [self.sizeColumn setWidth:100];
    
    // Add columns to table view
    [self.tableView addTableColumn:self.typeColumn];
    [self.tableView addTableColumn:self.nameColumn];
    [self.tableView addTableColumn:self.groupColumn];
    [self.tableView addTableColumn:self.instanceHiColumn];
    [self.tableView addTableColumn:self.instanceColumn];
    
    // Conditionally add hidden mode columns
    if ([Helper.windowsRegistry hiddenMode]) {
        [self.tableView addTableColumn:self.offsetColumn];
        [self.tableView addTableColumn:self.sizeColumn];
    }
    
    // Conditionally remove extension column
    if (![Helper.windowsRegistry resourceListShowExtensions]) {
        [self.tableView removeTableColumn:self.nameColumn];
    }
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
        // Remove event handlers from old resources
        for (NamedPackedFileDescriptor *pfd in self.names) {
            // TODO: Remove event handlers
            // pfd.descriptor.changedUserData -= descriptorChangedUserData
            // pfd.descriptor.descriptionChanged -= descriptorDescriptionChanged
            // pfd.descriptor.changedData -= descriptorChangedData
        }
        
        [self.names removeAllObjects];
        
        // Set image list if available
        if ([FileTable wrapperRegistry] != nil) {
            // TODO: Set up image list
            // self.tableView.imageList = FileTable.wrapperRegistry.wrapperImageList;
        }
        
        [self clear];
        
        for (NamedPackedFileDescriptor *pfd in resources) {
            BOOL add = YES;
            if (self.filter != nil && [self.filter active]) {
                add = ![self.filter isFiltered:[pfd descriptor]];
            }
            
            if (add) {
                [self.names addObject:pfd];
                // TODO: Add event handlers
                // pfd.descriptor.changedData += descriptorChangedData
                // pfd.descriptor.descriptionChanged += descriptorDescriptionChanged
                // pfd.descriptor.changedUserData += descriptorChangedUserData
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

// MARK: - Update Management

- (void)beginUpdate {
    self.noSelectEvent++;
    self.selectionChangedEvent = nil;
    self.selectedResourceEvent = nil;
    // TODO: Equivalent of lv.BeginUpdate()
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
    
    // TODO: Equivalent of lv.EndUpdate()
}

- (void)refresh {
    [self.tableView reloadData];
}

// MARK: - Resource Management

- (void)clear {
    // Clear table selection
    [self.tableView deselectAll:nil];
    
    // Clear cache
    for (ResourceListItemExt *item in [self.cache allValues]) {
        [item freeResources];
    }
    [self.cache removeAllObjects];
}

- (void)sortResources {
    self.sortTicket++;
    
    if ([Helper.windowsRegistry asynchronSort]) {
        // TODO: Implement async sorting
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
            // TODO: Remove old filter event handlers
            // curfilter.ChangedFilter -= curfilterChangedFilter
        }
        _filter = filter;
        if (_filter != nil) {
            // TODO: Add new filter event handlers
            // curfilter.ChangedFilter += curfilterChangedFilter
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
        if ([[namedResource descriptor] fileDescriptor] == [resource fileDescriptor]) {
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

// MARK: - Layout Management

- (void)storeLayout {
    // Store column widths in registry
    [Helper.windowsRegistry.layout setTypeColumnWidth:(NSInteger)[self.typeColumn width]];
    [Helper.windowsRegistry.layout setGroupColumnWidth:(NSInteger)[self.groupColumn width]];
    [Helper.windowsRegistry.layout setInstanceHighColumnWidth:(NSInteger)[self.instanceHiColumn width]];
    [Helper.windowsRegistry.layout setInstanceColumnWidth:(NSInteger)[self.instanceColumn width]];
    [Helper.windowsRegistry.layout setOffsetColumnWidth:(NSInteger)[self.offsetColumn width]];
    [Helper.windowsRegistry.layout setSizeColumnWidth:(NSInteger)[self.sizeColumn width]];
    
    // TODO: Store column order
}

- (void)restoreLayout {
    // Restore column widths from registry
    [self.typeColumn setWidth:[Helper.windowsRegistry.layout typeColumnWidth]];
    [self.groupColumn setWidth:[Helper.windowsRegistry.layout groupColumnWidth]];
    [self.instanceHiColumn setWidth:[Helper.windowsRegistry.layout instanceHighColumnWidth]];
    [self.instanceColumn setWidth:[Helper.windowsRegistry.layout instanceColumnWidth]];
    [self.offsetColumn setWidth:[Helper.windowsRegistry.layout offsetColumnWidth]];
    [self.sizeColumn setWidth:[Helper.windowsRegistry.layout sizeColumnWidth]];
    
    // TODO: Restore column order
    
    // Apply visibility settings
    if (![Helper.windowsRegistry resourceListShowExtensions]) {
        [self.tableView removeTableColumn:self.nameColumn];
    }
    if (![Helper.windowsRegistry hiddenMode]) {
        [self.tableView removeTableColumn:self.sizeColumn];
        [self.tableView removeTableColumn:self.offsetColumn];
    }
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.names count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < [self.names count]) {
        NamedPackedFileDescriptor *namedResource = [self.names objectAtIndex:row];
        
        if (tableColumn == self.typeColumn) {
            return [[namedResource descriptor] typeName];
        } else if (tableColumn == self.nameColumn) {
            return [namedResource getRealName];
        } else if (tableColumn == self.groupColumn) {
            return [NSString stringWithFormat:@"0x%08X", [[namedResource descriptor] group]];
        } else if (tableColumn == self.instanceHiColumn) {
            return [NSString stringWithFormat:@"0x%08X", [[namedResource descriptor] subType]];
        } else if (tableColumn == self.instanceColumn) {
            return [NSString stringWithFormat:@"0x%08X", [[namedResource descriptor] instance]];
        } else if (tableColumn == self.offsetColumn) {
            return [NSString stringWithFormat:@"0x%08lX", (long)[[namedResource descriptor] offset]];
        } else if (tableColumn == self.sizeColumn) {
            return [NSString stringWithFormat:@"%ld", (long)[[namedResource descriptor] size]];
        }
    }
    
    return @"";
}

// MARK: - NSTableViewDelegate

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
