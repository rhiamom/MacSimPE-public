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

#import "CompressedFileList.h"
#import "ClstItem.h"
#import "ClstForm.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "IPackageHeader.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "AbstractWrapperInfo.h"

@implementation CompressedFileList

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _indexType = ptShortFileIndex;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithIndexType:(IndexTypes)type {
    self = [super init];
    if (self) {
        _indexType = type;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithFileList:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package {
    self = [super init];
    if (self) {
        _indexType = package.header.indexType;
        _items = [[NSMutableArray alloc] init];
        [self processData:pfd package:package];
    }
    return self;
}

- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package {
    if (self = [super init]) {
        self.indexType = package.header.indexType;
        self.items = [[NSMutableArray alloc] init];
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
            ((lfi.subType == pfd.subtype) || (self.indexType == ptShortFileIndex)) &&
            (lfi.type == pfd.type)) {
            return i;
        }
    }
    
    return -1;
}

- (void)clear {
    self.items = [[NSMutableArray alloc] init];
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
    return [[ClstForm alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Compressed File Directory Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File contains a List of all compressed Files that are stored within this Package."
                                             version:2
                                               icon:[NSImage imageNamed:@"clst"]];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    self.indexType = self.package.header.indexType;
    
    NSInteger itemSize = (self.indexType == ptLongFileIndex) ? 0x14 : 0x10;
    NSInteger count = reader.baseStream.length / itemSize;
    self.items = [[NSMutableArray alloc] initWithCapacity:count];
    
    long long pos = reader.baseStream.position;
    BOOL hasTriedSwitch = NO;
    
    for (NSInteger i = 0; i < count; i++) {
        ClstItem *item = [[ClstItem alloc] initWithIndexType:self.indexType];
        [item unserialize:reader];
        
        // Test format validity at item 2
        if (i == 2 && !hasTriedSwitch) {
            hasTriedSwitch = YES;
            id<IPackedFileDescriptor> foundFile = [self.package findFileWithType:item.type
                                                                         subtype:item.subType
                                                                           group:item.group
                                                                        instance:item.instance];
            if (foundFile == nil) {
                // Wrong format, switch and restart
                self.indexType = (self.indexType == ptLongFileIndex) ? ptShortFileIndex : ptLongFileIndex;
                itemSize = (self.indexType == ptLongFileIndex) ? 0x14 : 0x10;
                count = reader.baseStream.length / itemSize;
                
                reader.baseStream.position = pos;
                [self.items removeAllObjects];
                i = -1; // Will become 0 on next iteration
                continue;
            }
        }
        
        [self.items addObject:item];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    for (ClstItem *item in self.items) {
        [item serialize:writer withFormat:self.indexType];
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
