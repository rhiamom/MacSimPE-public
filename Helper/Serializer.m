//
//  Serializer.m
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

#import "Serializer.h"
#import "ISerializeFormater.h"
#import "IPackedFileName.h"
#import "IPackedFileDescriptorBasic.h"
#import "DescriptiveSerializer.h"
#import <objc/runtime.h>

@implementation Serializer

// MARK: - Static Variables
static id<ISerializeFormater> _formater = nil;

// MARK: - Class Properties

+ (id<ISerializeFormater>)formater {
    if (_formater == nil) {
        [self resetFormater];
    }
    return _formater;
}

+ (void)setFormater:(id<ISerializeFormater>)formater {
    _formater = formater;
}

+ (void)resetFormater {
    _formater = [[DescriptiveSerializer alloc] init];
}

// MARK: - Instance Methods

- (NSString *)getPropertyDescription {
    return [Serializer serialize:self];
}

- (NSString *)description {
    return [self toStringWithName:NSStringFromClass([self class])];
}

- (NSString *)toStringWithName:(NSString *)name {
    return [Serializer subProperty:name value:[self getPropertyDescription]];
}

// MARK: - Static Utility Methods

+ (NSString *)saveStr:(NSString *)value {
    return [[self formater] saveStr:value];
}

+ (NSString *)subProperty:(NSString *)name value:(NSString *)value {
    return [[self formater] subProperty:name value:value];
}

+ (NSString *)property:(NSString *)name value:(NSString *)value {
    return [[self formater] property:name value:value];
}

+ (NSString *)separator {
    return [[self formater] separator];
}

// MARK: - Type Serialization

+ (NSString *)serializeTypeHeader:(id)object {
    if (object == nil) return @"";
    
    Class objectClass = [object class];
    NSArray<NSString *> *propertyNames = [self getPropertyNamesForClass:objectClass];
    
    return [[self formater] serializeHeader:object
                                      class:objectClass
                            propertyNames:propertyNames];
}

+ (NSString *)serializeTypeHeaderForWrapper:(id<IPackedFileName>)wrapper
                                 descriptor:(id<IPackedFileDescriptorBasic>)pfd {
    return [self serializeTypeHeaderForWrapper:wrapper descriptor:pfd withDescription:YES];
}

+ (NSString *)serializeTypeHeaderForWrapper:(id<IPackedFileName>)wrapper
                                 descriptor:(id<IPackedFileDescriptorBasic>)pfd
                            withDescription:(BOOL)withDesc {
    NSString *result = [[self formater] serializeTGIHeader];
    
    if (withDesc && wrapper != nil) {
        result = [result stringByAppendingString:[wrapper descriptionHeader]];
    }
    
    return result;
}

// MARK: - Object Serialization

+ (NSString *)serializeWrapper:(id<IPackedFileName>)wrapper
                    descriptor:(id<IPackedFileDescriptorBasic>)pfd {
    return [self serializeWrapper:wrapper descriptor:pfd withDescription:NO];
}

+ (NSString *)serializeWrapper:(id<IPackedFileName>)wrapper
                    descriptor:(id<IPackedFileDescriptorBasic>)pfd
               withDescription:(BOOL)withDesc {
    NSString *result = [[self formater] serializeTGI:wrapper descriptor:pfd];
    
    if (withDesc) {
        if (wrapper != nil) {
            result = [result stringByAppendingString:[wrapper description]];
        }
        result = [result stringByAppendingString:[self separator]];
    }
    
    return result;
}

+ (NSString *)serialize:(id)object {
    return [self serialize:object writeHeader:NO];
}

+ (NSString *)serialize:(id)object writeHeader:(BOOL)writeHeader {
    if (object == nil) return @"";
    
    Class objectClass = [object class];
    NSArray<NSString *> *propertyNames = [self getPropertyNamesForClass:objectClass];
    
    NSString *result = @"";
    if (writeHeader) {
        result = [[self formater] serializeHeader:object
                                            class:objectClass
                                  propertyNames:propertyNames];
    }
    
    result = [result stringByAppendingString:[[self formater] serialize:object
                                                                   class:objectClass
                                                         propertyNames:propertyNames]];
    return result;
}

// MARK: - Array Utilities

+ (NSArray<NSString *> *)convertArray:(NSArray *)array {
    NSMutableArray<NSString *> *result = [[NSMutableArray alloc] initWithCapacity:[array count]];
    
    for (id object in array) {
        [result addObject:[object description]];
    }
    
    return [result copy];
}

+ (NSString *)concat:(NSArray<NSString *> *)props {
    return [[self formater] concat:props];
}

+ (NSString *)concatHeader:(NSArray<NSString *> *)props {
    return [[self formater] concatHeader:props];
}

// MARK: - Private Helper Methods

+ (NSArray<NSString *> *)getPropertyNamesForClass:(Class)objectClass {
    NSMutableArray<NSString *> *propertyNames = [[NSMutableArray alloc] init];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(objectClass, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    free(properties);
    return [propertyNames copy];
}

@end
