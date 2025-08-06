//
//  ISerializeFormater.h
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

#import <Foundation/Foundation.h>

@protocol IPackedFileName;
@protocol IPackedFileDescriptorBasic;

/**
 * This defines Methods that a concrete Serializer has to implement
 */
@protocol ISerializeFormater <NSObject>

// MARK: - Properties
/**
 * The separator string used in serialization
 */
@property (nonatomic, readonly) NSString *separator;

// MARK: - String Formatting
/**
 * Make a string safe for serialization
 * @param val The string value to make safe
 * @returns The safe string
 */
- (NSString *)saveStr:(NSString *)val;

/**
 * Format a SubProperty of the Object (a Property that contains another serializable Object)
 * @param name Name of the Property
 * @param val Value of the Property
 * @returns Formatted string
 */
- (NSString *)subProperty:(NSString *)name value:(NSString *)val;

/**
 * Format a Property of the Object (a Property that does not contain a serializable Object)
 * @param name Name of the Property
 * @param val Value of the Property
 * @returns Formatted string
 */
- (NSString *)property:(NSString *)name value:(NSString *)val;

/**
 * Format a Property with the Value null
 * @param name Name of the Property
 * @returns Formatted string for null property
 */
- (NSString *)nullProperty:(NSString *)name;

// MARK: - Object Serialization
/**
 * Serialize the passed Object of the given Class with the given List of Properties
 * @param object The object to serialize
 * @param objectClass The class of the object
 * @param propertyNames Array of property names
 * @returns Serialized string
 */
- (NSString *)serialize:(id)object
                  class:(Class)objectClass
        propertyNames:(NSArray<NSString *> *)propertyNames;

/**
 * Serialize the passed Header Information for the passed Object
 * @param object The object to serialize header for
 * @param objectClass The class of the object
 * @param propertyNames Array of property names
 * @returns Serialized header string
 */
- (NSString *)serializeHeader:(id)object
                        class:(Class)objectClass
              propertyNames:(NSArray<NSString *> *)propertyNames;

// MARK: - TGI Serialization
/**
 * Serializes the given Wrapper,Descriptor Information
 * @param wrapper The wrapper object
 * @param pfd The packed file descriptor
 * @returns Serialized TGI string
 */
- (NSString *)serializeTGI:(id<IPackedFileName>)wrapper
                descriptor:(id<IPackedFileDescriptorBasic>)pfd;

/**
 * Serialize TGI Header
 * @returns TGI header string
 */
- (NSString *)serializeTGIHeader;

// MARK: - Array Concatenation
/**
 * Concatenate array of properties
 * @param props Array of property strings
 * @returns Concatenated string
 */
- (NSString *)concat:(NSArray<NSString *> *)props;

/**
 * Concatenate array of header properties
 * @param props Array of header property strings
 * @returns Concatenated header string
 */
- (NSString *)concatHeader:(NSArray<NSString *> *)props;

@end
