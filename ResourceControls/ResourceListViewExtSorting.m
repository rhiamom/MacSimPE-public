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
#import "ResourceNameSorter.h"

// MARK: - Associated Objects for Category Properties

static const char kSortedColumnKey[] = "sortedColumn";
static const char kSortingSorterKey[] = "sortingSorter";

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
        [self sortResourcesExt];
        [self refresh];
    }
}

- (ResourceNameSorter *)sortingSorter {
    return (ResourceNameSorter *)objc_getAssociatedObject(self, kSortingSorterKey);
}

- (void)setSortingSorter:(ResourceNameSorter *)sortingSorter {
    objc_setAssociatedObject(self, kSortingSorterKey, sortingSorter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
        // MARK: - Sorting Management
        
- (void)sortResourcesExt {
    self.sortTicket++;
    [self cancelSortThreadsExt];
            
    if (self.sortedColumn == SortColumnName) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronSort"]) {
            [Wait subStartWithCount:[self.names count]];
            [Wait setMessage:[Localization getString:@"Loading embedded resource names..."]];
        }
                
        ResourceNameSorter *sorter = [[ResourceNameSorter alloc] initWithListView:self
                                                                            names:self.names
                                                                            ticket:self.sortTicket];
        self.sortingSorter = sorter;
        [sorter start];
    } else {
        [self signalFinishedSortExt:self.sortTicket];
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
        
- (void)cancelSortThreadsExt {
            if (self.sortingSorter != nil) {
                [self.sortingSorter cancel];
                self.sortingSorter = nil;
            }
        }
        
- (void)signalFinishedSortExt:(NSInteger)ticket {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ticket == self.sortTicket) {
            self.sortingSorter = nil;
            [self doTheSorting];
            [self refresh];
                    
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronSort"]) {
                [Wait subStop];
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
        
