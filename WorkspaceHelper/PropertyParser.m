//
//  PropertyParser.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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

#import "PropertyParser.h"
#import "PropertyUserTypes.h"

@implementation PropertyDescription

// MARK: - Initialization

- (instancetype)initWithCategory:(NSString *)category
                     description:(nullable NSString *)description
                    defaultValue:(id)defaultValue
                        readOnly:(BOOL)readOnly {
    self = [super init];
    if (self) {
        _category = [category copy];
        _descriptionText = [description copy];
        _defaultValue = defaultValue;
        _readOnly = readOnly;
    }
    return self;
}

@end

@interface PropertyParser()

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PropertyDescription *> *props;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *enums;

@end

@implementation PropertyParser

// MARK: - Initialization

- (instancetype)initWithPath:(NSString *)filename {
    self = [super init];
    if (self) {
        _filename = [filename copy];
        _props = nil;
        _enums = nil;
    }
    return self;
}

// MARK: - Properties

- (NSDictionary<NSString *, PropertyDescription *> *)properties {
    if (_props == nil) {
        [self load];
    }
    return [_props copy];
}

- (NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *)enumerations {
    if (_enums == nil) {
        [self load];
    }
    return [_enums copy];
}

// MARK: - Property Building

- (nullable id)buildValue:(NSString *)typeName stringValue:(nullable NSString *)value {
    id object = @0;
    
    if ([typeName isEqualToString:@"int"]) {
        if (value == nil) {
            object = @0;
        } else {
            object = @([value intValue]);
        }
    }
    else if ([typeName isEqualToString:@"bool"]) {
        if (value == nil) {
            object = @NO;
        } else {
            object = @([value intValue] != 0);
        }
    }
    else if ([typeName isEqualToString:@"bool"]) {
        if (value == nil) {
            object = @NO;
        } else {
            object = @([value intValue] != 0);
        }
    }
    else if ([typeName isEqualToString:@"color"]) {
        if (value == nil) {
            object = [FloatColor fromColor:[NSColor blackColor]];
        } else {
            object = [FloatColor fromString:value];
        }
    }
    else if ([typeName isEqualToString:@"float"] || [typeName isEqualToString:@"transparence"]) {
        if (value == nil) {
            object = @1.0;
        } else {
            object = @([value doubleValue]);
        }
    }
    else if ([typeName isEqualToString:@"string"] ||
             [typeName isEqualToString:@"txtrref"] ||
             [typeName isEqualToString:@"guid"] ||
             [typeName isEqualToString:@"vector2f"] ||
             [typeName isEqualToString:@"vector3f"]) {
        if (value == nil) {
            object = @"";
        } else {
            object = value;
        }
    }
    else if ([typeName hasPrefix:@"enum:"]) {
        NSArray<NSString *> *parts = [typeName componentsSeparatedByString:@":"];
        if (parts.count >= 2) {
            NSString *enumTypeName = parts[1];
            
            if ([_enums.allKeys containsObject:enumTypeName]) {
                NSDictionary<NSString *, NSNumber *> *enumDict = _enums[enumTypeName];
                if (value == nil) {
                    // Get first enum value
                    NSArray *enumValues = enumDict.allValues;
                    if (enumValues.count > 0) {
                        object = enumValues[0];
                    } else {
                        object = @0;
                    }
                } else {
                    object = @([value intValue]);
                }
            } else {
                // Handle external assembly enums - simplified for Objective-C
                NSArray<NSString *> *assemblyParts = [enumTypeName componentsSeparatedByString:@","];
                if (assemblyParts.count > 1) {
                    enumTypeName = assemblyParts[1];
                }
                
                // For now, just return integer value since we can't dynamically load types
                if (value == nil) {
                    object = @0;
                } else {
                    object = @([value intValue]);
                }
            }
        }
    }
    else if ([typeName hasPrefix:@"class:"]) {
        NSArray<NSString *> *parts = [typeName componentsSeparatedByString:@":"];
        if (parts.count >= 2) {
            NSString *classTypeName = parts[1];
            
            NSArray<NSString *> *assemblyParts = [classTypeName componentsSeparatedByString:@","];
            if (assemblyParts.count > 1) {
                classTypeName = assemblyParts[1];
            }
            
            // For now, simplified handling - would need proper class loading mechanism
            // This would require implementing IPropertyClass protocol equivalent
            object = value ? value : @"";
        }
    }
    
    return object;
}

// MARK: - Property Access

- (nullable PropertyDescription *)propertyForName:(NSString *)name {
    if (_props == nil) {
        [self load];
    }
    return _props[name];
}

- (BOOL)hasProperty:(NSString *)name {
    if (_props == nil) {
        [self load];
    }
    return [_props.allKeys containsObject:name];
}

// MARK: - Enumeration Access

- (nullable NSDictionary<NSString *, NSNumber *> *)enumerationForName:(NSString *)name {
    if (_enums == nil) {
        [self load];
    }
    return _enums[name];
}

- (BOOL)hasEnumeration:(NSString *)name {
    if (_enums == nil) {
        [self load];
    }
    return [_enums.allKeys containsObject:name];
}

// MARK: - XML Parsing

- (void)handleCategory:(NSXMLElement *)node {
    NSString *categoryName = [[node attributeForName:@"name"] stringValue];
    
    for (NSXMLNode *subnode in [node children]) {
        if ([[subnode name] isEqualToString:@"property"]) {
            [self handleProperty:(NSXMLElement *)subnode category:categoryName];
        }
    }
}

- (void)handleProperty:(NSXMLElement *)node propertyDescription:(PropertyDescription *)pd {
    // Override in subclasses for additional property handling
}

- (void)handleProperty:(NSXMLElement *)node category:(nullable NSString *)category {
    id defaultValue = @0;
    NSString *descriptionText = nil;
    NSString *name = @"Unknown";
    
    NSString *typeName = [[node attributeForName:@"type"] stringValue];
    defaultValue = [self buildValue:typeName stringValue:nil];
    BOOL readOnly = NO;
    
    for (NSXMLNode *subnode in [node children]) {
        NSString *nodeName = [subnode name];
        
        if ([nodeName isEqualToString:@"name"]) {
            name = [subnode stringValue];
        }
        else if ([nodeName isEqualToString:@"help"]) {
            descriptionText = [subnode stringValue];
        }
        else if ([nodeName isEqualToString:@"default"]) {
            defaultValue = [self buildValue:typeName stringValue:[subnode stringValue]];
        }
        else if ([nodeName isEqualToString:@"readonly"]) {
            readOnly = YES;
        }
    }
    
    PropertyDescription *pd = [[PropertyDescription alloc] initWithCategory:category
                                                                description:descriptionText
                                                               defaultValue:defaultValue
                                                                   readOnly:readOnly];
    
    [self handleProperty:node propertyDescription:pd];
    
    _props[name] = pd;
}

- (void)handleEnum:(NSXMLElement *)node {
    NSString *name = [[node attributeForName:@"name"] stringValue];
    NSMutableDictionary<NSString *, NSNumber *> *enumValues = [[NSMutableDictionary alloc] init];
    
    for (NSXMLNode *subnode in [node children]) {
        if ([[subnode name] isEqualToString:@"field"]) {
            NSString *fieldName = [subnode stringValue];
            NSString *valueString = [[((NSXMLElement *)subnode) attributeForName:@"value"] stringValue];
            NSNumber *value = @([valueString intValue]);
            enumValues[fieldName] = value;
        }
    }
    
    _enums[name] = [enumValues copy];
}

// MARK: - Loading

- (void)load {
    _props = [[NSMutableDictionary alloc] init];
    _enums = [[NSMutableDictionary alloc] init];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filename]) {
        return;
    }
    
    NSError *error = nil;
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_filename]
                                                                      options:0
                                                                        error:&error];
    
    if (error) {
        NSLog(@"Error loading XML file: %@", error.localizedDescription);
        return;
    }
    
    // Seek Root Node
    NSArray<NSXMLNode *> *rootNodes = [xmlDocument nodesForXPath:@"//properties" error:&error];
    
    if (error) {
        NSLog(@"Error parsing XML: %@", error.localizedDescription);
        return;
    }
    
    // Process all Root Node Entries
    for (NSXMLNode *rootNode in rootNodes) {
        if ([rootNode kind] == NSXMLElementKind) {
            NSXMLElement *rootElement = (NSXMLElement *)rootNode;
            
            for (NSXMLNode *subnode in [rootElement children]) {
                NSString *nodeName = [subnode name];
                
                if ([nodeName isEqualToString:@"property"]) {
                    [self handleProperty:(NSXMLElement *)subnode category:nil];
                }
                else if ([nodeName isEqualToString:@"category"]) {
                    [self handleCategory:(NSXMLElement *)subnode];
                }
                else if ([nodeName isEqualToString:@"enum"]) {
                    [self handleEnum:(NSXMLElement *)subnode];
                }
            }
        }
    }
}

@end
