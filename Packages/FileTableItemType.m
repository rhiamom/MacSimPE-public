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
#import "FileTable.h"
#import "PathProvider.h"
#import "Helper.h"
#import "ExpansionItem.h"

@implementation FileTablePaths : NSObject

// MARK: - Factory Methods

+ (FileTableItemType)fromExpansion:(Expansions)expansion {
    return (FileTableItemType)expansion;
}

+ (FileTableItemType)fromInteger:(NSInteger)value {
    return (FileTableItemType)value;
}

+ (FileTableItemType)fromUnsignedInteger:(uint32_t)value {
    return (FileTableItemType)value;
}

// MARK: - Conversion Methods

+ (Expansions)asExpansion:(FileTableItemType)type {
    uint32_t val = (uint32_t)type;
    if (val <= 0x80000000) {
        return (Expansions)val;
    } else {
        return ExpansionsCustom;
    }
}

+ (uint32_t)asUnsignedInteger:(FileTableItemType)type {
    return (uint32_t)type;
}

// MARK: - Utility Methods

+ (NSString *)getRootForType:(FileTableItemType)type {
    uint32_t val = (uint32_t)type;
    NSString *ret = nil;
    
    if (val <= 0x80000000) {
        Expansions expansion = [self asExpansion:type];
        ExpansionItem *expansionItem = [[PathProvider global] getExpansionName:expansion];
        ret = expansionItem.installFolder;
    } else if (type == FileTableItemTypeSaveGameFolder) {
        ret = [PathProvider simSavegameFolder];
    } else if (type == FileTableItemTypeSimPEDataFolder) {
        ret = [Helper simPeDataPath];
    } else if (type == FileTableItemTypeSimPEFolder) {
        ret = [Helper simPePath];
    } else if (type == FileTableItemTypeSimPEPluginFolder) {
        ret = [Helper simPePluginPath];
    }
    
    return ret;
}

+ (NSInteger)getEPVersionForType:(FileTableItemType)type {
    uint32_t val = (uint32_t)type;
    if (val > 0x80000000) return -1;
    
    Expansions expansion = [self asExpansion:type];
    ExpansionItem *ei = [[PathProvider global] getExpansionName:expansion];
    // No need to check for Story packs on Mac - they don't exist
    return ei.version;
}

+ (NSString *)stringForExpansion:(Expansions)expansion {
    switch (expansion) {
        case ExpansionsBaseGame:
            return @"BaseGame";
        case ExpansionsUniversity:
            return @"University";
        case ExpansionsNightlife:
            return @"Nightlife";
        case ExpansionsBusiness:
            return @"Business";
        case ExpansionsFamilyFun:
            return @"FamilyFun";
        case ExpansionsGlamour:
            return @"Glamour";
        case ExpansionsPets:
            return @"Pets";
        case ExpansionsSeasons:
            return @"Seasons";
        case ExpansionsVoyage:
            return @"Voyage";
        // Add other cases as needed
        default:
            return @"Unknown";
    }
}
+ (NSString *)stringForType:(FileTableItemType)type {
    uint32_t val = (uint32_t)type;
    if (val > 0x80000000) {
        switch (type) {
            case FileTableItemTypeAbsolute:
                return @"Absolute";
            case FileTableItemTypeSaveGameFolder:
                return @"SaveGameFolder";
            case FileTableItemTypeSimPEFolder:
                return @"SimPEFolder";
            case FileTableItemTypeSimPEDataFolder:
                return @"SimPEDataFolder";
            case FileTableItemTypeSimPEPluginFolder:
                return @"SimPEPluginFolder";
            default:
                return @"Unknown";
        }
    } else {
        Expansions expansion = [self asExpansion:type];
        return [self stringForExpansion:expansion];
    }
}

- (ExpansionItem *)getExpansion:(Expansions)expansion {
    // Return appropriate ExpansionItem based on the expansion enum
    // For Mac version, you might have fixed paths for each expansion
}
// MARK: - Comparison Methods

+ (NSComparisonResult)compare:(FileTableItemType)typeA with:(FileTableItemType)typeB {
    uint32_t valA = (uint32_t)typeA;
    uint32_t valB = (uint32_t)typeB;
    
    if (valA < valB) return NSOrderedAscending;
    if (valA > valB) return NSOrderedDescending;
    return NSOrderedSame;
}

+ (BOOL)isEqual:(FileTableItemType)typeA to:(FileTableItemType)typeB {
    return [self compare:typeA with:typeB] == NSOrderedSame;
}

- (NSArray<NSString *> *)allPaths {
}

- (instancetype)initWithExpansion:(ExpansionItem *)expansion {
}

- (void)addPath:(NSString *)path {
}

@end
