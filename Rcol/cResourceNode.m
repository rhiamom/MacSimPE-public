//
//  cResourceNode.m
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
//
//  ResourceNode.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/12/25.
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

#import "cResourceNode.h"
#import "cObjectGraphNode.h"
#import "cCompositionTreeNode.h"
#import "cTransformNode.h"
#import "cSGResource.h"
#import "RcolWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Containers.h"
#import "Helper.h"
#import "ICresChildren.h"

// MARK: - ResourceNodeItem Implementation

@implementation ResourceNodeItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _unknown1 = 0;
        _unknown2 = 0;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.unknown1 = [reader readInt16];
    self.unknown2 = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeInt16:self.unknown1];
    [writer writeInt32:self.unknown2];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%@ 0x%@",
            [Helper hexStringUShort:self.unknown1],
            [Helper hexStringUInt:(uint32_t)self.unknown2]];
}

@end

// MARK: - ResourceNode Implementation

@interface ResourceNode ()
@property (nonatomic, assign) uint8_t typeCode;
@property (nonatomic, strong) ObjectGraphNode *graphNode;
@property (nonatomic, strong) CompositionTreeNode *treeNode;
@end

@implementation ResourceNode

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        self.sgres = [[SGResource alloc] initWithParent:nil];
        _graphNode = [[ObjectGraphNode alloc] initWithParent:nil];
        _treeNode = [[CompositionTreeNode alloc] initWithParent:nil];
        _items = @[];
        
        self.version = 0x07;
        _typeCode = 0x01;
        self.blockId = 0xE519C933;
    }
    return self;
}

// MARK: - AbstractCresChildren Protocol Implementation

- (NSString *)getName {
    [super getName];  // Required call to superclass
    return self.graphNode.fileName;
}

- (IntArrayList *)childBlocks {
    IntArrayList *list = [[IntArrayList alloc] init];
    for (ResourceNodeItem *rni in self.items) {
        [list addInt:(rni.unknown2 >> 24) & 0xff];
    }
    return list;
}

- (NSInteger)imageIndex {
    return 3; // mesh
}

- (TransformNode *)storedTransformNode {
    return nil;
}

// MARK: - Tree Building

- (void)addChildNode:(NSMutableArray *)parent
               index:(NSInteger)index
               child:(id<ICresChildren>)child {
    
    // Make the user aware that a Node was left out!
    if (child == nil) {
        // In the original C# this created Windows TreeNode objects
        // For macOS, we'd create our own tree node objects or use NSOutlineView data
        NSMutableDictionary *errorNode = [[NSMutableDictionary alloc] init];
        errorNode[@"title"] = [NSString stringWithFormat:@"[Error: Unsupported Child on Index %ld]", (long)index];
        errorNode[@"tag"] = @(index);
        errorNode[@"imageIndex"] = @4;
        [parent addObject:errorNode];
        return;
    }
    
    NSMutableDictionary *node = [[NSMutableDictionary alloc] init];
    node[@"title"] = [NSString stringWithFormat:@"0x%lX: %@", (long)index, [(NSObject *)child description]];
    node[@"tag"] = @(index);
    node[@"imageIndex"] = @([child imageIndex]);
    node[@"children"] = [[NSMutableArray alloc] init];
    [parent addObject:node];
    
    // Recursively add child nodes
    IntArrayList *childBlocks = [child childBlocks];
    for (NSInteger i = 0; i < [childBlocks count]; i++) {
        NSInteger childIndex = [childBlocks intAtIndex:i];
        id<ICresChildren> childBlock = [child getBlock:childIndex];
        [self addChildNode:node[@"children"] index:childIndex child:childBlock];
    }
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    _typeCode = [reader readByte];
    
    NSString *fldsc = [reader readString];
    uint32_t myId = [reader readUInt32];
    
    if (self.typeCode == 0x01) {
        [self.sgres unserialize:reader];
        self.sgres.blockId = myId;
        
        fldsc = [reader readString];
        myId = [reader readUInt32];
        [self.treeNode unserialize:reader];
        self.treeNode.blockId = myId;
        
        fldsc = [reader readString];
        myId = [reader readUInt32];
        [self.graphNode unserialize:reader];
        self.graphNode.blockId = myId;
        
        NSInteger itemCount = [reader readByte];
        NSMutableArray *itemsArray = [[NSMutableArray alloc] initWithCapacity:itemCount];
        for (NSInteger i = 0; i < itemCount; i++) {
            ResourceNodeItem *item = [[ResourceNodeItem alloc] init];
            [item unserialize:reader];
            [itemsArray addObject:item];
        }
        _items = [itemsArray copy];
        
        self.unknown1 = [reader readInt32];
    } else if (self.typeCode == 0x00) {
        [self.graphNode unserialize:reader];
        self.graphNode.blockId = myId;
        
        ResourceNodeItem *item = [[ResourceNodeItem alloc] init];
        [item unserialize:reader];
        _items = @[item];
    } else {
        @throw [NSException exceptionWithName:@"UnknownResourceNodeException"
                                       reason:[NSString stringWithFormat:@"Unknown ResourceNode 0x%@, 0x%@",
                                               [Helper hexStringUInt:self.version],
                                               [Helper hexStringByte:self.typeCode]]
                                     userInfo:nil];
    }
    
    self.unknown2 = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    [writer writeUInt8:self.typeCode];
    
    if (self.typeCode == 0x01) {
        [writer writeString:self.sgres.blockName];
        [writer writeUInt32:self.sgres.blockId];
        [self.sgres serialize:writer];
        
        [writer writeString:self.treeNode.blockName];
        [writer writeUInt32:self.treeNode.blockId];
        [self.treeNode serialize:writer];
        
        [writer writeString:self.graphNode.blockName];
        [writer writeUInt32:self.graphNode.blockId];
        [self.graphNode serialize:writer];
        
        [writer writeUInt8:(uint8_t)self.items.count];
        for (ResourceNodeItem *item in self.items) {
            [item serialize:writer];
        }
        
        [writer writeInt32:self.unknown1];
    } else if (self.typeCode == 0x00) {
        [writer writeString:self.graphNode.blockName];
        [writer writeUInt32:self.graphNode.blockId];
        [self.graphNode serialize:writer];
        
        if (self.items.count < 1) {
            _items = @[[[ResourceNodeItem alloc] init]];
        }
        [self.items[0] serialize:writer];
    } else {
        @throw [NSException exceptionWithName:@"UnknownResourceNodeException"
                                       reason:[NSString stringWithFormat:@"Unknown ResourceNode 0x%@, 0x%@",
                                               [Helper hexStringUInt:self.version],
                                               [Helper hexStringByte:self.typeCode]]
                                     userInfo:nil];
    }
    
    [writer writeInt32:self.unknown2];
}

// MARK: - Template Methods

- (void)initTabPage {
    // In the original C# version, this set up Windows Forms controls
    // For macOS with AppKit, UI setup will be handled through view controllers
    // This method can be used to configure data binding or prepare model objects
}

- (void)initResourceTabPage {
    // Original C# built a tree view of child nodes
    // For macOS, this would populate data source arrays for NSOutlineView
    // The tree building logic is preserved in addChildNode:index:child: method
}

- (void)extendTabView:(NSTabView *)tabView {
    // Add additional tabs for child components
    if (self.typeCode == 0x01) {
        [self.treeNode addToTabControl:tabView];
    }
    [self.graphNode addToTabControl:tabView];
}

// MARK: - Memory Management

- (void)dispose {
    _graphNode = nil;
    _treeNode = nil;
    _items = @[];
    [super dispose];
}

@end
