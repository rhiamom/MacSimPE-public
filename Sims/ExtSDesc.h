//
//  ExtSDesc.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/31/25.
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
#import "SDescWrapper.h"

@class ExtSRel, SimDNA, BinaryReader, BinaryWriter;
@protocol IPackedFileUI, IWrapperInfo, ILotItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * Extended Sim Description Wrapper
 * Contains settings (like interests, friendships, money, age, gender...) for one Sim
 */
@interface ExtSDesc : SDesc

// MARK: - Properties

/**
 * Returns true if this Sim is an NPC
 */
@property (nonatomic, readonly, assign) BOOL isNPC;

/**
 * Returns true if this Sim is a Townie
 */
@property (nonatomic, readonly, assign) BOOL isTownie;

/**
 * Override the character filename property for NPCs
 */
@property (nonatomic, readonly, copy, nullable) NSString *characterFileName;

/**
 * Override Sim family name with custom value if set
 */
@property (nonatomic, copy, nullable) NSString *simFamilyName;

/**
 * Override Sim name with custom value if set
 */
@property (nonatomic, copy, nullable) NSString *simName;

// MARK: - Initialization

/**
 * Initialize ExtSDesc
 */
- (instancetype)init;

// MARK: - Relationship Management

/**
 * Check if this Sim has a relationship with another Sim
 * @param sDesc The other Sim to check
 * @return YES if there is a relationship
 */
- (BOOL)hasRelationWith:(ExtSDesc *)sDesc;

/**
 * Add a relationship with another Sim
 * @param sDesc The Sim to add a relationship with
 */
- (void)addRelation:(ExtSDesc *)sDesc;

/**
 * Remove a relationship with another Sim
 * @param sDesc The Sim to remove the relationship with
 */
- (void)removeRelation:(ExtSDesc *)sDesc;

/**
 * Find a relationship between two Sims
 * @param src Source Sim
 * @param dst Destination Sim
 * @return The relationship object or nil
 */
+ (nullable ExtSRel *)findRelation:(ExtSDesc *)src destination:(ExtSDesc *)dst;

/**
 * Find a relationship between two Sims with cache
 * @param cache Cache Sim
 * @param src Source Sim
 * @param dst Destination Sim
 * @return The relationship object or nil
 */
+ (nullable ExtSRel *)findRelation:(ExtSDesc *)cache source:(ExtSDesc *)src destination:(ExtSDesc *)dst;

/**
 * Find a relationship with another Sim
 * @param sDesc The other Sim
 * @return The relationship object or nil
 */
- (nullable ExtSRel *)findRelation:(ExtSDesc *)sDesc;

/**
 * Get the relation instance for another Sim
 * @param sDesc The other Sim
 * @return The relation instance ID
 */
- (uint32_t)getRelationInstance:(ExtSDesc *)sDesc;

/**
 * Create a new relationship with another Sim
 * @param sDesc The other Sim
 * @return The new relationship object
 */
- (ExtSRel *)createRelation:(ExtSDesc *)sDesc;

// MARK: - Internal Relationship Cache Methods

/**
 * Get cached relationship by instance
 * @param instance The instance ID
 * @return The cached relationship or nil
 */
- (nullable ExtSRel *)getCachedRelation:(uint32_t)instance;

/**
 * Get cached relationship by Sim
 * @param sDesc The Sim
 * @return The cached relationship or nil
 */
- (nullable ExtSRel *)getCachedRelationForSim:(ExtSDesc *)sDesc;

/**
 * Add relationship to cache
 * @param srel The relationship to cache
 */
- (void)addRelationToCache:(ExtSRel *)srel;

/**
 * Remove relationship from cache
 * @param srel The relationship to remove
 */
- (void)removeRelationFromCache:(ExtSRel *)srel;

@end

// MARK: - LinkedSDesc

/**
 * Extended Sim Description with DNA linking
 */
@interface LinkedSDesc : ExtSDesc

/**
 * The associated SimDNA object
 */
@property (nonatomic, readonly, strong, nullable) SimDNA *simDNA;

/**
 * List of businesses owned by this Sim
 */
@property (nonatomic, readonly, strong) NSArray<id<ILotItem>> *businessList;

@end

NS_ASSUME_NONNULL_END
