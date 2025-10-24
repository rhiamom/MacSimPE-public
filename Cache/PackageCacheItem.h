//
//  PackageCacheItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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
#import "ICacheItem.h"

@class BinaryReader, BinaryWriter, PackageState, PackageStates;

NS_ASSUME_NONNULL_BEGIN

// MARK: - Enums

/**
 * Type of a Package
 */
typedef NS_OPTIONS(uint32_t, PackageType) {
    PackageTypeUndefined = 0x40,        /// This package was never scanned
    PackageTypeUnknown = 0x0,           /// The Package was scanned, but the Type is unknown
    PackageTypeSkin = 0x1,              /// The package contains a Skin
    PackageTypeWallpaper = 0x2,         /// The package contains a Wallpaper
    PackageTypeFloor = 0x4,             /// The package contains a Floor
    PackageTypeCloth = 0x8,             /// The package contains a Clothing
    PackageTypeObject = 0x10,           /// The package contains a Object or Clone
    PackageTypeRecolor = 0x20,          /// The package contains a Recolor
    PackageTypeMaxisObject = 0x80,      /// An Object probably created by Maxis
    PackageTypeCEP = 0x100,             /// A CEP Related File
    PackageTypeSim = 0x200,             /// A Sim or Sim Template
    PackageTypeHair = 0x1000,           /// Hairtones
    PackageTypeMakeup = 0x400,          /// Makeup for Sims
    PackageTypeAccessory = 0x800,
    PackageTypeEye = 0x401,
    PackageTypeBeard = 0x402,
    PackageTypeEyeBrow = 0x403,
    PackageTypeLipstick = 0x404,
    PackageTypeMask = 0x405,
    PackageTypeBlush = 0x406,
    PackageTypeEyeShadow = 0x407,
    PackageTypeGlasses = 0x801,
    PackageTypeNeighborhood = 0x2000,   /// Contains a Neighborhood
    PackageTypeLot = 0x4000,            /// Contains a Lot
    PackageTypeFence = 0x8000,          /// Describes a Fence
    PackageTypeRoof = 0x10000,          /// Describes a Roof
    PackageTypeTerrain = 0x20000        /// Describes TerrainPaint
};

/**
 * Adds the Null State to the Boolean states
 */
typedef NS_ENUM(uint8_t, TriState) {
    TriStateFalse = 0,
    TriStateTrue = 1,
    TriStateNull = 2
};

// MARK: - PackageState Class

/**
 * This class can give Informations about the State of a Package
 * You can save different informations along with a package file, each state (like contains duplicate GUID)
 * has its own uid. A TriState::Null means that the state was not investigated yet
 */
@interface PackageState : NSObject

// MARK: - Properties

@property (nonatomic, assign) uint32_t uid;
@property (nonatomic, assign) TriState state;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, strong) NSArray<NSNumber *> *data;

// MARK: - Initialization

- (instancetype)initWithUid:(uint32_t)uid state:(TriState)state info:(NSString *)info;
- (instancetype)init;

// MARK: - Serialization

- (void)load:(BinaryReader *)reader;
- (void)save:(BinaryWriter *)writer;

@end

// MARK: - PackageStates Collection

/**
 * Type-safe NSMutableArray for PackageState Objects
 */
@interface PackageStates : NSMutableArray<PackageState *>

// MARK: - Typed Accessors

- (PackageState *)objectAtIndex:(NSUInteger)index;
- (PackageState *)objectAtUnsignedIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(PackageState *)object;
- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(PackageState *)object;

// MARK: - Collection Operations

- (NSInteger)addPackageState:(PackageState *)item;
- (void)insertPackageState:(PackageState *)item atIndex:(NSUInteger)index;
- (void)removePackageState:(PackageState *)item;
- (BOOL)containsPackageState:(PackageState *)item;

// MARK: - Properties

@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying

- (id)clone;

@end

// MARK: - PackageCacheItem Class

/**
 * Contains one ObjectCacheItem
 */
@interface PackageCacheItem : NSObject <ICacheItem>

// MARK: - Constants

/**
 * The current Version
 */
@property (class, nonatomic, readonly, assign) uint8_t VERSION;

// MARK: - Properties

/**
 * Returns the Version
 */
@property (nonatomic, readonly, assign) uint8_t version;

/**
 * Array of GUIDs
 */
@property (nonatomic, strong) NSArray<NSNumber *> *guids;

/**
 * Package Type
 */
@property (nonatomic, assign) PackageType type;

/**
 * Package Name
 */
@property (nonatomic, copy) NSString *name;

/**
 * Thumbnail image
 */
@property (nonatomic, strong, nullable) NSImage *thumbnail;

/**
 * Package States
 */
@property (nonatomic, strong) PackageStates *states;

/**
 * Whether the package is enabled
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * Returns the number of states
 */
@property (nonatomic, readonly) NSInteger stateCount;

// MARK: - Initialization

- (instancetype)init;

// MARK: - State Management

/**
 * Returns a matching Item for the passed State-uid
 * @param uid the unique ID of the state
 * @param create true if you want to create a new state (and add it) if it did not exist
 * @returns The PackageState or nil if not found and create is NO
 */
- (nullable PackageState *)findState:(uint32_t)uid create:(BOOL)create;

// MARK: - ICacheItem Protocol Methods

- (void)load:(BinaryReader *)reader;
- (void)save:(BinaryWriter *)writer;

// MARK: - NSObject Overrides

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
