//
//  GlobalizedObject.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *from http://www.thecodeproject.com/cs/miscctrl/globalizedpropertygrid.asp*
// ***************************************************************************
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

#import "GlobalizedObject.h"
#import <objc/runtime.h>

// MARK: - GlobalizedPropertyAttribute Implementation

@implementation GlobalizedPropertyAttribute

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _resourceName = name ? [name copy] : @"";
        _resourceDescription = @"";
        _resourceTable = @"";
    }
    return self;
}

- (NSString *)name {
    return self.resourceName;
}

- (void)setName:(NSString *)name {
    self.resourceName = name ? [name copy] : @"";
}

- (NSString *)description {
    return self.resourceDescription;
}

- (void)setDescription:(NSString *)description {
    self.resourceDescription = description ? [description copy] : @"";
}

- (NSString *)table {
    return self.resourceTable;
}

- (void)setTable:(NSString *)table {
    self.resourceTable = table ? [table copy] : @"";
}

@end

// MARK: - GlobalizedPropertyDescriptor Implementation

@implementation GlobalizedPropertyDescriptor

- (instancetype)initWithResourceManager:(NSBundle *)resourceManager
                basePropertyDescriptor:(NSDictionary *)basePropertyDescriptor {
    self = [super init];
    if (self) {
        _resourceManager = resourceManager;
        _basePropertyDescriptor = basePropertyDescriptor;
        _localizedName = @"";
        _localizedDescription = @"";
        _localizedCategory = @"";
    }
    return self;
}

- (BOOL)canResetValue:(id)component {
    // In Objective-C, we'll use runtime introspection to determine if a property can be reset
    // For now, return YES as a default implementation
    return YES;
}

- (Class)componentType {
    NSString *componentTypeName = self.basePropertyDescriptor[@"componentType"];
    if (componentTypeName) {
        return NSClassFromString(componentTypeName);
    }
    return [NSObject class];
}

- (NSString *)displayName {
    // First lookup the property if GlobalizedPropertyAttribute instances are available.
    // If yes, then try to get resource table name and display name id from that attribute.
    NSString *tableName = @"";
    NSString *displayName = @"";
    
    NSArray *attributes = self.basePropertyDescriptor[@"attributes"];
    for (GlobalizedPropertyAttribute *attribute in attributes) {
        if ([attribute isKindOfClass:[GlobalizedPropertyAttribute class]]) {
            displayName = attribute.name;
            tableName = attribute.table;
            break;
        }
    }
    
    // If no resource table specified by attribute, then build it itself by using namespace and class name.
    if ([tableName length] == 0) {
        NSString *className = NSStringFromClass([self componentType]);
        tableName = className;
    }
    
    // If no display name id is specified by attribute, then construct it by using default display name (usually the property name)
    if ([displayName length] == 0) {
        displayName = self.basePropertyDescriptor[@"displayName"];
    }
    
    // Get the string from the resources.
    // If this fails, then use default display name (usually the property name)
    NSString *resourceKey = [NSString stringWithFormat:@"[Property:%@]", displayName];
    NSString *localizedString = [self.resourceManager localizedStringForKey:resourceKey
                                                                       value:nil
                                                                       table:nil];
    
    self.localizedName = localizedString ? localizedString : (self.basePropertyDescriptor[@"displayName"] ?: @"");
    
    return self.localizedName;
}

- (NSString *)category {
    // First lookup the property if there are GlobalizedPropertyAttribute instances available.
    NSString *tableName = @"";
    NSString *displayName = @"";
    
    NSArray *attributes = self.basePropertyDescriptor[@"attributes"];
    for (GlobalizedPropertyAttribute *attribute in attributes) {
        if ([attribute isKindOfClass:[GlobalizedPropertyAttribute class]]) {
            displayName = attribute.description;
            tableName = attribute.table;
            break;
        }
    }
    
    // If no resource table specified by attribute, then build it itself by using namespace and class name.
    if ([tableName length] == 0) {
        NSString *className = NSStringFromClass([self componentType]);
        tableName = className;
    }
    
    // If no display name id is specified by attribute, then construct it by using default display name
    if ([displayName length] == 0) {
        displayName = self.basePropertyDescriptor[@"category"];
    }
    
    // Get the string from the resources.
    // If this fails, then use default empty string indicating 'no description'
    NSString *resourceKey = [NSString stringWithFormat:@"[Category:%@]", displayName];
    NSString *localizedString = [self.resourceManager localizedStringForKey:resourceKey
                                                                       value:nil
                                                                       table:nil];
    
    self.localizedCategory = localizedString ? localizedString : @"";
    
    return self.localizedCategory;
}

- (NSString *)description {
    // First lookup the property if there are GlobalizedPropertyAttribute instances available.
    NSString *tableName = @"";
    NSString *displayName = @"";
    
    NSArray *attributes = self.basePropertyDescriptor[@"attributes"];
    for (GlobalizedPropertyAttribute *attribute in attributes) {
        if ([attribute isKindOfClass:[GlobalizedPropertyAttribute class]]) {
            displayName = attribute.description;
            tableName = attribute.table;
            break;
        }
    }
    
    // If no resource table specified by attribute, then build it itself by using namespace and class name.
    if ([tableName length] == 0) {
        NSString *className = NSStringFromClass([self componentType]);
        tableName = className;
    }
    
    // If no display name id is specified by attribute, then construct it by using default display name
    if ([displayName length] == 0) {
        displayName = self.basePropertyDescriptor[@"displayName"];
    }
    
    // Get the string from the resources.
    // If this fails, then use default empty string indicating 'no description'
    NSString *resourceKey = [NSString stringWithFormat:@"[Description:%@]", displayName];
    NSString *localizedString = [self.resourceManager localizedStringForKey:resourceKey
                                                                       value:nil
                                                                       table:nil];
    
    self.localizedDescription = localizedString ? localizedString : @"";
    
    return self.localizedDescription;
}

- (id)getValue:(id)component {
    NSString *propertyName = self.basePropertyDescriptor[@"name"];
    if (propertyName && [component respondsToSelector:NSSelectorFromString(propertyName)]) {
        return [component valueForKey:propertyName];
    }
    return nil;
}

- (BOOL)isReadOnly {
    NSNumber *readOnly = self.basePropertyDescriptor[@"isReadOnly"];
    return readOnly ? [readOnly boolValue] : NO;
}

- (NSString *)name {
    return self.basePropertyDescriptor[@"name"];
}

- (Class)propertyType {
    NSString *propertyTypeName = self.basePropertyDescriptor[@"propertyType"];
    if (propertyTypeName) {
        return NSClassFromString(propertyTypeName);
    }
    return [NSObject class];
}

- (void)resetValue:(id)component {
    // Implementation depends on specific property reset logic
    // For now, this is a placeholder
}

- (BOOL)shouldSerializeValue:(id)component {
    // Default implementation - in most cases we want to serialize
    return YES;
}

- (void)setValue:(id)value forComponent:(id)component {
    NSString *propertyName = self.basePropertyDescriptor[@"name"];
    if (propertyName && [component respondsToSelector:NSSelectorFromString(propertyName)]) {
        [component setValue:value forKey:propertyName];
    }
}

@end

// MARK: - GlobalizedObject Implementation

@implementation GlobalizedObject

- (instancetype)init {
    return [self initWithResourceManager:[Localization bundle]];
}

- (instancetype)initWithResourceManager:(NSBundle *)resourceManager {
    self = [super init];
    if (self) {
        _resourceManager = resourceManager;
        _globalizedProperties = nil;
    }
    return self;
}

- (NSString *)getClassName {
    return NSStringFromClass([self class]);
}

- (NSArray *)getAttributes {
    // Return an empty array as default implementation
    // In a full implementation, this would return runtime attributes
    return @[];
}

- (NSString *)getComponentName {
    return NSStringFromClass([self class]);
}

- (id)getConverter {
    // Default implementation - return nil
    return nil;
}

- (NSDictionary *)getDefaultEvent {
    // Default implementation - return nil
    return nil;
}

- (GlobalizedPropertyDescriptor *)getDefaultProperty {
    // Default implementation - return nil
    return nil;
}

- (id)getEditorForType:(Class)editorBaseType {
    // Default implementation - return nil
    return nil;
}

- (NSArray *)getEventsWithAttributes:(NSArray *)attributes {
    // Default implementation - return empty array
    return @[];
}

- (NSArray *)getEvents {
    return [self getEventsWithAttributes:nil];
}

- (NSArray<GlobalizedPropertyDescriptor *> *)getPropertiesWithAttributes:(NSArray *)attributes {
    if (self.globalizedProperties == nil) {
        // Get the collection of properties using runtime introspection
        NSMutableArray *baseProps = [[NSMutableArray alloc] init];
        
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        
        for (unsigned int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            const char *propertyAttributes = property_getAttributes(property);
            
            NSMutableDictionary *propertyDict = [[NSMutableDictionary alloc] init];
            propertyDict[@"name"] = [NSString stringWithUTF8String:propertyName];
            propertyDict[@"displayName"] = [NSString stringWithUTF8String:propertyName];
            propertyDict[@"attributes"] = @[]; // Would need to extract actual attributes
            propertyDict[@"componentType"] = NSStringFromClass([self class]);
            propertyDict[@"isReadOnly"] = @NO; // Would need to parse property attributes
            propertyDict[@"category"] = @""; // Default empty category
            
            // Parse property type from attributes string
            if (propertyAttributes) {
                NSString *attrs = [NSString stringWithUTF8String:propertyAttributes];
                // This is a simplified parser - full implementation would be more robust
                propertyDict[@"propertyType"] = @"NSObject";
            }
            
            [baseProps addObject:propertyDict];
        }
        
        free(properties);
        
        NSMutableArray *globalizedProps = [[NSMutableArray alloc] init];
        
        // For each property use a property descriptor of our own that is able to be globalized
        for (NSDictionary *propertyDict in baseProps) {
            GlobalizedPropertyDescriptor *globalizedProp =
                [[GlobalizedPropertyDescriptor alloc] initWithResourceManager:self.resourceManager
                                                       basePropertyDescriptor:propertyDict];
            [globalizedProps addObject:globalizedProp];
        }
        
        self.globalizedProperties = [globalizedProps copy];
    }
    
    return self.globalizedProperties;
}

- (NSArray<GlobalizedPropertyDescriptor *> *)getProperties {
    return [self getPropertiesWithAttributes:nil];
}

- (id)getPropertyOwner:(GlobalizedPropertyDescriptor *)propertyDescriptor {
    return self;
}

@end
