//
//  GroupCacheWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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
#import "IPackedFileSaveExtension.h"
#import "GroupCacheItem.h"

// Forward declarations
@protocol IGroupCache, IPackedFileUI, IWrapperInfo;
@class GroupCacheItems, BinaryReader, BinaryWriter;

// Forward declaration for protocol (would be defined elsewhere)
@protocol IGroupCache <NSObject>

/**
 * Return an appropriate Item for the passed File
 * @param filename The filename to get an item for
 * @return The GroupCacheItem for the file
 */
- (id<IGroupCacheItem>)getItem:(NSString *)filename;

@end

/**
 * Used to decode the Group Cache
 */
@interface GroupCache : AbstractWrapper <IFileWrapper, IPackedFileSaveExtension, IGroupCache>

// MARK: - Properties

/**
 * Returns the Items stored in the File
 * @remarks Do not add Items based on this List! use the addItem Method!!
 */
@property (nonatomic, readonly, strong) GroupCacheItems *items;

// MARK: - Item Management

/**
 * Add a new Item
 * @param item The Item to Add
 */
- (void)addItem:(GroupCacheItem *)item;

/**
 * Remove a Item
 * @param item The Item you want to remove
 */
- (void)removeItem:(GroupCacheItem *)item;

/**
 * Return an appropriate Item for the passed File
 * @param filename The filename to get an item for
 * @return The GroupCacheItem for the file
 */
- (id<IGroupCacheItem>)getItem:(NSString *)filename;

@end
