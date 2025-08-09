//
//  Containers.h
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

// MARK: - IntArrayList

/**
 * Type-safe ArrayList for int Objects
 */
@interface IntArrayList : NSMutableArray

/**
 * Integer Indexer - get value at index
 */
- (int)intAtIndex:(NSUInteger)index;

/**
 * Integer Indexer - set value at index
 */
- (void)setInt:(int)value atIndex:(NSUInteger)index;

/**
 * Unsigned Integer Indexer - get value at index
 */
- (int)intAtUnsignedIndex:(uint32_t)index;

/**
 * Unsigned Integer Indexer - set value at index
 */
- (void)setInt:(int)value atUnsignedIndex:(uint32_t)index;

/**
 * Add a new Element
 * @param item The int value you want to add
 * @returns The index it was added at
 */
- (NSUInteger)addInt:(int)item;

/**
 * Insert a new Element
 * @param index The Index where the Element should be stored
 * @param item The int value that should be inserted
 */
- (void)insertInt:(int)item atIndex:(NSUInteger)index;

/**
 * Remove an Element
 * @param item The int value that should be removed
 */
- (void)removeInt:(int)item;

/**
 * Checks whether or not the int value is already stored in the List
 * @param item The int value you are looking for
 * @returns YES if it was found
 */
- (BOOL)containsInt:(int)item;

/**
 * Number of stored Elements
 */
@property (nonatomic, readonly) NSUInteger length;

/**
 * Create a clone of this Object
 * @returns The clone
 */
- (IntArrayList *)clone;

@end

// MARK: - StringArrayList

/**
 * Type-safe ArrayList for string Objects
 */
@interface StringArrayList : NSMutableArray

/**
 * String Indexer - get value at index
 */
- (NSString *)stringAtIndex:(NSUInteger)index;

/**
 * String Indexer - set value at index
 */
- (void)setString:(NSString *)value atIndex:(NSUInteger)index;

/**
 * Unsigned Integer Indexer - get value at index
 */
- (NSString *)stringAtUnsignedIndex:(uint32_t)index;

/**
 * Unsigned Integer Indexer - set value at index
 */
- (void)setString:(NSString *)value atUnsignedIndex:(uint32_t)index;

/**
 * Add a new Element
 * @param item The string you want to add
 * @returns The index it was added at
 */
- (NSUInteger)addString:(NSString *)item;

/**
 * Insert a new Element
 * @param index The Index where the Element should be stored
 * @param item The string that should be inserted
 */
- (void)insertString:(NSString *)item atIndex:(NSUInteger)index;

/**
 * Remove an Element
 * @param item The string that should be removed
 */
- (void)removeString:(NSString *)item;

/**
 * Checks whether or not the string is already stored in the List
 * @param item The string you are looking for
 * @returns YES if it was found
 */
- (BOOL)containsString:(NSString *)item;

/**
 * Number of stored Elements
 */
@property (nonatomic, readonly) NSUInteger length;

/**
 * Create a clone of this Object
 * @returns The clone
 */
- (StringArrayList *)clone;

@end
