//
//  PathSettings.h
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
#import "GlobalizedObject.h"

@class Registry;

/**
 * This is used to display Paths in the Options Dialog
 * Simplified for Mac version with fixed expansion content
 */
@interface PathSettings : GlobalizedObject

// MARK: - Class Methods
+ (PathSettings *)global;

// MARK: - Initialization
- (instancetype)initWithRegistry:(Registry *)registry;

// MARK: - Path Properties (Mac Sims 2 expansions only)
@property (nonatomic, strong) NSString *saveGamePath;
@property (nonatomic, strong) NSString *baseGamePath;
@property (nonatomic, strong) NSString *universityPath;
@property (nonatomic, strong) NSString *nightlifePath;
@property (nonatomic, strong) NSString *businessPath;
@property (nonatomic, strong) NSString *familyFunPath;
@property (nonatomic, strong) NSString *glamourPath;
@property (nonatomic, strong) NSString *petsPath;
@property (nonatomic, strong) NSString *seasonsPath;
@property (nonatomic, strong) NSString *voyagePath;

// MARK: - Path Management
- (NSString *)getPathForExpansion:(ExpansionItem *)expansionItem;
- (NSString *)getPath:(NSString *)userPath defaultPath:(NSString *)defaultPath;

@end
