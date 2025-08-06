//
//  XmlRegistry.h
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

@class XmlRegistryKey;

/**
 * Represents one Key in the XML Registry
 */
@interface XmlRegistryKey : NSObject

// MARK: - Properties
@property (nonatomic, strong, readonly) NSString *name;

// MARK: - SubKey Management
/**
 * Add a new SubKey
 * @param name Name of the SubKey
 * @returns the created SubKey
 */
- (XmlRegistryKey *)createSubKey:(NSString *)name;

/**
 * Open the SubKey with the given Name
 * @param name Name of the Key
 * @param create create it if it does not exist
 * @returns the opened/created subKey (nil if created is false and the key does not exist)
 * @throws NSException if the passed Element is not a Key but a value
 */
- (XmlRegistryKey *)openSubKey:(NSString *)name create:(BOOL)create;

/**
 * Remove a SubKey
 * @param name The key name/path to remove
 * @param throwOnException Whether to throw if key not found
 */
- (void)deleteSubKey:(NSString *)name throwOnException:(BOOL)throwOnException;

// MARK: - Values
/**
 * Set a value
 * @param name Name of the value
 * @param object the value
 */
- (void)setValue:(NSString *)name object:(id)object;

/**
 * Returns the value stored in the passed Element
 * @param name name of the Value
 * @returns nil or the stored value
 * @throws NSException if the specified Value is a SubKey
 */
- (id)getValue:(NSString *)name;

/**
 * Returns the value stored in the passed Element
 * @param name name of the Value
 * @param defaultValue Default Value
 * @returns nil or the stored value
 * @throws NSException if the specified Value is a SubKey
 */
- (id)getValue:(NSString *)name defaultValue:(id)defaultValue;

// MARK: - Enumeration
/**
 * Returns a list of names for all SubKeys
 */
- (NSArray<NSString *> *)getSubKeyNames;

/**
 * Returns a list of names for all Values
 */
- (NSArray<NSString *> *)getValueNames;

@end

/**
 * This is a Platform independent Replacement for the Microsoft.Win32.Registry Class
 */
@interface XmlRegistry : NSObject

// MARK: - Properties
/**
 * Returns the CurrentUser Registry Key
 */
@property (nonatomic, strong, readonly) XmlRegistryKey *currentUser;

// MARK: - Initialization
/**
 * Load the Registry from the passed File
 * @param inFilename Name of the input Registry file
 * @param outFilename Name of the output Registry file
 * @param create true, if you want to create the File if it does not exist
 */
- (instancetype)initWithInputFile:(NSString *)inFilename
                       outputFile:(NSString *)outFilename
                           create:(BOOL)create;

// MARK: - File Operations
/**
 * Write changes to the File
 */
- (void)flush;

@end
