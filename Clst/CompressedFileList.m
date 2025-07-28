//
//  ClstWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/27/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop         *
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
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "ClstWrapper.h"
#import "ClstItem.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "IPackageHeader.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"

@implementation CompressedFileList

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _indexType = IndexTypesShortFileIndex;
        _items = @[];
    }
    return self;
}

- (instancetype)initWithIndexType:(IndexTypes)type {
    self = [super init];
    if (self) {
        _indexType = type;
        _items = @[];
    }
    return self;
}

- (instancetype)initWithFileList:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package {
    self = [super init];
    if (self) {
        _indexType = package.header.indexType;
        _items = @[];
        [self processData:pfd package:package];
    }
    return self;
}

// MARK: - Methods

- (NSInteger)findFile:(id<IPackedFileDescriptor>)pfd {
    if (self.items == nil) {
        return -1;
    }
    
    for (NSInteger i = 0; i < self.items.count; i++) {
        ClstItem *lfi = self.items[i];
        
        if ((lfi.group == pfd.group) &&
            (lfi.instance == pfd.instance) &&
            ((lfi.subType == pfd.subType) || (self.indexType == IndexTypesShortFileIndex)) &&
            (lfi.type == pfd.type)) {
            return i;
        }
    }
    
    return -1;
}

- (void)clear {
    self.items = @[];
}

- (void)add:(ClstItem *)item {
    NSMutableArray *newItems = [self.items mutableCopy];
    [newItems addObject:item];
    self.items = [newItems copy];
}

// MARK: - AbstractWrapper Overrides

- (BOOL)checkVersion:(uint32_t)version {
    return YES;
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Implement ClstForm UI handler
    return nil;
}

- (id<IWrapperInfo>)createWrapperInfo {
    // TODO: Implement WrapperInfo
    return nil;
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    self.indexType = self.package.header.indexType;
    
    NSInteger count = 0;
    if (self.indexType == IndexTypesLongFileIndex) {
        count = reader.baseStream.length / 0x14;
    } else {
        count = reader.baseStream.length / 0x10;
    }
    
    NSMutableArray<ClstItem *> *newItems = [[NSMutableArray alloc] initWithCapacity:count];
    
    int64_t pos = reader.baseStream.position;
    BOOL switchType = NO;
    
    for (NSInteger i = 0; i < count; i++) {
        ClstItem *item = [[ClstItem alloc] initWithIndexType:self.indexType];
        [item unserialize:reader];
        
        if ((i == 2) && (!switchType)) {
            switchType = YES;
            id<IPackedFileDescriptor> foundFile = [self.package findFile:item.type
                                                                 subType:item.subType
                                                                   group:item.group
                                                                instance:item.instance];
            if (foundFile == nil) {
                i = 0;
                if (self.indexType == IndexTypesLongFileIndex) {
                    self.indexType = IndexTypesShortFileIndex;
                } else {
                    self.indexType = IndexTypesLongFileIndex;
                }
                
                [reader.baseStream seekToOffset:pos origin:SeekOriginBegin];
                item = [[ClstItem alloc] initWithIndexType:self.indexType];
                [item unserialize:reader];
            }
        }
        
        newItems[i] = item;
    }
    
    self.items = [newItems copy];
}

- (void)serialize:(BinaryWriter *)writer {
    for (ClstItem *item in self.items) {
        [item serialize:writer indexType:self.indexType];
    }
}

// MARK: - IFileWrapper Protocol

- (NSData *)fileSignature {
    return [NSData data]; // Empty signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@0xE86B1EEF]; // clst type
}

@end
