//
//  OpcodeProvider.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/19/25.
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
#import "SimCommonPackage.h"
#import "IOpcodeProvider.h"

@protocol IAlias;
@protocol IScenegraphFileIndexItem;
@protocol IPackedFileDescriptor;

/**
 * Provides an Alias Matching a SimID with it's Name
 */
@interface OpcodeProvider : SimCommonPackage <IOpcodeProvider>

// MARK: - Private Properties
@property (nonatomic, strong) NSMutableArray *names;
@property (nonatomic, strong) NSMutableArray *operands;
@property (nonatomic, strong) NSMutableArray *dataowners;
@property (nonatomic, strong) NSMutableArray *objddesc;
@property (nonatomic, strong) NSMutableArray *motives;
@property (nonatomic, strong) NSMutableArray *objf;
@property (nonatomic, strong) NSMutableDictionary *memories;

// MARK: - Initialization
- (instancetype)init;

// MARK: - Loading Methods
- (void)loadMemories;
- (void)loadData:(NSMutableArray **)list instance:(uint16_t)instance lang:(uint16_t)lang;
- (void)loadObjdDescription:(uint16_t)type;
- (void)loadDataOwners;
- (void)loadObjf;
- (void)loadOperators;
- (void)loadMotives;
- (void)loadOpcodes;

@end
