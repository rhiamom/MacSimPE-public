//
//  FamilyTieItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
//**************************************************************************
//*   Copyright (C) 2005 by Ambertation                                     *
//*   quaxi@ambertation.de                                                  *
//*                                                                         *
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//**************************************************************************/

#import <Foundation/Foundation.h>
#import "MetaData.h"

@class SDesc, FamilyTies;
@protocol IPackedFileDescriptor, IPackageFile, ISimNames;

NS_ASSUME_NONNULL_BEGIN

// Forward declarations
@class FamilyTieItem, FamilyTieSim;

// MARK: - FamilyTieCommon Base Class

/**
 * This Class handles the instance -> Name assignment
 */
@interface FamilyTieCommon : NSObject

// MARK: - Properties

/**
 * Returns / Sets the Instance of the Target Sim
 */
@property (nonatomic, assign) uint16_t instance;

/**
 * Returns the Name of the sim
 */
@property (nonatomic, readonly, copy) NSString *simName;

/**
 * Returns the Sim Description
 */
@property (nonatomic, readonly, strong) SDesc *simDescription;

/**
 * Returns the Family Name of the sim
 */
@property (nonatomic, readonly, copy) NSString *simFamilyName;

/**
 * The Parent Wrapper
 */
@property (nonatomic, readonly, weak) FamilyTies *famt;

// MARK: - Initialization

/**
 * Constructor
 * @param simInstance Instance of the Sim
 * @param famt The Parent Wrapper
 */
- (instancetype)initWithSimInstance:(uint16_t)simInstance famt:(FamilyTies *)famt;

// MARK: - Description

/**
 * Returns a String describing the Object
 */
- (NSString *)description;

@end

// MARK: - FamilyTieSim Class

/**
 * A Sim that is stored within a FamilyTie File
 */
@interface FamilyTieSim : FamilyTieCommon

// MARK: - Properties

/**
 * Returns / Sets the ties he participates in
 */
@property (nonatomic, strong) NSArray<FamilyTieItem *> *ties;

/**
 * Returns / Sets the Block Delimiter
 * @remarks This is only stored for Safety reasons
 */
@property (nonatomic, assign) int32_t blockDelimiter;

// MARK: - Initialization

/**
 * Constructor for a new participation sim
 * @param simInstance Instance of the Sim
 * @param ties the ties he participates in
 * @param famt The Parent Wrapper
 */
- (instancetype)initWithSimInstance:(uint16_t)simInstance
                               ties:(NSArray<FamilyTieItem *> *)ties
                               famt:(FamilyTies *)famt;

// MARK: - Tie Management

/**
 * Returns the available FamilyTieItem for the passed Sim
 * @param sdsc The sim description
 * @return nil or the FamilyTieItem for that Sim
 */
- (nullable FamilyTieItem *)findTie:(nullable SDesc *)sdsc;

/**
 * Returns the available FamilyTieItem for the Sim, or creates a new One
 * @param sdsc The sim description
 * @param type The type of family tie
 * @return the FamilyTieItem for the passed Sim
 */
- (FamilyTieItem *)createTie:(SDesc *)sdsc type:(FamilyTieTypes)type;

/**
 * Remove the passed Family Tie
 * @param fti The family tie item to remove
 * @return YES if the Tie was removed
 */
- (BOOL)removeTie:(FamilyTieItem *)fti;

@end

// MARK: - FamilyTieItem Class

/**
 * Contains one FamilyTie
 */
@interface FamilyTieItem : FamilyTieCommon

// MARK: - Properties

/**
 * Returns / Sets the Type of the Tie
 */
@property (nonatomic, assign) FamilyTieTypes type;

// MARK: - Initialization

/**
 * Creates a new FamilyTie
 * @param type The Type of the tie
 * @param simInstance The instance of the Target sim
 * @param famt The Parent Wrapper
 */
- (instancetype)initWithType:(FamilyTieTypes)type
                 simInstance:(uint16_t)simInstance
                        famt:(FamilyTies *)famt;

// MARK: - Description

/**
 * Returns a String describing the Object
 */
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
