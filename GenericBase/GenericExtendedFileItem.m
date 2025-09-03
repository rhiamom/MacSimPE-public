//
//  GenericExtendedFileItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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

#import "GenericExtendedFileItem.h"
#import "GenericFileItem.h"

@implementation GenericExtendedItem {
    GenericCommon *_baseitem;
}

// MARK: - Initialization

- (instancetype)initWithItem:(GenericCommon *)item {
    self = [super init];
    if (self) {
        _baseitem = item;
    }
    return self;
}

- (instancetype)initWithGenericItem:(GenericItem *)item {
    return [self initWithItem:item];
}

// MARK: - Properties

- (GenericCommon *)base {
    return _baseitem;
}

// MARK: - Factory Methods

+ (instancetype)extendedItemWithGenericItem:(GenericItem *)item {
    return [[self alloc] initWithGenericItem:item];
}

+ (instancetype)extendedItemWithGenericCommon:(GenericCommon *)item {
    return [[self alloc] initWithItem:item];
}

@end
