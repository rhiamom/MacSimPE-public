//
//  CacheLists.h
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

#import <Foundation/Foundation.h>

@protocol ICacheItem;
@class CacheContainer;

NS_ASSUME_NONNULL_BEGIN

/**
 * Type-safe NSMutableArray for ICacheItem Objects
 */
@interface CacheItems : NSMutableArray<id<ICacheItem>>

// MARK: - Indexed Access
- (id<ICacheItem>)objectAtIndex:(NSUInteger)index;
- (id<ICacheItem>)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id<ICacheItem>)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(id<ICacheItem>)object;

// MARK: - Collection Operations
- (void)addCacheItem:(id<ICacheItem>)item;
- (void)insertCacheItem:(id<ICacheItem>)item atIndex:(NSUInteger)index;
- (void)removeCacheItem:(id<ICacheItem>)item;
- (BOOL)containsCacheItem:(id<ICacheItem>)item;

// MARK: - Properties
@property (nonatomic, readonly) NSUInteger length;

// MARK: - Copying
- (instancetype)deepCopy;

@end

/**
 * Type-safe NSMutableArray for CacheContainer Objects
 */
@interface CacheContainers : NSMutableArray<CacheContainer *>

// MARK: - Indexed Access
- (CacheContainer *)objectAtIndex:(NSUInteger)index;
- (CacheContainer *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(CacheContainer *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(CacheContainer *)object;

// MARK: - Collection Operations
- (void)addCacheContainer:(CacheContainer *)item;
- (void)insertCacheContainer:(CacheContainer *)item atIndex:(NSUInteger)index;
- (void)removeCacheContainer:(CacheContainer *)item;
- (BOOL)containsCacheContainer:(CacheContainer *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSUInteger length;

// MARK: - Copying
- (instancetype)deepCopy;

@end

NS_ASSUME_NONNULL_END
