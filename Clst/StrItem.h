//
//  StrItem.h
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

@class BinaryReader, BinaryWriter, StrItemList;

NS_ASSUME_NONNULL_BEGIN

// MARK: - StrLanguage

/**
 * This class exists:
 * - to provide access to Language Names given a Language ID
 * - to make Language IDs comparable so that StrLanguageLists can be sorted
 */
@interface StrLanguage : NSObject

/**
 * Language ID
 */
@property (nonatomic, readonly, assign) uint8_t languageId;

/**
 * Constructor
 * This is the only way to set the Language ID
 * @param languageId The Language ID
 */
- (instancetype)initWithLanguageId:(uint8_t)languageId;

// MARK: - Accessor methods

/**
 * Returns the Language Name
 */
@property (nonatomic, readonly, copy) NSString *name;

// MARK: - Comparison

/**
 * Allow StrLanguage and NSNumber objects to be compared
 * @param firstObject First item (StrLanguage, NSNumber)
 * @param secondObject Second Item (StrLanguage, NSNumber)
 * @returns Comparison value or NSOrderedSame if invalid object types passed
 */
+ (NSComparisonResult)compareLanguage:(id)firstObject withLanguage:(id)secondObject;

@end

// MARK: - StrLanguageList

/**
 * Type-safe NSMutableArray for StrLanguage Objects
 */
@interface StrLanguageList : NSMutableArray<StrLanguage *>

// MARK: - Indexed Access
- (StrLanguage *)objectAtIndex:(NSUInteger)index;
- (StrLanguage *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(StrLanguage *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(StrLanguage *)object;

// MARK: - Collection Operations
- (NSInteger)addLanguage:(StrLanguage *)strLanguage;
- (void)insertLanguage:(StrLanguage *)strLanguage atIndex:(NSUInteger)index;
- (void)removeLanguage:(StrLanguage *)strLanguage;
- (BOOL)containsLanguage:(StrLanguage *)strLanguage;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Sorting
- (void)sortLanguages;

@end

// MARK: - StrToken

/**
 * An Item stored in a STR# File
 */
@interface StrToken : NSObject

/**
 * Constructor
 * @param index hack to give line numbers
 * @param languageId Language ID (byte)
 * @param title Item Title
 * @param description Item Description
 */
- (instancetype)initWithIndex:(NSInteger)index
                   languageId:(uint8_t)languageId
                        title:(NSString *)title
                  description:(NSString *)description;

// MARK: - Properties

/**
 * Internal index (read-only)
 */
@property (nonatomic, readonly, assign) NSInteger index;

/**
 * Language is read-only
 */
@property (nonatomic, readonly, strong) StrLanguage *language;

/**
 * Item title
 */
@property (nonatomic, copy) NSString *title;

/**
 * Item description
 */
@property (nonatomic, copy) NSString *strDescription;

/**
 * Dirty is read-only
 * Indicates whether the object has been updated since creation (can't be cleared!)
 */
@property (nonatomic, readonly, assign) BOOL isDirty;

// MARK: - Serialize / Unserialize

/**
 * Unserialize from binary reader
 * File format is:
 * byte - Language ID
 * char[]\0 - Title
 * char[]\0 - Description
 * @param reader The binary reader to read from
 * @param lines Hashtable to store the results in
 */
+ (void)unserializeFromReader:(BinaryReader *)reader intoLines:(NSMutableDictionary *)lines;

/**
 * Serialize to binary writer
 * @param writer The binary writer to write to
 */
- (void)serializeToWriter:(BinaryWriter *)writer;

@end

// MARK: - StrItemList

/**
 * Type-safe NSMutableArray for StrToken Objects
 */
@interface StrItemList : NSMutableArray<StrToken *>

// MARK: - Indexed Access
- (StrToken *)objectAtIndex:(NSUInteger)index;
- (StrToken *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(StrToken *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(StrToken *)object;

// MARK: - Collection Operations
- (NSInteger)addStrToken:(StrToken *)strToken;
- (void)insertStrToken:(StrToken *)strToken atIndex:(NSUInteger)index;
- (void)removeStrToken:(StrToken *)strToken;
- (BOOL)containsStrToken:(StrToken *)strToken;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying
- (instancetype)deepCopy;

@end

NS_ASSUME_NONNULL_END
