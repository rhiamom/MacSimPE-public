//
//  ObjdPropertyParser.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/9/25.
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
#import "PropertyParser.h"

@class PropertyDescription;

NS_ASSUME_NONNULL_BEGIN

/**
 * Read an XML Description File and create a List of available Properties
 */
@interface ObjdPropertyParser : PropertyParser

// MARK: - Properties

/**
 * Type mapping for property descriptions indexed by property index
 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, PropertyDescription *> *typemap;

// MARK: - Initialization

/**
 * Create a new Instance
 * @param filename Name of the File to parse
 * @remarks If the File is not available, an empty Properties hashtable will be returned!
 */
- (instancetype)initWithFilename:(NSString *)filename;

// MARK: - Property Description Access

/**
 * Get property descriptor for given index
 * @param index The property index
 * @return PropertyDescription or nil if not found
 */
- (nullable PropertyDescription *)getDescriptor:(uint16_t)index;

@end

NS_ASSUME_NONNULL_END
