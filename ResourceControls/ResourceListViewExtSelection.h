//
//  ResourceListViewExtSelection.h
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

@class ResourceListViewExt;
@class NamedPackedFileDescriptor;
@class FileIndexItem;
@protocol IScenegraphFileIndexItem;

// MARK: - Constants
extern const NSTimeInterval WAIT_SELECT_INTERVAL;

// MARK: - Selection Event Args

@interface SelectResourceEventArgs : NSObject

@property (nonatomic, assign, readonly) BOOL ctrlDown;

- (instancetype)initWithCtrlDown:(BOOL)ctrlDown;

@end

// MARK: - ResourceListViewExtSelection

@interface ResourceListViewExtSelection : NSObject

// MARK: - Properties
@property (nonatomic, weak) ResourceListViewExt *listView;
@property (nonatomic, assign) BOOL ctrlDown;

// MARK: - Selection Blocks
@property (nonatomic, copy) void (^selectedResourceWithArgsBlock)(SelectResourceEventArgs *args);

// MARK: - Initialization
- (instancetype)initWithListView:(ResourceListViewExt *)listView;

// MARK: - Selection Management
- (void)signalSelectionChanged;
- (void)doSignalSelectionChanged;
- (void)selectionTimerCallback:(NSTimer *)timer;

// MARK: - Event Handling (for integration into main delegate methods)
- (void)handleSelectionChanged;
- (void)handleTableViewClick;
- (void)handleTableViewDoubleClick;
- (void)handleMouseUpWithEvent:(NSEvent *)event;
- (void)handleKeyDownWithEvent:(NSEvent *)event;
- (void)handleKeyUpWithEvent:(NSEvent *)event;

// MARK: - Resource Selection
- (void)onResourceSelectionChanged;
- (void)onSelectResource;

// MARK: - Public Methods
- (void)selectAllResources;
- (FileIndexItem *)selectedItem;

@end

