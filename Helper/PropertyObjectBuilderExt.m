//
//  PropertyObjectBuilderExt.m
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

#import "PropertyObjectBuilderExt.h"
#import "PropertyUserTypes.h"
#import <AppKit/AppKit.h>

@implementation PropertyDescription {
    NSString *_description;
    NSString *_category;
    id _property;
    Class _type;
    BOOL _readOnly;
}

- (instancetype)initWithCategory:(NSString *)category
                     description:(NSString *)description
                        property:(id)property {
    return [self initWithCategory:category
                      description:description
                         property:property
                             type:[property class]
                         readOnly:NO];
}

- (instancetype)initWithCategory:(NSString *)category
                     description:(NSString *)description
                        property:(id)property
                        readOnly:(BOOL)readOnly {
    return [self initWithCategory:category
                      description:description
                         property:property
                             type:[property class]
                         readOnly:readOnly];
}

- (instancetype)initWithCategory:(NSString *)category
                     description:(NSString *)description
                        property:(id)property
                            type:(Class)type
                        readOnly:(BOOL)readOnly {
    self = [super init];
    if (self) {
        _description = [description copy];
        _category = [category copy];
        _property = property;
        _readOnly = readOnly;
        _type = type;
    }
    return self;
}

- (NSString *)propertyDescription {
    return _description;
}

- (NSString *)category {
    return _category;
}

- (BOOL)readOnly {
    return _readOnly;
}

- (Class)type {
    return _type;
}

- (id)property {
    if ([_property isKindOfClass:[NSNumber class]]) {
        // Handle numeric types that should be wrapped in BaseChangeableNumber
        NSNumber *number = (NSNumber *)_property;
        const char *objCType = [number objCType];
        
        if (strcmp(objCType, @encode(char)) == 0 ||
            strcmp(objCType, @encode(short)) == 0 ||
            strcmp(objCType, @encode(int)) == 0 ||
            strcmp(objCType, @encode(long)) == 0 ||
            strcmp(objCType, @encode(long long)) == 0 ||
            strcmp(objCType, @encode(unsigned char)) == 0 ||
            strcmp(objCType, @encode(unsigned short)) == 0 ||
            strcmp(objCType, @encode(unsigned int)) == 0 ||
            strcmp(objCType, @encode(unsigned long)) == 0 ||
            strcmp(objCType, @encode(unsigned long long)) == 0) {
            return [[BaseChangeableNumber alloc] initWithObject:_property];
        }
    }
    
    return _property;
}

- (void)setProperty:(id)property {
    if ([property isKindOfClass:[BaseChangeableNumber class]]) {
        BaseChangeableNumber *changeableNumber = (BaseChangeableNumber *)property;
        _property = [changeableNumber objectValue];
    } else {
        @try {
            // Handle enum types (in Objective-C, we'll use NSString representations)
            if ([property isKindOfClass:[NSNumber class]] && _type == [NSString class]) {
                // Convert number to string for enum-like behavior
                _property = [property stringValue];
            }
            // Handle FloatColor conversions
            else if (_type == [FloatColor class] && [property isKindOfClass:[NSString class]]) {
                _property = [FloatColor fromString:(NSString *)property];
            }
            else if (_type == [FloatColor class] && [property isKindOfClass:[NSColor class]]) {
                _property = [FloatColor fromColor:(NSColor *)property];
            }
            // Handle general type conversions
            else {
                _property = property;
                if (property) {
                    _type = [property class];
                }
            }
        }
        @catch (NSException *exception) {
            // Special handle for Booleans from strings
            if (_type == [NSNumber class] && [property isKindOfClass:[NSString class]]) {
                NSString *stringValue = [(NSString *)property stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([stringValue isEqualToString:@"0"]) {
                    _property = @NO;
                } else {
                    _property = @YES;
                }
            } else {
                _property = property;
                if (property) {
                    _type = [property class];
                }
            }
        }
    }
}

- (PropertyDescription *)clone {
    return [[PropertyDescription alloc] initWithCategory:_category
                                             description:_description
                                                property:nil
                                                    type:_type
                                                readOnly:_readOnly];
}

@end

@implementation PropertyObjectBuilderExt {
    NSMutableDictionary *_properties;
    DynamicPropertyContainer *_instance;
}

- (instancetype)initWithProperties:(NSMutableDictionary *)properties {
    self = [super init];
    if (self) {
        _properties = [properties mutableCopy];
        
        // Create property descriptions dictionary
        NSMutableDictionary *descriptions = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in properties) {
            id value = properties[key];
            
            if ([value isKindOfClass:[PropertyDescription class]]) {
                descriptions[key] = value;
            } else {
                // Create a default PropertyDescription for non-PropertyDescription values
                PropertyDescription *pd = [[PropertyDescription alloc] initWithCategory:nil
                                                                           description:@"[Unknown Property]"
                                                                              property:value
                                                                              readOnly:NO];
                descriptions[key] = pd;
            }
        }
        
        // Create the dynamic container instance
        _instance = [[DynamicPropertyContainer alloc] initWithPropertyDescriptions:descriptions];
        
        // Set initial values
        for (NSString *key in properties) {
            id value = properties[key];
            
            if ([value isKindOfClass:[PropertyDescription class]]) {
                PropertyDescription *pd = (PropertyDescription *)value;
                id propertyValue = [pd property];
                
                // Convert FloatColor to NSColor for UI purposes
                if ([propertyValue isKindOfClass:[FloatColor class]]) {
                    FloatColor *floatColor = (FloatColor *)propertyValue;
                    propertyValue = [floatColor color];
                }
                
                [_instance setPropertyValue:propertyValue forKey:key];
            } else {
                [_instance setPropertyValue:value forKey:key];
            }
        }
    }
    return self;
}

- (NSMutableDictionary *)properties {
    if (!_instance) {
        return [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [_instance allPropertyKeys]) {
        id value = [_instance propertyValueForKey:key];
        
        if ([value isKindOfClass:[BaseChangeableNumber class]]) {
            BaseChangeableNumber *changeableNumber = (BaseChangeableNumber *)value;
            value = [changeableNumber objectValue];
        } else if ([value isKindOfClass:[NSColor class]]) {
            value = [FloatColor fromColor:(NSColor *)value];
        }
        
        result[key] = value;
    }
    
    return result;
}

- (id)instance {
    return _instance;
}

@end

@implementation DynamicPropertyContainer

- (instancetype)initWithPropertyDescriptions:(NSMutableDictionary *)descriptions {
    self = [super init];
    if (self) {
        _propertyStorage = [[NSMutableDictionary alloc] init];
        _propertyDescriptions = [descriptions mutableCopy];
    }
    return self;
}

- (void)setPropertyValue:(id)value forKey:(NSString *)key {
    if (value) {
        _propertyStorage[key] = value;
    } else {
        [_propertyStorage removeObjectForKey:key];
    }
}

- (id)propertyValueForKey:(NSString *)key {
    return _propertyStorage[key];
}

- (NSArray<NSString *> *)allPropertyKeys {
    return [_propertyStorage allKeys];
}

// Support for KVC (Key-Value Coding) to enable property access
- (void)setValue:(id)value forKey:(NSString *)key {
    [self setPropertyValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key {
    return [self propertyValueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self setPropertyValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [self propertyValueForKey:key];
}

@end
