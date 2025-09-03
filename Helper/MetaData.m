//
//  MetaData.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
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

#import "MetaData.h"
#import "TypeAlias.h"
#import "TGILoader.h"
#import "PathProvider.h"
#import <Cocoa/Cocoa.h>

@implementation MetaData

// MARK: - Core Constants

+ (uint32_t)DIRECTORY_FILE { return 0xE86B1EEF; }
+ (uint16_t)COMPRESS_SIGNATURE { return 0xFB10; }
+ (uint32_t)RELATION_FILE { return 0xCC364C2A; }
+ (uint32_t)STRING_FILE { return 0x53545223; }
+ (uint32_t)PIE_STRING_FILE { return 0x54544173; }
+ (uint32_t)SIM_DESCRIPTION_FILE { return 0xAACE2EFB; }
+ (uint32_t)SIM_IMAGE_FILE { return 0x856DDBAC; }
+ (uint32_t)FAMILY_TIES_FILE { return 0x8C870743; }
+ (uint32_t)BHAV_FILE { return 0x42484156; }
+ (uint32_t)GLOB_FILE { return 0x474C4F42; }
+ (uint32_t)OBJD_FILE { return 0x4F424A44; }
+ (uint32_t)CTSS_FILE { return 0x43545353; }
+ (uint32_t)NAME_MAP { return 0x4E6D6150; }
+ (uint32_t)GLUA { return 0x474C5541; }
+ (uint32_t)OLUA { return 0x4F4C5541; }
+ (uint32_t)MEMORIES { return 0x4E474248; }
+ (uint32_t)SDNA { return 0xEBFEE33F; }
+ (uint32_t)GZPS { return 0xEBCF3E27; }
+ (uint32_t)XWNT { return 0xED7D7B4D; }
+ (uint32_t)REF_FILE { return 0xAC506764; }
+ (uint32_t)IDNO { return 0xAC8A7A2E; }
+ (uint32_t)HOUS { return 0x484F5553; }
+ (uint32_t)SLOT { return 0x534C4F54; }
+ (uint32_t)GMND { return 0x7BA3838C; }
+ (uint32_t)TXMT { return 0x49596978; }
+ (uint32_t)TXTR { return 0x1C4A276C; }
+ (uint32_t)LIFO { return 0xED534136; }
+ (uint32_t)SHPE { return 0xFC6EB1F7; }
+ (uint32_t)CRES { return 0xE519C933; }
+ (uint32_t)GMDC { return 0xAC4F8687; }
+ (uint32_t)MMAT { return 0x4C697E5A; }
+ (uint32_t)BINX { return 0x0C560F39; }
+ (uint32_t)XSTN { return 0x4C158081; }
+ (uint32_t)XMOL { return 0x0C1FE246; }
+ (uint32_t)XHTN { return 0x8C1580B5; }
+ (uint32_t)AGED { return 0x2C1FD8A1; }
+ (uint32_t)FCRG { return 0x8C93BF6C; }
+ (uint32_t)FCNT { return 0x6C93B566; }
+ (uint32_t)FCMD { return 0x0C93E3DE; }
+ (uint32_t)FCAR { return 0x8C93E35C; }
+ (uint32_t)XPBO { return 0xD1954460; }
+ (uint32_t)XOBJ { return 0xCCA8E925; }
+ (uint32_t)XROF { return 0xACA8EA06; }
+ (uint32_t)XFLR { return 0x4DCADB7E; }
+ (uint32_t)XFNC { return 0x2CB230B8; }
+ (uint32_t)XNGB { return 0x6D619378; }
+ (uint32_t)ANIM { return 0xFB00791E; }
+ (uint32_t)LDIR { return 0xC9C81B9B; }
+ (uint32_t)LAMB { return 0xC9C81BA3; }
+ (uint32_t)LPNT { return 0xC9C81BA9; }
+ (uint32_t)LSPT { return 0xC9C81BAD; }
+ (uint32_t)CUSTOM_GROUP { return 0x1C050000; }
+ (uint32_t)GLOBAL_GROUP { return 0x1C0532FA; }
+ (uint32_t)LOCAL_GROUP { return 0xFFFFFFFF; }

// MARK: - CEP String Constants

+ (NSString *)GMND_PACKAGE {
    NSString *savegameFolder = [PathProvider simSavegameFolder];
    return [savegameFolder stringByAppendingPathComponent:@"Downloads/_EnableColorOptionsGMND.package"];
}

+ (NSString *)MMAT_PACKAGE {
    return @"/Applications/The Sims 2/Contents/Assets/TSData/Res/Sims3D/_EnableColorOptionsMMAT.package";
}

+ (NSString *)ZCEP_FOLDER {
    NSString *savegameFolder = [PathProvider simSavegameFolder];
    return [savegameFolder stringByAppendingPathComponent:@"Downloads/zCEP-EXTRA"];
}

+ (NSString *)CTLG_FOLDER {
    return @"/Applications/The Sims 2/Contents/Assets/TSData/Res/Catalog/zCEP-EXTRA";
}
// Add these implementations to your MetaData.m file

// MARK: - Color Properties Implementation

+ (NSColor *)specialSimColor {
    // Color of a Sim that is either Unlinked or does not have Character Data
    // C#: Color.FromArgb(0xD0, Color.Black) = rgba(0, 0, 0, 0xD0/255)
    return [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:(0xD0/255.0)];
}

+ (NSColor *)unlinkedSim {
    // Color of a Sim that is unlinked
    // C#: Color.FromArgb(0xEF, Color.SteelBlue) = rgba(70, 130, 180, 0xEF/255)
    return [NSColor colorWithRed:(70.0/255.0) green:(130.0/255.0) blue:(180.0/255.0) alpha:(0xEF/255.0)];
}

+ (NSColor *)npcSim {
    // Color of a NPC Sim
    // C#: Color.FromArgb(0xEF, Color.YellowGreen) = rgba(154, 205, 50, 0xEF/255)
    return [NSColor colorWithRed:(154.0/255.0) green:(205.0/255.0) blue:(50.0/255.0) alpha:(0xEF/255.0)];
}

+ (NSColor *)inactiveSim {
    // Color of a Sim that has no Character Data
    // C#: Color.FromArgb(0xEF, Color.LightCoral) = rgba(240, 128, 128, 0xEF/255)
    return [NSColor colorWithRed:(240.0/255.0) green:(128.0/255.0) blue:(128.0/255.0) alpha:(0xEF/255.0)];
}

// MARK: - Semi-Global Methods
+ (uint32_t)semiGlobalID:(NSString *)sgname {
    // Known semi-global mappings from SimPE
    NSDictionary *semiGlobals = @{
        @"objects": @0x7FD46CD0,
        @"doors": @0x7FD46CD1,
        @"windows": @0x7FD46CD2,
        @"stairs": @0x7FD46CD3,
        @"tiles": @0x7FD46CD4,
        @"roofs": @0x7FD46CD5,
        @"terrain": @0x7FD46CD6,
        @"sims": @0x7FD46CD7,
        @"vehicles": @0x7FD46CD8,
        @"pets": @0x7FD46CD9,
        @"lighting": @0x7FD46CDA,
        @"plumbing": @0x7FD46CDB,
        @"appliances": @0x7FD46CDC,
        @"electronics": @0x7FD46CDD,
        @"decorative": @0x7FD46CDE,
        @"general": @0x7FD46CDF,
        @"hobbies": @0x7FD46CE0,
        @"aspiration": @0x7FD46CE1,
        @"career": @0x7FD46CE2,
        @"comfort": @0x7FD46CE3,
        @"seating": @0x7FD46CE4,
        @"surfaces": @0x7FD46CE5,
        @"storage": @0x7FD46CE6,
        @"knowledge": @0x7FD46CE7,
        @"creativity": @0x7FD46CE8,
        @"exercise": @0x7FD46CE9,
        @"miscellaneous": @0x7FD46CEA
    };
    
    NSString *lowercaseName = [sgname lowercaseString];
    NSNumber *result = semiGlobals[lowercaseName];
    return result ? [result unsignedIntValue] : 0;
}

+ (NSString *)semiGlobalName:(uint32_t)sgid {
    // Reverse lookup for semi-global names
    NSDictionary *semiGlobalNames = @{
        @0x7FD46CD0: @"objects",
        @0x7FD46CD1: @"doors",
        @0x7FD46CD2: @"windows",
        @0x7FD46CD3: @"stairs",
        @0x7FD46CD4: @"tiles",
        @0x7FD46CD5: @"roofs",
        @0x7FD46CD6: @"terrain",
        @0x7FD46CD7: @"sims",
        @0x7FD46CD8: @"vehicles",
        @0x7FD46CD9: @"pets",
        @0x7FD46CDA: @"lighting",
        @0x7FD46CDB: @"plumbing",
        @0x7FD46CDC: @"appliances",
        @0x7FD46CDD: @"electronics",
        @0x7FD46CDE: @"decorative",
        @0x7FD46CDF: @"general",
        @0x7FD46CE0: @"hobbies",
        @0x7FD46CE1: @"aspiration",
        @0x7FD46CE2: @"career",
        @0x7FD46CE3: @"comfort",
        @0x7FD46CE4: @"seating",
        @0x7FD46CE5: @"surfaces",
        @0x7FD46CE6: @"storage",
        @0x7FD46CE7: @"knowledge",
        @0x7FD46CE8: @"creativity",
        @0x7FD46CE9: @"exercise",
        @0x7FD46CEA: @"miscellaneous"
    };
    
    NSString *result = semiGlobalNames[@(sgid)];
    return result ? result : @"";
}

+ (NSString *)findSemiGlobal:(NSString *)name {
    uint32_t sgid = [self semiGlobalID:name];
    if (sgid != 0) {
        return [NSString stringWithFormat:@"0x%08X", sgid];
    }
    return [name lowercaseString];
}

// MARK: - Static Methods

+ (NSArray<NSNumber *> *)rcolList {
    return @[
        @([self GMDC]),
        @([self TXTR]),
        @([self LIFO]),
        @([self TXMT]),
        @([self ANIM]),
        @([self GMND]),
        @([self SHPE]),
        @([self CRES]),
        @([self LDIR]),
        @([self LAMB]),
        @([self LSPT]),
        @([self LPNT])
    ];
}

+ (NSArray<NSNumber *> *)compressionCandidates {
    NSMutableArray *list = [[self rcolList] mutableCopy];
    [list addObject:@([self STRING_FILE])];
    [list addObject:@(0x0C560F39)]; // Binary Index
    [list addObject:@(0xAC506764)]; // 3D IDR
    return [list copy];
}

+ (NSArray<NSNumber *> *)cachedFileTypes {
    NSMutableArray *list = [[self rcolList] mutableCopy];
    [list addObject:@([self OBJD_FILE])];
    [list addObject:@([self CTSS_FILE])];
    [list addObject:@([self STRING_FILE])];
    [list addObject:@([self XFLR])];
    [list addObject:@([self XFNC])];
    [list addObject:@([self XNGB])];
    [list addObject:@([self XOBJ])];
    [list addObject:@([self XROF])];
    [list addObject:@([self XWNT])];
    return [list copy];
}

+ (ChildAge)ageTranslation:(LifeSections)age {
    switch (age) {
        case LifeSectionsAdult: return ChildAgeAdult;
        case LifeSectionsBaby: return ChildAgeBaby;
        case LifeSectionsChild: return ChildAgeChild;
        case LifeSectionsElder: return ChildAgeElder;
        case LifeSectionsTeen: return ChildAgeTeen;
        case LifeSectionsToddler: return ChildAgeToddler;
        default: return ChildAgeAdult;
    }
}

+ (TypeAlias *)findTypeAlias:(uint32_t)pfdType {
    TypeAlias *typeAlias = [[TGILoader shared] getByType:pfdType];
    
    // If not found in TGI loader, return a default unknown type
    if (!typeAlias) {
        typeAlias = [[TypeAlias alloc] initWithContainsFilename:NO
                                                      shortName:@"UNK"
                                                         typeID:pfdType
                                                           name:[NSString stringWithFormat:@"0x%08X", pfdType]
                                                      extension:@"dat"];
    }
    
    return typeAlias;
}
        @end
