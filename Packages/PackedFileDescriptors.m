//
//  PackedFileDescriptors.m
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


#import "PackedFileDescriptors.h"
#import "IPackedFileDescriptor.h"

@interface PackedFileDescriptors ()
@property (nonatomic, strong) NSMutableArray<id<IPackedFileDescriptor>> *internalArray;
@end

@implementation PackedFileDescriptors

- (instancetype)init {
    self = [super init];
    if (self) {
        _internalArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    if (self) {
        _internalArray = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

#pragma mark - Properties

- (NSInteger)count {
    return self.internalArray.count;
}

- (NSInteger)length {
    return self.count;
}

#pragma mark - Indexers

/**
 * Integer Indexer
 */
- (id<IPackedFileDescriptor>)objectAtIndex:(NSInteger)index {
    return self.internalArray[index];
}

- (id<IPackedFileDescriptor>)objectAtIndexedSubscript:(NSInteger)index {
    return [self objectAtIndex:index];
}

- (void)setObject:(id<IPackedFileDescriptor>)object atIndex:(NSInteger)index {
    self.internalArray[index] = object;
}

- (void)setObject:(id<IPackedFileDescriptor>)object atIndexedSubscript:(NSInteger)index {
    [self setObject:object atIndex:index];
}

/**
 * unsigned Integer Indexer
 */
- (id<IPackedFileDescriptor>)objectAtUnsignedIndex:(uint32_t)index {
    return [self objectAtIndex:(NSInteger)index];
}

- (void)setObject:(id<IPackedFileDescriptor>)object atUnsignedIndex:(uint32_t)index {
    [self setObject:object atIndex:(NSInteger)index];
}

#pragma mark - Collection Methods

/**
 * add a new Element
 * @param item The object you want to add
 * @returns The index it was added on
 */
- (NSInteger)addObject:(id<IPackedFileDescriptor>)item {
    [self.internalArray addObject:item];
    return self.internalArray.count - 1;
}

/**
 * insert a new Element
 * @param item The object that should be inserted
 * @param index The Index where the Element should be stored
 */
- (void)insertObject:(id<IPackedFileDescriptor>)item atIndex:(NSInteger)index {
    [self.internalArray insertObject:item atIndex:index];
}

/**
 * remove an Element
 * @param item The object that should be removed
 */
- (void)removeObject:(id<IPackedFileDescriptor>)item {
    [self.internalArray removeObject:item];
}

/**
 * Checks whether or not the object is already stored in the List
 * @param item The Object you are looking for
 * @returns true, if it was found
 */
- (BOOL)containsObject:(id<IPackedFileDescriptor>)item {
    return [self.internalArray containsObject:item];
}

- (void)removeAllObjects {
    [self.internalArray removeAllObjects];
}

// Add this method implementation to your existing PackedFileDescriptors.m
// (You'll need to see your existing implementation to know where exactly to place this,
// but it should go with the other collection methods)

- (void)addRange:(NSArray<id<IPackedFileDescriptor>> *)items {
    if (items != nil) {
        for (id<IPackedFileDescriptor> item in items) {
            [self addObject:item];
        }
    }
}

- (void)addObjectsFromCollection:(PackedFileDescriptors *)other {
    if (other != nil) {
        for (id<IPackedFileDescriptor> item in other) {
            [self addObject:item];
        }
    }
}

- (NSArray<id<IPackedFileDescriptor>> *)allObjects {
    // You'll need to implement this based on your internal storage
    // If you're using an NSMutableArray internally, return a copy
    // return [self.internalArray copy];
    
    // If you need to build the array from enumeration:
    NSMutableArray<id<IPackedFileDescriptor>> *result = [[NSMutableArray alloc] init];
    for (id<IPackedFileDescriptor> item in self) {
        [result addObject:item];
    }
    return [result copy];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    return [self.internalArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - NSCopying

/**
 * Create a clone of this Object
 * @returns The clone
 */
- (id)copyWithZone:(NSZone *)zone {
    PackedFileDescriptors *copy = [[PackedFileDescriptors alloc] init];
    for (id<IPackedFileDescriptor> item in self) {
        [copy addObject:item];
    }
    return copy;
}



@end
