//
//  PropertyUserTypes.m
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

#import "PropertyUserTypes.h"
#import "Helper.h"

@implementation FloatColor

+ (FloatColor *)fromColor:(NSColor *)color {
    return [[FloatColor alloc] initWithColor:color];
}

+ (FloatColor *)fromString:(NSString *)string {
    return [[FloatColor alloc] initWithString:string];
}

- (instancetype)initWithColor:(NSColor *)color {
    self = [super init];
    if (self) {
        _color = color;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _color = [FloatColor toColor:string];
    }
    return self;
}

- (float)toFloat:(NSInteger)component {
    double d = (double)component / (double)0xff;
    return (float)d;
}

- (NSString *)toString {
    // Convert NSColor to RGB color space if needed
    NSColor *rgbColor = [_color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    CGFloat red, green, blue, alpha;
    [rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSInteger redInt = (NSInteger)(red * 255);
    NSInteger greenInt = (NSInteger)(green * 255);
    NSInteger blueInt = (NSInteger)(blue * 255);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:5];
    [formatter setMaximumFractionDigits:5];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    return [NSString stringWithFormat:@"%@,%@,%@",
            [formatter stringFromNumber:@([self toFloat:redInt])],
            [formatter stringFromNumber:@([self toFloat:greenInt])],
            [formatter stringFromNumber:@([self toFloat:blueInt])]];
}

- (NSString *)description {
    return [self toString];
}

+ (NSColor *)toColor:(NSString *)string {
    NSColor *resultColor = [NSColor blackColor];
    
    // Remove all spaces
    NSString *cleanString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([cleanString rangeOfString:@";"].location == NSNotFound) {
        // Comma-separated float values
        NSArray<NSString *> *parts = [cleanString componentsSeparatedByString:@","];
        
        if (parts.count < 3) {
            resultColor = [NSColor blackColor];
        } else if (parts.count == 3) {
            CGFloat red = [parts[0] floatValue];
            CGFloat green = [parts[1] floatValue];
            CGFloat blue = [parts[2] floatValue];
            
            resultColor = [NSColor colorWithSRGBRed:red green:green blue:blue alpha:1.0];
        } else {
            CGFloat red = [parts[0] floatValue];
            CGFloat green = [parts[1] floatValue];
            CGFloat blue = [parts[2] floatValue];
            CGFloat alpha = [parts[3] floatValue];
            
            resultColor = [NSColor colorWithSRGBRed:red green:green blue:blue alpha:alpha];
        }
    } else {
        // Semicolon-separated integer values
        NSArray<NSString *> *parts = [cleanString componentsSeparatedByString:@";"];
        
        if (parts.count < 3) {
            resultColor = [NSColor blackColor];
        } else if (parts.count == 3) {
            CGFloat red = [parts[0] integerValue] / 255.0;
            CGFloat green = [parts[1] integerValue] / 255.0;
            CGFloat blue = [parts[2] integerValue] / 255.0;
            
            resultColor = [NSColor colorWithSRGBRed:red green:green blue:blue alpha:1.0];
        } else {
            CGFloat red = [parts[0] integerValue] / 255.0;
            CGFloat green = [parts[1] integerValue] / 255.0;
            CGFloat blue = [parts[2] integerValue] / 255.0;
            CGFloat alpha = [parts[3] integerValue] / 255.0;
            
            resultColor = [NSColor colorWithSRGBRed:red green:green blue:blue alpha:alpha];
        }
    }
    
    return resultColor;
}

@end

@implementation BaseChangeableNumber {
    int64_t _val;
    Class _type;
}

static NSInteger _digitBase = 16;

+ (NSInteger)digitBase {
    return _digitBase;
}

+ (void)setDigitBase:(NSInteger)digitBase {
    _digitBase = digitBase;
}

+ (NSString *)baseName {
    if (_digitBase == 16) return @"Hexadecimal";
    if (_digitBase == 2) return @"Binary";
    return @"Decimal";
}

- (Class)type {
    return _type;
}

- (instancetype)initWithObject:(id)value {
    self = [super init];
    if (self) {
        [self setObjectValue:value];
        if (value) {
            _type = [value class];
        }
    }
    return self;
}

- (instancetype)initWithObject:(id)value type:(Class)type {
    self = [super init];
    if (self) {
        [self setValue:value withType:type];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _val = 0;
        _type = [NSNumber class];
    }
    return self;
}

+ (BaseChangeableNumber *)convertString:(NSString *)string toType:(Class)type {
    NSString *cleanString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    id value = @0;
    
    NSInteger base = 10;
    NSInteger offset = 0;
    
    if ([cleanString hasPrefix:@"0x"]) {
        base = 16;
        offset = 2;
    } else if ([cleanString hasPrefix:@"b"]) {
        base = 2;
        offset = 1;
    }
    
    NSString *numberString = [cleanString substringFromIndex:offset];
    
    // Convert based on type
    if (type == [NSNumber class]) {
        // Determine the specific numeric type from context
        long long longValue = strtoll([numberString UTF8String], NULL, (int)base);
        
        // For now, default to int64_t
        value = @(longValue);
    } else {
        // Handle specific numeric types if needed
        long long longValue = strtoll([numberString UTF8String], NULL, (int)base);
        value = @(longValue);
    }
    
    return [[BaseChangeableNumber alloc] initWithObject:value type:type];
}

- (int16_t)value {
    return (int16_t)(_val & 0xffff);
}

- (void)setValue:(int16_t)value {
    _val = (int16_t)(value & 0xffff);
}

- (int32_t)integerValue {
    return (int32_t)_val;
}

- (void)setIntegerValue:(int32_t)integerValue {
    _val = integerValue;
}

- (int64_t)longValue {
    return _val;
}

- (void)setLongValue:(int64_t)longValue {
    _val = longValue;
}

- (void)setValue:(id)object withType:(Class)type {
    _type = type;
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        
        // Handle different numeric types
        const char *objCType = [number objCType];
        
        if (strcmp(objCType, @encode(char)) == 0) {
            _val = [number charValue];
        } else if (strcmp(objCType, @encode(unsigned char)) == 0) {
            _val = [number unsignedCharValue];
        } else if (strcmp(objCType, @encode(short)) == 0) {
            _val = [number shortValue];
        } else if (strcmp(objCType, @encode(unsigned short)) == 0) {
            _val = [number unsignedShortValue];
        } else if (strcmp(objCType, @encode(int)) == 0) {
            _val = [number intValue];
        } else if (strcmp(objCType, @encode(unsigned int)) == 0) {
            _val = [number unsignedIntValue];
        } else if (strcmp(objCType, @encode(long)) == 0) {
            _val = [number longValue];
        } else if (strcmp(objCType, @encode(unsigned long)) == 0) {
            _val = (long)[number unsignedLongValue];
        } else if (strcmp(objCType, @encode(long long)) == 0) {
            _val = [number longLongValue];
        } else {
            _val = [number longLongValue];
        }
    } else {
        _val = [object longLongValue];
    }
    
    _type = type;
}

- (id)objectValue {
    if (_type == [NSNumber class]) {
        // Return appropriate NSNumber type based on original type
        const char *typeName = [NSStringFromClass(_type) UTF8String];
        
        // For simplicity, return as NSNumber with appropriate value
        return @(_val);
    }
    
    return @(_val);
}

- (void)setObjectValue:(id)objectValue {
    [self setValue:objectValue withType:[objectValue class]];
}

- (NSString *)toString {
    NSInteger length = 64;
    
    // Determine bit length based on type
    if (_type == [NSNumber class]) {
        // Default handling for NSNumber
        length = 32;
    }
    
    if (_digitBase == 16) {
        length = length / 4;
        NSString *hexString = [NSString stringWithFormat:@"%llx", _val];
        return [NSString stringWithFormat:@"0x%@", [Helper hexStringWithPadding:(NSUInteger)_val padding:length]];
    } else if (_digitBase == 2) {
        // Convert to binary string
        NSMutableString *binaryString = [[NSMutableString alloc] init];
        long long tempVal = _val;
        
        if (tempVal == 0) {
            [binaryString appendString:@"0"];
        } else {
            while (tempVal > 0) {
                [binaryString insertString:(tempVal % 2 ? @"1" : @"0") atIndex:0];
                tempVal /= 2;
            }
        }
        
        // Pad to length
        while (binaryString.length < length) {
            [binaryString insertString:@"0" atIndex:0];
        }
        
        return [NSString stringWithFormat:@"b%@", binaryString];
    } else {
        return [NSString stringWithFormat:@"%lld", _val];
    }
}

- (NSString *)description {
    return [self toString];
}

- (uint32_t)unsignedIntegerValue {
    return (uint32_t)[self integerValue];
}

@end
#import <Foundation/Foundation.h>
