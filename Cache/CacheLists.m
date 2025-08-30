//
//  CacheLists.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/29/25.
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

#import "CacheLists.h"
#import "ICacheItem.h"
#import "CacheContainer.h"

// MARK: - CacheItems Implementation

@implementation CacheItems

// MARK: - Indexed Access

- (id<ICacheItem>)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (id<ICacheItem>)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id<ICacheItem>)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(id<ICacheItem>)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

// MARK: - Collection Operations

- (void)addCacheItem:(id<ICacheItem>)item {
    [self addObject:item];
}

- (void)insertCacheItem:(id<ICacheItem>)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeCacheItem:(id<ICacheItem>)item {
    [self removeObject:item];
}

- (BOOL)containsCacheItem:(id<ICacheItem>)item {
    return [self containsObject:item];
}

// MARK: - Properties

- (NSUInteger)length {
    return [self count];
}

// MARK: - Copying

- (instancetype)deepCopy {
    CacheItems *list = [[CacheItems alloc] init];
    for (id<ICacheItem> item in self) {
        [list addCacheItem:item];
    }
    return list;
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self deepCopy];
}

@end

// MARK: - CacheContainers Implementation

@implementation CacheContainers

// MARK: - Indexed Access

- (CacheContainer *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (CacheContainer *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(CacheContainer *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(CacheContainer *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

// MARK: - Collection Operations

- (void)addCacheContainer:(CacheContainer *)item {
    [self addObject:item];
}

- (void)insertCacheContainer:(CacheContainer *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeCacheContainer:(CacheContainer *)item {
    [self removeObject:item];
}

- (BOOL)containsCacheContainer:(CacheContainer *)item {
    return [self containsObject:item];
}

// MARK: - Properties

- (NSUInteger)length {
    return [self count];
}

// MARK: - Copying

- (instancetype)deepCopy {
    CacheContainers *list = [[CacheContainers alloc] init];
    for (CacheContainer *item in self) {
        [list addCacheContainer:item];
    }
    return list;
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self deepCopy];
}

@end
