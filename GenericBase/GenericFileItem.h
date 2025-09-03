//
//  GenericFileItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/2/25.
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
#import "GenericCommon.h"

NS_ASSUME_NONNULL_BEGIN

@class GenericItem;

/**
 * Type-safe NSMutableArray for GenericItem Objects
 */
@interface GenericItems : NSMutableArray<GenericItem *>

// MARK: - Indexed Access
- (GenericItem *)objectAtIndex:(NSUInteger)index;
- (GenericItem *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(GenericItem *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(GenericItem *)object;

// MARK: - Collection Operations
- (void)addGenericItem:(GenericItem *)item;
- (void)insertGenericItem:(GenericItem *)item atIndex:(NSUInteger)index;
- (void)removeGenericItem:(GenericItem *)item;
- (BOOL)containsGenericItem:(GenericItem *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSUInteger length;

// MARK: - Copying
- (instancetype)deepCopy;

@end

/**
 * A SubItem of a Generic File
 */
@interface GenericItem : GenericCommon

// MARK: - Properties

/**
 * Returns or sets the List of Subitems
 */
@property (nonatomic, strong, nullable) NSArray<GenericItem *> *subitems;

/**
 * Number of Subitems stored
 */
@property (nonatomic, readonly, assign) NSInteger count;

// MARK: - Initialization

/**
 * Creates a new Instance
 */
- (instancetype)init;

// MARK: - Protected Methods

/**
 * Returns the List of Subitems
 */
- (NSArray<GenericItem *> *)getSubitems;

@end

NS_ASSUME_NONNULL_END
