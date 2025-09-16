//
//  VectorTransformations.m
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

#import "VectorTransformation.h"
#import "Vectors.h"
#import "Quaternion.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"

// MARK: - Constants

const double VECTOR_TRANSFORMATION_SMALL_NUMBER = 0.000001;

// MARK: - VectorTransformation Implementation

@implementation VectorTransformation

// MARK: - Initialization

- (instancetype)initWithOrder:(VectorTransformationOrder)order {
    self = [super init];
    if (self) {
        _order = order;
        _translation = [[Vector3f alloc] init];
        _rotation = [Quaternion identity];
#ifdef DEBUG
        _name = nil;
#endif
    }
    return self;
}

- (instancetype)init {
    return [self initWithOrder:VectorTransformationOrderTranslateRotate];
}

// MARK: - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"trans=%@    rot=%@",
            self.translation, self.rotation];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    if (self.order == VectorTransformationOrderRotateTranslate) {
        [self.rotation unserialize:reader];
        [self.translation unserialize:reader];
    } else {
        [self.translation unserialize:reader];
        [self.rotation unserialize:reader];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    if (self.order == VectorTransformationOrderRotateTranslate) {
        [self.rotation serialize:writer];
        [self.translation serialize:writer];
    } else {
        [self.translation serialize:writer];
        [self.rotation serialize:writer];
    }
}

// MARK: - Transformation

- (Vector3f *)transformVector:(Vector3f *)vector {
    if (self.order == VectorTransformationOrderRotateTranslate) {
        Vector3f *rotated = [self.rotation rotateVector:vector];
        return [rotated addVector:self.translation];
    } else {
        Vector3f *translated = [vector addVector:self.translation];
        return [self.rotation rotateVector:translated];
    }
}

// MARK: - Cloning

- (VectorTransformation *)clone {
    VectorTransformation *cloned = [[VectorTransformation alloc] initWithOrder:self.order];
    cloned.rotation = [self.rotation clone];
    cloned.translation = [self.translation clone];
#ifdef DEBUG
    cloned.name = [self.name copy];
#endif
    return cloned;
}

@end

// MARK: - VectorTransformations Implementation

@implementation VectorTransformations

// MARK: - Indexed Access

- (VectorTransformation *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (VectorTransformation *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(VectorTransformation *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(VectorTransformation *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

// MARK: - Collection Operations

- (NSInteger)addTransformation:(VectorTransformation *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertTransformation:(VectorTransformation *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeTransformation:(VectorTransformation *)item {
    [self removeObject:item];
}

- (BOOL)containsTransformation:(VectorTransformation *)item {
    return [self containsObject:item];
}

// MARK: - Properties

- (NSInteger)length {
    return self.count;
}

// MARK: - Cloning

- (id)copy {
    VectorTransformations *cloned = [[VectorTransformations alloc] init];
    for (VectorTransformation *transformation in self) {
        [cloned addTransformation:[transformation clone]];
    }
    return cloned;
}

@end
