//
//  Boolset.m
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

#import "Boolset.h"

@interface Boolset ()
@property (nonatomic, assign) BOOL *bitset;
@property (nonatomic, assign) NSInteger size;
@end

@implementation Boolset

// MARK: - Initialization

- (instancetype)initWithSize:(NSInteger)size value:(uint32_t)val {
    self = [super init];
    if (self) {
        _size = size;
        _bitset = calloc(size, sizeof(BOOL));
        
        for (NSInteger i = 0; i < size; i++) {
            _bitset[i] = (val & (1U << i)) != 0;
        }
    }
    return self;
}

- (instancetype)initWithUInt32:(uint32_t)val {
    return [self initWithSize:32 value:val];
}

- (instancetype)initWithUInt16:(uint16_t)val {
    return [self initWithSize:16 value:(uint32_t)val];
}

- (instancetype)initWithUInt8:(uint8_t)val {
    return [self initWithSize:8 value:(uint32_t)val];
}

- (instancetype)initWithString:(NSString *)val {
    self = [super init];
    if (self) {
        _size = val.length;
        _bitset = calloc(_size, sizeof(BOOL));
        
        NSInteger j = 0;
        for (NSInteger i = val.length - 1; i >= 0; i--) {
            NSString *charStr = [val substringWithRange:NSMakeRange(i, 1)];
            _bitset[j++] = ![charStr isEqualToString:@"0"];
        }
    }
    return self;
}

// MARK: - Convenience Constructors

+ (instancetype)boolsetWithUInt32:(uint32_t)val {
    return [[self alloc] initWithUInt32:val];
}

+ (instancetype)boolsetWithUInt16:(uint16_t)val {
    return [[self alloc] initWithUInt16:val];
}

+ (instancetype)boolsetWithUInt8:(uint8_t)val {
    return [[self alloc] initWithUInt8:val];
}

+ (instancetype)boolsetWithString:(NSString *)val {
    return [[self alloc] initWithString:val];
}

// MARK: - Memory Management

- (void)dealloc {
    if (_bitset) {
        free(_bitset);
        _bitset = NULL;
    }
}

// MARK: - Properties

- (NSInteger)length {
    return _size;
}

// MARK: - Bit Access

- (BOOL)getBit:(NSInteger)index {
    if (index >= _size) {
        @throw [NSException exceptionWithName:NSRangeException
                                       reason:@"Bit index out of range"
                                     userInfo:nil];
    }
    return _bitset[index];
}

- (void)setBit:(NSInteger)index value:(BOOL)value {
    if (index >= _size) {
        @throw [NSException exceptionWithName:NSRangeException
                                       reason:@"Bit index out of range"
                                     userInfo:nil];
    }
    _bitset[index] = value;
}

// MARK: - Conversion Methods

- (uint32_t)doOperatorWithLength:(NSInteger)length {
    uint32_t val = 0;
    for (NSInteger i = 0; i < length && i < _size; i++) {
        val += (_bitset[i] ? 1U : 0U) << i;
    }
    return val;
}

- (uint8_t)uint8Value {
    return (uint8_t)[self doOperatorWithLength:8];
}

- (uint16_t)uint16Value {
    return (uint16_t)[self doOperatorWithLength:16];
}

- (uint32_t)uint32Value {
    return [self doOperatorWithLength:32];
}

- (NSString *)stringValue {
    NSMutableString *s = [NSMutableString string];
    for (NSInteger i = 0; i < _size; i++) {
        NSString *bitStr = _bitset[i] ? @"1" : @"0";
        [s insertString:bitStr atIndex:0];
    }
    return [s copy];
}

// MARK: - Pattern Matching

- (BOOL)matches:(NSString *)mask {
    // right-hand end of mask is low end of bitset
    NSInteger mcnt = mask.length - 1;
    BOOL matched = YES;
    NSInteger i = 0;
    
    while (matched && mcnt >= 0 && i < _size) {
        unichar maskChar = [mask characterAtIndex:mcnt];
        if (maskChar == '0') {
            matched = !_bitset[i];
        } else if (maskChar == '1') {
            matched = _bitset[i];
        }
        // For any other character, we don't care (always matches)
        mcnt--;
        i++;
    }
    return matched;
}

// MARK: - Bit Manipulation

- (void)flip:(NSInteger)bit {
    if (bit < _size) {
        _bitset[bit] = !_bitset[bit];
    }
}

- (void)flipBits:(NSArray<NSNumber *> *)bits {
    for (NSNumber *bitNumber in bits) {
        [self flip:[bitNumber integerValue]];
    }
}

// MARK: - NSObject Overrides

- (NSString *)description {
    return [self stringValue];
}

@end
