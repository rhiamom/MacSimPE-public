//
//  MmatCacheFile.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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
#import "CacheFile.h"

@class FileIndex, MmatWrapper;
@protocol IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains an Instance of a CacheFile
 */
@interface MmatCacheFile : CacheFile

// MARK: - Properties

/**
 * Return the FileIndex represented by the Cached Files
 */
@property (nonatomic, strong, readonly) FileIndex *fileIndex;

/**
 * Returns all known MMAT Files sorted by the Default State
 */
@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, NSArray *> *defaultMap;

/**
 * Returns all known MMAT Files sorted by the ModelName
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray *> *modelMap;

// MARK: - Initialization

/**
 * Create a new Instance for an empty File
 */
- (instancetype)init;

// MARK: - Item Management

/**
 * Add a MaterialOverride to the Cache
 * @param mmat The Material Override to add
 */
- (void)addItem:(MmatWrapper *)mmat;

/**
 * Creates a FileIndex with all available MMAT Files
 * @remarks
 * The Tags of the FileDescriptions contain the MmatCacheItem Object,
 * the FileNames of the FileDescriptions contain the Name of the package File
 */
- (void)loadOverrides;

/**
 * Load the Map Files
 */
- (void)loadOverrideMaps;

@end

NS_ASSUME_NONNULL_END
