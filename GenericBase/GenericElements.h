//
//  GenericElements.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/2/25.
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

#import <Cocoa/Cocoa.h>

@protocol IFileWrapperSaveExtension;
@class GenericItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * Generic UI elements for displaying data in both list and tree formats
 * Used throughout SimPE for file editing interfaces
 */
@interface GenericElements : NSViewController

// MARK: - UI Components

/**
 * List view panel containing the table and associated controls
 */
@property (nonatomic, strong) IBOutlet NSView *listPanel;

/**
 * Tree view panel containing the outline view and associated controls
 */
@property (nonatomic, strong) IBOutlet NSView *treePanel;

/**
 * Banner label for the list view
 */
@property (nonatomic, strong) IBOutlet NSTextField *listBanner;

/**
 * Banner label for the tree view
 */
@property (nonatomic, strong) IBOutlet NSTextField *treeBanner;

/**
 * Main table view for displaying list data
 */
@property (nonatomic, strong) IBOutlet NSTableView *listList;

/**
 * Main outline view for displaying tree data
 */
@property (nonatomic, strong) IBOutlet NSOutlineView *mytree;

/**
 * Panel for item detail controls (right side of list view)
 */
@property (nonatomic, strong) IBOutlet NSView *itemPanel;

/**
 * Panel for tree item detail controls (right side of tree view)
 */
@property (nonatomic, strong) IBOutlet NSView *treeItemPanel;

/**
 * Commit button for saving changes to list view items
 */
@property (nonatomic, strong) IBOutlet NSButton *lllvcommit;

// MARK: - Properties

/**
 * The wrapper instance that provides data and handles saving
 */
@property (nonatomic, weak, nullable) id<IFileWrapperSaveExtension> wrapper;

// MARK: - Initialization

/**
 * Initialize the generic elements view controller
 */
- (instancetype)init;

// MARK: - IBActions

/**
 * Handle commit button click to save list view changes
 * @param sender The commit button
 */
- (IBAction)commitListViewClick:(id)sender;

// MARK: - Data Management

/**
 * Refresh the UI with current data
 */
- (void)refresh;

/**
 * Setup the table view columns and data source
 */
- (void)setupTableView;

/**
 * Setup the outline view and data source
 */
- (void)setupOutlineView;

@end

NS_ASSUME_NONNULL_END
