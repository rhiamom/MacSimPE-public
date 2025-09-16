//
//  ICresChildren.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
//
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

@class IntArrayList;
@class TransformNode;
@class Rcol;
@class VectorTransformation;

/**
 * Implemented by Blocks available in a CRES Hierarchy to link to child Blocks
 */
@protocol ICresChildren <NSFastEnumeration>

/**
 * Returns a List of all Child Blocks referenced by this Element
 */
@property (nonatomic, strong, readonly) IntArrayList *childBlocks;

/**
 * Returns the Index of this node within its Parent (-1 if not found)
 */
@property (nonatomic, readonly) NSInteger index;

/**
 * Returns the parent RCol Container
 */
@property (nonatomic, weak, readonly) Rcol *parent;

/**
 * Returns the Index of the Image that should be displayed in the TreeView
 * @remarks
 * 0 = Nothing
 * 1 = Joint
 * 2 = Light
 * 3 = Shape
 * 4 = Error
 */
@property (nonatomic, readonly) NSInteger imageIndex;

/**
 * Returns the TransformNode Object of this Node (can be null!)
 */
@property (nonatomic, strong, readonly) TransformNode *storedTransformNode;

/**
 * Returns a List of all Parent Nodes
 */
- (IntArrayList *)getParentBlocks;

/**
 * Returns the First Block that holds this Node as a Child
 */
- (id<ICresChildren>)getFirstParent;

/**
 * Returns the Child Block with the given Index from the Parent Rcol
 * @param index The index of the block to retrieve
 * @returns The child block or nil if not found
 */
- (id<ICresChildren>)getBlock:(NSInteger)index;

/**
 * Returns the effective Transformation, that is described by the CresHierarchy
 * @returns Effective Transformation
 */
- (VectorTransformation *)getEffectiveTransformation;

/**
 * Returns the name of this block
 */
- (NSString *)getName;

@end
