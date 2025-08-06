//
//  ResourceMaps.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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
// ***************************************************************************/

#import "ResourceMaps.h"

// MARK: - IntMap Implementation

@implementation IntMap

// IntMap inherits all functionality from NSMutableDictionary
// No additional implementation needed for basic dictionary operations

@end

// MARK: - LongMap Implementation

@implementation LongMap

// LongMap inherits all functionality from NSMutableDictionary
// No additional implementation needed for basic dictionary operations

@end

// MARK: - ResourceMaps Implementation

@interface ResourceMaps ()
@property (nonatomic, strong, readwrite) ResourceNameList *everything;
@property (nonatomic, strong, readwrite) IntMap *byType;
@property (nonatomic, strong, readwrite) IntMap *byGroup;
@property (nonatomic, strong, readwrite) LongMap *byInstance;
@end

@implementation ResourceMaps

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _everything = [[ResourceNameList alloc] init];
        _byType = [[IntMap alloc] init];
        _byGroup = [[IntMap alloc] init];
        _byInstance = [[LongMap alloc] init];
    }
    return self;
}

// MARK: - Management

- (void)clear {
    [self clearKeepEverything:YES];
}

- (void)clearKeepEverything:(BOOL)clearEverything {
    [self.byType removeAllObjects];
    [self.byGroup removeAllObjects];
    [self.byInstance removeAllObjects];
    
    if (clearEverything) {
        [self.everything removeAllObjects];
    }
}

@end
