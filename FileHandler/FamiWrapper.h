//
//  FamiWrapper.h
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
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "FlagBase.h"

@class BinaryReader, BinaryWriter, SDesc;
@protocol ISimNames, IPackedFileDescriptor, IPackageFile, IPackedFileUI, IWrapperInfo;

NS_ASSUME_NONNULL_BEGIN

// MARK: - Enumerations

/**
 * The Type of this Memory
 */
typedef NS_ENUM(uint16_t, MemoryType) {
    MemoryTypeGoodMemory = 0x0000,
    MemoryTypeBadMemory = 0xfff8
};

/**
 * Fami file versions
 */
typedef NS_ENUM(int32_t, FamiVersions) {
    FamiVersionsOriginal = 0x4e,
    FamiVersionsUniversity = 0x4f,
    FamiVersionsBusiness = 0x51,
    FamiVersionsVoyage = 0x55,
    //FamiVersionsCastaway = 0x56
};

// MARK: - Flag Classes

/**
 * Family flags wrapper
 */
@interface FamiFlags : FlagBase

// MARK: - Family State Properties

@property (nonatomic, assign) BOOL hasPhone;
@property (nonatomic, assign) BOOL hasBaby;
@property (nonatomic, assign) BOOL newLot;
@property (nonatomic, assign) BOOL hasComputer;

// MARK: - Initialization

- (instancetype)initWithFlags:(uint16_t)flags;

@end

// MARK: - Main Wrapper Class

/**
 * Represents a PackedFile in Fami Format
 */
@interface Fami : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * Returns the version of the Fami file
 */
@property (nonatomic, readonly, assign) FamiVersions version;

/**
 * Returns/Sets the Flags
 */
@property (nonatomic, assign) uint32_t flags;

/**
 * Returns/Sets the Story Telling Album GUID
 */
@property (nonatomic, assign) uint32_t albumGUID;

/**
 * Returns/Sets the Business Money (???)
 */
@property (nonatomic, assign) int32_t businessMoney;

/**
 * Returns/Sets the amount of Money the Family possesses
 */
@property (nonatomic, assign) int32_t money;

/**
 * Returns/Sets Castaway Resources
 
@property (nonatomic, assign) int32_t castAwayResources;


 * Returns/Sets Castaway Food
 
@property (nonatomic, assign) int32_t castAwayFood;

**
 * Returns/Sets Castaway Food Decay
 
@property (nonatomic, assign) int32_t castAwayFoodDecay;

**
 * Returns the Number of Family friends
 */
@property (nonatomic, assign) uint32_t friends;

/**
 * Returns/Sets the Sim Id's for Family members
 */
@property (nonatomic, strong) NSArray<NSNumber *> *members;

/**
 * Returns the FirstName of the Sims
 * @remarks If no SimName Provider is available, all Names will be empty
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *simNames;

/**
 * Returns a Descriptor for the Lot the Family lives in, or 0 if none assigned
 */
@property (nonatomic, assign) uint32_t lotInstance;

/**
 * Returns a Descriptor for the Lot where the family stays for vacation
 */
@property (nonatomic, assign) uint32_t vacationLotInstance;

/**
 * Returns the Instance of the Lot, where the Player last left the Family
 */
@property (nonatomic, assign) uint32_t currentlyOnLotInstance;

/**
 * Returns/Sets the SubHood Number
 */
@property (nonatomic, assign) uint32_t subHoodNumber;

/**
 * Returns/Sets the Name of the Family
 */
@property (nonatomic, copy) NSString *name;

/**
 * Returns the Name Provider
 */
@property (nonatomic, readonly, strong, nullable) id<ISimNames> nameProvider;

// MARK: - Initialization

/**
 * Constructor with name provider
 * @param names The sim names provider
 */
- (instancetype)initWithNameProvider:(nullable id<ISimNames>)names;

// MARK: - Sim Management

/**
 * Returns the Description File for the passed Sim id
 * @param simId id of the Sim
 * @return The Description file for the Sim
 * @remarks
 * If the Description file does not exist in
 * the current Package, it will be added!
 * @exception Thrown when processData was not called.
 */
- (SDesc *)getDescriptionFile:(uint32_t)simId;

// MARK: - IFileWrapper Protocol

/**
 * Returns the Signature that can be used to identify Files processable with this Plugin
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

/**
 * Returns a list of File Types this Plugin can process
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

@end

NS_ASSUME_NONNULL_END
