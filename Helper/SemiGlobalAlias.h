//
//  SemiGlobalAlias.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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
#import "Alias.h"

/**
 * Overrides the Alias class
 */
@interface SemiGlobalAlias : Alias

/**
 * Returns true if this Global is known for certain
 */
@property (nonatomic, readonly, assign) BOOL known;

/**
 * Initialize with ID and name
 * @param aliasId The alias identifier
 * @param name The alias name
 */
- (instancetype)initWithId:(uint32_t)aliasId name:(NSString *)name;

/**
 * Initialize with known status, ID and name
 * @param known Whether this can be used as a valid Global
 * @param aliasId The alias identifier
 * @param name The alias name
 */
- (instancetype)initWithKnown:(BOOL)known id:(uint32_t)aliasId name:(NSString *)name;

@end
