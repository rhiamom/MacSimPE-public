//
//  SimDescriptions.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/20/25.
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
#import "SimCommonPackage.h"
#import "ISimDescriptionProvider.h"

@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol ISDesc;
@protocol ISimNames;
@protocol ISimFamilyNames;
@class TraitAlias;
@class CollectibleAlias;
@class LinkedSDesc;

/**
 * Zusammenfassung für SimDescription.
 */
@interface SimDescriptions : SimCommonPackage <ISimDescriptions>

// MARK: - Properties

/**
 * Holds all Descriptions by SimId
 */
@property (nonatomic, strong) NSMutableDictionary *bySimId;

/**
 * Holds all Descriptions by Instance
 */
@property (nonatomic, strong) NSMutableDictionary *byInstance;

/**
 * Null or a Nameprovider
 */
@property (nonatomic, strong) id<ISimNames> names;

/**
 * Null or a FamilyName Provider
 */
@property (nonatomic, strong) id<ISimFamilyNames> famNames;

/**
 * Nightlife Turn On/Off data
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *turnOns;

/**
 * BonVoyage Vacation Collectibles data
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, CollectibleAlias *> *collectibles;

// MARK: - Initialization

/**
 * Creates the List for the specific Package
 * @param package The Base Package
 * @param names null or a valid SimNames Provider
 * @param famNames null or a valid SimFamilyNames Provider
 */
- (instancetype)initWithPackage:(id<IPackageFile>)package
                          names:(id<ISimNames>)names
                       famNames:(id<ISimFamilyNames>)famNames;

/**
 * Constructor
 * @param names null or a valid SimNames Provider
 * @param famNames null or a valid SimFamilyNames Provider
 */
- (instancetype)initWithNames:(id<ISimNames>)names famNames:(id<ISimFamilyNames>)famNames;

// MARK: - Loading Methods

/**
 * Loads all Available Description Files in the Package
 */
- (void)loadDescriptions;

// MARK: - Nightlife Turn On/Off Extension

/**
 * Loads turn on/off data from game files
 */
- (void)loadTurnOns;

// MARK: - BonVoyage Vacation Collectibles Extension

/**
 * Loads collectibles data from game files
 */
- (void)loadCollectibles;

/**
 * Creates a collectible alias from parsed data
 */
- (NSInteger)createCollectibleAlias:(StrItemList *)strs
                            picture:(Picture *)pic
                               line:(NSString *)line
                              index:(NSInteger)index;

/**
 * Loads collectible icon from game files
 */
+ (NSImage *)loadCollectibleIcon:(Picture *)pic group:(uint32_t)group instance:(uint32_t)instance;

/**
 * Utility methods for parsing UI attributes
 */
+ (NSString *)getUIListAttribute:(NSString *)line name:(NSString *)name;
+ (NSString *)getUIAttribute:(NSString *)line name:(NSString *)name;
+ (NSString *)getUITextAttribute:(NSString *)line name:(NSString *)name;

@end
