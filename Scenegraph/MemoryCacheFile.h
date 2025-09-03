//
//  MemoryCacheFile.h
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
#import "CacheFile.h"

@class FileIndex, MemoryCacheItem, ExtObjd;
@protocol IScenegraphFileIndex, IScenegraphFileIndexItem, IAlias;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains an Instance of a CacheFile for Memory Objects
 */
@interface MemoryCacheFile : CacheFile

// MARK: - Class Methods

/**
 * Updates and Loads the Memory Cache
 * @return Initialized MemoryCacheFile instance
 */
+ (MemoryCacheFile *)initCacheFile;

/**
 * Updates and Loads the Memory Cache
 * @param fileIndex The file index to use for cache initialization
 * @return Initialized MemoryCacheFile instance
 */
+ (MemoryCacheFile *)initCacheFile:(id<IScenegraphFileIndex>)fileIndex;

// MARK: - Properties

/**
 * Return a Map of all cached Memory Items (GUID -> MemoryCacheItem)
 */
@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, MemoryCacheItem *> *map;

/**
 * Return a List of all cached Memory Items
 */
@property (nonatomic, strong, readonly) NSArray<MemoryCacheItem *> *list;

/**
 * Return the FileIndex represented by the Cached Files
 */
@property (nonatomic, strong, readonly) FileIndex *fileIndex;

// MARK: - Initialization

/**
 * Create a new Instance for an empty File
 */
- (instancetype)init;

// MARK: - Cache Management

/**
 * Reload the cache using the default file index
 */
- (void)reloadCache;

/**
 * Reload the cache using the default file index
 * @param save Whether to save the cache after reloading
 */
- (void)reloadCacheWithSave:(BOOL)save;

/**
 * Reload the cache using the specified file index
 * @param fileIndex The file index to use for reloading
 * @param save Whether to save the cache after reloading
 */
- (void)reloadCache:(id<IScenegraphFileIndex>)fileIndex save:(BOOL)save;

// MARK: - Item Management

/**
 * Add an Object Data File to the Cache
 * @param objd The Object Data File
 * @return The created MemoryCacheItem
 */
- (MemoryCacheItem *)addItem:(ExtObjd *)objd;

// MARK: - Data Loading

/**
 * Creates the Map (GUID -> MemoryCacheItem lookup)
 * @remarks The Tags of the FileDescriptions contain the MemoryCacheItem Object,
 * the FileNames of the FileDescriptions contain the Name of the package File
 */
- (void)loadMem;

/**
 * Creates the List of all cached items
 * @remarks The Tags of the FileDescriptions contain the MemoryCacheItem Object,
 * the FileNames of the FileDescriptions contain the Name of the package File
 */
- (void)loadMemList;

/**
 * Creates a FileIndex with all available Memory Files
 * @remarks The Tags of the FileDescriptions contain the MemoryCacheItem Object,
 * the FileNames of the FileDescriptions contain the Name of the package File
 */
- (void)loadMemTable;

// MARK: - Item Lookup

/**
 * Returns a MemoryCacheItem for the given GUID
 * @param guid The GUID to search for
 * @return The MemoryCacheItem if found, nil otherwise
 */
- (nullable MemoryCacheItem *)findItem:(uint32_t)guid;

/**
 * Returns an Alias for the given GUID
 * @param guid The GUID to search for
 * @return An IAlias object representing the found item or unknown item
 */
- (id<IAlias>)findObject:(uint32_t)guid;

@end

NS_ASSUME_NONNULL_END
