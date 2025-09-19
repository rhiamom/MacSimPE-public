//
//  Scenegraph.h
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

@class GeneratableFile;
@class GenericRcol;
@class CloneSettings;
@class MmatCacheFile;
@class PackedFileDescriptor;
@class MmatWrapper;
@class Cpf;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IScenegraphFileIndexItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class builds the SceneGraph Chain based on a modelname
 */
@interface Scenegraph : NSObject

// MARK: - Class Properties

/**
 * A List of Files you the Reference Check should exclude
 */
@property (class, nonatomic, strong) NSMutableArray<NSString *> *fileExcludeList;

/**
 * The Default List for FileExcludeList
 */
@property (class, nonatomic, readonly, strong) NSArray<NSString *> *defaultFileExcludeList;

// MARK: - Instance Properties

/**
 * Contains the base Modelnames
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *modelnames;

/**
 * Contains all found Files
 */
@property (nonatomic, strong, readonly) NSMutableArray<GenericRcol *> *files;

/**
 * All loaded Items
 */
@property (nonatomic, strong, readonly) NSMutableArray<id<IScenegraphFileIndexItem>> *itemlist;

/**
 * Returns a List of a References that should be excluded
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *excludedReferences;

// MARK: - Initialization

/**
 * Create a new Instance and build the CRES chain
 * @param modelname Name of the Model
 */
- (instancetype)initWithModelname:(NSString *)modelname;

/**
 * Create a new Instance and build the CRES chain
 * @param modelnames Array of Model names
 */
- (instancetype)initWithModelnames:(NSArray<NSString *> *)modelnames;

/**
 * Create a new Instance and build the CRES chain
 * @param modelnames Array of Model names
 * @param excludeList List of all ReferenceNames that should be excluded from the chain
 * @param settings Clone settings
 */
- (instancetype)initWithModelnames:(NSArray<NSString *> *)modelnames
                       excludeList:(NSArray<NSString *> *)excludeList
                          settings:(CloneSettings *)settings;

/**
 * Initialize the scenegraph with given parameters
 * @param modelnames Array of Model names
 * @param excludeList List of all ReferenceNames that should be excluded from the chain
 */
- (void)initWithModelnames:(NSArray<NSString *> *)modelnames excludeList:(NSArray<NSString *> *)excludeList;

// MARK: - Static Utility Methods

/**
 * Create a clone of the Descriptor, so changes won't affect the source Package anymore!
 * @param item Clone the Descriptor in this Item
 */
+ (void)cloneDescriptorForItem:(id<IScenegraphFileIndexItem>)item;

/**
 * Create a clone of the Descriptor, so changes won't affect the source Package anymore!
 * @param original The original descriptor to clone
 * @returns Cloned PackedFileDescriptor
 */
+ (PackedFileDescriptor *)cloneDescriptor:(id<IPackedFileDescriptor>)original;

/**
 * Return all Modelnames that can be found in this package
 * @param package The Package you want to scan
 * @returns Array of Modelnames
 */
+ (NSArray<NSString *> *)findModelNames:(id<IPackageFile>)package;

/**
 * Returns a unique identifier for the MMAT Files
 * @param mmat The MMAT file
 * @returns Unique content identifier
 */
+ (NSString *)mmatContent:(Cpf *)mmat;

/**
 * Loads Slave TXMTs by name Replacement
 * @param package The package File with the base TXMTs
 * @param slaves The Dictionary holding all Slave Subsets
 */
+ (void)addSlaveTxmts:(id<IPackageFile>)package slaves:(NSDictionary *)slaves;

/**
 * Will return an Array of all SubSets that can be recolored
 * @param package The package to scan
 * @returns Array of Subset Names
 */
+ (NSArray<NSString *> *)getRecolorableSubsets:(id<IPackageFile>)package;

/**
 * Will return an Array of all SubSets that are borrowed from a Parent Object
 * @param package The package to scan
 * @returns Array of Subset Names
 */
+ (NSArray<NSString *> *)getParentSubsets:(id<IPackageFile>)package;

/**
 * Will return an Array of all SubSets based on block name
 * @param package The package to scan
 * @param blockname The block name to search for
 * @returns Array of Subset Names
 */
+ (NSArray<NSString *> *)getSubsets:(id<IPackageFile>)package blockname:(nullable NSString *)blockname;

/**
 * Will return a Dictionary (key = subset name) of Arrays (slave subset names)
 * @param package The package to scan
 * @returns The Dictionary
 */
+ (NSDictionary<NSString *, NSArray<NSString *> *> *)getSlaveSubsets:(id<IPackageFile>)package;

/**
 * Return a Dictionary (subset) of Dictionary (family) of Arrays (mmat Files) specifying all available Material Overrides
 * @param package The package you want to scan
 * @returns The Dictionary
 */
+ (NSDictionary *)getMmatMap:(id<IPackageFile>)package;

/**
 * Loads the ModelNames of the Objects referenced in all tsMaterialsMeshName Block
 * @param package The package to scan
 * @param shouldDelete true, if the tsMaterialsMeshName Blocks should get cleared
 * @returns Array of Modelnames
 */
+ (NSArray<NSString *> *)loadParentModelNames:(id<IPackageFile>)package delete:(BOOL)shouldDelete;

/**
 * Create a package based on the collected Files
 * @param files Array of files to add
 * @param package Target package
 */
+ (void)buildPackage:(NSArray<GenericRcol *> *)files package:(id<IPackageFile>)package;

// MARK: - Instance Methods

/**
 * Loads Slave TXMTs by name Replacement
 * @param slaves The Dictionary holding all Slave Subsets
 */
- (void)addSlaveTxmts:(NSDictionary *)slaves;

/**
 * Will return a Dictionary (key = subset name) of Arrays (slave subset names)
 * @returns The Dictionary
 */
- (NSDictionary<NSString *, NSArray<NSString *> *> *)getSlaveSubsets;

/**
 * Adds all known MMATs that reference one of the models
 * @param package The package to add to
 * @param onlyDefault true, if you only want to read default MMATS
 * @param subitems true, if you also want to load MMAT Files that reference Files outside the passed package
 * @param shouldThrowException true if you want to throw an exception when something goes wrong
 */
- (void)addMaterialOverrides:(id<IPackageFile>)package
                 onlyDefault:(BOOL)onlyDefault
                    subitems:(BOOL)subitems
                   exception:(BOOL)shouldThrowException;

/**
 * Add Wallmasks (if available) to the Clone
 * @param modelnames Array of model names
 */
- (void)addWallmasks:(NSArray<NSString *> *)modelnames;

/**
 * Add Anim Resources (if available) to the Clone
 * @param names Array of animation names
 */
- (void)addAnims:(NSArray<NSString *> *)names;

/**
 * Add Resources referenced from 3IDR Files
 * @param package The package to scan
 */
- (void)addFrom3IDR:(id<IPackageFile>)package;

/**
 * Add Resources referenced from XML Files
 * @param package The package to scan
 */
- (void)addFromXml:(id<IPackageFile>)package;

/**
 * Add String-linked resources to the Clone
 * @param package The package to scan
 * @param instances Array of string instance aliases
 */
- (void)addStrLinked:(id<IPackageFile>)package instances:(NSArray *)instances;

/**
 * Create a package based on the collected Files
 * @returns Generated package file
 */
- (GeneratableFile *)buildPackage;

/**
 * Create a package based on the collected Files
 * @param package Target package to populate
 */
- (void)buildPackage:(id<IPackageFile>)package;

@end

NS_ASSUME_NONNULL_END
