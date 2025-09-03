//
//  SlotItem.m
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

#import "SlotItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "SlotWrapper.h"

// MARK: - SlotItem Implementation

@implementation SlotItem

// MARK: - Initialization

- (instancetype)initWithParent:(Slot *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _type = SlotItemTypeUnknown;
        
        // Initialize all values to zero
        _unknownFloat1 = 0.0f;
        _unknownFloat2 = 0.0f;
        _unknownFloat3 = 0.0f;
        _unknownFloat4 = 0.0f;
        _unknownFloat5 = 0.0f;
        _unknownFloat6 = 0.0f;
        _unknownFloat7 = 0.0f;
        _unknownFloat8 = 0.0f;
        
        _unknownInt1 = 0;
        _unknownInt2 = 0;
        _unknownInt3 = 0;
        _unknownInt4 = 0;
        _unknownInt5 = 0;
        _unknownInt6 = 0;
        _unknownInt7 = 0;
        _unknownInt8 = 0;
        _unknownInt9 = 0;
        _unknownInt10 = 0;
        
        _unknownShort1 = 0;
        _unknownShort2 = 0;
    }
    return self;
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    _type = (SlotItemType)[reader readUInt16];
    
    _unknownFloat1 = [reader readSingle];
    _unknownFloat2 = [reader readSingle];
    _unknownFloat3 = [reader readSingle];
    
    _unknownInt1 = [reader readInt32];
    _unknownInt2 = [reader readInt32];
    _unknownInt3 = [reader readInt32];
    _unknownInt4 = [reader readInt32];
    _unknownInt5 = [reader readInt32];
    
    if (_parent.version >= 5) {
        _unknownFloat4 = [reader readSingle];
        _unknownFloat5 = [reader readSingle];
        _unknownFloat6 = [reader readSingle];
        
        _unknownInt6 = [reader readInt32];
    }
    
    if (_parent.version >= 6) {
        _unknownShort1 = [reader readInt16];
        _unknownShort2 = [reader readInt16];
    }
    
    if (_parent.version >= 7) {
        _unknownFloat7 = [reader readSingle];
    }
    
    if (_parent.version >= 8) {
        _unknownInt7 = [reader readInt32];
    }
    
    if (_parent.version >= 9) {
        _unknownInt8 = [reader readInt32];
    }
    
    if (_parent.version >= 0x10) {
        _unknownFloat8 = [reader readSingle];
    }
    
    if (_parent.version >= 0x40) {
        _unknownInt9 = [reader readInt32];
        _unknownInt10 = [reader readInt32];
    }
}

- (void)serialize:(BinaryWriter *)writer parent:(Slot *)parent {
    _parent = parent;
    
    [writer writeUInt16:(uint16_t)_type];
    
    [writer writeSingle:_unknownFloat1];
    [writer writeSingle:_unknownFloat2];
    [writer writeSingle:_unknownFloat3];
    
    [writer writeInt32:_unknownInt1];
    [writer writeInt32:_unknownInt2];
    [writer writeInt32:_unknownInt3];
    [writer writeInt32:_unknownInt4];
    [writer writeInt32:_unknownInt5];
    
    if (parent.version >= 5) {
        [writer writeSingle:_unknownFloat4];
        [writer writeSingle:_unknownFloat5];
        [writer writeSingle:_unknownFloat6];
        
        [writer writeInt32:_unknownInt6];
    }
    
    if (parent.version >= 6) {
        [writer writeInt16:_unknownShort1];
        [writer writeInt16:_unknownShort2];
    }
    
    if (parent.version >= 7) {
        [writer writeSingle:_unknownFloat7];
    }
    
    if (parent.version >= 8) {
        [writer writeInt32:_unknownInt7];
    }
    
    if (parent.version >= 9) {
        [writer writeInt32:_unknownInt8];
    }
    
    if (parent.version >= 0x10) {
        [writer writeSingle:_unknownFloat8];
    }
    
    if (parent.version >= 0x40) {
        [writer writeInt32:_unknownInt9];
        [writer writeInt32:_unknownInt10];
    }
}

// MARK: - Description

- (NSString *)description {
    NSString *typeString;
    switch (_type) {
        case SlotItemTypeContainer:
            typeString = @"Container";
            break;
        case SlotItemTypeLocation:
            typeString = @"Location";
            break;
        case SlotItemTypeUnknown:
            typeString = @"Unknown";
            break;
        case SlotItemTypeRouting:
            typeString = @"Routing";
            break;
        case SlotItemTypeTarget:
            typeString = @"Target";
            break;
        default:
            typeString = @"Unknown";
            break;
    }
    return typeString;
}

@end

// MARK: - SlotItems Implementation

@implementation SlotItems

// MARK: - Indexed Access

- (SlotItem *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (SlotItem *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(SlotItem *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(SlotItem *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

// MARK: - Collection Operations

- (void)addSlotItem:(SlotItem *)item {
    [self addObject:item];
}

- (void)insertSlotItem:(SlotItem *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeSlotItem:(SlotItem *)item {
    [self removeObject:item];
}

- (BOOL)containsSlotItem:(SlotItem *)item {
    return [self containsObject:item];
}

// MARK: - Properties

- (NSUInteger)length {
    return [self count];
}

// MARK: - Copying

- (instancetype)deepCopy {
    SlotItems *list = [[SlotItems alloc] init];
    for (SlotItem *item in self) {
        [list addSlotItem:item];
    }
    return list;
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self deepCopy];
}

@end
