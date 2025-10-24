//
//  AbstractCresChildren.h
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
#import "AbstractRcolBlock.h"
#import "ICresChildren.h"

@class IntArrayList;
@class TransformNode;
@class VectorTransformations;
@class VectorTransformation;
@class Rcol;

/**
 * Implemented common Methods of the ICresChildren Protocol
 */
@interface AbstractCresChildren : AbstractRcolBlock <ICresChildren>

// MARK: - Private Properties
@property (nonatomic, strong) NSMutableArray *seenBones;
@property (nonatomic, assign) NSInteger pos;
@property (nonatomic, strong) TransformNode *transformNode;

// MARK: - Initialization
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - Abstract Methods (Must be implemented by subclasses)
- (NSString *)getName NS_REQUIRES_SUPER;

// MARK: - ICresChildren Protocol Implementation
- (id<ICresChildren>)getBlock:(NSInteger)index;
- (IntArrayList *)getParentBlocks;
- (id<ICresChildren>)getFirstParent;

// MARK: - Hierarchy Transformations
- (VectorTransformations *)getHierarchyTransformations;
- (VectorTransformation *)getEffectiveTransformation;

// MARK: - Private Helper Methods
- (VectorTransformations *)getAbsoluteTransformation:(id<ICresChildren>)node
                               vectorTransformations:(VectorTransformations *)v;

// MARK: - NSFastEnumeration Support
- (void)reset;

@end
