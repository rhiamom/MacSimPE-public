//
//  SimFamilyNames.m
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
#import "ISimFamilyNames.h"

@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IAlias;
@class Alias;

/**
 * Provides an Alias Matching a SimID with it's Name
 */
@interface SimFamilyNames : SimCommonPackage <ISimFamilyNames>

// MARK: - Properties

/**
 * List of known Aliases (can be null)
 */
@property (nonatomic, strong) NSMutableDictionary *names;

// MARK: - Initialization

/**
 * Creates the List for the specific Package
 * @param package The Base Package
 */
- (instancetype)initWithPackage:(id<IPackageFile>)package;

/**
 * Creates the List without a package
 */
- (instancetype)init;

// MARK: - Loading Methods

/**
 * Loads all package Files in the directory and scans them for Name Informations
 */
- (void)loadSimsFromFolder;

// MARK: - ISimFamilyNames Protocol Methods

/**
 * Returns the the Alias with the specified Type
 * @param simId The id of a Sim
 * @returns The Alias of the Sim
 */
- (id<IAlias>)findName:(uint32_t)simId;

/**
 * Returns a List of All SimID's found in the Package
 * @returns The List of found SimID's
 */
- (NSMutableArray *)getAllSimIDs;

@end
