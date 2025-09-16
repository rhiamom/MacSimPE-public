//
//  cTransformNode.h
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AbstractCresChildren.h"

@class CompositionTreeNode;
@class ObjectGraphNode;
@class VectorTransformation;
@class Vector3f;
@class Quaternion;
@class TransformNodeItems;
@class Rcol;
@class BinaryReader;
@class BinaryWriter;
@class IntArrayList;

// MARK: - Constants

/**
 * This value in Joint Reference tells us that the
 * Node is not directly linked to a joint
 */
extern const int32_t TRANSFORM_NODE_NO_JOINT;

// MARK: - TransformNodeItem

@interface TransformNodeItem : NSObject

// MARK: - Properties

@property (nonatomic, assign) uint16_t unknown1;
@property (nonatomic, assign) int32_t childNode;

// MARK: - Initialization

- (instancetype)init;

// MARK: - Serialization

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @remarks
 * Be sure that the Position of the stream is Proper on
 * return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

- (NSString *)description;

@end

// MARK: - TransformNodeItems

/**
 * Type-safe NSMutableArray for TransformNodeItem Objects
 */
@interface TransformNodeItems : NSMutableArray<TransformNodeItem *>

// MARK: - Indexed Access
- (TransformNodeItem *)objectAtIndex:(NSUInteger)index;
- (TransformNodeItem *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(TransformNodeItem *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(TransformNodeItem *)object;

// MARK: - Collection Operations
- (NSInteger)addItem:(TransformNodeItem *)item;
- (void)insertItem:(TransformNodeItem *)item atIndex:(NSUInteger)index;
- (void)removeItem:(TransformNodeItem *)item;
- (BOOL)containsItem:(TransformNodeItem *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning
- (id)copy;

@end

// MARK: - TransformNode

/**
 * Zusammenfassung für cTransformNode.
 */
@interface TransformNode : AbstractCresChildren

// MARK: - Properties

@property (nonatomic, readonly, strong) CompositionTreeNode *compositionTreeNode;
@property (nonatomic, readonly, strong) ObjectGraphNode *objectGraphNode;
@property (nonatomic, strong) TransformNodeItems *items;
@property (nonatomic, strong) VectorTransformation *transformation;
@property (nonatomic, assign) int32_t jointReference;

// MARK: - Transformation Access Properties

@property (nonatomic, readonly, strong) Vector3f *translation;

@property (nonatomic, assign) float transformX;
@property (nonatomic, assign) float transformY;
@property (nonatomic, assign) float transformZ;

@property (nonatomic, assign) float rotationX;
@property (nonatomic, assign) float rotationY;
@property (nonatomic, assign) float rotationZ;
@property (nonatomic, assign) float rotationW;

@property (nonatomic, strong) Quaternion *rotation;

// MARK: - AbstractCresChildren Overrides

@property (nonatomic, readonly, strong) TransformNode *storedTransformNode;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - AbstractCresChildren Protocol Implementation

- (NSString *)getName;
- (IntArrayList *)childBlocks;
- (NSInteger)imageIndex;

// MARK: - Child Management

/**
 * Remove the Child with the given Index from the List
 * @param index The child index to remove
 * @returns YES when the Child was found and removed
 */
- (BOOL)removeChild:(int32_t)index;

/**
 * Add the Child with the given Index to the List
 * @param index The child index to add
 * @returns YES when the Child was added successfully
 */
- (BOOL)addChild:(int32_t)index;

// MARK: - IRcolBlock Protocol Methods

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @remarks
 * Be sure that the Position of the stream is Proper on
 * return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Template Methods

- (void)initTabPage;
- (void)extendTabView:(NSTabView *)tabView;

// MARK: - Memory Management

- (void)dispose;

@end
