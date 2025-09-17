//
//  SRelWrapper.h
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
// ***************************************************************************

#import <Foundation/Foundation.h>
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "FlagBase.h"
#import "MetaData.h"

@class BinaryReader, BinaryWriter;
@protocol IPackedFileUI, IWrapperInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * Relationship flags wrapper
 */
@interface RelationshipFlags : FlagBase

// MARK: - Relationship State Properties

@property (nonatomic, assign) BOOL isEnemy;
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, assign) BOOL isBuddie;
@property (nonatomic, assign) BOOL hasCrush;
@property (nonatomic, assign) BOOL inLove;
@property (nonatomic, assign) BOOL goSteady;
@property (nonatomic, assign) BOOL isEngaged;
@property (nonatomic, assign) BOOL isMarried;
@property (nonatomic, assign) BOOL isFamilyMember;
@property (nonatomic, assign) BOOL isKnown;

// MARK: - Initialization

- (instancetype)initWithFlags:(uint16_t)flags;

@end

/**
 * UI flags 2 wrapper
 */
@interface UIFlags2 : FlagBase

// MARK: - UI State Properties

@property (nonatomic, assign) BOOL isBFF;

// MARK: - Initialization

- (instancetype)initWithFlags:(uint16_t)flags;

@end

/**
 * Sim Relationship wrapper - handles relationship data between two sims
 */
@interface SRel : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * Returns the Shortterm Relationship value
 */
@property (nonatomic, assign) int32_t shortterm;

/**
 * Returns the Relationship State flags
 * @remarks The Meaning of the Bits is stored in MetaData.RelationshipStateBits
 */
@property (nonatomic, readonly, strong) RelationshipFlags *relationState;

/**
 * Returns the Longterm Relationship value
 */
@property (nonatomic, assign) int32_t longterm;

/**
 * The Type of Family Relationship the Sim has to another
 */
@property (nonatomic, assign) RelationshipTypes familyRelation;

/**
 * Returns the second set of relationship state flags
 * @remarks The Meaning of the Bits is given by MetaData.UIFlags2Names
 */
@property (nonatomic, readonly, strong, nullable) UIFlags2 *relationState2;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

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
