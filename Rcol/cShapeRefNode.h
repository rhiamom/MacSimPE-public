//
//  cShapeRefNode.h
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AbstractCresChildren.h"

@class RenderableNode;
@class BoundedNode;
@class TransformNode;
@class IntArrayList;
@class BinaryReader;
@class BinaryWriter;
@class Rcol;

// MARK: - ShapeRefNodeItemA

@interface ShapeRefNodeItemA : NSObject

@property (nonatomic, assign) uint16_t unknown1;
@property (nonatomic, assign) int32_t unknown2;

- (instancetype)init;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (NSString *)description;

@end

// MARK: - ShapeRefNodeItemB

@interface ShapeRefNodeItemB : NSObject

@property (nonatomic, assign) int32_t unknown1;
@property (nonatomic, copy) NSString *name;

- (instancetype)init;
- (NSString *)description;

@end

// MARK: - ShapeRefNode

/**
 * Zusammenfassung für cShapeRefNode.
 */
@interface ShapeRefNode : AbstractCresChildren

// MARK: - Node Properties

@property (nonatomic, strong) RenderableNode *renderableNode;
@property (nonatomic, strong) BoundedNode *boundedNode;
@property (nonatomic, strong) TransformNode *transformNode;

// MARK: - Data Properties

@property (nonatomic, assign) int16_t unknown1;
@property (nonatomic, assign) int32_t unknown2;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int32_t unknown3;
@property (nonatomic, assign) uint8_t unknown4;
@property (nonatomic, strong) NSArray<ShapeRefNodeItemA *> *itemsA;
@property (nonatomic, assign) int32_t unknown5;
@property (nonatomic, strong) NSArray<ShapeRefNodeItemB *> *itemsB;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) int32_t unknown6;

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (void)dispose;

// MARK: - UI Management

- (void)extendTabView:(NSTabView *)tabView;

// MARK: - AbstractCresChildren Overrides

- (NSString *)getName;
- (IntArrayList *)childBlocks;
- (NSInteger)imageIndex;
- (TransformNode *)storedTransformNode;

@end
