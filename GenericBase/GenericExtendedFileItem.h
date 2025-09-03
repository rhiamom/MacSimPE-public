//
//  GenericExtendedFileItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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
 * Use this class to implement specific FileItems
 */
@interface GenericExtendedItem : NSObject

// MARK: - Properties

/**
 * Returns the based FileItem
 */
@property (nonatomic, readonly, strong) GenericCommon *base;

// MARK: - Initialization

/**
 * Creates a new Instance
 * @param item The based GenericItem Object
 */
- (instancetype)initWithItem:(GenericCommon *)item;

/**
 * Convenience initializer with GenericItem
 * @param item The GenericItem to wrap
 */
- (instancetype)initWithGenericItem:(GenericItem *)item;

// MARK: - Factory Methods

/**
 * Creates a new ExtendedFileItem Object from a GenericItem
 * @param item The FileItem you want to convert from
 * @returns The new ExtendedFileItem Object
 * @remarks Every derived class should implement this for its implementation!
 */
+ (instancetype)extendedItemWithGenericItem:(GenericItem *)item;

/**
 * Creates a new ExtendedFileItem Object from a GenericCommon
 * @param item The Common Object you want to convert from
 * @returns The new ExtendedFileItem Object
 * @remarks Every derived class should implement this for its implementation!
 */
+ (instancetype)extendedItemWithGenericCommon:(GenericCommon *)item;

@end

NS_ASSUME_NONNULL_END
