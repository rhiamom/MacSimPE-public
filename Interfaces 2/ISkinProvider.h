//
//  ISkinProvider.h
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

@protocol IPackedFileDescriptor;

/**
 * Interface to obtain Skin Files from the Game Installation
 */
@protocol ISkinProvider <ICommonPackage>

// MARK: - Package Management

/**
 * Load the package data
 */
- (void)loadPackage;

// MARK: - Property Set Management

/**
 * Returns the Property Set of a Skin
 * @param spfd The File Description of the File you are looking for
 * @returns null or the Property Set File
 */
- (id)findSet:(id<IPackedFileDescriptor>)spfd;

// MARK: - Stored Skins

/**
 * Returns a list of all known skins
 */
@property (nonatomic, readonly, strong) NSMutableArray *storedSkins;

// MARK: - Texture Name Resolution

/**
 * Find texture name from file descriptor
 * @param spfd The file descriptor
 * @returns The texture name or nil
 */
- (NSString *)findTxtrName:(id<IPackedFileDescriptor>)spfd;

/**
 * Find texture name from material name
 * @param matdName The material name
 * @returns The texture name or nil
 */
- (NSString *)findTxtrNameFromMaterial:(NSString *)matdName;

/**
 * Find texture name from MMAT or Property Set
 * @param ocpf The MMAT or Property Set describing the Model
 * @returns The Texture name or nil
 */
- (NSString *)findTxtrNameFromObject:(id)ocpf;

// MARK: - Texture Finding

/**
 * Find texture by name
 * @param name The texture name
 * @returns The texture object or nil
 */
- (id)findTxtr:(NSString *)name;

/**
 * Find user texture by name
 * @param name The texture name
 * @returns The user texture object or nil
 */
- (id)findUserTxtr:(NSString *)name;

@end
