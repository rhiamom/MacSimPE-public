//
//  PackedFileWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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

#import "PackedFileWrapper.h"
#import "PackedFileUI.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "AbstractWrapperInfo.h"
#import "MetaData.h"
#import "IPackedFileDescriptor.h"

@implementation RefFile {
    uint32_t _fileId;
    IndexTypes _indexType;
    NSMutableArray<id<IPackedFileDescriptor>> *_items;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _fileId = 0xDEADBEEF;
        _indexType = IndexTypesLongFileIndex;
    }
    return self;
}

#pragma mark - Properties

- (NSArray<id<IPackedFileDescriptor>> *)items {
    return [_items copy];
}

- (void)setItems:(NSArray<id<IPackedFileDescriptor>> *)items {
    _items = [items mutableCopy];
}

- (uint32_t)fileId {
    return _fileId;
}

- (IndexTypes)indexType {
    return _indexType;
}

- (NSData *)fileSignature {
    return [[NSData alloc] init]; // Empty signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@0xAC506764]; // handles the 3IDR File
}

#pragma mark - AbstractWrapper Overrides

- (BOOL)checkVersion:(uint32_t)version {
    return (version == 9 || version == 10);
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[RefFileUI alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    NSImage *icon = [NSImage imageNamed:@"3didr"];
    if (!icon) {
        // Try to load from bundle resource
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        icon = [bundle imageForResource:@"3didr"];
    }
    
    return [[AbstractWrapperInfo alloc]
            initWithName:@"3D Reference File Wrapper"
            author:@"Quaxi"
            description:@"This File contains References to 3D Elements (from the Scenegraph) of a Sim, Skin or Clothing."
            version:5
            icon:icon];
}

#pragma mark - Serialization

- (void)unserialize:(BinaryReader *)reader {
    _fileId = [reader readUInt32];
    _indexType = (IndexTypes)[reader readUInt32];
    
    uint32_t itemCount = [reader readUInt32];
    [_items removeAllObjects];
    
    for (uint32_t i = 0; i < itemCount; i++) {
        RefFileItem *item = [[RefFileItem alloc] initWithParent:self];
        
        item.type = [reader readUInt32];
        item.group = [reader readUInt32];
        item.instance = [reader readUInt32];
        
        if (_indexType == IndexTypesLongFileIndex) {
            item.subType = [reader readUInt32];
        }
        
        [_items addObject:item];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:_fileId];
    [writer writeUInt32:(uint32_t)_indexType];
    [writer writeUInt32:(uint32_t)_items.count];
    
    for (id<IPackedFileDescriptor> item in _items) {
        [writer writeUInt32:item.type];
        [writer writeUInt32:item.group];
        [writer writeUInt32:item.instance];
        
        if (_indexType == IndexTypesLongFileIndex) {
            [writer writeUInt32:item.subType];
        }
    }
}

@end

#pragma mark - RefFileItem Implementation

@implementation RefFileItem

- (instancetype)initWithParent:(RefFile *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _type = 0;
        _group = 0;
        _instance = 0;
        _subType = 0;
    }
    return self;
}

#pragma mark - IPackedFileDescriptor Protocol

// Note: Additional IPackedFileDescriptor methods would be implemented here
// based on the actual protocol definition

- (NSString *)description {
    return [NSString stringWithFormat:@"RefFileItem - Type: 0x%08X, Group: 0x%08X, Instance: 0x%08X, SubType: 0x%08X",
            _type, _group, _instance, _subType];
}

@end
