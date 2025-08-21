//
//  ILotProvider.h
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
#import <AppKit/AppKit.h>

@protocol IScenegraphFileIndexItem;
@protocol ILotItem;

// MARK: - ILotItem Protocol

/**
 * Interface for individual lot items
 */
@protocol ILotItem <NSObject>

/**
 * The instance ID of the lot
 */
@property (nonatomic, readonly, assign) uint32_t instance;

/**
 * The lot's image/thumbnail
 */
@property (nonatomic, readonly, strong) NSImage *image;

/**
 * The name of the lot
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * The lot name (alias for name)
 */
@property (nonatomic, readonly, copy) NSString *lotName;

/**
 * The owner sim instance
 */
@property (nonatomic, readonly, assign) uint32_t owner;

/**
 * Associated tags/metadata
 */
@property (nonatomic, readonly, strong) NSMutableArray *tags;

/**
 * LTXT file index item
 */
@property (nonatomic, readonly, strong) id<IScenegraphFileIndexItem> ltxtFileIndexItem;

/**
 * BNFO file index item
 */
@property (nonatomic, readonly, strong) id<IScenegraphFileIndexItem> bnfoFileIndexItem;

/**
 * STR file index item
 */
@property (nonatomic, readonly, strong) id<IScenegraphFileIndexItem> strFileIndexItem;

/**
 * Find a tag of a specific type
 * @param type The class type to search for
 * @returns The found tag object or nil
 */
- (id)findTag:(Class)type;

@end

// MARK: - Delegate Protocol

/**
 * Delegate protocol for lot loading events
 */
@protocol ILotProviderDelegate <NSObject>

@optional
/**
 * Called when a lot is being loaded
 * @param provider The lot provider
 * @param item The lot item being loaded
 */
- (void)lotProvider:(id)provider loadingLot:(id<ILotItem>)item;

@end

// MARK: - ILotProvider Protocol

/**
 * Interface to obtain Lot Informations
 */
@protocol ILotProvider <NSObject>

/**
 * Returns or sets the Folder where the Character Files are stored
 * @remarks Sets the names List to null
 */
@property (nonatomic, strong) NSString *baseFolder;

/**
 * Stored lot data (keyed by instance)
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *storedData;

/**
 * Delegate for lot loading events
 */
@property (nonatomic, weak) id<ILotProviderDelegate> delegate;

/**
 * Returns a list of all Lot Names
 * @returns Array of lot names
 */
- (NSArray<NSString *> *)getNames;

/**
 * Find a lot by instance ID
 * @param instance The instance ID to search for
 * @returns The lot item or nil if not found
 */
- (id<ILotItem>)findLot:(uint32_t)instance;

/**
 * Find lots owned by a specific sim
 * @param simInstance The sim's instance ID
 * @returns Array of lot items owned by the sim
 */
- (NSArray<id<ILotItem>> *)findLotsOwnedBySim:(uint32_t)simInstance;

@end
