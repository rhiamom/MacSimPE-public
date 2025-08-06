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

// MARK: - Expansions Enum (simplified for Mac)

typedef NS_OPTIONS(uint32_t, Expansions) {
    ExpansionsNone =              0x0,
    ExpansionsBaseGame =          0x1,
    ExpansionsUniversity =        0x2,
    ExpansionsNightlife =         0x4,
    ExpansionsBusiness =          0x8,
    ExpansionsFamilyFun =         0x10,
    ExpansionsGlamour =           0x20,
    ExpansionsPets =              0x40,
    ExpansionsSeasons =           0x80,
    //ExpansionsCelebrations =      0x100,
    //ExpansionsFashion =           0x200,
    ExpansionsVoyage =            0x400,
    //ExpansionsTeen =              0x800,
    //ExpansionsStore =             0x1000,
    //ExpansionsFreeTime =          0x2000,
    //ExpansionsApartments =        0x00010000,
    //ExpansionsMansions =          0x00020000,
    ExpansionsCustom =            0x80000000
};

// MARK: - PathProvider Interface

@interface PathProvider : NSObject

// MARK: - Properties (simplified for Mac with fixed content)
@property (nonatomic, readonly) Expansions lastKnown;
@property (nonatomic, readonly) int gameVersion;
@property (nonatomic, readonly) int epInstalled;
@property (nonatomic, readonly) int spInstalled;
@property (nonatomic, readonly) int64_t availableGroups;
@property (nonatomic, readonly) int currentGroup;

// MARK: - Class Methods
+ (PathProvider *)global;
+ (NSString *)expansionFile;
+ (NSString *)personalFolder;
+ (NSString *)displayedName;

// MARK: - Path Properties (Mac-specific paths)
+ (NSString *)simSavegameFolder;
+ (void)setSimSavegameFolder:(NSString *)folder;
@property (nonatomic, readonly) NSString *neighborhoodFolder;
@property (nonatomic, readonly) NSString *backupFolder;

// MARK: - Initialization
- (instancetype)init;

// MARK: - Path Management
- (NSArray<NSString *> *)getSaveGamePathForGroup:(int64_t)group;
- (int64_t)saveGamePathProvidedByGroup:(NSString *)path;

// MARK: - System Management
- (void)flush;

@end
