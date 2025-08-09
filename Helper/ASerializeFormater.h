//
//  ASerializeFormater.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
//
//  AbstractSerializer.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/31/25.
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
#import "ISerializeFormater.h"

@protocol IPackedFileName;
@protocol IPackedFileDescriptorBasic;
@class Serializer;

/**
 * This is the default descriptive Serializer
 */
@interface AbstractSerializer : NSObject <ISerializeFormater>

// MARK: - Abstract Properties

/**
 * The separator character used between properties
 */
@property (nonatomic, readonly) NSString *separator;

// MARK: - Abstract Methods

/**
 * Save a string value with proper formatting
 * @param value The string value to save
 * @returns The formatted string
 */
- (NSString *)saveString:(NSString *)value;

/**
 * Format a SubProperty of the Object (a Property that contains another serializable Object)
 * @param name Name of the Property
 * @param value Value of the Property
 * @returns Formatted property string
 */
- (NSString *)subProperty:(NSString *)name value:(NSString *)value;

/**
 * Format a Property of the Object (a Property that does not contain a serializable Object)
 * @param name Name of the Property
 * @param value Value of the Property
 * @returns Formatted property string
 */
- (NSString *)property:(NSString *)name value:(NSString *)value;

/**
 * Format a Property with the Value null
 * @param name Name of the Property
 * @returns Formatted null property string
 */
- (NSString *)nullProperty:(NSString *)name;

// MARK: - Concrete Methods

/**
 * Serialize TGI header
 * @returns Header string for TGI properties
 */
- (NSString *)serializeTGIHeader;

/**
 * Serialize header for an object
 * @param object The object to serialize header for
 * @param objectClass The class of the object
 * @param properties Array of property names to include
 * @returns Header string
 */
- (NSString *)serializeHeaderForObject:(id)object
                           objectClass:(Class)objectClass
                            properties:(NSArray<NSString *> *)properties;

/**
 * Serialize an object
 * @param object The object to serialize
 * @param objectClass The class of the object
 * @param properties Array of property names to serialize
 * @returns Serialized string
 */
- (NSString *)serializeObject:(id)object
                  objectClass:(Class)objectClass
                   properties:(NSArray<NSString *> *)properties;

/**
 * Serialize TGI (Type, Group, Instance) information
 * @param wrapper The wrapper containing the file name
 * @param descriptor The file descriptor containing TGI data
 * @returns Serialized TGI string
 */
- (NSString *)serializeTGI:(id<IPackedFileName>)wrapper
                descriptor:(id<IPackedFileDescriptorBasic>)descriptor;

/**
 * Concatenate property strings with separators
 * @param properties Array of property strings
 * @returns Concatenated string
 */
- (NSString *)concat:(NSArray<NSString *> *)properties;

/**
 * Concatenate header strings with separators
 * @param properties Array of header strings
 * @returns Concatenated header string
 */
- (NSString *)concatHeader:(NSArray<NSString *> *)properties;

@end
