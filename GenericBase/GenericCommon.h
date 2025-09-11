//
//  GenericCommon.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/2/25.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Type Definitions

/**
 * Block type for alternative property names retrieval
 * Equivalent to C# GetAlternativeNames delegate
 */
typedef NSArray<NSString *> * _Nullable (^GetAlternativeNamesBlock)(void);

// MARK: - Abstract Base Class

/**
 * Basic Class for Generic.File and GenericItem. Implements the property System.
 */
@interface GenericCommon : NSObject

// MARK: - Properties

/**
 * Properties of the File
 */
@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, id> *properties;

/**
 * Returns a list of all available Property names
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *names;

/**
 * Block for alternative set of Property Names
 * When this block is nil, the Names property will return all keys stored in properties,
 * when you assign a block to this property, the Names property will return the return
 * value of the assigned block.
 */
@property (nonatomic, copy, nullable) GetAlternativeNamesBlock nameDelegate;

/**
 * Arbitrary Data
 */
@property (nonatomic, strong, nullable) id tag;

// MARK: - Initialization

/**
 * Constructor for the class
 */
- (instancetype)init;

// MARK: - Protected Methods

/**
 * Returns the property dictionary (for subclass access)
 */
- (NSMutableDictionary<NSString *, id> *)getProperties;

// MARK: - Utility Methods

/**
 * Converts an Object into a NSData
 * @param object The Object to Convert
 * @returns NSData representation
 */
+ (NSData *)toByteArray:(nullable id)object;

/**
 * Generates a Character that can be Printed
 * @param character The Input Character
 * @param alternative The Character to return when the input is not displayable
 * @returns alternative or character
 */
+ (unichar)toPrintableChar:(unichar)character alternative:(unichar)alternative;

// MARK: - Property Access Methods

/**
 * Get value for property name
 * @param propertyName The name of the property
 * @returns The value or nil if not found
 */
- (nullable id)valueForProperty:(NSString *)propertyName;

/**
 * Set value for property name
 * @param value The value to set
 * @param propertyName The name of the property
 */
- (void)setValue:(nullable id)value forProperty:(NSString *)propertyName;

/**
 * Remove property
 * @param propertyName The name of the property to remove
 */
- (void)removeProperty:(NSString *)propertyName;

/**
 * Check if property exists
 * @param propertyName The name of the property
 * @returns YES if property exists
 */
- (BOOL)hasProperty:(NSString *)propertyName;

@end

// MARK: - Concrete Implementation

/**
 * Just for this Library to create a GenericCommon Object
 * Equivalent to C# ImplementedGenericCommon
 */
@interface ImplementedGenericCommon : GenericCommon

@end

NS_ASSUME_NONNULL_END

