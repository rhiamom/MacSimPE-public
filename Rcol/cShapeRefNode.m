//
//  cShapeRefNode.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/15/25.
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

#import "cShapeRefNode.h"
#import "cRenderableNode.h"
#import "cBoundedNode.h"
#import "cTransformNode.h"
#import "Containers.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "RcolWrapper.h"
#import "cObjectGraphNode.h"

// MARK: - ShapeRefNodeItemA Implementation

@implementation ShapeRefNodeItemA

- (instancetype)init {
    self = [super init];
    if (self) {
        self.unknown1 = 0x101;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.unknown1 = [reader readUInt16];
    self.unknown2 = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt16:self.unknown1];
    [writer writeInt32:self.unknown2];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%@ 0x%@",
            [Helper hexString:self.unknown1],
            [Helper hexString:(uint32_t)self.unknown2]];
}

@end

// MARK: - ShapeRefNodeItemB Implementation

@implementation ShapeRefNodeItemB

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"";
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%@: %@",
            [Helper hexString:(uint32_t)self.unknown1],
            self.name];
}

@end

// MARK: - ShapeRefNode Implementation

@interface ShapeRefNode ()

@property (nonatomic, strong) NSViewController *shapeRefNodeViewController;

@end

@implementation ShapeRefNode

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        self.renderableNode = [[RenderableNode alloc] initWithParent:nil];
        self.boundedNode = [[BoundedNode alloc] initWithParent:nil];
        self.transformNode = [[TransformNode alloc] initWithParent:nil];
        
        self.itemsA = @[];
        self.itemsB = @[];
        self.data = [NSData data];
        
        self.version = 0x15;
        self.unknown1 = 1;
        self.unknown2 = 1;
        self.unknown4 = 1;
        self.unknown5 = 0x10;
        self.unknown6 = -1;
        self.name = @"Practical";
        self.blockId = 0x65245517;
    }
    return self;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    NSString *name = [reader readString];
    uint32_t myId = [reader readUInt32];
    [self.renderableNode unserialize:reader];
    self.renderableNode.blockId = myId;
    
    name = [reader readString];
    myId = [reader readUInt32];
    [self.boundedNode unserialize:reader];
    self.boundedNode.blockId = myId;
    
    name = [reader readString];
    myId = [reader readUInt32];
    [self.transformNode unserialize:reader];
    self.transformNode.blockId = myId;
    
    self.unknown1 = [reader readInt16];
    self.unknown2 = [reader readInt32];
    self.name = [reader readString];
    self.unknown3 = [reader readInt32];
    self.unknown4 = [reader readByte];
    
    uint32_t itemsACount = [reader readUInt32];
    NSMutableArray<ShapeRefNodeItemA *> *itemsAMutable = [[NSMutableArray alloc] initWithCapacity:itemsACount];
    for (uint32_t i = 0; i < itemsACount; i++) {
        ShapeRefNodeItemA *item = [[ShapeRefNodeItemA alloc] init];
        [item unserialize:reader];
        [itemsAMutable addObject:item];
    }
    self.itemsA = [itemsAMutable copy];
    
    self.unknown5 = [reader readInt32];
    
    uint32_t itemsBCount = [reader readUInt32];
    NSMutableArray<ShapeRefNodeItemB *> *itemsBMutable = [[NSMutableArray alloc] initWithCapacity:itemsBCount];
    for (uint32_t i = 0; i < itemsBCount; i++) {
        ShapeRefNodeItemB *item = [[ShapeRefNodeItemB alloc] init];
        item.unknown1 = [reader readInt32];
        [itemsBMutable addObject:item];
    }
    
    if (self.version == 0x15) {
        for (uint32_t i = 0; i < itemsBCount; i++) {
            ShapeRefNodeItemB *item = itemsBMutable[i];
            item.name = [reader readString];
        }
    }
    
    self.itemsB = [itemsBMutable copy];
    
    int32_t dataLength = [reader readInt32];
    self.data = [reader readBytes:dataLength];
    self.unknown6 = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    [writer writeString:self.renderableNode.blockName];
    [writer writeUInt32:self.renderableNode.blockId];
    [self.renderableNode serialize:writer];
    
    [writer writeString:self.boundedNode.blockName];
    [writer writeUInt32:self.boundedNode.blockId];
    [self.boundedNode serialize:writer];
    
    [writer writeString:self.transformNode.blockName];
    [writer writeUInt32:self.transformNode.blockId];
    [self.transformNode serialize:writer];
    
    [writer writeInt16:self.unknown1];
    [writer writeInt32:self.unknown2];
    [writer writeString:self.name];
    [writer writeInt32:self.unknown3];
    [writer writeUInt8:self.unknown4];
    
    [writer writeUInt32:(uint32_t)self.itemsA.count];
    for (ShapeRefNodeItemA *item in self.itemsA) {
        [item serialize:writer];
    }
    [writer writeInt32:self.unknown5];
    
    [writer writeUInt32:(uint32_t)self.itemsB.count];
    for (ShapeRefNodeItemB *item in self.itemsB) {
        [writer writeInt32:item.unknown1];
    }
    
    if (self.version == 0x15) {
        for (ShapeRefNodeItemB *item in self.itemsB) {
            [writer writeString:item.name];
        }
    }
    
    [writer writeInt32:(int32_t)self.data.length];
    [writer writeData:self.data];
    [writer writeInt32:self.unknown6];
}

// MARK: - UI Management

- (NSViewController *)viewController {
    if (self.shapeRefNodeViewController == nil) {
        // TODO: Create ShapeRefNodeViewController
        // self.shapeRefNodeViewController = [[ShapeRefNodeViewController alloc] init];
        // [self initTabPage];
    }
    return self.shapeRefNodeViewController;
}

- (void)initTabPage {
    if (self.shapeRefNodeViewController == nil) {
        // TODO: Create ShapeRefNodeViewController
        // self.shapeRefNodeViewController = [[ShapeRefNodeViewController alloc] init];
    }
    
    // TODO: Update UI controls with data
    // Clear and populate list boxes with itemsA and itemsB
    // Set text fields with hex values of unknown properties
    // Set name and data fields
}

- (void)extendTabView:(NSTabView *)tabView {
    [super extendTabView:tabView];
    [self.renderableNode addToTabControl:tabView];
    [self.boundedNode addToTabControl:tabView];
    [self.transformNode addToTabControl:tabView];
}

// MARK: - AbstractCresChildren Overrides

- (NSString *)getName {
    return self.transformNode.objectGraphNode.fileName;
}

- (IntArrayList *)childBlocks {
    return self.transformNode.childBlocks;
}

- (NSInteger)imageIndex {
    return 3; // mesh
}

- (TransformNode *)storedTransformNode {
    return self.transformNode;
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (%@)",
            self.name,
            self.transformNode.objectGraphNode.fileName,
            [super description]];
}

// MARK: - Memory Management

- (void)dispose {
    [self.shapeRefNodeViewController.view removeFromSuperview];
    self.shapeRefNodeViewController = nil;
    
    [self.renderableNode dispose];
    [self.boundedNode dispose];
    [self.transformNode dispose];
    
    [super dispose];
}

@end
