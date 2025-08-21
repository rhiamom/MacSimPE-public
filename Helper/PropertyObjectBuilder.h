//
//  PropertyObjectBuilder.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
//
//  BaseChangeShort class
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

/**
 * This is a class that can present short Values in different Ways
 * @note Simplified for macOS - dynamic PropertyGrid functionality replaced with basic number formatting
 */
@interface BaseChangeShort : NSObject

// MARK: - Class Properties

/**
 * The Number Base used for Display (2, 10, or 16)
 */
@property (class, nonatomic, assign) NSInteger digitBase;

/**
 * Name of this Number Representation
 */
@property (class, nonatomic, readonly, copy) NSString *baseName;

// MARK: - Instance Properties

/**
 * The actual Value (as short)
 */
@property (nonatomic, assign) int16_t value;

/**
 * The actual Value (as Integer)
 */
@property (nonatomic, assign) NSInteger integerValue;

// MARK: - Initialization

/**
 * Initialize with integer value
 */
- (instancetype)initWithInt:(NSInteger)value;

/**
 * Initialize with unsigned integer value
 */
- (instancetype)initWithUInt:(NSUInteger)value;

/**
 * Initialize with short value
 */
- (instancetype)initWithShort:(int16_t)value;

// MARK: - Class Methods

/**
 * Converts a String Back to a type of this Class
 * @param string The string Representation (supports 0x prefix for hex, b prefix for binary)
 * @return a new Instance
 */
+ (instancetype)convertFromString:(NSString *)string;

@end

/**
 * Simple property container for key-value pairs with BaseChangeShort values
 * @note Replaces the complex dynamic type generation from the original C# code
 */
@interface PropertyObject : NSObject

/**
 * Initialize with dictionary of string keys to NSNumber values
 */
- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSNumber *> *)dictionary;

/**
 * Get value for key
 */
- (BaseChangeShort *)valueForKey:(NSString *)key;

/**
 * Set value for key
 */
- (void)setValue:(BaseChangeShort *)value forKey:(NSString *)key;

/**
 * Get all properties as a dictionary
 */
- (NSDictionary<NSString *, NSNumber *> *)properties;

/**
 * Get all property keys
 */
- (NSArray<NSString *> *)allKeys;

@end
