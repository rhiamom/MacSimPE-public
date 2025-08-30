//
//  MmatCacheItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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
#import "ICacheItem.h"

@protocol IPackedFileDescriptor;
@class BinaryReader, BinaryWriter, PackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains one ObjectCacheItem
 */
@interface MmatCacheItem : NSObject <ICacheItem>

// MARK: - Constants

/**
 * The current Version
 */
extern const uint8_t MMAT_CACHE_ITEM_VERSION;

// MARK: - Properties

/**
 * Returns an (unitialized) FileDescriptor
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * Returns the Type Field of the Object
 */
@property (nonatomic, assign) BOOL defaultMaterial;

/**
 * Returns the ModelName for this Object
 */
@property (nonatomic, copy) NSString *modelName;

/**
 * Returns the Familyname for this Object
 */
@property (nonatomic, copy) NSString *family;

/**
 * The version of this cache item
 */
@property (nonatomic, readonly, assign) uint8_t version;

// MARK: - Initialization

/**
 * Creates a new MmatCacheItem
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
