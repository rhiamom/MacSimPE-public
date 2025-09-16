//
//  cResourceNode.h
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AbstractCresChildren.h"

@class ObjectGraphNode;
@class CompositionTreeNode;
@class TransformNode;
@class Rcol;
@class BinaryReader;
@class BinaryWriter;
@class IntArrayList;

// MARK: - ResourceNodeItem

@interface ResourceNodeItem : NSObject

// MARK: - Properties

@property (nonatomic, assign) int16_t unknown1;
@property (nonatomic, assign) int32_t unknown2;

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

// MARK: - ResourceNode

/**
 * This is the actual FileWrapper
 * @remarks
 * The wrapper is used to (un)serialize the Data of a file into its Attributes. So Basically it reads
 * a BinaryStream and translates the data into some user-defined Attributes.
 */
@interface ResourceNode : AbstractCresChildren

// MARK: - Properties

@property (nonatomic, readonly, assign) uint8_t typeCode;
@property (nonatomic, readonly, strong) ObjectGraphNode *graphNode;
@property (nonatomic, readonly, strong) CompositionTreeNode *treeNode;
@property (nonatomic, strong) NSArray<ResourceNodeItem *> *items;
@property (nonatomic, assign) int32_t unknown1;
@property (nonatomic, assign) int32_t unknown2;

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

// MARK: - Tree Building

/**
 * Add a ChildNode (and all its subChilds) to a TreeNode
 * @param parent The parent TreeNode collection
 * @param index The Index of the Child Block in the Parent
 * @param child The ChildBlock (can be nil)
 */
- (void)addChildNode:(NSMutableArray *)parent
               index:(NSInteger)index
               child:(id<ICresChildren>)child;

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
- (void)initResourceTabPage;
- (void)extendTabView:(NSTabView *)tabView;

// MARK: - Memory Management

- (void)dispose;

@end
