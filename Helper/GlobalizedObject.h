//
//  GlobalizedObject.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *from http://www.thecodeproject.com/cs/miscctrl/globalizedpropertygrid.asp*
// ***************************************************************************
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

#import <Foundation/Foundation.h>
#import "Localization.h"

// MARK: - GlobalizedPropertyAttribute

@interface GlobalizedPropertyAttribute : NSObject

@property (nonatomic, strong) NSString *resourceName;
@property (nonatomic, strong) NSString *resourceDescription;
@property (nonatomic, strong) NSString *resourceTable;

- (instancetype)initWithName:(NSString *)name;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *table;

@end

// MARK: - GlobalizedPropertyDescriptor

/// <summary>
/// GlobalizedPropertyDescriptor enhances the base class by obtaining the display name for a property
/// from the resource.
/// </summary>
@interface GlobalizedPropertyDescriptor : NSObject

@property (nonatomic, strong) NSBundle *resourceManager;
@property (nonatomic, strong) NSDictionary *basePropertyDescriptor;
@property (nonatomic, strong) NSString *localizedName;
@property (nonatomic, strong) NSString *localizedDescription;
@property (nonatomic, strong) NSString *localizedCategory;

- (instancetype)initWithResourceManager:(NSBundle *)resourceManager
                basePropertyDescriptor:(NSDictionary *)basePropertyDescriptor;

- (BOOL)canResetValue:(id)component;
- (Class)componentType;
- (NSString *)displayName;
- (NSString *)category;
- (NSString *)description;
- (id)getValue:(id)component;
- (BOOL)isReadOnly;
- (NSString *)name;
- (Class)propertyType;
- (void)resetValue:(id)component;
- (BOOL)shouldSerializeValue:(id)component;
- (void)setValue:(id)value forComponent:(id)component;

@end

// MARK: - GlobalizedObject

/// <summary>
/// GlobalizedObject implements custom type description to enable
/// required functionality to describe a type (class).
/// The main task of this class is to instantiate our own property descriptor
/// of type GlobalizedPropertyDescriptor.
/// </summary>
@interface GlobalizedObject : NSObject

@property (nonatomic, strong) NSBundle *resourceManager;
@property (nonatomic, strong) NSArray<GlobalizedPropertyDescriptor *> *globalizedProperties;

- (instancetype)init;
- (instancetype)initWithResourceManager:(NSBundle *)resourceManager;

- (NSString *)getClassName;
- (NSArray *)getAttributes;
- (NSString *)getComponentName;
- (id)getConverter;
- (NSDictionary *)getDefaultEvent;
- (GlobalizedPropertyDescriptor *)getDefaultProperty;
- (id)getEditorForType:(Class)editorBaseType;
- (NSArray *)getEventsWithAttributes:(NSArray *)attributes;
- (NSArray *)getEvents;
- (NSArray<GlobalizedPropertyDescriptor *> *)getPropertiesWithAttributes:(NSArray *)attributes;
- (NSArray<GlobalizedPropertyDescriptor *> *)getProperties;
- (id)getPropertyOwner:(GlobalizedPropertyDescriptor *)propertyDescriptor;

- (instancetype)initWithBundle:(NSBundle *)bundle
                     tableName:(NSString *)tableName NS_DESIGNATED_INITIALIZER;


@property (nonatomic, strong, readonly) NSBundle *bundle;
@property (nonatomic, copy, readonly) NSString *tableName;
@end
