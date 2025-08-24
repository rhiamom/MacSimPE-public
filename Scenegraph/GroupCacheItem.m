//
//  GroupCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "GroupCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"

@implementation GroupCacheItem {
    NSString *_fileName;
    uint32_t _unknown1;
    uint32_t _localGroup;
    NSMutableArray<NSNumber *> *_unknown2;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileName = @"";
        _unknown1 = 0;
        _localGroup = 0;
        _unknown2 = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - Properties

- (NSString *)fileName {
    return [_fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
}

- (void)setFileName:(NSString *)fileName {
    _fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
}

- (uint32_t)localGroup {
    return _localGroup;
}

- (void)setLocalGroup:(uint32_t)localGroup {
    _localGroup = localGroup;
}

// MARK: - Serialization Methods

- (void)unserialize:(BinaryReader *)reader {
    int32_t count = [reader readInt32];
    
    // Read filename bytes
    NSData *filenameData = [reader readBytes:count];
    _fileName = [Helper dataToString:filenameData];
    
    _unknown1 = [reader readUInt32];
    _localGroup = [reader readUInt32];
    
    // Read unknown2 array
    uint32_t unknown2Count = [reader readUInt32];
    _unknown2 = [[NSMutableArray alloc] initWithCapacity:unknown2Count];
    
    for (uint32_t i = 0; i < unknown2Count; i++) {
        uint32_t value = [reader readUInt32];
        [_unknown2 addObject:@(value)];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    // Convert filename to bytes
    NSData *filenameData = [Helper stringToBytes:_fileName];
    
    // Write filename length and data
    [writer writeInt32:(int32_t)filenameData.length];
    [writer writeData:filenameData];
    
    // Write unknown1 and localGroup
    [writer writeUInt32:_unknown1];
    [writer writeUInt32:_localGroup];
    
    // Write unknown2 array
    [writer writeUInt32:(uint32_t)_unknown2.count];
    for (NSNumber *value in _unknown2) {
        [writer writeUInt32:[value unsignedIntValue]];
    }
}

// MARK: - String Representation

- (NSString *)description {
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result appendString:self.fileName];
    [result appendString:@" => 0x"];
    [result appendString:[Helper hexStringUInt:_unknown1]];
    [result appendString:@":0x"];
    [result appendString:[Helper hexStringUInt:self.localGroup]];
    [result appendString:@" ("];
    
    for (NSUInteger i = 0; i < _unknown2.count; i++) {
        if (i != 0) {
            [result appendString:@", "];
        }
        [result appendString:[Helper hexStringUInt:[_unknown2[i] unsignedIntValue]]];
    }
    
    [result appendString:@" )"];
    
    return [result copy];
}

@end

// MARK: - GroupCacheItems Implementation

@implementation GroupCacheItems

// MARK: - Typed Accessors

- (GroupCacheItem *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(GroupCacheItem *)item {
    [super replaceObjectAtIndex:index withObject:item];
}

- (GroupCacheItem *)objectAtUIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtUIntIndex:(uint32_t)index withObject:(GroupCacheItem *)item {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:item];
}

// MARK: - Collection Operations

- (NSInteger)addItem:(GroupCacheItem *)item {
    [self addObject:item];
    return (NSInteger)(self.count - 1);
}

- (void)insertItem:(GroupCacheItem *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeItem:(GroupCacheItem *)item {
    [self removeObject:item];
}

- (BOOL)containsItem:(GroupCacheItem *)item {
    return [self containsObject:item];
}

// MARK: - Properties

- (NSInteger)length {
    return (NSInteger)self.count;
}

// MARK: - Copying

- (id)clone {
    GroupCacheItems *clonedList = [[GroupCacheItems alloc] init];
    for (GroupCacheItem *item in self) {
        [clonedList addItem:item];
    }
    return clonedList;
}

@end
