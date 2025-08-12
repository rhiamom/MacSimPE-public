//
//  PathProvider.h
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
// ***************************************************************************

#import <Foundation/Foundation.h>
#import "FileTableEnums.h"

@class ExpansionItem;

// MARK: - PathProvider Interface
NS_ASSUME_NONNULL_BEGIN

@interface PathProvider : NSObject

// MARK: - Properties (simplified for Mac with fixed content)
@property (nonatomic, readonly) Expansions lastKnown;
@property (nonatomic, readonly) int gameVersion;
@property (nonatomic, readonly) int epInstalled;
@property (nonatomic, readonly) int spInstalled;
@property (nonatomic, readonly) int64_t availableGroups;
@property (nonatomic, readonly) int currentGroup;
@property (nonatomic, strong, readonly) NSMutableArray<ExpansionItem *> *expansions;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ExpansionItem *> *expansionMap;


// MARK: - Static Properties
+ (ExpansionItem *)nilExpansion;
+ (PathProvider *)global;
+ (NSInteger)groupCount;

// MARK: - Class Methods
+ (NSString *)expansionFile;
+ (NSString *)personalFolder;
+ (NSString *)displayedName;

// MARK: - Path Properties (Mac-specific paths)
+ (NSString *)simSavegameFolder;
+ (void)setSimSavegameFolder:(NSString *)folder;
+ (NSString *)realSavegamePath;
+ (NSArray<NSString *> *)allPathsForPath:(NSString *)path;
+ (NSString *)expandPath:(NSString *)path;
+ (nullable NSString *)expansionFolderNameForExpansion:(Expansions)exp;

@property (nonatomic, readonly) NSString *neighborhoodFolder;
@property (nonatomic, readonly) NSString *backupFolder;

// MARK: - Initialization
- (instancetype)init;

// MARK: - Path Management
- (NSArray<NSString *> *)getSaveGamePathForGroup:(int64_t)group;
- (int64_t)saveGamePathProvidedByGroup:(NSString *)path;

// MARK: - System Management
- (void)flush;

// MARK: - Expansion Management
- (ExpansionItem *)getExpansionName:(Expansions)expansion;
- (ExpansionItem *)getExpansion:(int)version;
- (ExpansionItem *)getLatestExpansion;
- (ExpansionItem *)getHighestAvailableExpansion:(int)minver maxver:(int)maxver;

// MARK: - Subscript-like access (matching C# indexers)
- (ExpansionItem *)expansionForEnum:(Expansions)expansion;
- (ExpansionItem *)expansionForVersion:(int)version;

@end

NS_ASSUME_NONNULL_END
