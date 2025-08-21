//
//  FileTable.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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

#import "FileTable.h"
#import "PathProvider.h"
#import "FileTableItem.h"
#import "IScenegraphFileIndex.h"


// MARK: - FileTablePath Implementation

@interface FileTablePath ()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) FTFileLocation location;
@property (nonatomic, strong, readwrite) NSString *expansionName;
@property (nonatomic, assign, readwrite) Expansions expansion;
@property (nonatomic, assign, readwrite) BOOL isPreObject;
@end

@implementation FileTablePath

- (instancetype)initWithName:(NSString *)name
                    location:(FTFileLocation)location
               expansionName:(NSString *)expansionName
                   expansion:(Expansions)expansion
                 isPreObject:(BOOL)isPreObject {
    self = [super init];
    if (self) {
        _name = name;
        _location = location;
        _expansionName = expansionName;
        _expansion = expansion;
        _isPreObject = isPreObject;
    }
    return self;
}

- (NSString *)basePath {
    switch (self.location) {
        case FileLocationBaseGame:
            // /Applications/The Sims 2.app/Contents/Assets
            return @"/Applications/The Sims 2.app/Contents/Assets";

        case FileLocationExpansionPack: {
            // /Applications/The Sims 2.app/Contents/Assets/Expansion Packs/<Expansion Name>
            NSString *expName = self.expansionName ?: @"";
            NSString *expRoot = @"/Applications/The Sims 2.app/Contents/Assets/Expansion Packs";
            return [expRoot stringByAppendingPathComponent:expName];
        }

        case FileLocationDownloads: {
            // ~/Documents/EA Games/The Sims 2/Downloads (via PathProvider)
            NSString *save = [PathProvider simSavegameFolder];
            return [save stringByAppendingPathComponent:@"Downloads"];
        }
    }
    return nil;
}

- (NSString *)fullPath {
    return [[self basePath] stringByAppendingPathComponent:self.name];
}

- (BOOL)exists {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self fullPath]];
}

+ (Expansions)asExpansion:(FileTableItemType *)type {
    return [type asExpansions];
}

+ (uint32_t)asUnsignedInteger:(FileTableItemType *)type {
    return [type asUint];
}

+ (NSComparisonResult)compare:(FileTableItemType *)type1 with:(FileTableItemType *)type2 {
    uint32_t val1 = [type1 asUint];
    uint32_t val2 = [type2 asUint];
    if (val1 < val2) return NSOrderedAscending;
    if (val1 > val2) return NSOrderedDescending;
    return NSOrderedSame;
}

+ (FileTableItemType *)fromExpansion:(Expansions)expansion {
    return [[FileTableItemType alloc] initWithExpansion:expansion];
}

+ (FileTableItemType *)fromInteger:(int32_t)value {
    return [[FileTableItemType alloc] initWithInt:value];
}

+ (FileTableItemType *)fromUnsignedInteger:(uint32_t)value {
    return [[FileTableItemType alloc] initWithUInt:value];
}

+ (NSInteger)getEPVersionForType:(FileTableItemType *)type {
    return [FileTableItem getEPVersionForType:type];
}

+ (NSString *)getRootForType:(FileTableItemType *)type {
    return [FileTableItem getRootForType:type];
}

+ (BOOL)isEqual:(FileTableItemType *)type1 to:(FileTableItemType *)type2 {
    return [type1 asUint] == [type2 asUint];
}

+ (NSString *)stringForType:(FileTableItemType *)type {
    return [FileTableItemType stringForType:type];
}

@end

// MARK: - FileTable Implementation

@implementation FileTable

// MARK: - Static Variables

static id<IToolRegistry> s_toolRegistry = nil;
static id<IHelpRegistry> s_helpTopicRegistry = nil;
static id<ISettingsRegistry> s_settingsRegistry = nil;
static id<ICommandLineRegistry> s_commandLineRegistry = nil;
static NSMutableArray<NSString *> *s_detectedStuffPacks = nil;
static NSMutableArray<FileTablePath *> *s_fileTable = nil;

// MARK: - Class Properties (Registry from C#)

+ (id<IToolRegistry>)toolRegistry {
    return s_toolRegistry;
}

+ (void)setToolRegistry:(id<IToolRegistry>)toolRegistry {
    s_toolRegistry = toolRegistry;
}

+ (id<IHelpRegistry>)helpTopicRegistry {
    return s_helpTopicRegistry;
}

+ (void)setHelpTopicRegistry:(id<IHelpRegistry>)helpTopicRegistry {
    s_helpTopicRegistry = helpTopicRegistry;
}

+ (id<ISettingsRegistry>)settingsRegistry {
    return s_settingsRegistry;
}

+ (void)setSettingsRegistry:(id<ISettingsRegistry>)settingsRegistry {
    s_settingsRegistry = settingsRegistry;
}

+ (id<ICommandLineRegistry>)commandLineRegistry {
    return s_commandLineRegistry;
}

+ (void)setCommandLineRegistry:(id<ICommandLineRegistry>)commandLineRegistry {
    s_commandLineRegistry = commandLineRegistry;
}

// MARK: - File System Properties (from Swift)

+ (NSArray<NSString *> *)detectedStuffPacks {
    if (!s_detectedStuffPacks) {
        s_detectedStuffPacks = [[NSMutableArray alloc] init];
        [self detectStuffPacks];
    }
    return [s_detectedStuffPacks copy];
}

+ (NSArray<FileTablePath *> *)fileTable {
    if (!s_fileTable) {
        [self buildFileTable];
    }
    return [s_fileTable copy];
}

// MARK: - Methods

+ (void)reload {
    id<IScenegraphFileIndex> fileIndex = [[self class] fileIndex];
    
    // Clear base folders on the file index, not file table item
    [[fileIndex baseFolders] removeAllObjects];
    
    // Set base folders on the file index
    NSMutableArray *mutableFolders = [[[self class] defaultFolders] mutableCopy];
        [fileIndex setBaseFolders:mutableFolders];
    
    // Force reload on the file index
    [fileIndex forceReload];
}

+ (void)detectStuffPacks {
    if (!s_detectedStuffPacks) {
        s_detectedStuffPacks = [[NSMutableArray alloc] init];
    } else {
        [s_detectedStuffPacks removeAllObjects];
    }
    
    // Check for Huge Lunatic's extracted SPs (exactly from Swift)
    NSString *bonVoyageBinsPath = @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Bon Voyage/TSData/Res/Catalog/Bins";
    
    NSArray *optionalStuffPacks = @[
        @[@"celebration-build.bundle.package", @"celebration-buy.bundle.package", @"Celebration"],
        @[@"ikea-build.bundle.package", @"ikea-buy.bundle.package", @"IKEA"],
        @[@"kb-build.bundle.package", @"kb-buy.bundle.package", @"Kitchen & Bath"],
        @[@"teen-build.bundle.package", @"teen-buy.bundle.package", @"Teen Style"]
    ];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSArray *stuffPack in optionalStuffPacks) {
        NSString *buildPackage = stuffPack[0];
        NSString *buyPackage = stuffPack[1];
        NSString *name = stuffPack[2];
        
        NSString *buildPath = [bonVoyageBinsPath stringByAppendingPathComponent:buildPackage];
        NSString *buyPath = [bonVoyageBinsPath stringByAppendingPathComponent:buyPackage];
        
        if ([fileManager fileExistsAtPath:buildPath] && [fileManager fileExistsAtPath:buyPath]) {
            [s_detectedStuffPacks addObject:name];
        }
    }
}

+ (void)buildFileTable {
    if (!s_fileTable) {
        s_fileTable = [[NSMutableArray alloc] init];
    } else {
        [s_fileTable removeAllObjects];
    }
    
    // Base game pre-object folders (exactly from Swift)
    [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"TSData/Res/Catalog/Bins"
                                                       location:FileLocationBaseGame
                                                  expansionName:nil
                                                      expansion:ExpansionsBaseGame
                                                    isPreObject:YES]];
    
    // Base game regular folders (exactly from Swift)
    [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"TSData/Res/Sims3D"
                                                       location:FileLocationBaseGame
                                                  expansionName:nil
                                                      expansion:ExpansionsBaseGame
                                                    isPreObject:NO]];
    
    NSArray *baseGameFolders = @[
        @"TSData/Res/Catalog/Materials",
        @"TSData/Res/Catalog/Skins",
        @"TSData/Res/Catalog/Patterns",
        @"TSData/Res/Catalog/CANHObjects",
        @"TSData/Res/Wants",
        @"TSData/Res/UI"
    ];
    
    for (NSString *folder in baseGameFolders) {
        [s_fileTable addObject:[[FileTablePath alloc] initWithName:folder
                                                           location:FileLocationBaseGame
                                                      expansionName:nil
                                                          expansion:ExpansionsBaseGame
                                                        isPreObject:NO]];
    }
    
    // CEP enabling files (exactly from Swift)
    [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"_EnableColorOptionsGMND.package"
                                                       location:FileLocationDownloads
                                                  expansionName:nil
                                                      expansion:ExpansionsBaseGame
                                                    isPreObject:NO]];
    
    [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"TSData/Res/Sims3D/_EnableColorOptionsMMAT.package"
                                                       location:FileLocationBaseGame
                                                  expansionName:nil
                                                      expansion:ExpansionsBaseGame
                                                    isPreObject:NO]];
    
    // CEP folders (exactly from Swift)
    [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"zCEP-EXTRA"
                                                       location:FileLocationDownloads
                                                  expansionName:nil
                                                      expansion:ExpansionsBaseGame
                                                    isPreObject:NO]];
    
    [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"TSData/Res/Catalog/zCEP-EXTRA"
                                                       location:FileLocationBaseGame
                                                  expansionName:nil
                                                      expansion:ExpansionsBaseGame
                                                    isPreObject:NO]];
    
    // Expansion Packs - using exact Swift naming structure
    NSArray *expansionMappings = @[
        @[@"University", @(ExpansionsUniversity)],
        @[@"Nightlife", @(ExpansionsNightlife)],
        @[@"Open for Business", @(ExpansionsBusiness)],
        @[@"Family Fun Stuff", @(ExpansionsFamilyFun)],
        @[@"Glamour Life Stuff", @(ExpansionsGlamour)],
        @[@"Pets", @(ExpansionsPets)],
        @[@"Seasons", @(ExpansionsSeasons)],
        @[@"Bon Voyage", @(ExpansionsVoyage)]
    ];
    
    NSArray *standardCatalogFolders = @[
        @"TSData/Res/Catalog/Materials",
        @"TSData/Res/Catalog/Skins",
        @"TSData/Res/Catalog/Patterns",
        @"TSData/Res/Catalog/CANHObjects",
        @"TSData/Res/Wants",
        @"TSData/Res/UI"
    ];
    
    for (NSArray *expansionMapping in expansionMappings) {
        NSString *epName = expansionMapping[0];
        Expansions expansion = (Expansions)[expansionMapping[1] integerValue];
        
        // Objects folder - main content (exactly from Swift)
        [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"TSData/Res/3D"
                                                           location:FileLocationExpansionPack
                                                      expansionName:epName
                                                          expansion:expansion
                                                        isPreObject:NO]];
        
        // Objects subfolder for certain expansions (exactly from Swift)
        if (expansion == ExpansionsVoyage) {
            [s_fileTable addObject:[[FileTablePath alloc] initWithName:@"TSData/Res/Objects"
                                                               location:FileLocationExpansionPack
                                                          expansionName:epName
                                                              expansion:expansion
                                                            isPreObject:NO]];
        }
        
        // Standard catalog and UI folders for all expansions (exactly from Swift)
        for (NSString *folder in standardCatalogFolders) {
            [s_fileTable addObject:[[FileTablePath alloc] initWithName:folder
                                                               location:FileLocationExpansionPack
                                                          expansionName:epName
                                                              expansion:expansion
                                                            isPreObject:NO]];
        }
    }
    
    // Ensure stuff packs are detected
    [self detectStuffPacks];
}
@end
