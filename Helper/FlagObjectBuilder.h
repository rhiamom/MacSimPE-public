//
//  FlagObjectBuilder.h
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

#import <Foundation/Foundation.h>
#import "FlagBase.h"

/**
 * Property descriptor for dynamically created flag properties
 */
@interface FlagPropertyDescriptor : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) BOOL readOnly;
@property (nonatomic, strong) id defaultValue;
@property (nonatomic, assign) Class propertyType;

@end

/**
 * You can use this Class to dynamically create a Flag Class based on an NSDictionary of flag definitions
 * Provides similar functionality to the .NET version but adapted for Objective-C runtime
 */
@interface FlagObjectBuilder : FlagBase

// MARK: - Dynamic Type Creation

/**
 * Build a flag object class dynamically based on flag definitions
 * @param className The name for the dynamically created class
 * @param flagDefinitions Dictionary where keys are flag names and values are flag values (NSNumber)
 * @returns The dynamically created class, or FlagBase if creation fails
 */
+ (Class)buildFlagObjectWithClassName:(NSString *)className
                      flagDefinitions:(NSDictionary<NSString *, NSNumber *> *)flagDefinitions;

/**
 * Build a flag object class from an array of flag names
 * @param className The name for the dynamically created class
 * @param flagNames Array of flag names (will create sequential bit flags)
 * @returns The dynamically created class, or FlagBase if creation fails
 */
+ (Class)buildFlagObjectWithClassName:(NSString *)className
                            flagNames:(NSArray<NSString *> *)flagNames;

/**
 * Create an instance of a dynamically created type
 * @param targetClass The class to instantiate
 * @param arguments Optional array of initialization arguments
 * @returns New instance of the class, or nil if creation fails
 */
+ (id)activateType:(Class)targetClass withArguments:(NSArray *)arguments;

// MARK: - Property Management

/**
 * Add a dynamic property to a flag class
 * @param name Name of the property
 * @param targetClass The class to add the property to
 * @param defaultValue Default value for the property
 * @param description Description for the property
 * @param category Category the property belongs to
 * @param readOnly Whether the property should be read-only
 */
+ (void)addPropertyWithName:(NSString *)name
                toClass:(Class)targetClass
               defaultValue:(id)defaultValue
                description:(NSString *)description
                   category:(NSString *)category
                   readOnly:(BOOL)readOnly;

// MARK: - Property Descriptor Management

/**
 * Get property descriptors for a dynamically created class
 * @param targetClass The class to get descriptors for
 * @returns Array of FlagPropertyDescriptor objects
 */
+ (NSArray<FlagPropertyDescriptor *> *)propertyDescriptorsForClass:(Class)targetClass;

/**
 * Set property descriptors for a class (used during dynamic creation)
 * @param descriptors Array of property descriptors
 * @param targetClass The class to set descriptors for
 */
+ (void)setPropertyDescriptors:(NSArray<FlagPropertyDescriptor *> *)descriptors
                      forClass:(Class)targetClass;

// MARK: - Utility Methods

/**
 * Check if a class was dynamically created by FlagObjectBuilder
 * @param targetClass The class to check
 * @returns YES if the class was dynamically created
 */
+ (BOOL)isDynamicFlagClass:(Class)targetClass;

/**
 * Get the original flag definitions for a dynamic class
 * @param targetClass The dynamic class
 * @returns Dictionary of flag definitions, or nil if not a dynamic class
 */
+ (NSDictionary<NSString *, NSNumber *> *)flagDefinitionsForClass:(Class)targetClass;

@end
