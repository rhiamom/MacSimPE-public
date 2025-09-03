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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Property Description Container
 */
@interface PropertyDescription : NSObject

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy, nullable) NSString *descriptionText;
@property (nonatomic, strong) id defaultValue;
@property (nonatomic, assign) BOOL readOnly;

- (instancetype)initWithCategory:(NSString *)category
                     description:(nullable NSString *)description
                    defaultValue:(id)defaultValue
                        readOnly:(BOOL)readOnly;

@end

/**
 * Read an XML Description File and create a List of available Properties
 */
@interface PropertyParser : NSObject

// MARK: - Properties

/**
 * Return all known Properties (NSString name -> PropertyDescription)
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, PropertyDescription *> *properties;

/**
 * Return all known Enumerations (NSString name -> NSDictionary values)
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *enumerations;

// MARK: - Initialization

/**
 * Create a new Instance
 * @param filename Name of the File to parse
 * @remarks If the File is not available, an empty Properties dictionary will be returned!
 */
- (instancetype)initWithPath:(NSString *)filename;

// MARK: - Property Building

/**
 * Create an object of a given type
 * @param typeName The type name from XML
 * @param value The string value to convert
 * @return The converted object
 */
- (nullable id)buildValue:(NSString *)typeName stringValue:(nullable NSString *)value;

// MARK: - Property Access

/**
 * Get a property description by name
 * @param name The property name
 * @return The PropertyDescription or nil if not found
 */
- (nullable PropertyDescription *)propertyForName:(NSString *)name;

/**
 * Check if a property exists
 * @param name The property name
 * @return YES if the property exists
 */
- (BOOL)hasProperty:(NSString *)name;

// MARK: - Enumeration Access

/**
 * Get an enumeration by name
 * @param name The enumeration name
 * @return Dictionary of name->value mappings or nil if not found
 */
- (nullable NSDictionary<NSString *, NSNumber *> *)enumerationForName:(NSString *)name;

/**
 * Check if an enumeration exists
 * @param name The enumeration name
 * @return YES if the enumeration exists
 */
- (BOOL)hasEnumeration:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
