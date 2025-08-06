//
//  ResourceListViewExtSorting.m
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

#import "ResourceListViewExtSorting.h"
#import "NamedPackedFileDescriptor.h"
#import "Wait.h"
#import "Localization.h"
#import <objc/runtime.h>

// MARK: - Associated Objects for Category Properties

static const char kSortedColumnKey[] = "sortedColumn";
static const char kSortingThreadKey[] = "sortingThread";

// MARK: - ResourceListViewExt Sorting Implementation

@implementation ResourceListViewExt (Sorting)

// MARK: - Property Implementations

- (SortColumn)sortedColumn {
    NSNumber *number = objc_getAssociatedObject(self, kSortedColumnKey);
    return [number integerValue];
}

- (void)setSortedColumn:(SortColumn)sortedColumn {
    objc_setAssociatedObject(self, kSortedColumnKey, @(sortedColumn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    @synchronized (self.names) {
        [self sortResources];
        [self refresh];
    }
}

- (ResourceNameSorter *)sortingThread {
    return objc_getAssociatedObject(self, kSortingThreadKey);
}

- (void)setSortingThread:(ResourceNameSorter *)sortingThread {
    objc_setAssociatedObject(self, kSortingThreadKey, sortingThread, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// MARK: - Sorting Management

- (void)sortResources {
    self.sortTicket++;
    [self cancelThreads];
    
    if (self.sortedColumn == SortColumnName) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronSort"]) {
            [[Wait shared] subStartWithCount:[self.names count]];
        }
        
        [[Wait shared] setMessage:[[Localization shared] getString:@"Loading embedded resource names..."]];
        
        ResourceNameSorter *sorter = [[ResourceNameSorter alloc] initWithListView:self
                                                                            names:self.names
                                                                           ticket:self.sortTicket];
        self.sortingThread = sorter;
        [sorter start];
    } else {
        [self signalFinishedSort:self.sortTicket];
    }
}

- (void)doTheSorting {
    [self beginUpdate];
    
    ResourceNameList *oldSelection = [self selectedItems];
    
    [self.tableView deselectAll:nil];
    [self.names sortByColumn:self.sortedColumn ascending:self.ascending];
    
    BOOL first = YES;
    for (NamedPackedFileDescriptor *pfd in oldSelection) {
        NSUInteger index = [self.names indexOfObject:pfd];
        if (index != NSNotFound) {
            if (first) {
                [self.tableView scrollRowToVisible:index];
                first = NO;
            }
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
                        byExtendingSelection:YES];
        }
    }
    
    [self endUpdateWithFireEvents:NO];
}

- (void)cancelThreads {
    if (self.sortingThread != nil) {
        [self.sortingThread cancel];
        self.sortingThread = nil;
    }
}

- (void)signalFinishedSort:(NSInteger)ticket {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ticket == self.sortTicket) {
            self.sortingThread = nil;
            [self doTheSorting];
            [self refresh];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronSort"]) {
                [[Wait shared] subStop];
            }
        }
    });
}

// MARK: - Column Click Handling

- (void)handleColumnClick:(NSTableColumn *)column {
    SortColumn newSortColumn = SortColumnOffset; // Default
    
    if (column == self.typeColumn) {
        newSortColumn = SortColumnName;
    } else if (column == self.nameColumn) {
        newSortColumn = SortColumnExtension;
    } else if (column == self.groupColumn) {
        newSortColumn = SortColumnGroup;
    } else if (column == self.instanceHiColumn) {
        newSortColumn = SortColumnInstanceHi;
    } else if (column == self.instanceColumn) {
        newSortColumn = SortColumnInstanceLo;
    } else if (column == self.sizeColumn) {
        newSortColumn = SortColumnSize;
    } else if (column == self.offsetColumn) {
        newSortColumn = SortColumnOffset;
    }
    
    if (newSortColumn == self.sortedColumn) {
        self.ascending = !self.ascending;
    }
    
    self.sortedColumn = newSortColumn;
}

@end

// MARK: - ResourceNameSorter Implementation

@implementation ResourceNameSorter

- (instancetype)initWithListView:(ResourceListViewExt *)listView
                           names:(ResourceNameList *)names
                          ticket:(NSInteger)ticket {
    self = [super init];
    if (self) {
        _listView = listView;
        _names = names;
        _ticket = ticket;
        _cancelled = NO;
    }
    return self;
}

- (void)start {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performSorting];
    });
}

- (void)cancel {
    self.cancelled = YES;
}

- (void)performSorting {
    if (self.cancelled) return;
    
    // Pre-load all resource names
    for (NamedPackedFileDescriptor *pfd in self.names) {
        if (self.cancelled) return;
        [pfd getRealName]; // This loads the name if not already loaded
    }
    
    if (!self.cancelled) {
        [self.listView signalFinishedSort:self.ticket];
    }
}

@end
