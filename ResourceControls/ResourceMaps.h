//
//  ResourceMaps.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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
#import "ResourceViewManagerHelpers.h"

// MARK: - Type Definitions

/**
 * Dictionary mapping uint32_t keys to ResourceNameList values
 * Used for Type and Group mappings
 */
@interface IntMap : NSMutableDictionary<NSNumber *, ResourceNameList *>

@end

/**
 * Dictionary mapping uint64_t keys to ResourceNameList values
 * Used for Instance mappings
 */
@interface LongMap : NSMutableDictionary<NSNumber *, ResourceNameList *>

@end

// MARK: - Resource Maps

/**
 * Container for organized resource mappings by type, group, and instance
 */
@interface ResourceMaps : NSObject

// MARK: - Properties

@property (nonatomic, strong, readonly) ResourceNameList *everything;
@property (nonatomic, strong, readonly) IntMap *byType;
@property (nonatomic, strong, readonly) IntMap *byGroup;
@property (nonatomic, strong, readonly) LongMap *byInstance;

// MARK: - Initialization

- (instancetype)init;

// MARK: - Management

/**
 * Clears all mappings including the everything list
 */
- (void)clear;

/**
 * Clears all mappings, optionally preserving the everything list
 * @param clearEverything YES to also clear the everything list, NO to preserve it
 */
- (void)clearKeepEverything:(BOOL)clearEverything;

@end
