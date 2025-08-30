//
//  SlotItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/29/25.
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

@class BinaryReader, BinaryWriter, Slot;

NS_ASSUME_NONNULL_BEGIN

/**
 * Known Types for Slot Items
 */
typedef NS_ENUM(uint16_t, SlotItemType) {
    SlotItemTypeContainer = 0,
    SlotItemTypeLocation = 1,
    SlotItemTypeUnknown = 2,
    SlotItemTypeRouting = 3,
    SlotItemTypeTarget = 4
};

/**
 * Contains a Slot Item
 */
@interface SlotItem : NSObject

// MARK: - Properties

/**
 * The type of this slot item
 */
@property (nonatomic, assign) SlotItemType type;

/**
 * The parent slot object
 */
@property (nonatomic, weak, readonly) Slot *parent;

/**
 * Unknown float values
 */
@property (nonatomic, assign) float unknownFloat1;
@property (nonatomic, assign) float unknownFloat2;
@property (nonatomic, assign) float unknownFloat3;
@property (nonatomic, assign) float unknownFloat4;
@property (nonatomic, assign) float unknownFloat5;
@property (nonatomic, assign) float unknownFloat6;
@property (nonatomic, assign) float unknownFloat7;
@property (nonatomic, assign) float unknownFloat8;

/**
 * Unknown integer values
 */
@property (nonatomic, assign) int32_t unknownInt1;
@property (nonatomic, assign) int32_t unknownInt2;
@property (nonatomic, assign) int32_t unknownInt3;
@property (nonatomic, assign) int32_t unknownInt4;
@property (nonatomic, assign) int32_t unknownInt5;
@property (nonatomic, assign) int32_t unknownInt6;
@property (nonatomic, assign) int32_t unknownInt7;
@property (nonatomic, assign) int32_t unknownInt8;
@property (nonatomic, assign) int32_t unknownInt9;
@property (nonatomic, assign) int32_t unknownInt10;

/**
 * Unknown short values
 */
@property (nonatomic, assign) int16_t unknownShort1;
@property (nonatomic, assign) int16_t unknownShort2;

// MARK: - Initialization

/**
 * Initialize with parent slot
 * @param parent The parent Slot object
 */
- (instancetype)initWithParent:(Slot *)parent;

// MARK: - Serialization

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @param parent The parent Slot object for version checking
 * @remarks Be sure that the Position of the stream is Proper on return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer parent:(Slot *)parent;

// MARK: - Description

- (NSString *)description;

@end

/**
 * Type-safe NSMutableArray for SlotItem Objects
 */
@interface SlotItems : NSMutableArray<SlotItem *>

// MARK: - Indexed Access
- (SlotItem *)objectAtIndex:(NSUInteger)index;
- (SlotItem *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(SlotItem *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(SlotItem *)object;

// MARK: - Collection Operations
- (void)addSlotItem:(SlotItem *)item;
- (void)insertSlotItem:(SlotItem *)item atIndex:(NSUInteger)index;
- (void)removeSlotItem:(SlotItem *)item;
- (BOOL)containsSlotItem:(SlotItem *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSUInteger length;

// MARK: - Copying
- (instancetype)deepCopy;

@end

NS_ASSUME_NONNULL_END
