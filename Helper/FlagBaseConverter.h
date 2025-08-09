//
//  FlagBaseConverter.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
// ***************************************************************************
// *   Copyright (C) 2025 by GramzeSweatShop                                  *
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

@class FlagBase;

/**
 * Used for dynamic property editing using FlagBase Objects.
 * Converts between FlagBase objects and their string representations for UI display.
 */
@interface FlagBaseConverter : NSObject

// MARK: - Type Conversion Support

/**
 * Check if the converter can convert to the specified type
 * @param destinationType The target type for conversion
 * @returns YES if conversion is supported
 */
- (BOOL)canConvertToType:(Class)destinationType;

/**
 * Convert a FlagBase object to the specified type
 * @param value The FlagBase object to convert
 * @param destinationType The target type for conversion
 * @returns The converted object, or nil if conversion failed
 */
- (id)convertObject:(id)value toType:(Class)destinationType;

/**
 * Check if the converter can convert from the specified type
 * @param sourceType The source type for conversion
 * @returns YES if conversion is supported
 */
- (BOOL)canConvertFromType:(Class)sourceType;

/**
 * Convert from the specified type to a FlagBase object
 * @param value The value to convert
 * @param targetType The target FlagBase class type
 * @returns The converted FlagBase object, or nil if conversion failed
 */
- (id)convertValue:(id)value toFlagBaseOfType:(Class)targetType;

// MARK: - String Conversion Utilities

/**
 * Convert a FlagBase object to its string representation
 * @param flagBase The FlagBase object to convert
 * @returns String representation of the flag values
 */
- (NSString *)flagBaseToString:(FlagBase *)flagBase;

/**
 * Convert a binary string to a FlagBase object
 * @param binaryString Binary string representation (e.g., "1010")
 * @param flagBaseClass The target FlagBase class
 * @returns New FlagBase instance, or nil if conversion failed
 */
- (FlagBase *)stringToFlagBase:(NSString *)binaryString
                       ofClass:(Class)flagBaseClass;

// MARK: - Validation

/**
 * Validate that a string can be converted to a flag value
 * @param string The string to validate
 * @returns YES if the string is a valid binary flag representation
 */
- (BOOL)isValidFlagString:(NSString *)string;

@end
