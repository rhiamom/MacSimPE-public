//
//  Serializer.h
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

@protocol ISerializeFormater;
@protocol IPackedFileName;
@protocol IPackedFileDescriptorBasic;

/**
 * Provides Methods to serialize Object Properties
 */
@interface Serializer : NSObject

// MARK: - Formatter Management
/**
 * Gets or sets the current formatter
 */
@property (class, nonatomic, strong) id<ISerializeFormater> formater;

/**
 * Reset the formatter to default
 */
+ (void)resetFormater;

// MARK: - Instance Methods
/**
 * Get property description for this object
 */
- (NSString *)getPropertyDescription;

/**
 * String representation with custom name
 */
- (NSString *)toStringWithName:(NSString *)name;

// MARK: - Static Utility Methods
/**
 * Create a sub-property string
 */
+ (NSString *)subProperty:(NSString *)name value:(NSString *)value;

/**
 * Create a property string
 */
+ (NSString *)property:(NSString *)name value:(NSString *)value;

/**
 * Get the current separator
 */
+ (NSString *)separator;

// MARK: - Type Serialization
/**
 * Serialize type header for an object
 */
+ (NSString *)serializeTypeHeader:(id)object;

/**
 * Serialize type header for wrapper and file descriptor
 */
+ (NSString *)serializeTypeHeaderForWrapper:(id<IPackedFileName>)wrapper
                                 descriptor:(id<IPackedFileDescriptorBasic>)pfd;

/**
 * Serialize type header for wrapper and file descriptor with description option
 */
+ (NSString *)serializeTypeHeaderForWrapper:(id<IPackedFileName>)wrapper
                                 descriptor:(id<IPackedFileDescriptorBasic>)pfd
                            withDescription:(BOOL)withDesc;

// MARK: - Object Serialization
/**
 * Serialize wrapper and file descriptor
 */
+ (NSString *)serializeWrapper:(id<IPackedFileName>)wrapper
                    descriptor:(id<IPackedFileDescriptorBasic>)pfd;

/**
 * Serialize wrapper and file descriptor with description option
 */
+ (NSString *)serializeWrapper:(id<IPackedFileName>)wrapper
                    descriptor:(id<IPackedFileDescriptorBasic>)pfd
               withDescription:(BOOL)withDesc;

/**
 * Serialize an object
 */
+ (NSString *)serialize:(id)object;

/**
 * Serialize an object with optional header
 */
+ (NSString *)serialize:(id)object writeHeader:(BOOL)writeHeader;

// MARK: - Array Utilities
/**
 * Convert array to string array
 */
+ (NSArray<NSString *> *)convertArray:(NSArray *)array;

/**
 * Concatenate string array
 */
+ (NSString *)concat:(NSArray<NSString *> *)props;

/**
 * Concatenate header string array
 */
+ (NSString *)concatHeader:(NSArray<NSString *> *)props;

@end
