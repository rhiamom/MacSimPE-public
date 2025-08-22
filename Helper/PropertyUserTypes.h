//
//  PropertyUserTypes.h
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
// ***************************************************************************/


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/**
 * Stores a Floating-point Color
 */
@interface FloatColor : NSObject

/**
 * The NSColor representation
 */
@property (nonatomic, strong) NSColor *color;

/**
 * Create FloatColor from NSColor
 * @param color The NSColor to convert
 * @return New FloatColor instance
 */
+ (FloatColor *)fromColor:(NSColor *)color;

/**
 * Create FloatColor from string representation
 * @param string The string representation (e.g., "1.0,1.0,1.0")
 * @return New FloatColor instance
 */
+ (FloatColor *)fromString:(NSString *)string;

/**
 * Returns the color represented by a string like 1.0,1.0,1.0
 * @param string The string to parse
 * @return NSColor representation
 */
+ (NSColor *)toColor:(NSString *)string;

/**
 * Initialize with NSColor
 * @param color The NSColor to store
 * @return Initialized FloatColor instance
 */
- (instancetype)initWithColor:(NSColor *)color;

/**
 * Initialize with string representation
 * @param string The string representation
 * @return Initialized FloatColor instance
 */
- (instancetype)initWithString:(NSString *)string;

/**
 * Convert to string representation
 * @return String representation of the color
 */
- (NSString *)toString;

@end

/**
 * This is a class that can present numeric values in different ways (Dec, Hex, Bin)
 */
@interface BaseChangeableNumber : NSObject

/**
 * The Number Base used for Display
 */
@property (class, nonatomic, assign) NSInteger digitBase;

/**
 * Name of this Number Representation
 */
@property (class, nonatomic, readonly, copy) NSString *baseName;

/**
 * What kind of number was it to begin with?
 */
@property (nonatomic, readonly, assign) Class type;

/**
 * The actual Value (as short)
 */
@property (nonatomic, assign) int16_t value;

/**
 * The actual Value (as Integer)
 */
@property (nonatomic, assign) int32_t integerValue;

/**
 * The actual Value (as Long)
 */
@property (nonatomic, assign) int64_t longValue;

/**
 * The actual value (same type as this value was created with, or last set)
 */
@property (nonatomic, strong) id objectValue;

/**
 * Initialize with an object value
 * @param value The value to store
 * @return Initialized BaseChangeableNumber instance
 */
- (instancetype)initWithObject:(id)value;

/**
 * Initialize with an object value and specific type
 * @param value The value to store
 * @param type The type class
 * @return Initialized BaseChangeableNumber instance
 */
- (instancetype)initWithObject:(id)value type:(Class)type;

/**
 * Converts a String Back to a type of this Class
 * @param string The string Representation
 * @param type The type of the Target Number
 * @return A new Instance
 */
+ (BaseChangeableNumber *)convertString:(NSString *)string toType:(Class)type;

/**
 * Return the String Representation of the stored Value
 * @return A String
 */
- (NSString *)toString;

/**
 * Convert to unsigned integer
 * @return Unsigned integer value
 */
- (uint32_t)unsignedIntegerValue;

@end
