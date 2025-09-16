//
//  Vectors.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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

@class BinaryReader;
@class BinaryWriter;
@class Helper;

// MARK: - Vector2f

/**
 * Contains a 2D Vector (when (un)serialized, it will be interpreted as SingleFloat!)
 */
@interface Vector2f : NSObject

// MARK: - Properties

/**
 * The X Coordinate of the Vector
 */
@property (nonatomic, assign) double x;

/**
 * The Y Coordinate of the Vector
 */
@property (nonatomic, assign) double y;

// MARK: - Class Methods

/**
 * Returns a zero vector
 */
+ (Vector2f *)zero;

// MARK: - Initialization

/**
 * Creates a new Vector Instance (0-Vector)
 */
- (instancetype)init;

/**
 * Creates new Vector Instance
 * @param x X-Coordinate
 * @param y Y-Coordinate
 */
- (instancetype)initWithX:(double)x y:(double)y;

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

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector2f *)clone;

@end

// MARK: - Vector3f

/**
 * Contains a 3D Vector (when (un)serialized, it will be interpreted as SingleFloat!)
 */
@interface Vector3f : Vector2f

// MARK: - Properties

/**
 * The Z Coordinate of the Vector
 */
@property (nonatomic, assign) double z;

/**
 * Returns the UnitVector for this Vector
 */
@property (nonatomic, readonly, strong) Vector3f *unitVector;

/**
 * Returns the Norm of the Vector
 */
@property (nonatomic, readonly) double norm;

/**
 * Returns the Length of the Vector
 */
@property (nonatomic, readonly) double length;

// MARK: - Class Methods

/**
 * Returns a zero vector
 */
+ (Vector3f *)zero;

// MARK: - Initialization

/**
 * Creates a new Vector Instance (0-Vector)
 */
- (instancetype)init;

/**
 * Creates new Vector Instance
 * @param x X-Coordinate
 * @param y Y-Coordinate
 * @param z Z-Coordinate
 */
- (instancetype)initWithX:(double)x y:(double)y z:(double)z;

/**
 * Creates new Vector Instance from string array
 * @param dataArray String array with x, y, z values
 */
- (instancetype)initWithStringArray:(NSArray<NSString *> *)dataArray;

/**
 * Creates new Vector Instance from string
 * @param data String with space-separated x, y, z values
 */
- (instancetype)initWithString:(NSString *)data;

/**
 * Creates new Vector Instance from double array
 * @param data Double array with x, y, z values
 */
- (instancetype)initWithDoubleArray:(NSArray<NSNumber *> *)data;

// MARK: - Vector Operations

/**
 * Makes sure this Vector is a Unit Vector (Length=1)
 */
- (void)makeUnitVector;

/**
 * Create the Inverse of a Vector
 */
- (Vector3f *)getInverse;

/**
 * Vector addition
 * @param other The vector to add
 * @return The resulting vector
 */
- (Vector3f *)add:(Vector3f *)other;

/**
 * Vector subtraction
 * @param other The vector to subtract
 * @return The resulting vector
 */
- (Vector3f *)subtract:(Vector3f *)other;

/**
 * Scalar multiplication
 * @param scalar The scalar to multiply by
 * @return The resulting vector
 */
- (Vector3f *)multiplyByScalar:(double)scalar;

/**
 * Scalar division
 * @param scalar The scalar to divide by
 * @return The resulting vector
 */
- (Vector3f *)divideByScalar:(double)scalar;

/**
 * Scalar product (dot product)
 * @param other The other vector
 * @return The dot product result
 */
- (double)dotProduct:(Vector3f *)other;

/**
 * Cross product
 * @param other The other vector
 * @return The cross product vector
 */
- (Vector3f *)crossProduct:(Vector3f *)other;

/**
 * Compare vectors
 * @param other The other vector
 * @return YES if equal, NO otherwise
 */
- (BOOL)isEqualToVector:(Vector3f *)other;

// MARK: - Component Access

/**
 * Returns a Component of this Vector (0=x, 1=y, 2=z)
 * @param index Index of the component
 * @returns the value stored in that Component
 */
- (double)getComponent:(int)index;

/**
 * Set a Component of this Vector (0=x, 1=y, 2=z)
 * @param index Index of the component
 * @param val The new Value
 */
- (void)setComponent:(int)index value:(double)val;

// MARK: - String Representation

/**
 * String representation with high precision
 */
- (NSString *)toString2;

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector3f *)clone;

@end

// MARK: - Vector3i

/**
 * Contains a 3D Vector with integer components
 */
@interface Vector3i : NSObject

// MARK: - Properties

/**
 * The X Coordinate of the Vector
 */
@property (nonatomic, assign) int x;

/**
 * The Y Coordinate of the Vector
 */
@property (nonatomic, assign) int y;

/**
 * The Z Coordinate of the Vector
 */
@property (nonatomic, assign) int z;

// MARK: - Initialization

/**
 * Creates a new Vector Instance (0-Vector)
 */
- (instancetype)init;

/**
 * Creates new Vector Instance
 * @param x X-Coordinate
 * @param y Y-Coordinate
 * @param z Z-Coordinate
 */
- (instancetype)initWithX:(int)x y:(int)y z:(int)z;

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

@end

// MARK: - Vector4f

/**
 * Contains a 4D Vector (when (un)serialized, it will be interpreted as SingleFloat!)
 */
@interface Vector4f : Vector3f

// MARK: - Properties

/**
 * The 4th Component of a Vector (often used as focal Point)
 */
@property (nonatomic, assign) double w;

// MARK: - Class Methods

/**
 * Returns a zero vector
 */
+ (Vector4f *)zero;

// MARK: - Initialization

/**
 * Creates a new Vector Instance (0-Vector)
 */
- (instancetype)init;

/**
 * Creates new Vector Instance
 * @param x X-Coordinate
 * @param y Y-Coordinate
 * @param z Z-Coordinate
 */
- (instancetype)initWithX:(double)x y:(double)y z:(double)z;

/**
 * Creates new Vector Instance
 * @param x X-Coordinate
 * @param y Y-Coordinate
 * @param z Z-Coordinate
 * @param w 4th-Coordinate (often the focal Point)
 */
- (instancetype)initWithX:(double)x y:(double)y z:(double)z w:(double)w;

// MARK: - Component Access

/**
 * Returns a Component of this Vector (0=x, 1=y, 2=z, 3=w)
 * @param index Index of the component
 * @returns the value stored in that Component
 */
- (double)getComponent:(int)index;

/**
 * Set a Component of this Vector (0=x, 1=y, 2=z, 3=w)
 * @param index Index of the component
 * @param val The new Value
 */
- (void)setComponent:(int)index value:(double)val;

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector4f *)clone;

@end

// MARK: - Container Classes

/**
 * Type-safe NSMutableArray for Vector3i Objects
 */
@interface Vectors3i : NSMutableArray<Vector3i *>

// MARK: - Indexed Access
- (Vector3i *)objectAtIndex:(NSUInteger)index;
- (Vector3i *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3i *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector3i *)object;

// MARK: - Collection Operations
- (NSInteger)addVector3i:(Vector3i *)item;
- (void)insertVector3i:(Vector3i *)item atIndex:(NSUInteger)index;
- (void)removeVector3i:(Vector3i *)item;
- (BOOL)containsVector3i:(Vector3i *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning
- (id)copy;

@end

/**
 * Type-safe NSMutableArray for Vector3f Objects
 */
@interface Vectors3f : NSMutableArray<Vector3f *>

// MARK: - Indexed Access
- (Vector3f *)objectAtIndex:(NSUInteger)index;
- (Vector3f *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3f *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector3f *)object;

// MARK: - Collection Operations
- (NSInteger)addVector3f:(Vector3f *)item;
- (void)insertVector3f:(Vector3f *)item atIndex:(NSUInteger)index;
- (void)removeVector3f:(Vector3f *)item;
- (BOOL)containsVector3f:(Vector3f *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning
- (id)copy;

@end

/**
 * Type-safe NSMutableArray for Vector2f Objects
 */
@interface Vectors2f : NSMutableArray<Vector2f *>

// MARK: - Indexed Access
- (Vector2f *)objectAtIndex:(NSUInteger)index;
- (Vector2f *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector2f *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector2f *)object;

// MARK: - Collection Operations
- (NSInteger)addVector2f:(Vector2f *)item;
- (void)insertVector2f:(Vector2f *)item atIndex:(NSUInteger)index;
- (void)removeVector2f:(Vector2f *)item;
- (BOOL)containsVector2f:(Vector2f *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning
- (id)copy;

@end

/**
 * Type-safe NSMutableArray for Vector4f Objects
 */
@interface Vectors4f : NSMutableArray<Vector4f *>

// MARK: - Indexed Access
- (Vector4f *)objectAtIndex:(NSUInteger)index;
- (Vector4f *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector4f *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector4f *)object;

// MARK: - Collection Operations
- (NSInteger)addVector4f:(Vector4f *)item;
- (void)insertVector4f:(Vector4f *)item atIndex:(NSUInteger)index;
- (void)removeVector4f:(Vector4f *)item;
- (BOOL)containsVector4f:(Vector4f *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning
- (id)copy;

@end
