//
//  DescriptiveSerializer.m
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
// ***************************************************************************

#import "DescriptiveSerializer.h"

@implementation DescriptiveSerializer

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialization specific to DescriptiveSerializer if needed
    }
    return self;
}

// MARK: - ISerializeFormater Protocol Implementation

- (NSString *)separator {
    return @";";
}

- (NSString *)saveStr:(NSString *)val {
    if (val == nil) return @"";
    
    NSString *result = val;
    result = [result stringByReplacingOccurrencesOfString:@";" withString:@","];
    result = [result stringByReplacingOccurrencesOfString:@"{" withString:@"["];
    result = [result stringByReplacingOccurrencesOfString:@"}" withString:@"]"];
    
    return result;
}

- (NSString *)subProperty:(NSString *)name value:(NSString *)val {
    if (val == nil) val = @"";
    return [NSString stringWithFormat:@"%@={%@}", name, val];
}

- (NSString *)property:(NSString *)name value:(NSString *)val {
    if (val == nil) val = @"";
    return [NSString stringWithFormat:@"%@=%@", name, [self saveStr:val]];
}

- (NSString *)nullProperty:(NSString *)name {
    return [self property:name value:@"NULL"];
}

- (NSString *)serialize:(id)object
                  class:(Class)objectClass
        propertyNames:(NSArray<NSString *> *)propertyNames {
    // Default implementation - can be overridden by subclasses
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (NSString *propertyName in propertyNames) {
        if ([result length] > 0) {
            [result appendString:[self separator]];
        }
        
        // Get property value using KVC
        @try {
            id value = [object valueForKey:propertyName];
            if (value == nil) {
                [result appendString:[self nullProperty:propertyName]];
            } else {
                [result appendString:[self property:propertyName value:[value description]]];
            }
        } @catch (NSException *exception) {
            [result appendString:[self nullProperty:propertyName]];
        }
    }
    
    return [result copy];
}

- (NSString *)serializeHeader:(id)object
                        class:(Class)objectClass
              propertyNames:(NSArray<NSString *> *)propertyNames {
    return @"";
}

- (NSString *)serializeTGI:(id<IPackedFileName>)wrapper
                descriptor:(id<IPackedFileDescriptorBasic>)pfd {
    // Default implementation - returns empty string
    // This would be implemented based on the specific TGI format needed
    return @"";
}

- (NSString *)serializeTGIHeader {
    return @"";
}

- (NSString *)concat:(NSArray<NSString *> *)props {
    return [props componentsJoinedByString:[self separator]];
}

- (NSString *)concatHeader:(NSArray<NSString *> *)props {
    return @"";
}

@end
