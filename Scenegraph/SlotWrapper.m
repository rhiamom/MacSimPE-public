//
//  SlotWrapper.m
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

#import "SlotWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "AbstractWrapperInfo.h"
#import "MetaData.h"

@implementation Slot {
    uint32_t _id;
    SlotItems *_items;
    NSString *_filename;
    uint32_t _version;
    uint32_t _unknown;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [[SlotItems alloc] init];
        _filename = @"";
        _id = 0x534C4F54; // 'SLOT' in hex
        _version = 4;
        _unknown = 0;
    }
    return self;
}

// MARK: - Properties

- (SlotItems *)items {
    return _items;
}

- (NSString *)filename {
    return _filename;
}

- (void)setFilename:(NSString *)filename {
    _filename = [filename copy];
}

- (uint32_t)version {
    return _version;
}

- (void)setVersion:(uint32_t)version {
    _version = version;
}

- (uint32_t)unknown {
    return _unknown;
}

- (void)setUnknown:(uint32_t)unknown {
    _unknown = unknown;
}

// MARK: - IWrapper Protocol

- (BOOL)checkVersion:(uint32_t)version {
    return YES;
}

// MARK: - AbstractWrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Create SlotUI when it's translated
    // For now, return nil - this will need to be implemented
    // when SlotUI is translated from C#
    return nil;
}

- (id<IWrapperInfo>)createWrapperInfo {
    // Load the slot.png icon from resources if available
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSImage *icon = [bundle imageForResource:@"slot"];
    
    return [[AbstractWrapperInfo alloc] initWithName:@"Slot Wrapper"
                                              author:@"Quaxi"
                                         description:@""
                                             version:1
                                                icon:icon];
}

- (void)unserialize:(BinaryReader *)reader {
    // Read filename (64 bytes, null-terminated string)
    NSData *filenameData = [reader readBytes:0x40];
    _filename = [Helper dataToString:filenameData];
    
    _id = [reader readUInt32];
    _version = [reader readUInt32];
    _unknown = [reader readUInt32];
    
    int32_t count = [reader readInt32];
    [_items removeAllObjects];
    
    for (int i = 0; i < count; i++) {
        SlotItem *item = [[SlotItem alloc] initWithParent:self];
        [item unserialize:reader];
        [_items addSlotItem:item];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    // Write filename as 64-byte null-terminated string
    NSData *filenameData = [Helper stringToBytes:_filename length:0x40];
    [writer writeData:filenameData];
    
    [writer writeUInt32:_id];
    [writer writeUInt32:_version];
    [writer writeUInt32:_unknown];
    
    [writer writeInt32:(int32_t)_items.length];
    
    for (NSUInteger i = 0; i < _items.length; i++) {
        SlotItem *item = [_items objectAtIndex:i];
        [item serialize:writer parent:self];
    }
}

// MARK: - IFileWrapper Protocol

- (NSString *)description {
    return [NSString stringWithFormat:@"FileName=%@, Version=%u, Items=%lu",
            self.filename, self.version, (unsigned long)_items.count];
}

- (NSData *)fileSignature {
    // Return empty signature - this wrapper uses type-based identification
    return [NSData data];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@([MetaData SLOT])];
}

@end
