//
//  GroupCacheForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

/**
 * Group Cache Viewer interface
 * Equivalent to the Windows Forms GroupCacheForm
 */
@interface GroupCacheForm : NSViewController

// MARK: - UI Components

/**
 * List box for displaying group cache items
 * Equivalent to Windows Forms ListBox lbgroup
 */
@property (nonatomic, strong) IBOutlet NSTableView *groupListView;

/**
 * Main content panel
 * Equivalent to Windows Forms Panel GropPanel
 */
@property (nonatomic, strong) IBOutlet NSView *groupPanel;

/**
 * Header panel with title
 * Equivalent to Windows Forms Panel panel4
 */
@property (nonatomic, strong) IBOutlet NSView *headerPanel;

/**
 * Title label
 * Equivalent to Windows Forms Label label12
 */
@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;

/**
 * Array controller for managing list data
 */
@property (nonatomic, strong) NSArrayController *arrayController;

// MARK: - Data Management

/**
 * Array of items to display in the list
 */
@property (nonatomic, strong) NSMutableArray *groupItems;

// MARK: - Initialization

/**
 * Initialize the view controller
 */
- (instancetype)init;

// MARK: - UI Setup

/**
 * Configure the user interface components
 */
- (void)setupUI;

/**
 * Load data into the list view
 */
- (void)loadData:(NSArray *)items;

@end

