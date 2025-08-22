//
//  PropertyObjectBuilderExt.h
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

#import <Foundation/Foundation.h>

@class BaseChangeableNumber, FloatColor;

/**
 * Meta Descriptions for a Property
 */
@interface PropertyDescription : NSObject

/**
 * The Description of the Property (=Help Text)
 */
@property (nonatomic, readonly, copy) NSString *propertyDescription;

/**
 * The Category of the Property
 */
@property (nonatomic, readonly, copy) NSString *category;

/**
 * True if this Property is ReadOnly
 */
@property (nonatomic, readonly, assign) BOOL readOnly;

/**
 * The Property (=Content)
 */
@property (nonatomic, strong) id property;

/**
 * Returns the Type of the Object
 */
@property (nonatomic, readonly, assign) Class type;

/**
 * Creates a new Instance
 * @param category The category for this property
 * @param description The description for this property
 * @param property The property value
 */
- (instancetype)initWithCategory:(NSString *)category
                     description:(NSString *)description
                        property:(id)property;

/**
 * Creates a new Instance
 * @param category The category for this property
 * @param description The description for this property
 * @param property The property value
 * @param readOnly Whether this property is read-only
 */
- (instancetype)initWithCategory:(NSString *)category
                     description:(NSString *)description
                        property:(id)property
                        readOnly:(BOOL)readOnly;

/**
 * Creates a new Instance
 * @param category The category for this property
 * @param description The description for this property
 * @param property The property value
 * @param type The type of the object
 * @param readOnly Whether this property is read-only
 */
- (instancetype)initWithCategory:(NSString *)category
                     description:(NSString *)description
                        property:(id)property
                            type:(Class)type
                        readOnly:(BOOL)readOnly;

/**
 * Create a clone (this will NOT copy the property, but set it to nil!!!)
 * @return The cloned Object
 */
- (PropertyDescription *)clone;

@end

/**
 * Used to Dynamically create an Object Displayed in a PropertyGrid
 */
@interface PropertyObjectBuilderExt : NSObject

/**
 * All Properties stored in the object
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *properties;

/**
 * Returns the created Object
 */
@property (nonatomic, readonly, strong) id instance;

/**
 * Initialize with a dictionary of properties
 * @param properties Dictionary containing property name/value pairs
 */
- (instancetype)initWithProperties:(NSMutableDictionary *)properties;

@end

/**
 * Dynamic property container that can hold arbitrary key-value pairs
 * This replaces the dynamically generated types from the C# version
 */
@interface DynamicPropertyContainer : NSObject

/**
 * Internal storage for properties
 */
@property (nonatomic, strong) NSMutableDictionary *propertyStorage;

/**
 * Property descriptions for metadata
 */
@property (nonatomic, strong) NSMutableDictionary *propertyDescriptions;

/**
 * Initialize with property descriptions
 * @param descriptions Dictionary of PropertyDescription objects keyed by property name
 */
- (instancetype)initWithPropertyDescriptions:(NSMutableDictionary *)descriptions;

/**
 * Set a property value
 * @param value The value to set
 * @param key The property key
 */
- (void)setPropertyValue:(id)value forKey:(NSString *)key;

/**
 * Get a property value
 * @param key The property key
 * @return The property value
 */
- (id)propertyValueForKey:(NSString *)key;

/**
 * Get all property keys
 * @return Array of property keys
 */
- (NSArray<NSString *> *)allPropertyKeys;

@end
