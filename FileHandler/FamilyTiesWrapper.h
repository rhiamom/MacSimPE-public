//
//  FamilyTiesWrapper.h
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

@class BinaryReader, BinaryWriter, SDesc, FamilyTieSim;
@protocol ISimNames, IPackedFileUI, IWrapperInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a PackedFile in Family Ties Format
 */
@interface FamilyTies : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * Returns the Name Provider
 */
@property (nonatomic, readonly, strong, nullable) id<ISimNames> nameProvider;

/**
 * Returns/Sets all stored Sims
 */
@property (nonatomic, strong) NSArray<FamilyTieSim *> *sims;

// MARK: - Initialization

/**
 * Constructor with name provider
 * @param names The sim names provider
 */
- (instancetype)initWithNameProvider:(nullable id<ISimNames>)names;

// MARK: - Tie Management

/**
 * Returns the available FamilyTieSim for the passed Sim
 * @param sdsc The sim description
 * @return nil or the FamilyTieSim for that Sim
 */
- (nullable FamilyTieSim *)findTies:(nullable SDesc *)sdsc;

/**
 * Returns the available FamilyTieSim for the Sim, or creates a new One
 * @param sdsc The sim description
 * @return the FamilyTieSim for the passed Sim
 */
- (FamilyTieSim *)createTie:(SDesc *)sdsc;

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
