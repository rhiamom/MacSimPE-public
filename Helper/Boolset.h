//
//  Boolset.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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
 * Summary description for Boolset.
 * A class that represents a set of boolean values with bit manipulation capabilities.
 */
@interface Boolset : NSObject

// MARK: - Properties

/**
 * Returns the length of the bitset
 */
@property (nonatomic, readonly) NSInteger length;

// MARK: - Initialization

/**
 * Initialize with uint32 value (32-bit)
 * @param val The uint32 value
 */
- (instancetype)initWithUInt32:(uint32_t)val;

/**
 * Initialize with uint16 value (16-bit)
 * @param val The uint16 value
 */
- (instancetype)initWithUInt16:(uint16_t)val;

/**
 * Initialize with uint8 value (8-bit)
 * @param val The uint8 value
 */
- (instancetype)initWithUInt8:(uint8_t)val;

/**
 * Initialize with string representation
 * @param val The string representation (rightmost char = bit 0)
 */
- (instancetype)initWithString:(NSString *)val;

/**
 * Private initializer with size and value
 * @param size The number of bits
 * @param val The value to initialize with
 */
- (instancetype)initWithSize:(NSInteger)size value:(uint32_t)val;

// MARK: - Convenience Constructors

/**
 * Create with uint32 value
 */
+ (instancetype)boolsetWithUInt32:(uint32_t)val;

/**
 * Create with uint16 value
 */
+ (instancetype)boolsetWithUInt16:(uint16_t)val;

/**
 * Create with uint8 value
 */
+ (instancetype)boolsetWithUInt8:(uint8_t)val;

/**
 * Create with string
 */
+ (instancetype)boolsetWithString:(NSString *)val;

// MARK: - Bit Access

/**
 * Get bit value at index
 * @param index The bit index
 * @returns YES if bit is set, NO otherwise
 * @throws NSException if index is out of range
 */
- (BOOL)getBit:(NSInteger)index;

/**
 * Set bit value at index
 * @param index The bit index
 * @param value YES to set bit, NO to clear bit
 * @throws NSException if index is out of range
 */
- (void)setBit:(NSInteger)index value:(BOOL)value;

// MARK: - Conversion Methods

/**
 * Convert to uint8 value
 */
- (uint8_t)uint8Value;

/**
 * Convert to uint16 value
 */
- (uint16_t)uint16Value;

/**
 * Convert to uint32 value
 */
- (uint32_t)uint32Value;

/**
 * Convert to string representation
 */
- (NSString *)stringValue;

// MARK: - Pattern Matching

/**
 * Check if bitset matches a pattern mask
 * @param mask Pattern mask where '0' = must be 0, '1' = must be 1, other = don't care
 * @returns YES if pattern matches
 */
- (BOOL)matches:(NSString *)mask;

// MARK: - Bit Manipulation

/**
 * Flip (toggle) a single bit
 * @param bit The bit index to flip
 */
- (void)flip:(NSInteger)bit;

/**
 * Flip multiple bits
 * @param bits Array of NSNumber containing bit indices to flip
 */
- (void)flipBits:(NSArray<NSNumber *> *)bits;

// MARK: - NSObject Overrides

- (NSString *)description;

@end
