//
//  Containers.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

#import "Containers.h"

// MARK: - IntArrayList Implementation

@implementation IntArrayList

// MARK: - Indexer Methods

- (int)intAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] intValue];
}

- (void)setInt:(int)value atIndex:(NSUInteger)index {
    [self replaceObjectAtIndex:index withObject:@(value)];
}

- (int)intAtUnsignedIndex:(uint32_t)index {
    return [self intAtIndex:(NSUInteger)index];
}

- (void)setInt:(int)value atUnsignedIndex:(uint32_t)index {
    [self setInt:value atIndex:(NSUInteger)index];
}

// MARK: - Collection Methods

- (NSUInteger)addInt:(int)item {
    [self addObject:@(item)];
    return self.count - 1;
}

- (void)insertInt:(int)item atIndex:(NSUInteger)index {
    [self insertObject:@(item) atIndex:index];
}

- (void)removeInt:(int)item {
    [self removeObject:@(item)];
}

- (BOOL)containsInt:(int)item {
    return [self containsObject:@(item)];
}

// MARK: - Properties

- (NSUInteger)length {
    return self.count;
}

// MARK: - Cloning

- (IntArrayList *)clone {
    IntArrayList *newList = [[IntArrayList alloc] init];
    for (NSNumber *number in self) {
        [newList addInt:[number intValue]];
    }
    return newList;
}

@end

// MARK: - StringArrayList Implementation

@implementation StringArrayList

// MARK: - Indexer Methods

- (NSString *)stringAtIndex:(NSUInteger)index {
    return [self objectAtIndex:index];
}

- (void)setString:(NSString *)value atIndex:(NSUInteger)index {
    [self replaceObjectAtIndex:index withObject:value ?: @""];
}

- (NSString *)stringAtUnsignedIndex:(uint32_t)index {
    return [self stringAtIndex:(NSUInteger)index];
}

- (void)setString:(NSString *)value atUnsignedIndex:(uint32_t)index {
    [self setString:value atIndex:(NSUInteger)index];
}

// MARK: - Collection Methods

- (NSUInteger)addString:(NSString *)item {
    [self addObject:item ?: @""];
    return self.count - 1;
}

- (void)insertString:(NSString *)item atIndex:(NSUInteger)index {
    [self insertObject:item ?: @"" atIndex:index];
}

- (void)removeString:(NSString *)item {
    [self removeObject:item ?: @""];
}

- (BOOL)containsString:(NSString *)item {
    return [self containsObject:item ?: @""];
}

// MARK: - Properties

- (NSUInteger)length {
    return self.count;
}

// MARK: - Cloning

- (StringArrayList *)clone {
    StringArrayList *newList = [[StringArrayList alloc] init];
    for (NSString *string in self) {
        [newList addString:string];
    }
    return newList;
}

@end
