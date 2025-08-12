//
//  FileTableItemType.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/6/25.
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "FileTableItemType.h"
#import "FileTableEnums.h"
#import "PathProvider.h"   // only if you call into it (e.g., getRoot/allPaths)
#import "Helper.h"
#import "ExpansionItem.h"

@interface FileTableItemType ()
@property (nonatomic, readwrite) uint32_t val;
@end

@implementation FileTableItemType
- (BOOL)isPathToken {
    return (self.val & 0x80000000u) != 0;
}

- (Expansions)asExpansions {
    NSAssert(!self.isPathToken, @"asExpansions called on a path token");
    return (Expansions)self.val;
}

- (FileTableItemTypePaths)asFileTableItemTypePaths {
    NSAssert(self.isPathToken, @"asFileTableItemTypePaths called on an expansion value");
    return (FileTableItemTypePaths)self.val;
}

- (instancetype)initWithExpansion:(Expansions)expansion {
    return [self initWithInt:(int)expansion];
}

- (instancetype)initWithFileTablePath:(FileTablePaths)path {
    return [self initWithRawValue:(uint32_t)path];
}

- (instancetype)initWithUInt:(uint32_t)raw {
    self = [super init];
    if (self) { _val = raw; }
    return self;
}

- (instancetype)initWithRawValue:(uint32_t)raw {
    self = [super init];
    if (self) {
        _val = raw;
    }
    return self;
}

// If you kept -init available, funnel it:
- (instancetype)init {
    return [self initWithRawValue:0];
}

- (instancetype)initWithInt:(int32_t)raw {
    return [self initWithUInt:(uint32_t)raw];
}

- (FileTablePaths)asFileTablePaths {
    return (_val >  0x80000000u) ? (FileTablePaths)_val : FileTablePathsAbsolute;
}

- (uint32_t)asUint { return _val; }

- (NSString *)getRoot {
    if (_val <= 0x80000000u) {
        // Base game
        if ([self asExpansions] == ExpansionsBaseGame) {
            return @"/Applications/The Sims 2.app/Contents/Assets/TSData";
        }
        // Expansion packs
        NSString *expansionName = [[[PathProvider global] expansionForEnum:[self asExpansions]] name];
        return [NSString stringWithFormat:
            @"/Applications/The Sims 2.app/Contents/Assets/Expansion Packs/%@/TSData",
            expansionName];
    }
    if (_val == (uint32_t)FileTablePathsSaveGameFolder)  return [PathProvider simSavegameFolder];
    if (_val == (uint32_t)FileTablePathsSimPEDataFolder) return [Helper simPeDataPath];
    if (_val == (uint32_t)FileTablePathsSimPEFolder)     return [Helper simPePath];
    if (_val == (uint32_t)FileTablePathsSimPEPluginFolder) return [Helper simPePluginPath];
    return nil;
}
- (NSInteger)getEpVersion {
    // For Aspyr Super Collection only:
    // Treat any expansion-coded value as Bon Voyage (max supported EP).
    if (_val > 0x80000000u) return -1;   // not an expansion (it's a special FileTable path)
    return 6;                             // Bon Voyage
}

// Your convenience method (adjust to your PathProvider API)
- (NSArray<NSString *> *)allPaths {
    // 1) Path tokens (high bit set)
    if ((self.val & 0x80000000u) != 0) {
        NSString *token = [self fileTablePathToken];
        if (token) {
            // allPathsForPath: is a CLASS method; call it on the class
            return [PathProvider allPathsForPath:token];
        }
        // e.g., Absolute token (no variable to expand)
        return @[];
    }

    // 2) Expansion -> concrete EP folder (Aspyr layout)
    Expansions ep = [self asExpansions];
    if (ep != ExpansionsNone) {
        NSString *assets = @"/Applications/The Sims 2.app/Contents/Assets";
        NSString *epRoot = [assets stringByAppendingPathComponent:@"Expansion Packs"];
        NSString *expName = [PathProvider expansionFolderNameForExpansion:ep];
        if (expName.length) {
            return @[ [epRoot stringByAppendingPathComponent:expName] ];
        }
    }

    // 3) Fallback (neither token nor known expansion)
    return @[];
}

+ (NSString *)stringForType:(FileTableItemType *)type {
    return [type stringValue];
}

- (NSString *)stringValue {
    // Path-kinds live above 0x80000000; expansions are below/equal.
    if (self.val > 0x80000000u) {
        // Path token
        switch ([self asFileTableItemTypePaths]) {
            case FileTableItemTypeAbsolute:           return @"Absolute";
            case FileTableItemTypeSaveGameFolder:     return @"SaveGameFolder";
            case FileTableItemTypeSimPEFolder:        return @"SimPEFolder";
            case FileTableItemTypeSimPEDataFolder:    return @"SimPEDataFolder";
            case FileTableItemTypeSimPEPluginFolder:  return @"SimPEPluginFolder";
            default:                                  return [NSString stringWithFormat:@"0x%08X", self.val];
        }
    } else
        switch ([self asExpansions]) {
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
            default:                     return [NSString stringWithFormat:@"Expansions(0x%08X)", self.val];
        }
    
}

- (NSString *)fileTablePathLabel {
    switch ([self asFileTableItemTypePaths]) {
        case FileTableItemTypeAbsolute:           return @"Absolute";
        case FileTableItemTypeSaveGameFolder:     return @"SaveGameFolder";
        case FileTableItemTypeSimPEFolder:        return @"SimPEFolder";
        case FileTableItemTypeSimPEDataFolder:    return @"SimPEDataFolder";
        case FileTableItemTypeSimPEPluginFolder:  return @"SimPEPluginFolder";
    }
    return [NSString stringWithFormat:@"0x%08X", self.val];
}

- (nullable NSString *)fileTablePathToken {
    switch ([self asFileTableItemTypePaths]) {
        case FileTableItemTypeAbsolute:
            return nil; // absolute path, nothing to expand

        case FileTableItemTypeSaveGameFolder:
            return @"$(TS2_Downloads)";

        case FileTableItemTypeSimPEFolder:
            return @"$(SimPE_Folder)";

        case FileTableItemTypeSimPEDataFolder:
            return @"$(SimPE_DataFolder)";

        case FileTableItemTypeSimPEPluginFolder:
            return @"$(SimPE_PluginFolder)";
    }
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)pathVars {
    NSString *assets   = @"/Applications/The Sims 2.app/Contents/Assets";
    NSString *epRoot   = [assets stringByAppendingPathComponent:@"Expansion Packs"];
    NSString *downloads = [[PathProvider simSavegameFolder] stringByAppendingPathComponent:@"Downloads"];

    NSMutableDictionary<NSString *, NSString *> *vars = [@{
        @"TS2_Base": assets,
        @"TS2_EP_Root": epRoot,
        @"TS2_Downloads": downloads
    } mutableCopy];

    NSString *expName = [PathProvider expansionFolderNameForExpansion:self.expansion] ?: @"";
    if (expName.length > 0) {
        vars[@"TS2_EP_Current"] = [epRoot stringByAppendingPathComponent:expName];
    }
    return [vars copy];
}

@end
