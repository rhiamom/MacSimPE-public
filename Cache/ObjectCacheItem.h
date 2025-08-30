//
//  ObjectCacheItem.h
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
#import <AppKit/AppKit.h>
#import "ICacheItem.h"
#import "MetaData.h"

@class BinaryReader, BinaryWriter, PackedFileDescriptor, MemoryStream;
@protocol IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 * What general class is the Object in
 */
typedef NS_ENUM(uint8_t, ObjectClass) {
    /**
     * It is a real Object (OBJd-Based)
     */
    ObjectClassObject = 0x00,
    /**
     * It something like a Skin (cpf based)
     */
    ObjectClassSkin = 0x01,
    /**
     * Wallpapers, Floors, Fences
     */
    ObjectClassXObject = 0x02
};

typedef NS_ENUM(uint8_t, ObjectCacheItemVersions) {
    ObjectCacheItemVersionsOutdated = 0x00,
    ObjectCacheItemVersionsClassicOW = 0x03,
    ObjectCacheItemVersionsDockableOW = 0x04,
    ObjectCacheItemVersionsUnsupported = 0xff
};

// Forward declarations for category function parameters
typedef NS_ENUM(uint32_t, ObjFunctionSubSort);
typedef NS_ENUM(uint32_t, XObjFunctionSubSort);

/**
 * Contains one ObjectCacheItem
 */
@interface ObjectCacheItem : NSObject <ICacheItem>

// MARK: - Constants

/**
 * The current Version
 */
extern const uint8_t OBJECT_CACHE_ITEM_VERSION;

// MARK: - Properties

/**
 * User-defined tag object
 */
@property (nonatomic, strong, nullable) id tag;

/**
 * Returns the version information as enum
 */
@property (nonatomic, readonly) ObjectCacheItemVersions objectVersion;

/**
 * Returns an (uninitialized) FileDescriptor
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * Returns the Type Field of the Object
 */
@property (nonatomic, assign) ObjectTypes objectType;

/**
 * The class the Object is assigned to
 */
@property (nonatomic, assign) ObjectClass objectClass;

/**
 * Returns the FunctionSort Field of the Object
 */
@property (nonatomic, assign) uint32_t objectFunctionSort;

/**
 * Returns the LocalGroup
 */
@property (nonatomic, assign) uint32_t localGroup;

/**
 * Returns the Name of this Object
 */
@property (nonatomic, copy) NSString *name;

/**
 * Returns the Name of this Object
 */
@property (nonatomic, copy) NSString *objectFileName;

/**
 * Returns the Name of this Object
 */
@property (nonatomic, assign) BOOL useable;

/**
 * Returns the ModeName for this Object
 */
@property (nonatomic, copy) NSString *modelName;

/**
 * Returns the Thumbnail
 */
@property (nonatomic, strong, nullable) NSImage *thumbnail;

/**
 * Returns the Category this Object should get sorted in
 */
@property (nonatomic, readonly) NSArray<NSArray<NSString *> *> *objectCategory;

// MARK: - Initialization

- (instancetype)init;

// MARK: - Category Methods

/**
 * Get category information for object classification
 * @param version The cache item version
 * @param subsort The function subsort value
 * @param type The object type
 * @return Array of string arrays representing category hierarchy
 */
+ (NSArray<NSArray<NSString *> *> *)getCategory:(ObjectCacheItemVersions)version
                                        subsort:(ObjFunctionSubSort)subsort
                                           type:(ObjectTypes)type;

/**
 * Get category information for object classification with class
 * @param version The cache item version
 * @param subsort The function subsort value
 * @param type The object type
 * @param objectClass The object class
 * @return Array of string arrays representing category hierarchy
 */
+ (NSArray<NSArray<NSString *> *> *)getCategory:(ObjectCacheItemVersions)version
                                        subsort:(ObjFunctionSubSort)subsort
                                           type:(ObjectTypes)type
                                    objectClass:(ObjectClass)objectClass;

// MARK: - Description

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
