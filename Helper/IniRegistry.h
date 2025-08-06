//
//  IniRegistry.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *   Copyright (C) 2007 by Ambertation                                     *
// *   pljones@users.sf.net                                                  *
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

@class IniRegistrySectionContent;

/// <summary>
/// Simple "[section name]", "key name=value" ini file reader/writer.
/// Any comments and blank lines read are lost if the file is written.
/// </summary>
@interface IniRegistry : NSObject <NSFastEnumeration>

// MARK: - Properties

@property (nonatomic, strong) NSString *iniFile;
@property (nonatomic, assign) BOOL fileIsReadOnly;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, IniRegistrySectionContent *> *sections;

// MARK: - Initialization

- (instancetype)initWithFileName:(NSString *)fileName readOnly:(BOOL)readOnly;
- (instancetype)initWithFileName:(NSString *)fileName;
- (instancetype)initWithStreamReader:(NSInputStream *)stream;

// MARK: - File Operations

- (BOOL)flush;

// MARK: - Section Management

- (IniRegistrySectionContent *)createSection:(NSString *)sectionName;
- (IniRegistrySectionContent *)getSection:(NSString *)sectionName;
- (IniRegistrySectionContent *)getSection:(NSString *)sectionName createIfNeeded:(BOOL)create;
- (BOOL)containsSection:(NSString *)sectionName;
- (BOOL)removeSection:(NSString *)sectionName;
- (void)clearSection:(NSString *)sectionName;

// MARK: - Direct Key Access

- (NSString *)getValue:(NSString *)key inSection:(NSString *)section;
- (NSString *)getValue:(NSString *)key inSection:(NSString *)section defaultValue:(NSString *)defaultValue;
- (void)setValue:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section;
- (void)setValue:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section createIfNeeded:(BOOL)create;

// MARK: - Subscript Access

- (IniRegistrySectionContent *)objectForKeyedSubscript:(NSString *)sectionName;
- (void)setObject:(IniRegistrySectionContent *)section forKeyedSubscript:(NSString *)sectionName;

// MARK: - Private Methods

+ (BOOL)keyCompare:(NSString *)key1 withKey:(NSString *)key2;

@end

// MARK: - IniRegistrySectionContent

@interface IniRegistrySectionContent : NSObject <NSFastEnumeration>

// MARK: - Properties

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSString *> *keyValuePairs;

// MARK: - Initialization

- (instancetype)init;

// MARK: - Key Management

- (void)createKey:(NSString *)key;
- (void)setValue:(NSString *)value forKey:(NSString *)key;
- (void)setValue:(NSString *)value forKey:(NSString *)key createIfNeeded:(BOOL)create;
- (NSString *)getValue:(NSString *)key;
- (NSString *)getValue:(NSString *)key defaultValue:(NSString *)defaultValue;
- (BOOL)containsKey:(NSString *)key;
- (BOOL)removeKey:(NSString *)key;
- (void)clear;

// MARK: - Subscript Access

- (NSString *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)key;

@end
