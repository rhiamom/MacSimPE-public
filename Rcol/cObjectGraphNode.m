//
//  cObjectGraphNode.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

#import "cObjectGraphNode.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"

// MARK: - ObjectGraphNodeItem Implementation

@implementation ObjectGraphNodeItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = 0;
        _dependant = 0;
        _index = 0;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.enabled = [reader readByte];
    self.dependant = [reader readByte];
    self.index = [reader readUInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeByte:self.enabled];
    [writer writeByte:self.dependant];
    [writer writeUInt32:self.index];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%u: 0x%@, 0x%@",
            (unsigned int)self.index,
            [Helper hexString:self.enabled],
            [Helper hexString:self.dependant]];
}

@end

// MARK: - ObjectGraphNode Implementation

@implementation ObjectGraphNode

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _items = @[];
        _fileName = self.blockName;
        self.version = 4;
    }
    return self;
}

#pragma mark - IRcolBlock Protocol

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    // Read items array
    NSMutableArray *itemsArray = [NSMutableArray array];
    uint32_t itemsCount = [reader readUInt32];
    for (uint32_t i = 0; i < itemsCount; i++) {
        ObjectGraphNodeItem *item = [[ObjectGraphNodeItem alloc] init];
        [item unserialize:reader];
        [itemsArray addObject:item];
    }
    self.items = [itemsArray copy];
    
    // Read filename if version 0x04
    if (self.version == 0x04) {
        self.fileName = [reader readString];
    } else {
        self.fileName = @"cObjectGraphNode";
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    [writer writeUInt32:(uint32_t)self.items.count];
    for (ObjectGraphNodeItem *item in self.items) {
        [item serialize:writer];
    }
    
    if (self.version == 0x04) {
        [writer writeString:self.fileName];
    }
}

#pragma mark - UI Management (TODO: Implement for macOS)

- (NSViewController *)viewController {
    // TODO: Implement macOS-specific view controller
    // This would replace the Windows Forms TabPage functionality
    return nil;
}

- (void)refresh {
    // TODO: Implement refresh logic for UI updates
}

#pragma mark - String Representation

- (NSString *)description {
    return self.fileName;
}

#pragma mark - Resource Management

- (void)dispose {
    self.items = nil;
    self.fileName = nil;
    [super dispose];
}

@end
#import <Foundation/Foundation.h>
