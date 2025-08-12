//
//  ASerializeFormater.m
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

#import "ASerializeFormater.h"
#import "IPackedFileName.h"
#import "IPackedFileDescriptorBasic.h"
#import "Serializer.h"
#import "Helper.h"
#import "TypeAlias.h"
#import <objc/runtime.h>
#import "ExceptionForm.h"

@implementation AbstractSerializer

// MARK: - Abstract Properties (must be overridden)

- (NSString *)separator {
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be overridden", NSStringFromSelector(_cmd)];
    return nil;
}

// MARK: - Abstract Methods (must be overridden)

- (NSString *)saveString:(NSString *)value {
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be overridden", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSString *)subProperty:(NSString *)name value:(NSString *)value {
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be overridden", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSString *)property:(NSString *)name value:(NSString *)value {
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be overridden", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSString *)nullProperty:(NSString *)name {
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be overridden", NSStringFromSelector(_cmd)];
    return nil;
}

// MARK: - Concrete Methods

- (NSString *)serializeTGIHeader {
    NSString *sep = self.separator;
    return [NSString stringWithFormat:@"Name%@Type%@Group%@InstanceHi%@Instance%@",
            sep, sep, sep, sep, sep];
}

- (NSString *)serializeHeaderForObject:(id)object
                           objectClass:(Class)objectClass
                            properties:(NSArray<NSString *> *)properties {
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (NSString *propertyName in properties) {
        @try {
            // Check if property exists and is readable
            objc_property_t property = class_getProperty(objectClass, [propertyName UTF8String]);
            if (property == NULL) continue;
            
            // Get property attributes to check if it's readable
            const char *attrs = property_getAttributes(property);
            NSString *attributeString = [NSString stringWithUTF8String:attrs];
            if ([attributeString containsString:@",R"]) continue; // Read-only check
            
            if (result.length > 0) {
                [result appendString:self.separator];
            }
            
            [result appendString:propertyName];
            
            // Get property value
            id value = [object valueForKey:propertyName];
            NSString *headerExtension = @"";
            
            if ([value conformsToProtocol:@protocol(IPackedFileName)]) {
                id<IPackedFileName> packedFileName = (id<IPackedFileName>)value;
                if ([packedFileName respondsToSelector:@selector(descriptionHeader)]) {
                    headerExtension = [packedFileName descriptionHeader];
                    [result appendString:headerExtension];
                }
            }
            
            if ([value isKindOfClass:[Serializer class]] && headerExtension.length == 0) {
                NSString *typeHeader = [Serializer serializeTypeHeader:value];
                [result appendString:typeHeader];
            }
        }
        @catch (NSException *exception) {
            [ExceptionForm executeWithMessage:[exception reason] exception:exception];
        }
    }
    
    return [result copy];
}

- (NSString *)serializeObject:(id)object
                  objectClass:(Class)objectClass
                   properties:(NSArray<NSString *> *)properties {
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (NSString *propertyName in properties) {
        @try {
            // Check if property exists and is readable
            objc_property_t property = class_getProperty(objectClass, [propertyName UTF8String]);
            if (property == NULL) continue;
            
            // Get property attributes to check if it's readable
            const char *attrs = property_getAttributes(property);
            NSString *attributeString = [NSString stringWithUTF8String:attrs];
            if ([attributeString containsString:@",R"]) continue; // Read-only check
            
            if (result.length > 0) {
                [result appendString:self.separator];
            }
            
            // Get property value
            id value = [object valueForKey:propertyName];
            
            if (value == nil) {
                [result appendString:[self nullProperty:propertyName]];
            } else if ([value isKindOfClass:[Serializer class]]) {
                Serializer *serializer = (Serializer *)value;
                [result appendString:[serializer toStringWithName:propertyName]];
            } else {
                [result appendString:[self property:propertyName value:[value description]]];
            }
        }
        @catch (NSException *exception) {
            [ExceptionForm executeWithMessage:[exception reason] exception:exception];
        }
    }
    
    return [result copy];
}

- (NSString *)serializeTGI:(id<IPackedFileName>)wrapper
                descriptor:(id<IPackedFileDescriptorBasic>)descriptor {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *sep = self.separator;
    
    // Name
    if (wrapper != nil) {
        [result appendString:[self saveString:[wrapper resourceName]]];
    } else {
        [result appendString:[self saveString:[[descriptor pfdTypeName] description]]];
    }
    [result appendString:sep];
    
    // Type
    [result appendFormat:@"0x%@%@", [Helper hexString:[descriptor type]], sep];
    
    // Group
    [result appendFormat:@"0x%@%@", [Helper hexString:[descriptor group]], sep];
    
    // SubType (InstanceHi)
    [result appendFormat:@"0x%@%@", [Helper hexString:[descriptor subtype]], sep];
    
    // Instance
    [result appendFormat:@"0x%@%@", [Helper hexString:[descriptor instance]], sep];
    
    return [result copy];
}

- (NSString *)concat:(NSArray<NSString *> *)properties {
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (NSString *property in properties) {
        if (result.length > 0) {
            [result appendString:self.separator];
        }
        [result appendString:property];
    }
    
    return [result copy];
}

- (NSString *)concatHeader:(NSArray<NSString *> *)properties {
    return [self concat:properties];
}

- (NSString *)saveStr:(NSString *)val {
    // If val is nil, store an empty string
    return val ?: @"";
}

- (NSString *)serialize:(id)object
                   class:(Class)objectClass
          propertyNames:(NSArray<NSString *> *)propertyNames {
    // Minimal stub: just return the class name and property count
    return [NSString stringWithFormat:@"<%@ with %lu properties>",
            NSStringFromClass(objectClass),
            (unsigned long)propertyNames.count];
}

- (NSString *)serializeHeader:(id)object
                        class:(Class)objectClass
               propertyNames:(NSArray<NSString *> *)propertyNames {
    // Minimal stub: header info only
    return [NSString stringWithFormat:@"Header for %@",
            NSStringFromClass(objectClass)];
}

@end
