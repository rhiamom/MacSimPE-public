//
//  ExpansionItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/2/25.
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
#import "FlagBase.h"
#import "XmlRegistryKey.h"
#import "Helper.h"
#import "PathProvider.h"
#import "Localization.h"
#import "IniRegistry.h"
#import "CaseInvariantArrayList.h"

typedef NS_ENUM(NSInteger, ExpansionClasses) {
    ExpansionClassesBaseGame,
    ExpansionClassesExpansionPack,
    ExpansionClassesStuffPack,
    //ExpansionClassesStory
};

@class ExpansionItemFlags;
@class NeighborhoodPath;
@class NeighborhoodPaths;


// MARK: - ExpansionItem

@interface ExpansionItem : NSObject

// MARK: - Properties

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *objectsFolder;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger runtimeVersion;
@property (nonatomic, assign) Expansions expansion;
@property (nonatomic, strong) NSDictionary *registryKey;
@property (nonatomic, strong) NSString *exeName;
@property (nonatomic, strong) ExpansionItemFlags *flag;
@property (nonatomic, strong) NSString *censorFileName;
@property (nonatomic, strong) CaseInvariantArrayList *simNameDeepSearch;
@property (nonatomic, strong) CaseInvariantArrayList *saveGames;
@property (nonatomic, strong) CaseInvariantArrayList *preObjectFileTableFolders;
@property (nonatomic, strong) CaseInvariantArrayList *fileTableFolders;
@property (nonatomic, strong) NSArray<NSNumber *> *groups;
@property (nonatomic, assign) NSInteger group;
@property (nonatomic, strong) NSString *shortNameId;
@property (nonatomic, strong) NSString *shorterName;
@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *nameListNumber;
@property (nonatomic, strong) NSString *installSuffix;

// MARK: - Initialization

- (instancetype)initWithXmlRegistryKey:(XmlRegistryKey *)key;

// MARK: - File Table Management

- (void)setDefaultFileTableFolders;
- (void)addFileTableFolder:(NSString *)folder;
- (void)addFileTableFolder:(NSString *)folder toList:(CaseInvariantArrayList *)list;

// MARK: - Group Management

- (void)buildGroupList;
- (BOOL)shareOneGroupWithExpansion:(ExpansionItem *)expansion;
- (BOOL)shareOneGroupWithGroup:(long long)group;

// MARK: - Path Management

- (void)addNeighborhoodPaths:(NeighborhoodPaths *)neighborhoods;
- (void)addSaveGamePaths:(CaseInvariantArrayList *)realSaveGames;
- (NSString *)getRealPath:(NSString *)path;

// MARK: - Computed Properties

@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *censorFile;
@property (nonatomic, readonly) BOOL exists;
@property (nonatomic, readonly) NSString *applicationPath;
@property (nonatomic, readonly) NSString *objectsSubFolder;
@property (nonatomic, readonly) NSString *idKey;
@property (nonatomic, readonly) NSString *shortId;
@property (nonatomic, readonly) NSString *nameShort;
@property (nonatomic, readonly) NSString *nameSortNumber;
@property (nonatomic, readonly) NSString *nameShorter;
@property (nonatomic, readonly) NSString *realInstallFolder;
@property (nonatomic, strong) NSString *installFolder;

// MARK: - Private Methods

- (NSString *)getShortName;

@end
// MARK: - ExpansionItemFlags

@interface ExpansionItemFlags : FlagBase

- (instancetype)initWithValue:(NSInteger)value;

@property (nonatomic, readonly) BOOL regularExpansion;
@property (nonatomic, readonly) BOOL stuffPack;
@property (nonatomic, readonly) BOOL luaFolders;
@property (nonatomic, readonly) BOOL loadWantText;
//@property (nonatomic, readonly) BOOL simStory;
@property (nonatomic, readonly) BOOL fullObjectsPackage;
@property (nonatomic, readonly) BOOL hasNgbhProfiles;
@property (nonatomic, readonly) ExpansionClasses expansionClass;

@end

// MARK: - NeighborhoodPath

@interface NeighborhoodPath : NSObject

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) ExpansionItem *expansion;
@property (nonatomic, readonly) BOOL isDefault;

- (instancetype)initWithName:(NSString *)name
                        path:(NSString *)path
                   expansion:(ExpansionItem *)expansion
                   isDefault:(BOOL)isDefault;

@end

// MARK: - NeighborhoodPaths

@interface NeighborhoodPaths : NSMutableArray<NeighborhoodPath *>

@end
