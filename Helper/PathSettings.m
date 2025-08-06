//
//  PathSettings.m
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

#import "PathSettings.h"
#import "Registry.h"
#import "PathProvider.h"
#import "ExpansionItem.h"
#import "Helper.h"

// MARK: - Static Variables

static PathSettings *globalInstance = nil;

// MARK: - Implementation

@implementation PathSettings {
    Registry *_registry;
}

// MARK: - Class Methods

+ (PathSettings *)global {
    if (globalInstance == nil) {
        globalInstance = [[PathSettings alloc] initWithRegistry:[Helper windowsRegistry]];
    }
    return globalInstance;
}

// MARK: - Initialization

- (instancetype)initWithRegistry:(Registry *)registry {
    self = [super init];
    if (self) {
        _registry = registry;
    }
    return self;
}

// MARK: - Path Management Helpers

- (NSString *)getPathForExpansion:(ExpansionItem *)expansionItem {
    if (expansionItem.installFolder == nil || [expansionItem.installFolder isEqualToString:@""]) {
        return expansionItem.realInstallFolder;
    }
    return expansionItem.installFolder;
}

- (NSString *)getPath:(NSString *)userPath defaultPath:(NSString *)defaultPath {
    if (userPath == nil || [[userPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return defaultPath;
    }
    return userPath;
}

// MARK: - Save Game Path

- (NSString *)saveGamePath {
    return [self getPath:[PathProvider simSavegameFolder] defaultPath:[PathProvider realSavegamePath]];
}

- (void)setSaveGamePath:(NSString *)saveGamePath {
    [PathProvider setSimSavegameFolder:saveGamePath];
}

- (NSString *)baseGamePath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData";
}

- (void)setBaseGamePath:(NSString *)baseGamePath {
    // Base game path is fixed in Mac version
    NSLog(@"Base game path is fixed in Mac version: %@", baseGamePath);
}

- (NSString *)universityPath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/University";
}

- (void)setUniversityPath:(NSString *)universityPath {
    // Expansion paths are fixed in Mac version
    NSLog(@"University path is fixed in Mac version: %@", universityPath);
}

- (NSString *)nightlifePath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Nightlife";
}

- (void)setNightlifePath:(NSString *)nightlifePath {
    NSLog(@"Nightlife path is fixed in Mac version: %@", nightlifePath);
}

- (NSString *)businessPath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Open for Business";
}

- (void)setBusinessPath:(NSString *)businessPath {
    NSLog(@"Business path is fixed in Mac version: %@", businessPath);
}

- (NSString *)familyFunPath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Family Fun Stuff";
}

- (void)setFamilyFunPath:(NSString *)familyFunPath {
    NSLog(@"Family Fun path is fixed in Mac version: %@", familyFunPath);
}

- (NSString *)glamourPath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Glamour Life Stuff";
}

- (void)setGlamourPath:(NSString *)glamourPath {
    NSLog(@"Glamour path is fixed in Mac version: %@", glamourPath);
}

- (NSString *)petsPath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Pets";
}

- (void)setPetsPath:(NSString *)petsPath {
    NSLog(@"Pets path is fixed in Mac version: %@", petsPath);
}

- (NSString *)seasonsPath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Seasons";
}

- (void)setSeasonsPath:(NSString *)seasonsPath {
    NSLog(@"Seasons path is fixed in Mac version: %@", seasonsPath);
}

- (NSString *)bonVoyagePath {
    return @"/Applications/The Sims 2.app/Contents/Resources/TranslationDictionary/GameData/Expansion Packs/Bon Voyage";
}

- (void)setBonVoyagePath:(NSString *)bonVoyagePath {
    NSLog(@"Bon Voyage path is fixed in Mac version: %@", bonVoyagePath);
}
@end
