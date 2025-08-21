//
//  PropertyObjectBuilder.m
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

#import "PropertyObjectBuilder.h"

@implementation BaseChangeShort

static NSInteger _digitBase = 16;

// MARK: - Class Properties

+ (NSInteger)digitBase {
    return _digitBase;
}

+ (void)setDigitBase:(NSInteger)digitBase {
    _digitBase = digitBase;
}

+ (NSString *)baseName {
    switch (_digitBase) {
        case 16:
            return @"Hexadecimal";
        case 2:
            return @"Binary";
        default:
            return @"Decimal";
    }
}

// MARK: - Initialization

- (instancetype)initWithInt:(NSInteger)value {
    self = [super init];
    if (self) {
        _integerValue = value;
    }
    return self;
}

- (instancetype)initWithUInt:(NSUInteger)value {
    return [self initWithInt:(NSInteger)value];
}

- (instancetype)initWithShort:(int16_t)value {
    return [self initWithInt:value];
}

- (instancetype)init {
    return [self initWithInt:0];
}

// MARK: - Properties

- (int16_t)value {
    return (int16_t)(_integerValue & 0xffff);
}

- (void)setValue:(int16_t)value {
    _integerValue = (int16_t)(value & 0xffff);
}

- (void)setIntegerValue:(NSInteger)integerValue {
    _integerValue = integerValue;
}

// MARK: - Class Methods

+ (instancetype)convertFromString:(NSString *)string {
    if (!string) return nil;
    
    NSString *trimmed = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    int16_t value = 0;
    
    @try {
        if ([trimmed hasPrefix:@"0x"]) {
            // Hexadecimal
            NSString *hexString = [trimmed substringFromIndex:2];
            NSScanner *scanner = [NSScanner scannerWithString:hexString];
            unsigned int hexValue;
            if ([scanner scanHexInt:&hexValue]) {
                value = (int16_t)hexValue;
            }
        } else if ([trimmed hasPrefix:@"b"]) {
            // Binary
            NSString *binaryString = [trimmed substringFromIndex:1];
            value = (int16_t)strtol([binaryString UTF8String], NULL, 2);
        } else {
            // Decimal
            value = (int16_t)[trimmed integerValue];
        }
    } @catch (NSException *exception) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Can not convert '%@'. This is not a valid %@ Number!", string, [self baseName]]
                                     userInfo:nil];
    }
    
    return [[self alloc] initWithShort:value];
}

// MARK: - NSObject Overrides

- (NSString *)description {
    switch ([[self class] digitBase]) {
        case 16:
            return [NSString stringWithFormat:@"0x%x", (unsigned int)_integerValue];
        case 2:
            return [NSString stringWithFormat:@"b%@", [self binaryStringFromInteger:_integerValue]];
        default:
            return [NSString stringWithFormat:@"%ld", (long)_integerValue];
    }
}

// MARK: - Private Methods

- (NSString *)binaryStringFromInteger:(NSInteger)value {
    if (value == 0) return @"0";
    
    NSMutableString *binary = [[NSMutableString alloc] init];
    NSInteger temp = value;
    
    while (temp > 0) {
        [binary insertString:(temp & 1) ? @"1" : @"0" atIndex:0];
        temp >>= 1;
    }
    
    return [binary copy];
}

@end

// MARK: - PropertyObject Implementation

@interface PropertyObject ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BaseChangeShort *> *values;
@end

@implementation PropertyObject

- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSNumber *> *)dictionary {
    self = [super init];
    if (self) {
        _values = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in dictionary) {
            NSNumber *number = dictionary[key];
            BaseChangeShort *value = [[BaseChangeShort alloc] initWithShort:[number shortValue]];
            _values[key] = value;
        }
    }
    return self;
}

- (BaseChangeShort *)valueForKey:(NSString *)key {
    return _values[key];
}

- (void)setValue:(BaseChangeShort *)value forKey:(NSString *)key {
    if (value) {
        _values[key] = value;
    } else {
        [_values removeObjectForKey:key];
    }
}

- (NSDictionary<NSString *, NSNumber *> *)properties {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in _values) {
        BaseChangeShort *value = _values[key];
        result[key] = @(value.value);
    }
    
    return [result copy];
}

- (NSArray<NSString *> *)allKeys {
    return [_values allKeys];
}

@end
