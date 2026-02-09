//
//  ISimDescriptionProvider.h
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
#import "ICommonPackage.h"

@protocol ISDesc;
@class TraitAlias;
@class CollectibleAlias;

/**
 * Interface to obtain all SimDescriptions available in a Package
 */
@protocol ISimDescriptions <ICommonPackage>

// MARK: - Sim Finding Methods

/**
 * Find the Description of a Sim using the Instance Number
 * @param instance The Instance Id of the sim
 * @returns null or a ISDesc Object
 */
- (id<ISDesc>)findSim:(uint16_t)instance;

/**
 * Find the Description of a Sim using the Sim ID
 * @param simId The Sim ID
 * @returns null or a ISDesc Object
 */
- (id<ISDesc>)findSimById:(uint32_t)simId;

/**
 * returns the Instance Id for the given Sim
 * @param simId ID of the Sim
 * @returns 0xffff or a valid Instance Number
 */
- (uint16_t)getInstance:(uint32_t)simId;

/**
 * returns the Sim Id for the given Sim
 * @param instance Instance Number of the Sim
 * @returns 0xffffffff or a valid Sim ID
 */
- (uint32_t)getSimId:(uint16_t)instance;

// MARK: - Data Maps

/**
 * Returns available SDSC Files by SimGUID
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *simGuidMap;

/**
 * Returns available SDSC Files by Instance
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *simInstance;

// MARK: - Household Methods

/**
 * Returns a List containing all Household Names
 */
- (NSMutableArray *)getHouseholdNames;

/**
 * Returns a List containing all Household Names
 * @param firstCustom Returns the name of the first household with a custom Sim in it
 */
- (NSMutableArray *)getHouseholdNames:(NSString **)firstCustom;

// MARK: - Nightlife Expansion

/**
 * Returns the name of a Turnon/Turnoff
 * @param val1 stored Number for TurnOns1
 * @param val2 stored Number for TurnOns2
 * @param val3 stored Number for TurnOns3
 */
- (NSString *)getTurnOnName:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3;

/**
 * Create the Index from the passed Numbers
 * @param val1 First value
 * @param val2 Second value
 * @param val3 Third value
 */
- (uint64_t)buildTurnOnIndex:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3;

/**
 * Inverse Operation to buildTurnOnIndex
 * @param index The index to decode
 * @returns Array containing val1, val2 and val3
 */
- (NSArray<NSNumber *> *)getFromTurnOnIndex:(uint64_t)index;

/**
 * Returns a List of all available TurnOns
 */
- (NSArray<TraitAlias *> *)getAllTurnOns;

// MARK: - BonVoyage Expansion

/**
 * Returns the name of a Vacation Collectibles
 * @param val1 stored Number for Collectible1
 * @param val2 stored Number for Collectible2
 * @param val3 stored Number for Collectible3
 * @param val4 stored Number for Collectible4
 */
- (NSString *)getCollectibleName:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 val4:(uint16_t)val4;

/**
 * Create the Index from the passed Numbers
 * @param val1 First value
 * @param val2 Second value
 * @param val3 Third value
 * @param val4 Fourth value
 */
- (uint64_t)buildCollectibleIndex:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 val4:(uint16_t)val4;

/**
 * Inverse Operation to buildCollectibleIndex
 * @param index The index to decode
 * @returns Array containing val1 - val4
 */
- (NSArray<NSNumber *> *)getFromCollectibleIndex:(uint64_t)index;

/**
 * Returns a List of all available Collectibles
 */
- (NSArray<CollectibleAlias *> *)getAllCollectibles;

@end
