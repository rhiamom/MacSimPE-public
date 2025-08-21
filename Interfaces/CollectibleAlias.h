//
//  CollectibleAlias.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
//
//
//  CollectibleAlias.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
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
#import <AppKit/AppKit.h>

/**
 * Represents a collectible item alias with name, ID, number and image
 */
@interface CollectibleAlias : NSObject

// MARK: - Properties

/**
 * The name of the collectible
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * The unique identifier of the collectible
 */
@property (nonatomic, readonly, assign) uint64_t itemId;

/**
 * The number/index of the collectible
 */
@property (nonatomic, readonly, assign) NSInteger nr;

/**
 * The image associated with the collectible
 */
@property (nonatomic, readonly, strong) NSImage *image;

// MARK: - Initialization

/**
 * Creates a new CollectibleAlias instance
 * @param itemId The unique identifier
 * @param nr The number/index
 * @param name The name of the collectible
 * @param image The associated image (if nil, a default 32x32 image will be created)
 */
- (instancetype)initWithId:(uint64_t)itemId
                        nr:(NSInteger)nr
                      name:(NSString *)name
                     image:(NSImage *)image;

@end
