//
//  GenericFileItem.m
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

#import "GenericFileItem.h"

// MARK: - GenericItems Implementation

@implementation GenericItems

// MARK: - Indexed Access

- (GenericItem *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (GenericItem *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [self objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(GenericItem *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(GenericItem *)object {
    [self replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

// MARK: - Collection Operations

- (void)addGenericItem:(GenericItem *)item {
    [self addObject:item];
}

- (void)insertGenericItem:(GenericItem *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeGenericItem:(GenericItem *)item {
    [self removeObject:item];
}

- (BOOL)containsGenericItem:(GenericItem *)item {
    return [self containsObject:item];
}

// MARK: - Properties

- (NSUInteger)length {
    return self.count;
}

// MARK: - Copying

- (instancetype)deepCopy {
    GenericItems *copy = [[GenericItems alloc] init];
    for (GenericItem *item in self) {
        // Note: GenericItem would need to implement a deep copy method
        // For now, we'll just copy the reference
        [copy addGenericItem:item];
    }
    return copy;
}

@end

// MARK: - GenericItem Implementation

@implementation GenericItem
@synthesize subitems = _subitems;
// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _subitems = nil;
    }
    return self;
}

// MARK: - Properties

- (void)setSubitems:(NSArray<GenericItem *> *)subitems {
    _subitems = subitems;
}

- (NSArray<GenericItem *> *)subitems {
    return [self getSubitems];
}

- (NSInteger)count {
    if (_subitems != nil) {
        return (NSInteger)_subitems.count;
    } else {
        return 0;
    }
}

// MARK: - Protected Methods

/**
 * Returns the List of Subitems
 */
- (NSArray<GenericItem *> *)getSubitems {
    if (_subitems == nil) {
        return @[];
    } else {
        return _subitems;
    }
}

@end
