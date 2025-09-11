//
//  cShape.m
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

#import "cShape.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "cObjectGraphNode.h"
#import "cReferentNode.h"
#import "cSGResource.h"
#import "Helper.h"
#import "Localization.h"
#import "ScenegraphHelper.h"
#import "MetaData.h"

// MARK: - ShapePart Implementation

@implementation ShapePart

- (instancetype)init {
    self = [super init];
    if (self) {
        _data = [NSMutableData dataWithLength:9];
        _subset = @"";
        _fileName = @"";
    }
    return self;
}

- (void)setData:(NSData *)data {
    if (data.length == 9) {
        _data = [data copy];
    } else if (data.length > 9) {
        _data = [data subdataWithRange:NSMakeRange(0, 9)];
    } else {
        NSMutableData *paddedData = [NSMutableData dataWithLength:9];
        [paddedData replaceBytesInRange:NSMakeRange(0, data.length) withBytes:data.bytes];
        _data = [paddedData copy];
    }
}

- (void)unserialize:(BinaryReader *)reader {
    self.subset = [reader readString];
    self.fileName = [reader readString];
    self.data = [reader readBytes:9];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeString:self.subset];
    [writer writeString:self.fileName];
    [writer writeData:self.data];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", self.subset, self.fileName];
}

@end

// MARK: - ShapeItem Implementation

@implementation ShapeItem

- (instancetype)initWithParent:(Shape *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _fileName = @"";
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.unknown1 = [reader readInt32];
    self.unknown2 = [reader readByte];
    
    if ((self.parent.version == 0x07) || (self.parent.version == 0x06)) {
        self.fileName = @"";
        self.unknown3 = [reader readInt32];
        self.unknown4 = [reader readByte];
    } else {
        self.fileName = [reader readString];
        self.unknown3 = 0;
        self.unknown4 = 0;
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeInt32:self.unknown1];
    [writer writeByte:self.unknown2];
    
    if ((self.parent.version == 0x07) || (self.parent.version == 0x06)) {
        [writer writeInt32:self.unknown3];
        [writer writeByte:self.unknown4];
    } else {
        [writer writeString:self.fileName];
    }
}

- (NSString *)description {
    NSString *name = [NSString stringWithFormat:@"0x%@ - 0x%@",
                      [Helper hexString:(uint32_t)self.unknown1],
                      [Helper hexString:self.unknown2]];
    
    if ((self.parent.version == 0x07) || (self.parent.version == 0x06)) {
        return [NSString stringWithFormat:@"%@ - 0x%@ - 0x%@", name,
                [Helper hexString:(uint32_t)self.unknown3],
                [Helper hexString:self.unknown4]];
    } else {
        return [NSString stringWithFormat:@"%@: %@", name, self.fileName];
    }
}

@end

// MARK: - Shape Implementation

@implementation Shape

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        self.sgres = [[SGResource alloc] initWithParent:nil];
        _refNode = [[ReferentNode alloc] initWithParent:nil];
        self.graphNode = [[ObjectGraphNode alloc] initWithParent:nil];
        
        _unknown = @[];
        _items = @[];
        _parts = @[];
        self.blockId = 0xFC6EB1F7;
    }
    return self;
}

#pragma mark - IRcolBlock Protocol

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    NSString *s = [reader readString];
    
    self.sgres.blockId = [reader readUInt32];
    [self.sgres unserialize:reader];
    
    s = [reader readString];
    self.refNode.blockId = [reader readUInt32];
    [self.refNode unserialize:reader];
    
    s = [reader readString];
    self.graphNode.blockId = [reader readUInt32];
    [self.graphNode unserialize:reader];
    
    // Read unknown array
    NSMutableArray *unknownArray = [NSMutableArray array];
    if (self.version != 0x06) {
        uint32_t unknownCount = [reader readUInt32];
        for (uint32_t i = 0; i < unknownCount; i++) {
            [unknownArray addObject:@([reader readUInt32])];
        }
    }
    self.unknown = [unknownArray copy];
    
    // Read items array
    NSMutableArray *itemsArray = [NSMutableArray array];
    uint32_t itemsCount = [reader readUInt32];
    for (uint32_t i = 0; i < itemsCount; i++) {
        ShapeItem *item = [[ShapeItem alloc] initWithParent:self];
        [item unserialize:reader];
        [itemsArray addObject:item];
    }
    self.items = [itemsArray copy];
    
    // Read parts array
    NSMutableArray *partsArray = [NSMutableArray array];
    uint32_t partsCount = [reader readUInt32];
    for (uint32_t i = 0; i < partsCount; i++) {
        ShapePart *part = [[ShapePart alloc] init];
        [part unserialize:reader];
        [partsArray addObject:part];
    }
    self.parts = [partsArray copy];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    [writer writeString:[self.sgres registerInListing:nil]];
    [writer writeUInt32:self.sgres.blockId];
    [self.sgres serialize:writer];
    
    [writer writeString:[self.refNode registerInListing:nil]];
    [writer writeUInt32:self.refNode.blockId];
    [self.refNode serialize:writer];
    
    [writer writeString:[self.graphNode registerInListing:nil]];
    [writer writeUInt32:self.graphNode.blockId];
    [self.graphNode serialize:writer];
    
    if (self.version != 0x06) {
        [writer writeUInt32:(uint32_t)self.unknown.count];
        for (NSNumber *num in self.unknown) {
            [writer writeUInt32:[num unsignedIntValue]];
        }
    }
    
    [writer writeUInt32:(uint32_t)self.items.count];
    for (ShapeItem *item in self.items) {
        [item serialize:writer];
    }
    
    [writer writeUInt32:(uint32_t)self.parts.count];
    for (ShapePart *part in self.parts) {
        [part serialize:writer];
    }
}

#pragma mark - IScenegraphBlock Protocol

- (void)referencedItems:(NSMutableDictionary<NSString *, NSMutableArray *> *)refmap
            parentGroup:(uint32_t)parentgroup {
    
    NSMutableArray *subsetsList = [NSMutableArray array];
    for (ShapePart *part in self.parts) {
        NSString *fileName = [part.fileName stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        fileName = [fileName stringByAppendingString:@"_txmt"];
        
        id pfd = [ScenegraphHelper buildPfdWithFilename:fileName
                                               type:[MetaData TXMT]
                                       defaultGroup:parentgroup];
        [subsetsList addObject:pfd];
    }
    refmap[@"Subsets"] = subsetsList;
    
    NSMutableArray *modelsList = [NSMutableArray array];
    for (ShapeItem *item in self.items) {
        NSString *fileName = [item.fileName stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        id pfd = [ScenegraphHelper buildPfdWithFilename:fileName
                                       type:[MetaData GMND]
                               defaultGroup:parentgroup];
        [modelsList addObject:pfd];
    }
    refmap[@"Models"] = modelsList;
}

#pragma mark - UI Management

- (NSViewController *)viewController {
    // TODO: Implement macOS-specific view controller
    // This would replace the Windows Forms TabPage functionality
    return nil;
}

- (void)extendTabView:(NSTabView *)tabView {
    // TODO: Implement macOS-specific tab view extension
    // This would replace the Windows Forms TabControl functionality
}

- (void)refresh {
    // TODO: Implement refresh logic for UI updates
}

#pragma mark - Resource Management

- (void)dispose {
    // Clean up resources
    self.unknown = nil;
    self.items = nil;
    self.parts = nil;
    self.graphNode = nil;
    _refNode = nil;
    
    [super dispose];
}

@end
