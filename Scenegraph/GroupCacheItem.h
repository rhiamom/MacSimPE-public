//
//  GroupCacheItem.h
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
// ***************************************************************************/

#import <Foundation/Foundation.h>

@class BinaryReader, BinaryWriter;

// Forward declaration for protocol (would be defined elsewhere)
@protocol IGroupCacheItem <NSObject>

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) uint32_t localGroup;

@end

/**
 * This is the actual FileWrapper for GroupCache items
 */
@interface GroupCacheItem : NSObject <IGroupCacheItem>

// MARK: - Properties

/**
 * Returns the FileName for this Item
 */
@property (nonatomic, copy) NSString *fileName;

/**
 * Returns the Group that was assigned by the Game
 */
@property (nonatomic, assign) uint32_t localGroup;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Serialization Methods

/**
 * Unserializes a BinaryReader into the Attributes of this Instance
 * @param reader The Reader that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryWriter
 * @param writer The Writer the Data should be stored to
 * @remarks
 * Be sure that the Position of the stream is Proper on
 * return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - String Representation

/**
 * Returns a string representation of this GroupCacheItem
 */
- (NSString *)description;

@end

// MARK: - GroupCacheItems Collection

/**
 * Type-safe NSMutableArray for GroupCacheItem Objects
 */
@interface GroupCacheItems : NSMutableArray<GroupCacheItem *>

// MARK: - Typed Accessors

/**
 * Get/set item at index
 */
- (GroupCacheItem *)objectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(GroupCacheItem *)item;

/**
 * Get/set item at uint32_t index
 */
- (GroupCacheItem *)objectAtUIntIndex:(uint32_t)index;
- (void)replaceObjectAtUIntIndex:(uint32_t)index withObject:(GroupCacheItem *)item;

// MARK: - Collection Operations

/**
 * Add item to collection
 * @param item The GroupCacheItem to add
 * @return The index where the item was added
 */
- (NSInteger)addItem:(GroupCacheItem *)item;

/**
 * Insert item at specific index
 * @param index The index to insert at
 * @param item The GroupCacheItem to insert
 */
- (void)insertItem:(GroupCacheItem *)item atIndex:(NSUInteger)index;

/**
 * Remove specific item
 * @param item The GroupCacheItem to remove
 */
- (void)removeItem:(GroupCacheItem *)item;

/**
 * Check if collection contains item
 * @param item The GroupCacheItem to check for
 * @return YES if the item is in the collection
 */
- (BOOL)containsItem:(GroupCacheItem *)item;

// MARK: - Properties

/**
 * Returns the length of the collection (alias for count)
 */
@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying

/**
 * Create a deep copy of this collection
 */
- (id)clone;

@end
