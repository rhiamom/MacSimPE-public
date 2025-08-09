//
//  FlagBaseConverter.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

#import "FlagBaseConverter.h"
#import "FlagBase.h"
#import "Helper.h"

@implementation FlagBaseConverter

// MARK: - Type Conversion Support

- (BOOL)canConvertToType:(Class)destinationType {
    // Can convert FlagBase to FlagBase subclasses
    if ([destinationType isSubclassOfClass:[FlagBase class]]) {
        return YES;
    }
    
    // Can convert to string
    if (destinationType == [NSString class]) {
        return YES;
    }
    
    return NO;
}

- (id)convertObject:(id)value toType:(Class)destinationType {
    // Convert to string
    if (destinationType == [NSString class] && [value isKindOfClass:[FlagBase class]]) {
        return [self flagBaseToString:(FlagBase *)value];
    }
    
    // Convert between FlagBase types (if needed)
    if ([destinationType isSubclassOfClass:[FlagBase class]] && [value isKindOfClass:[FlagBase class]]) {
        FlagBase *flagBase = (FlagBase *)value;
        
        // If it's already the right type, return as-is
        if ([value isKindOfClass:destinationType]) {
            return value;
        }
        
        // Create new instance of target type with same value
        return [self createFlagBaseOfClass:destinationType withValue:[flagBase value]];
    }
    
    return nil;
}

- (BOOL)canConvertFromType:(Class)sourceType {
    // Can convert from string
    if (sourceType == [NSString class]) {
        return YES;
    }
    
    // Can convert from NSNumber
    if (sourceType == [NSNumber class]) {
        return YES;
    }
    
    return NO;
}

- (id)convertValue:(id)value toFlagBaseOfType:(Class)targetType {
    if (![targetType isSubclassOfClass:[FlagBase class]]) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [self stringToFlagBase:(NSString *)value ofClass:targetType];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)value;
        return [self createFlagBaseOfClass:targetType withValue:[number unsignedShortValue]];
    }
    
    return nil;
}

// MARK: - String Conversion Utilities

- (NSString *)flagBaseToString:(FlagBase *)flagBase {
    if (!flagBase) return @"";
    
    // Get the string representation and ensure minimum length of 16 characters
    NSString *flagString = [flagBase description];
    return [Helper minStrLength:flagString length:16];
}

- (FlagBase *)stringToFlagBase:(NSString *)binaryString ofClass:(Class)flagBaseClass {
    if (!binaryString || ![self isValidFlagString:binaryString]) {
        return nil;
    }
    
    @try {
        // Convert binary string to unsigned short
        uint16_t value = [self binaryStringToUShort:binaryString];
        
        // Create new instance of the specified FlagBase class
        return [self createFlagBaseOfClass:flagBaseClass withValue:value];
    }
    @catch (NSException *exception) {
        // Log the error and return nil
        NSLog(@"Error converting flag string '%@': %@", binaryString, exception.reason);
        return nil;
    }
}

// MARK: - Validation

- (BOOL)isValidFlagString:(NSString *)string {
    if (!string || string.length == 0) {
        return NO;
    }
    
    // Check if string contains only 0s and 1s
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"01"];
    NSCharacterSet *stringChars = [NSCharacterSet characterSetWithCharactersInString:string];
    
    return [validChars isSupersetOfSet:stringChars];
}

// MARK: - Helper Methods

- (uint16_t)binaryStringToUShort:(NSString *)binaryString {
    if (!binaryString || binaryString.length == 0) {
        @throw [NSException exceptionWithName:@"InvalidArgumentException"
                                       reason:@"Binary string cannot be nil or empty"
                                     userInfo:nil];
    }
    
    // Validate the string contains only 0s and 1s
    if (![self isValidFlagString:binaryString]) {
        @throw [NSException exceptionWithName:@"InvalidArgumentException"
                                       reason:[NSString stringWithFormat:@"'%@' is not a valid binary flag value!", binaryString]
                                     userInfo:nil];
    }
    
    // Convert binary string to unsigned short
    uint16_t result = 0;
    NSUInteger length = binaryString.length;
    
    for (NSUInteger i = 0; i < length; i++) {
        unichar ch = [binaryString characterAtIndex:i];
        result = result * 2 + (ch - '0');
        
        // Check for overflow
        if (result > UINT16_MAX) {
            @throw [NSException exceptionWithName:@"OverflowException"
                                           reason:@"Binary string value exceeds uint16_t range"
                                         userInfo:nil];
        }
    }
    
    return result;
}

- (FlagBase *)createFlagBaseOfClass:(Class)flagBaseClass withValue:(uint16_t)value {
    if (![flagBaseClass isSubclassOfClass:[FlagBase class]]) {
        return nil;
    }
    
    // Use the designated initializer that takes a value
    return [[flagBaseClass alloc] initWithValue:value];
}

@end
