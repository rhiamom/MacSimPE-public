//
//  SkinProvider.h
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
#import "ISkinProvider.h"

@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@class Cpf;
@class RefFile;
@class GenericRcol;
@class Nmap;
@class Txtr;

/**
 * Provides an Alias Matching a SimID with it's Name
 */
@interface Skins : SimCommonPackage <ISkinProvider>

// MARK: - Properties

/**
 * List of known Property Sets
 */
@property (nonatomic, strong) NSMutableArray *sets;

/**
 * List of known Material Definitions
 */
@property (nonatomic, strong) NSMutableArray *matds;

/**
 * List of known Reference Files
 */
@property (nonatomic, strong) NSMutableArray *refs;

/**
 * Available Textures (keyed by name)
 */
@property (nonatomic, strong) NSMutableDictionary *txtrs;

// MARK: - Initialization

/**
 * Creates the List for the specific Folder
 */
- (instancetype)init;

// MARK: - Package Loading Methods

/**
 * Load skin data from a specific package
 * @param package The package to load from
 */
- (void)loadSkinFromPackage:(id<IPackageFile>)package;

/**
 * Load skin image data from a specific package
 * @param package The package to load from
 */
- (void)loadSkinImageFromPackage:(id<IPackageFile>)package;

/**
 * Load available Skin Files
 */
- (void)loadSkins;

/**
 * Load available Skin Images
 */
- (void)loadSkinImages;

/**
 * Load user packages from Downloads folder
 */
- (void)loadUserPackages;

/**
 * Load user image packages from Downloads folder
 */
- (void)loadUserImagePackages;

@end
