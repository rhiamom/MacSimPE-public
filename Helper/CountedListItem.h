//
//  CountedListItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

/**
 * Can be used as a Wrapper Class when adding unnamed Objects to a List
 */
@interface CountedListItem : NSObject

// MARK: - Properties

/**
 * Returns/Sets the stored Object
 */
@property (nonatomic, strong) id object;

/**
 * The index of this item
 */
@property (nonatomic, readonly) NSInteger index;

/**
 * Whether to display the index in hexadecimal format
 */
@property (nonatomic, readonly) BOOL hex;

// MARK: - Class Properties

/**
 * Returns/Sets the lowest Number used for the Index
 */
@property (class, nonatomic, assign) NSInteger offset;

// MARK: - Initialization

/**
 * Creates a new CountedListItem
 * @param index The index for this item
 * @param object The object to store
 * @param hex Whether to display index in hex format
 */
- (instancetype)initWithIndex:(NSInteger)index object:(id)object hex:(BOOL)hex;

// MARK: - Convenience Methods for NSComboBox

/**
 * Adds an Item to the given NSComboBox
 * @param comboBox The NSComboBox
 * @param object The Item you want to add
 */
+ (void)addToComboBox:(NSComboBox *)comboBox object:(id)object;

/**
 * Adds an Item to the given NSComboBox with hex formatting
 * @param comboBox The NSComboBox
 * @param object The Item you want to add
 */
+ (void)addHexToComboBox:(NSComboBox *)comboBox object:(id)object;

// MARK: - Convenience Methods for NSPopUpButton

/**
 * Adds an Item to the given NSPopUpButton
 * @param popUpButton The NSPopUpButton
 * @param object The Item you want to add
 */
+ (void)addToPopUpButton:(NSPopUpButton *)popUpButton object:(id)object;

/**
 * Adds an Item to the given NSPopUpButton with hex formatting
 * @param popUpButton The NSPopUpButton
 * @param object The Item you want to add
 */
+ (void)addHexToPopUpButton:(NSPopUpButton *)popUpButton object:(id)object;

// MARK: - Convenience Methods for NSTableView (via array)

/**
 * Adds an Item to the given array (for use with NSTableView data sources)
 * @param array The mutable array to add to
 * @param object The Item you want to add
 */
+ (void)addToArray:(NSMutableArray *)array object:(id)object;

/**
 * Adds an Item to the given array with hex formatting
 * @param array The mutable array to add to
 * @param object The Item you want to add
 */
+ (void)addHexToArray:(NSMutableArray *)array object:(id)object;

@end
