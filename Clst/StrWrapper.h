//
//  StrWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
//
//***************************************************************************
//*   Copyright (C) 2005 by Ambertation                                     *
//*   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2005 by Peter L Jones (blame me for string bugs!)       *
//*   pljones@users.sf.net                                                  *
//*                                                                         *
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/

#import <Foundation/Foundation.h>
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "StrItem.h"
#import "MetaData.h"


@class BinaryReader, BinaryWriter;

NS_ASSUME_NONNULL_BEGIN

/**
 * This is the actual FileWrapper
 * @remarks
 * The wrapper is used to (un)serialize the Data of a file into it's Attributes. So Basically it reads
 * a BinaryStream and translates the data into some userdefine Attributes.
 */
@interface StrWrapper : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Initialization

/**
 * Constructor with limit
 * @param limit Maximum Number of Lines to load
 */
- (instancetype)initWithLimit:(NSInteger)limit;

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Core Properties

/**
 * Returns/Sets the Filename (max 64 characters)
 */
@property (nonatomic, copy) NSString *fileName;

/**
 * Returns/Sets the Format Code
 */
@property (nonatomic, assign) FormatCode format;

/**
 * Returns/Sets all stored lines
 * @remarks This is the fastest way to access the String Items!
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, StrItemList *> *lines;

// MARK: - Extended Accessor Methods

/**
 * Gets or Sets the list of languages in the file
 * @remarks Adds empty lists when setting for missing languages
 */
@property (nonatomic, strong) StrLanguageList *languages;

/**
 * StrItemList interface to the lines hashtable
 */
@property (nonatomic, strong) StrItemList *items;

// MARK: - Item Management

/**
 * Adds a new String Item
 * @param item The Item you want to add
 */
- (void)addStrToken:(StrToken *)item;

/**
 * Removes this Item From the List
 * @param item The Item you want to remove
 */
- (void)removeStrToken:(StrToken *)item;

// MARK: - Language-Specific Access

/**
 * Returns all Language-specific Strings
 * @param language the Language
 * @returns List of Strings
 */
- (StrItemList *)languageItemsForStrLanguage:(StrLanguage *)language;

/**
 * Returns all Language-specific Strings
 * @param language the Language
 * @returns List of Strings
 */
- (StrItemList *)languageItemsForLanguage:(Languages)language;

/**
 * Returns a Language String (if available in the passed Language)
 * @param language the Language
 * @param index the index of the string
 * @returns String token or empty token if not found
 */
- (StrToken *)fallbackedLanguageItemForLanguage:(Languages)language atIndex:(NSInteger)index;

/**
 * Returns all Language specific Strings, if the String is not included in the passed
 * Language the Fallback String (use en) will be returned
 * @param language the Language
 * @returns List of Strings
 */
- (StrItemList *)fallbackedLanguageItemsForLanguage:(Languages)language;

// MARK: - Utility Methods

/**
 * Removes all String Items that are not assigned to the Default Language
 */
- (void)clearNonDefault;

/**
 * Copy the content of the Default Language down to the other Languages
 */
- (void)copyFromDefaultToAll;

@end

NS_ASSUME_NONNULL_END
