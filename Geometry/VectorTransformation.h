//
//  VectorTransformations.h
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

@class Vector3f;
@class Quaternion;
@class BinaryReader;
@class BinaryWriter;

// MARK: - Constants

extern const double VECTOR_TRANSFORMATION_SMALL_NUMBER;

// MARK: - Transform Order Enumeration

/**
 * What Order should the Transformation be applied
 */
typedef NS_ENUM(uint8_t, VectorTransformationOrder) {
    /**
     * Rotate then Translate
     */
    VectorTransformationOrderRotateTranslate = 0,
    
    /**
     * Translate then Rotate (rigid Body)
     */
    VectorTransformationOrderTranslateRotate = 1
};

// MARK: - VectorTransformation

/**
 * One basic Vector Transformation
 */
@interface VectorTransformation : NSObject

// MARK: - Properties

/**
 * Returns / Sets the current Order
 */
@property (nonatomic, assign) VectorTransformationOrder order;

/**
 * The Translation
 */
@property (nonatomic, strong) Vector3f *translation;

/**
 * The Rotation
 */
@property (nonatomic, strong) Quaternion *rotation;

#ifdef DEBUG
/**
 * Debug name for the transformation
 */
@property (nonatomic, copy) NSString *name;
#endif

// MARK: - Initialization

/**
 * Create a new Instance
 * @param order The order of the Transform
 */
- (instancetype)initWithOrder:(VectorTransformationOrder)order;

/**
 * Create a new Instance
 * @remarks Order is implicitly set to VectorTransformationOrderTranslateRotate
 */
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

// MARK: - Transformation

/**
 * Applies the Transformation to the passed Vertex
 * @param vector The Vertex you want to Transform
 * @returns Transformed Vertex
 */
- (Vector3f *)transformVector:(Vector3f *)vector;

// MARK: - Cloning

/**
 * Create a Clone of this Transformation Set
 * @returns A cloned VectorTransformation
 */
- (VectorTransformation *)clone;

@end

// MARK: - VectorTransformations Collection

/**
 * Type-safe NSMutableArray for VectorTransformation Objects
 */
@interface VectorTransformations : NSMutableArray<VectorTransformation *>

// MARK: - Indexed Access

- (VectorTransformation *)objectAtIndex:(NSUInteger)index;
- (VectorTransformation *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(VectorTransformation *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(VectorTransformation *)object;

// MARK: - Collection Operations

/**
 * add a new Element
 * @param item The object you want to add
 * @returns The index it was added on
 */
- (NSInteger)addTransformation:(VectorTransformation *)item;

/**
 * insert a new Element
 * @param index The Index where the Element should be stored
 * @param item The object that should be inserted
 */
- (void)insertTransformation:(VectorTransformation *)item atIndex:(NSUInteger)index;

/**
 * remove an Element
 * @param item The object that should be removed
 */
- (void)removeTransformation:(VectorTransformation *)item;

/**
 * Checks whether or not the object is already stored in the List
 * @param item The Object you are looking for
 * @returns YES if it was found
 */
- (BOOL)containsTransformation:(VectorTransformation *)item;

// MARK: - Properties

/**
 * Number of stored Elements
 */
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning

/**
 * Create a clone of this Object
 * @returns The clone
 */
- (id)copy;

@end
