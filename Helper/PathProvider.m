//
//  PathProvider.m
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

#import "PathProvider.h"
#import "Helper.h"
#import "ExpansionItem.h"

// MARK: - Static Variables

static PathProvider *globalInstance = nil;
static ExpansionItem *nilExpansionItem = nil;

// MARK: - Implementation

@implementation PathProvider

// MARK: - Class Methods

+ (NSInteger)groupCount {
    // number of bits available in the groups bitmask
    return (NSInteger)(sizeof(int64_t) * 8); // 64
}

+ (PathProvider *)global {
    if (globalInstance == nil) {
        globalInstance = [[PathProvider alloc] init];
    }
    return globalInstance;
}

+ (NSString *)expansionFile {
    return [[Helper simPeDataPath] stringByAppendingPathComponent:@"expansions.xreg"];
}

+ (NSString *)displayedName {
    // Mac path: C# returned "The Sims 2" unconditionally on MAC
    return @"The Sims 2";
}

+ (NSString *)personalFolder {
    // Mirrors Environment.GetFolderPath(Environment.SpecialFolder.Personal)
    NSArray<NSString *> *paths =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject ?: NSHomeDirectory(); // fallback, just in case
}

+ (NSString *)simSavegameFolder {
    @try {
        // Try to get custom path from preferences first
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *customPath = [defaults stringForKey:@"SavegamePath"];
        
        if (customPath && [[NSFileManager defaultManager] fileExistsAtPath:customPath]) {
            return customPath;
        }
        
        // Use the correct Mac Sims 2 sandbox path
        NSString *homeDirectory = NSHomeDirectory();
        NSString *path = [homeDirectory stringByAppendingPathComponent:@"Library/Containers/com.aspyr.sims2.appstore/Data/Library/Application Support/Aspyr/The Sims 2"];
        
        return path;
    } @catch (NSException *exception) {
        return @"";
    }
}

+ (NSString *)realSavegamePath {
    // This should return the same path since it's the actual location
    NSString *homeDirectory = NSHomeDirectory();
    return [homeDirectory stringByAppendingPathComponent:@"Library/Containers/com.aspyr.sims2.appstore/Data/Library/Application Support/Aspyr/The Sims 2"];
}

+ (void)setSimSavegameFolder:(NSString *)folder {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:folder forKey:@"SavegamePath"];
    [defaults synchronize];
}

+ (ExpansionItem *)nilExpansion {
    if (nilExpansionItem == nil) {
        nilExpansionItem = [[ExpansionItem alloc] initWithXmlRegistryKey:nil];
    }
    return nilExpansionItem;
}

// MARK: - Expansion Management (matching C# implementation exactly)

- (ExpansionItem *)getExpansionName:(Expansions)expansion {
    // C# version: if (!map.ContainsKey(exp)) return Nil;
    NSNumber *key = @(expansion);
    if (![self.expansionMap.allKeys containsObject:key]) {
        return [PathProvider nilExpansion];
    }
    // C# version: return map[exp];
    return [self.expansionMap objectForKey:key];
}

- (ExpansionItem *)getExpansion:(int)version {
    // C# version: Expansions exp = (Expansions)Math.Pow(2, version);
    Expansions exp = (Expansions)pow(2, version);
    return [self getExpansion:exp];
}

- (ExpansionItem *)getLatestExpansion {
    return [self getExpansion:[self gameVersion]];
}

- (ExpansionItem *)getHighestAvailableExpansion:(int)minver maxver:(int)maxver {
    ExpansionItem *exp = nil;
    ExpansionItem *t = nil;
    int v = minver;
    while (v < maxver) {
        t = [self getExpansion:v++];
        if (t != nil) {
            if ([t exists]) {
                exp = t;
            }
        }
    }
    return exp;
}

// MARK: - Subscript-like access (matching C# indexers)
- (ExpansionItem *)expansionForEnum:(Expansions)expansion {
    return [self getExpansion:expansion];
}

- (ExpansionItem *)expansionForVersion:(int)version {
    return [self getExpansion:version];
}
// MARK: - Properties (Mac version content through Seasons + Voyage + some SPs)

- (Expansions)lastKnown {
    return ExpansionsVoyage; // Latest expansion in Mac version
}

- (int)gameVersion {
    return 10; // Voyage is version 10
}

- (int)epInstalled {
    return 7; // Through Seasons (version 7)
}

- (int)spInstalled {
    return 10; // Through Voyage (version 10)
}

- (int64_t)availableGroups {
    // Mac version available expansions: Base + University + Nightlife + Business + FamilyFun + Glamour + Pets + Seasons + Voyage
    return (ExpansionsBaseGame | ExpansionsUniversity | ExpansionsNightlife |
            ExpansionsBusiness | ExpansionsFamilyFun | ExpansionsGlamour |
            ExpansionsPets | ExpansionsSeasons | ExpansionsVoyage);
}

- (int)currentGroup {
    return 10; // Voyage group as the latest content
}

- (NSString *)neighborhoodFolder {
    @try {
        return [[[self class] simSavegameFolder] stringByAppendingPathComponent:@"Neighborhoods"];
    } @catch (NSException *exception) {
        return @"";
    }
}

- (NSString *)backupFolder {
    @try {
        NSString *path = [[[self class] personalFolder] stringByAppendingPathComponent:@"EA Games"];
        return [path stringByAppendingPathComponent:@"SimPE Backup"];
    } @catch (NSException *exception) {
        return @"";
    }
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Mac version doesn't need to scan for installations
        // All content is bundled and available
    }
    return self;
}

// MARK: - Path Management (simplified for Mac)

- (NSArray<NSString *> *)getSaveGamePathForGroup:(int64_t)group {
    // Mac version: return standard save game paths
    NSMutableArray<NSString *> *paths = [[NSMutableArray alloc] init];
    
    NSString *saveGameFolder = [[self class] simSavegameFolder];
    if (saveGameFolder && ![@"" isEqualToString:saveGameFolder]) {
        [paths addObject:saveGameFolder];
    }
    
    return [paths copy];
}

- (int64_t)saveGamePathProvidedByGroup:(NSString *)path {
    // Simplified for Mac - most paths are in the base game group
    return ExpansionsBaseGame;
}

// MARK: - System Management

- (void)flush {
    // Mac version uses NSUserDefaults, which auto-syncs
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray<NSString *> *)allPathsForPath:(NSString *)path
{
    if (path == nil || path.length == 0) {
        return @[];
    }
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    NSArray<NSString *> *parts = [path componentsSeparatedByString:@";"];
    NSFileManager *fm = [NSFileManager defaultManager];

    for (NSString *rawPart in parts) {
        NSString *expanded = [PathProvider expandPath:[rawPart stringByTrimmingCharactersInSet:
                                               [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        if (expanded.length == 0) continue;

        NSRange starRange = [expanded rangeOfString:@"*"];
        if (starRange.location != NSNotFound) {
            NSString *basePath = [expanded substringToIndex:starRange.location];
            NSString *rest = [expanded substringFromIndex:(starRange.location + 1)];

            NSString *parentDir = [basePath stringByDeletingLastPathComponent];
            NSString *baseName = [basePath lastPathComponent];

            BOOL isDir = NO;
            if ([fm fileExistsAtPath:parentDir isDirectory:&isDir] && isDir) {
                NSError *error = nil;
                NSArray<NSString *> *entries = [fm contentsOfDirectoryAtPath:parentDir error:&error];
                for (NSString *entry in entries) {
                    if (![entry hasPrefix:baseName]) continue;

                    NSString *entryPath = [parentDir stringByAppendingPathComponent:entry];

                    // Only consider directories, matching C# Directory.GetDirectories(...)
                    BOOL entryIsDir = NO;
                    if (![fm fileExistsAtPath:entryPath isDirectory:&entryIsDir] || !entryIsDir) continue;

                    NSString *finalPath = [entryPath stringByAppendingString:rest];

                    BOOL finalIsDir = NO;
                    if ([fm fileExistsAtPath:finalPath isDirectory:&finalIsDir] && finalIsDir) {
                        [result addObject:finalPath];
                    }
                }
            }
        } else {
            BOOL isDir = NO;
            if ([fm fileExistsAtPath:expanded isDirectory:&isDir] && isDir) {
                [result addObject:expanded];
            }
        }
    }

    return [result copy];
}

+ (NSString *)expandPath:(NSString *)path
{
    if (path == nil) return @"";

    // 1) Normalize backslashes to forward slashes
    NSString *ret = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];

    // 2) Replace variables using our dictionary
    NSDictionary<NSString *, NSString *> *vars = [PathProvider defaultPathVars];

    for (NSString *key in vars) {
        NSString *val = vars[key];
        if (val.length == 0) continue;

        NSString *needle = [NSString stringWithFormat:@"$(%@)", key];
        ret = [ret stringByReplacingOccurrencesOfString:needle withString:val];
        ret = [ret stringByReplacingOccurrencesOfString:key withString:val];
    }

    // 3) Collapse duplicate slashes
    while ([ret containsString:@"//"]) {
        ret = [ret stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    return ret;
}

// Class helper lives OUTSIDE the method:
+ (NSDictionary<NSString *, NSString *> *)defaultPathVars
{
    NSString *assets    = @"/Applications/The Sims 2.app/Contents/Assets";
    NSString *epRoot    = [assets stringByAppendingPathComponent:@"Expansion Packs"];
    NSString *downloads = [[self simSavegameFolder] stringByAppendingPathComponent:@"Downloads"];

    return @{
        @"TS2_Base": assets,
        @"TS2_EP_Root": epRoot,
        @"TS2_Downloads": downloads
    };
}

+ (nullable NSString *)expansionFolderNameForExpansion:(Expansions)exp {
    switch (exp) {
        case ExpansionsNone:            return nil;
        case ExpansionsBaseGame:        return @"Basegame";
        case ExpansionsUniversity:      return @"University";
        case ExpansionsNightlife:       return @"Nightlife";
        case ExpansionsBusiness:        return @"Open for Business";
        case ExpansionsFamilyFun:       return @"Family Fun Stuff";
        case ExpansionsGlamour:         return @"Glamour Life Stuff";
        case ExpansionsPets:            return @"Pets";
        case ExpansionsSeasons:         return @"Seasons";
        case ExpansionsVoyage:          return @"Bon Voyage";
      //case ExpansionsFreeTime:        return @"FreeTime";
      //case ExpansionsApartmentLife:   return @"Apartment Life";
      // Add any SPs if you model them; use the exact folder names in Contents/Assets/Expansion Packs
    }
}

@end
