//
//  ResourceListViewExt+Sorting.h
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
#import "ResourceViewManagerHelpers.h"

@class ResourceNameSorter;

// MARK: - ResourceListViewExt Sorting Category

@interface ResourceListViewExt (Sorting)

// MARK: - Sorting Properties
@property (nonatomic, assign) SortColumn sortedColumn;

// MARK: - Sorting Management
- (void)sortResources;
- (void)doTheSorting;
- (void)cancelThreads;

// MARK: - Sorting Signals
- (void)signalFinishedSort:(NSInteger)ticket;

// MARK: - Column Click Handling
- (void)handleColumnClick:(NSTableColumn *)column;

@end

// MARK: - Resource Name Sorter

@interface ResourceNameSorter : NSObject

@property (nonatomic, weak) ResourceListViewExt *listView;
@property (nonatomic, strong) ResourceNameList *names;
@property (nonatomic, assign) NSInteger ticket;
@property (nonatomic, assign) BOOL cancelled;

- (instancetype)initWithListView:(ResourceListViewExt *)listView
                           names:(ResourceNameList *)names
                          ticket:(NSInteger)ticket;

- (void)start;
- (void)cancel;

@end
