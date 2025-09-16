//
//  cTransformNode.m
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

#import "cTransformNode.h"
#import "cCompositionTreeNode.h"
#import "cObjectGraphNode.h"
#import "VectorTransformation.h"
#import "Vectors.h"
#import "Quaternion.h"
#import "RcolWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Containers.h"
#import "Helper.h"

// MARK: - Constants

const int32_t TRANSFORM_NODE_NO_JOINT = 0x7fffffff;

// MARK: - TransformNodeItem Implementation

@implementation TransformNodeItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _unknown1 = 1;
        _childNode = 0;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.unknown1 = [reader readUInt16];
    self.childNode = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt16:self.unknown1];
    [writer writeInt32:self.childNode];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%@ 0x%@",
            [Helper hexStringUShort:self.unknown1],
            [Helper hexStringUInt:(uint32_t)self.childNode]];
}

@end

// MARK: - TransformNodeItems Implementation

@implementation TransformNodeItems

- (TransformNodeItem *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (TransformNodeItem *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(TransformNodeItem *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(TransformNodeItem *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addItem:(TransformNodeItem *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertItem:(TransformNodeItem *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeItem:(TransformNodeItem *)item {
    [self removeObject:item];
}

- (BOOL)containsItem:(TransformNodeItem *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (id)copy {
    TransformNodeItems *list = [[TransformNodeItems alloc] init];
    for (TransformNodeItem *item in self) {
        [list addItem:item];
    }
    return list;
}

@end

// MARK: - TransformNode Implementation

@interface TransformNode ()
@property (nonatomic, strong) CompositionTreeNode *compositionTreeNode;
@property (nonatomic, strong) ObjectGraphNode *objectGraphNode;
@end

@implementation TransformNode

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _compositionTreeNode = [[CompositionTreeNode alloc] initWithParent:parent];
        _objectGraphNode = [[ObjectGraphNode alloc] initWithParent:parent];
        
        _items = [[TransformNodeItems alloc] init];
        
        // Note: VectorTransformation may need to be implemented or adapted for macOS
        // For now, assuming it exists with TransformOrderTranslateRotate
        _transformation = [[VectorTransformation alloc] initWithOrder:VectorTransformationOrderTranslateRotate];
        
        self.version = 0x07;
        self.blockId = 0x65246462;
        
        _jointReference = TRANSFORM_NODE_NO_JOINT;
    }
    return self;
}

// MARK: - Transformation Properties

- (Vector3f *)translation {
    return self.transformation.translation;
}

- (float)transformX {
    return self.transformation.translation.x;
}

- (void)setTransformX:(float)transformX {
    self.transformation.translation.x = transformX;
}

- (float)transformY {
    return self.transformation.translation.y;
}

- (void)setTransformY:(float)transformY {
    self.transformation.translation.y = transformY;
}

- (float)transformZ {
    return self.transformation.translation.z;
}

- (void)setTransformZ:(float)transformZ {
    self.transformation.translation.z = transformZ;
}

- (float)rotationX {
    return self.transformation.rotation.x;
}

- (void)setRotationX:(float)rotationX {
    self.transformation.rotation.x = rotationX;
}

- (float)rotationY {
    return self.transformation.rotation.y;
}

- (void)setRotationY:(float)rotationY {
    self.transformation.rotation.y = rotationY;
}

- (float)rotationZ {
    return self.transformation.rotation.z;
}

- (void)setRotationZ:(float)rotationZ {
    self.transformation.rotation.z = rotationZ;
}

- (float)rotationW {
    return self.transformation.rotation.w;
}

- (void)setRotationW:(float)rotationW {
    self.transformation.rotation.w = rotationW;
}

- (Quaternion *)rotation {
    return self.transformation.rotation;
}

- (void)setRotation:(Quaternion *)rotation {
    self.transformation.rotation = rotation;
}

// MARK: - AbstractCresChildren Protocol Implementation

- (NSString *)getName {
    [super getName];  // Required call to superclass
    return self.objectGraphNode.fileName;
}

- (IntArrayList *)childBlocks {
    IntArrayList *list = [[IntArrayList alloc] init];
    for (TransformNodeItem *tni in self.items) {
        [list addInt:tni.childNode];
    }
    return list;
}

- (NSInteger)imageIndex {
    if (self.jointReference == TRANSFORM_NODE_NO_JOINT) {
        return 0; // clear
    }
    return 1; // bone
}

- (TransformNode *)storedTransformNode {
    return self;
}

// MARK: - Child Management

- (BOOL)removeChild:(int32_t)index {
    for (NSInteger i = 0; i < self.items.length; i++) {
        if ([self.items objectAtIndex:i].childNode == index) {
            [self.items removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}

- (BOOL)addChild:(int32_t)index {
    // Check if child already exists
    for (NSInteger i = 0; i < self.items.length; i++) {
        if ([self.items objectAtIndex:i].childNode == index) {
            return NO;
        }
    }
    
    TransformNodeItem *tni = [[TransformNodeItem alloc] init];
    tni.childNode = index;
    [self.items addItem:tni];
    return YES;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    NSString *name = [reader readString];
    uint32_t myId = [reader readUInt32];
    [self.compositionTreeNode unserialize:reader];
    self.compositionTreeNode.blockId = myId;
    
    name = [reader readString];
    myId = [reader readUInt32];
    [self.objectGraphNode unserialize:reader];
    self.objectGraphNode.blockId = myId;
    
    uint32_t count = [reader readUInt32];
    [self.items removeAllObjects];
    for (uint32_t i = 0; i < count; i++) {
        TransformNodeItem *tni = [[TransformNodeItem alloc] init];
        [tni unserialize:reader];
        [self.items addItem:tni];
    }
    
    // Note: Assuming VectorTransformation has the required methods
    self.transformation.order = VectorTransformationOrderTranslateRotate;
    [self.transformation unserialize:reader];
    
#ifdef DEBUG
    self.transformation.name = self.objectGraphNode.fileName;
#endif
    
    self.jointReference = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    [writer writeString:self.compositionTreeNode.blockName];
    [writer writeUInt32:self.compositionTreeNode.blockId];
    [self.compositionTreeNode serialize:writer];
    
    [writer writeString:self.objectGraphNode.blockName];
    [writer writeUInt32:self.objectGraphNode.blockId];
    [self.objectGraphNode serialize:writer];
    
    [writer writeUInt32:(uint32_t)self.items.length];
    for (NSInteger i = 0; i < self.items.length; i++) {
        [[self.items objectAtIndex:i] serialize:writer];
    }
    
    self.transformation.order = VectorTransformationOrderTranslateRotate;
    [self.transformation serialize:writer];
    
    [writer writeInt32:self.jointReference];
}

// MARK: - Template Methods

- (void)initTabPage {
    // Original C# code set up Windows Forms controls
    // For macOS with AppKit, this would configure data binding
    // The transformation data would be bound to UI controls showing:
    // - Translation values (X, Y, Z)
    // - Rotation values (quaternion components)
    // - Joint reference
    // - Child node list
}

- (void)extendTabView:(NSTabView *)tabView {
    [super extendTabView:tabView];
    [self.objectGraphNode addToTabControl:tabView];
    [self.compositionTreeNode addToTabControl:tabView];
}

- (NSString *)description {
    NSMutableString *s = [[NSMutableString alloc] init];
    
    if (self.jointReference != TRANSFORM_NODE_NO_JOINT) {
        [s appendFormat:@"[Joint%d] - ", self.jointReference];
    }
    
    [s appendString:self.objectGraphNode.fileName];
    [s appendFormat:@": %@ (%@)", self.transformation, [super description]];
    
    return s;
}

// MARK: - Memory Management

- (void)dispose {
    _compositionTreeNode = nil;
    _objectGraphNode = nil;
    _items = nil;
    _transformation = nil;
    [super dispose];
}

@end
