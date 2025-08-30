//
//  CacheFile.h
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
#import "ICacheFileTest.h"

@class CacheContainers, CacheContainer;

// Forward declarations for enums
typedef NS_ENUM(uint8_t, ContainerType) {
    ContainerTypeNone = 0x00,
    ContainerTypeObject = 0x01,
    ContainerTypeMaterialOverride = 0x02,
    ContainerTypeWant = 0x03,
    ContainerTypeMemory = 0x04,
    ContainerTypePackage = 0x05,
    ContainerTypeRcol = 0x06
};

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains an Instance of a CacheFile
 */
@interface CacheFile : NSObject <ICacheFileTest>

// MARK: - Constants

/**
 * This is the 64-Bit Int, a cache File needs to start with
 */
extern const uint64_t CACHE_FILE_SIGNATURE;

/**
 * The current Version
 */
extern const uint8_t CACHE_FILE_VERSION;

// MARK: - Properties

/**
 * Returns the Version of the File
 */
@property (nonatomic, readonly, assign) uint8_t version;

/**
 * The last used FileName (can be null)
 */
@property (nonatomic, readonly, copy, nullable) NSString *fileName;

/**
 * Returns all Available Containers
 */
@property (nonatomic, strong, readonly) CacheContainers *containers;

/**
 * The default type for this container
 */
@property (nonatomic, assign) ContainerType defaultType;

// MARK: - Initialization

/**
 * Create a new Instance for an empty File
 */
- (instancetype)init;

// MARK: - File Operations

/**
 * Load a Cache File from the Disk
 * @param filename the name of the File
 * @exception CacheException Thrown if the File is not readable (ie, wrong Version or Signature)
 */
- (void)load:(NSString *)filename;

/**
 * Load a Cache File from the Disk
 * @param filename the name of the File
 * @param withProgress true if you want to set the Progress in the current Wait control
 * @exception CacheException Thrown if the File is not readable (ie, wrong Version or Signature)
 */
- (void)load:(NSString *)filename withProgress:(BOOL)withProgress;

/**
 * Save a Cache File to the Disk
 */
- (void)save;

/**
 * Save a Cache File to the Disk
 * @param filename the name of the File
 */
- (void)save:(NSString *)filename;

// MARK: - Container Management

/**
 * Returns a container for the passed type and File
 * @param containerType The Container Type
 * @param name The name of the File
 * @remarks If no container is Found, a new one will be created for this File and Type!
 */
- (CacheContainer *)useContainer:(ContainerType)containerType fileName:(NSString * _Nullable)name;

/**
 * Clean up invalid containers
 */
- (void)cleanUp;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end

NS_ASSUME_NONNULL_END
