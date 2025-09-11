//
//  cShape.h
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
#import "AbstractRcolBlock.h"
#import "IScenegraphBlock.h"

@class Shape, ObjectGraphNode, ReferentNode, BinaryReader, BinaryWriter;

// MARK: - ShapePart

@interface ShapePart : NSObject

@property (nonatomic, copy) NSString *subset;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSData *data;

- (instancetype)init;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (NSString *)description;

@end

// MARK: - ShapeItem

@interface ShapeItem : NSObject

@property (nonatomic, assign) int32_t unknown1;
@property (nonatomic, assign) uint8_t unknown2;
@property (nonatomic, assign) int32_t unknown3;
@property (nonatomic, assign) uint8_t unknown4;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, weak) Shape *parent;

- (instancetype)initWithParent:(Shape *)parent;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (NSString *)description;

@end

// MARK: - Shape

@interface Shape : AbstractRcolBlock <IScenegraphBlock>

@property (nonatomic, strong) NSArray<NSNumber *> *unknown;
@property (nonatomic, strong) NSArray<ShapeItem *> *items;
@property (nonatomic, strong) NSArray<ShapePart *> *parts;
@property (nonatomic, strong) ObjectGraphNode *graphNode;
@property (nonatomic, strong, readonly) ReferentNode *refNode;

- (instancetype)initWithParent:(Rcol *)parent;

@end
