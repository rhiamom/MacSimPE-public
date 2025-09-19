//
//  ObjectCloner.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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
#import "Alias.h"

@protocol IPackageFile;
@protocol IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

// MARK: - Enums

/**
 * Base resource types for cloning
 */
typedef NS_OPTIONS(uint8_t, BaseResourceType) {
    BaseResourceTypeObjd = 0x01,
    BaseResourceTypeRef = 0x02,
    BaseResourceTypeXml = 0x04
};

// MARK: - StrInstanceAlias

/**
 * Alias for string instance references
 */
@interface StrInstanceAlias : Alias

/**
 * The file type
 */
@property (nonatomic, readonly, assign) uint32_t type;

/**
 * The instance ID
 */
@property (nonatomic, readonly, assign) uint32_t instance;

/**
 * The file extension
 */
@property (nonatomic, readonly, copy) NSString *extension;

/**
 * Create a new string instance alias
 * @param instance The instance ID
 * @param type The file type
 * @param extension The file extension
 */
- (instancetype)initWithInstance:(uint32_t)instance type:(uint32_t)type extension:(NSString *)extension;

@end

// MARK: - CloneSettings

/**
 * Determines the basic Settings for the ObjectCloner
 */
@interface CloneSettings : NSObject

// MARK: - Resource Options

/**
 * Base resource types to include
 */
@property (nonatomic, assign) BaseResourceType baseResource;

/**
 * If true, do not include the Mesh Data into the package
 */
@property (nonatomic, assign) BOOL keepOriginalMesh;

/**
 * If true, the clone should include Wallmasks
 */
@property (nonatomic, assign) BOOL includeWallmask;

/**
 * If true, only include default MMAT Files
 */
@property (nonatomic, assign) BOOL onlyDefaultMmats;

/**
 * Update the GUIDs in the MMAT Files
 */
@property (nonatomic, assign) BOOL updateMmatGuids;

/**
 * If true, throw an exception when something goes wrong
 */
@property (nonatomic, assign) BOOL throwExceptions;

/**
 * If true, Animation Resources should be included in the package
 */
@property (nonatomic, assign) BOOL includeAnimationResources;

/**
 * If true, check all Str resources with the instance listed in strInstances
 * and pull all Resources linked from there too
 */
@property (nonatomic, assign) BOOL pullResourcesByStr;

/**
 * The Instances of StrResources, that can contain valid Links to Scenegraph Resources
 */
@property (nonatomic, strong) NSArray<StrInstanceAlias *> *strInstances;

/**
 * Create a new Instance and set everything to default
 */
- (instancetype)init;

@end

// MARK: - ObjectCloner

/**
 * This Class provides Methods to clone ingame Objects
 */
@interface ObjectCloner : NSObject

/**
 * The Base Package
 */
@property (nonatomic, strong, readonly) id<IPackageFile> package;

/**
 * The Settings for this Cloner
 */
@property (nonatomic, strong) CloneSettings *setup;

// MARK: - Initialization

/**
 * Creates a new Instance based on an existing Package
 * @param package The Package that should receive the Clone
 */
- (instancetype)initWithPackage:(id<IPackageFile>)package;

/**
 * Creates a new Instance and a new Package
 */
- (instancetype)init;

// MARK: - Static Utility Methods

/**
 * Find the second MMAT that matches the state
 * @param name The material name
 * @param package The package to search in
 * @returns Array of matching file descriptors
 */
+ (NSArray<id<IPackedFileDescriptor>> *)findStateMatchingMatd:(NSString *)name package:(id<IPackageFile>)package;

// MARK: - GUID Management

/**
 * Returns the Primary Guid of the Object
 * @returns 0 or the default guid
 */
- (uint32_t)getPrimaryGuid;

/**
 * Load a List of all available GUIDs in the package
 * @returns Array of GUIDs as NSNumber objects
 */
- (NSArray<NSNumber *> *)getGuidList;

/**
 * Updates the MMAT GUIDs
 * @param guids Array of allowed GUIDS
 * @param primary The guid you want to use if the guid was not allowed
 */
- (void)updateMmatGuids:(NSArray<NSNumber *> *)guids primary:(uint32_t)primary;

// MARK: - Model Cloning

/**
 * Clone a InGame Object based on the relations of the RCOL Files
 * @param modelname The Name of the Model
 */
- (void)rcolModelClone:(NSString *)modelname;

/**
 * Clone a InGame Object based on the relations of the RCOL Files
 * @param modelnames Array of Model names
 */
- (void)rcolModelClone:(NSArray<NSString *> *)modelnames;

/**
 * Clone a InGame Object based on the relations of the RCOL Files
 * @param modelnames Array of Model names
 * @param exclude Array of ReferenceNames that should be excluded
 */
- (void)rcolModelClone:(NSArray<NSString *> *)modelnames exclude:(NSArray<NSString *> *)exclude;

// MARK: - Name Extraction

/**
 * Returns an Array of all stored names from string files
 * @param instances Instances of TextLists that should be searched
 * @param extension Extension (in lowercase) that should be added (can be nil for none)
 * @returns Array of found Names
 */
- (NSArray<NSString *> *)getNames:(NSArray<NSNumber *> *)instances extension:(nullable NSString *)extension;

/**
 * Returns an Array of all stored Anim Resources
 * @returns Array of animation names
 */
- (NSArray<NSString *> *)getAnimNames;

// MARK: - Parent File Management

/**
 * Add all Files that could be borrowed from the current package by the passed one, to the passed package
 * @param orgModelnames Array of available modelnames in this package
 * @param targetPackage The package that should receive the Files
 * @remarks Simply Copies MMAT, LIFO, TXTR and TXMT Files
 */
- (void)addParentFiles:(NSArray<NSString *> *)orgModelnames package:(id<IPackageFile>)targetPackage;

/**
 * Remove all Files that are referenced by a SHPE and belong to a subset as named in the exclude List
 * @param exclude Array of subset names
 * @param modelnames nil or an Array of allowed Modelnames. If an Array is passed, only references to files
 * starting with one of the passed Modelnames will be kept
 */
- (void)removeSubsetReferences:(NSArray<NSString *> *)exclude modelnames:(nullable NSArray<NSString *> *)modelnames;

@end

NS_ASSUME_NONNULL_END
