//
//  ResourceListViewExt.h
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ResourceViewManagerHelpers.h"

@class ResourceViewManager;
@class NamedPackedFileDescriptor;
@class ResourceListItemExt;
@class ResourceListViewExtSelection;
@protocol IScenegraphFileIndexItem;
@protocol IResourceViewFilter;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;

/**
 * Extended list view for displaying individual resources
 * This is the right panel in Object Workshop mode showing resource files
 */
@interface ResourceListViewExt : NSView <NSTableViewDataSource, NSTableViewDelegate>

// MARK: - Properties
@property (nonatomic, weak) ResourceViewManager *manager;
@property (nonatomic, strong) ResourceNameList *names;
@property (nonatomic, strong) ResourceNameList *lastResources;
@property (nonatomic, strong) id<IResourceViewFilter> filter;

// MARK: - Selection Handler
@property (nonatomic, strong) ResourceListViewExtSelection *selectionHandler;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;

// MARK: - Drag & Drop Support
- (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)tableView:(NSTableView *)tableView
               draggingSession:(NSDraggingSession *)session
sourceOperationMaskForDraggingContext:(NSDraggingContext)context;

// MARK: - Table Columns
@property (nonatomic, strong) NSTableColumn *typeColumn;
@property (nonatomic, strong) NSTableColumn *nameColumn;
@property (nonatomic, strong) NSTableColumn *groupColumn;
@property (nonatomic, strong) NSTableColumn *instanceHiColumn;
@property (nonatomic, strong) NSTableColumn *instanceColumn;
@property (nonatomic, strong) NSTableColumn *offsetColumn;
@property (nonatomic, strong) NSTableColumn *sizeColumn;

// MARK: - State Management
@property (nonatomic, assign) NSInteger noSelectEvent;
@property (nonatomic, assign) SortColumn sortColumn;
@property (nonatomic, assign) BOOL ascending;
@property (nonatomic, assign) NSInteger sortTicket;

// MARK: - Threading
@property (nonatomic, strong) NSTimer *selectionTimer;
@property (nonatomic, strong) NSThread *sortingThread;

// MARK: - Cache
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ResourceListItemExt *> *cache;

// MARK: - Events
@property (nonatomic, copy) void (^selectionChangedBlock)(void);
@property (nonatomic, copy) void (^selectedResourceBlock)(NamedPackedFileDescriptor *resource);

// MARK: - Initialization
- (instancetype)init;

// MARK: - UI Setup
- (void)setupUI;
- (void)setupColumns;
- (void)setupTimer;

// MARK: - ResourceViewManager Integration
- (void)setManager:(ResourceViewManager *)manager;
- (void)setResources:(ResourceNameList *)resources;
- (void)setResourceList:(ResourceList *)resources package:(id<IPackageFile>)package;

// MARK: - Update Management
- (void)beginUpdate;
- (void)endUpdate;
- (void)endUpdateWithFireEvents:(BOOL)fireEvents;
- (void)refresh;

// MARK: - Resource Management
- (void)clear;
- (void)sortResources;
- (void)replaySetResources;

// MARK: - Threading
- (void)cancelThreads;

// MARK: - Layout Management
- (void)storeLayout;
- (void)restoreLayout;

// MARK: - Selection (from Selection handler integration)
- (BOOL)selectResource:(id<IScenegraphFileIndexItem>)resource;
- (ResourceNameList *)selectedItems;

// MARK: - Events
- (void)onResourceSelectionChanged;

@end
