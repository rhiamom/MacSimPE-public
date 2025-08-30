//
//  CacheContainer.h
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

@class BinaryReader, BinaryWriter, CacheItems;

/**
 * What type have the items stored in the container
 */
typedef NS_ENUM(uint8_t, ContainerType) {
    ContainerTypeNone = 0x00,
    ContainerTypeObject = 0x01,
    ContainerTypeMaterialOverride = 0x02,
    ContainerTypeWant = 0x03,
    ContainerTypeMemory = 0x04,
    ContainerTypePackage = 0x05,
    ContainerTypeRcol = 0x06
};

/**
 * Detailed Information about the Valid State of the Container
 */
typedef NS_ENUM(uint8_t, ContainerValid) {
    ContainerValidYes = 0x04,
    ContainerValidFileNotFound = 0x01,
    ContainerValidModified = 0x02,
    ContainerValidUnknownVersion = 0x03
};

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains one or more CacheItems
 */
@interface CacheContainer : NSObject

// MARK: - Constants

/**
 * The current Version
 */
extern const uint8_t CACHE_CONTAINER_VERSION;

// MARK: - Properties

/**
 * Returns the Version of the File
 */
@property (nonatomic, readonly, assign) uint8_t version;

/**
 * Returns the Date when this container was added
 */
@property (nonatomic, assign) NSTimeInterval added;

/**
 * Return all available Items
 */
@property (nonatomic, strong, readonly) CacheItems *items;

/**
 * Returns the Type of this Container
 */
@property (nonatomic, readonly, assign) ContainerType type;

/**
 * True if this Container is still valid
 */
@property (nonatomic, readonly, assign) BOOL valid;

/**
 * Returns the detailed valid state
 */
@property (nonatomic, readonly, assign) ContainerValid validState;

/**
 * Return the Name of the File this Container was used for
 */
@property (nonatomic, copy) NSString *fileName;

// MARK: - Initialization

/**
 * Create a new Instance
 * @param type The container type
 */
- (instancetype)initWithType:(ContainerType)type;

// MARK: - File Operations

/**
 * Load the Container from the Stream
 * @param reader the Stream Reader
 */
- (void)load:(BinaryReader *)reader;

/**
 * Save the Container to the Stream
 * @param writer the Stream Writer
 * @param offset the offset for writing (-1 for prewrite phase)
 */
- (void)save:(BinaryWriter *)writer offset:(int32_t)offset;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end

NS_ASSUME_NONNULL_END
