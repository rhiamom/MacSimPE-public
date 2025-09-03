//
//  GenericTree.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Generic.h"

@protocol IFileWrapper;
@class GenericItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * Tree-based UI Handler for Generic Files
 * Displays file data in a hierarchical tree structure instead of a flat list
 */
@interface GenericTree : Generic

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - IPackedFileUI Protocol Override

/**
 * Returns the tree panel as the main GUI view
 */
- (NSView *)createView;

/**
 * Updates the GUI with the given wrapper data using tree display
 * @param wrapper The file wrapper containing data to display
 */
- (void)updateGUI:(id<IFileWrapper>)wrapper;

// MARK: - Tree Building Methods

/**
 * Recursively adds tree nodes for the given items
 * @param items Array of GenericItem objects to add as nodes
 * @param parentNode The parent node to add children to, or nil for root level
 * @param names Array of property names to display
 */
- (void)addTreeNodes:(NSArray<GenericItem *> *)items
          parentNode:(nullable NSOutlineViewItem *)parentNode
               names:(NSArray<NSString *> *)names;

@end

NS_ASSUME_NONNULL_END
