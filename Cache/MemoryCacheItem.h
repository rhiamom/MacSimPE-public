//
//  MemoryCacheItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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
#import <AppKit/AppKit.h>
#import "ICacheItem.h"
#import "MetaData.h"

@protocol IPackedFileDescriptor;
@class BinaryReader, BinaryWriter, PackedFileDescriptor, CacheContainer;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains one ObjectCacheItem
 */
@interface MemoryCacheItem : NSObject <ICacheItem>

// MARK: - Constants

/**
 * The current Version
 */
extern const uint8_t MEMORY_CACHE_ITEM_VERSION;

/**
 * Discard versions smaller than this
 */
extern const uint8_t MEMORY_CACHE_ITEM_DISCARD_VERSIONS_SMALLER_THAN;

// MARK: - Properties

/**
 * Returns an (unitialized) FileDescriptor
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * The GUID of this cache item
 */
@property (nonatomic, assign) uint32_t guid;

/**
 * The object type
 */
@property (nonatomic, assign) ObjectTypes objectType;

/**
 * The name of the object
 */
@property (nonatomic, copy) NSString *name;

/**
 * Array of value names
 */
@property (nonatomic, strong) NSArray<NSString *> *valueNames;

/**
 * The object definition name
 */
@property (nonatomic, copy, nullable) NSString *objdName;

/**
 * The icon image (can be null)
 */
@property (nonatomic, strong, nullable) NSImage *icon;

/**
 * Returns the loaded icon, or an empty image if no icon was found
 */
@property (nonatomic, strong, readonly) NSImage *image;

/**
 * The parent cache container
 */
@property (nonatomic, weak, nullable) CacheContainer *parentCacheContainer;

/**
 * The version of this cache item
 */
@property (nonatomic, readonly, assign) uint8_t version;

// MARK: - Object Classification Properties

/**
 * Returns true if this is a token object
 */
@property (nonatomic, readonly, assign) BOOL isToken;

/**
 * Returns true if this is job data
 */
@property (nonatomic, readonly, assign) BOOL isJobData;

/**
 * Returns true if this is a memory object
 */
@property (nonatomic, readonly, assign) BOOL isMemory;

/**
 * Returns true if this is a badge
 */
@property (nonatomic, readonly, assign) BOOL isBadge;

/**
 * Returns true if this is skill-related
 */
@property (nonatomic, readonly, assign) BOOL isSkill;

/**
 * Returns true if this is an aspiration
 */
@property (nonatomic, readonly, assign) BOOL isAspiration;

/**
 * Returns true if this is an inventory item
 */
@property (nonatomic, readonly, assign) BOOL isInventory;

// MARK: - Initialization

/**
 * Creates a new MemoryCacheItem
 */
- (instancetype)init;

// MARK: - ICacheItem Protocol

/**
 * Load cache item from binary reader
 * @param reader The binary reader to load from
 */
- (void)load:(BinaryReader *)reader;

/**
 * Save cache item to binary writer
 * @param writer The binary writer to save to
 */
- (void)save:(BinaryWriter *)writer;

// MARK: - String Representation

/**
 * Returns string description of the cache item
 */
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
