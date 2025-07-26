//
//  PackedFileDescriptors.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>

@protocol IPackedFileDescriptor;

/**
 * Typesafe collection for IPackedFileDescriptor Objects
 */
@interface PackedFileDescriptors : NSObject <NSFastEnumeration, NSCopying>

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSInteger length;

- (instancetype)init;
- (instancetype)initWithCapacity:(NSInteger)capacity;

// Indexers
- (id<IPackedFileDescriptor>)objectAtIndex:(NSInteger)index;
- (id<IPackedFileDescriptor>)objectAtIndexedSubscript:(NSInteger)index;
- (void)setObject:(id<IPackedFileDescriptor>)object atIndex:(NSInteger)index;
- (void)setObject:(id<IPackedFileDescriptor>)object atIndexedSubscript:(NSInteger)index;

// Collection methods
- (NSInteger)addObject:(id<IPackedFileDescriptor>)item;
- (void)insertObject:(id<IPackedFileDescriptor>)item atIndex:(NSInteger)index;
- (void)removeObject:(id<IPackedFileDescriptor>)item;
- (BOOL)containsObject:(id<IPackedFileDescriptor>)item;
- (void)removeAllObjects;

// Convenience methods for uint indexing
- (id<IPackedFileDescriptor>)objectAtUnsignedIndex:(uint32_t)index;
- (void)setObject:(id<IPackedFileDescriptor>)object atUnsignedIndex:(uint32_t)index;

@end
