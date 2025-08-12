//
//  FileTableEnums.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/11/25.
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

#pragma once
#import <Foundation/Foundation.h>

// Matches the C# Expansions bitmask enum
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
    //ExpansionsCustom =            0x80000000
};

// Matches the C# FileTablePaths enum
typedef NS_ENUM(uint32_t, FileTablePaths) {
    FileTablePathsAbsolute         = 0x8FFF0000,
    FileTablePathsSaveGameFolder   = 0x8FFF0001,

    FileTablePathsSimPEFolder      = 0x8FFE0000,
    FileTablePathsSimPEDataFolder  = 0x8FFE0001,
    FileTablePathsSimPEPluginFolder= 0x8FFE0002
};

typedef NS_ENUM(NSInteger, FTFileLocation) {
    FileLocationBaseGame,
    FileLocationExpansionPack,
    FileLocationDownloads
};

typedef NS_ENUM(uint32_t, FileTableItemTypePaths) {
    FileTableItemTypeAbsolute = 0x8FFF0000,
    FileTableItemTypeSaveGameFolder = 0x8FFF0001,
    FileTableItemTypeSimPEFolder = 0x8FFE0000,
    FileTableItemTypeSimPEDataFolder = 0x8FFE0001,
    FileTableItemTypeSimPEPluginFolder = 0x8FFE0002
};
