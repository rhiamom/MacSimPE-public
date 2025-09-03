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

@class BinaryReader, BinaryWriter;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains a 2D Vector (when (un)serialized, it will be interpreted as SingleFloat!)
 */
@interface Vector2 : NSObject <NSCopying>

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
+ (Vector2 *)zero;

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
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector2 *)clone;

/**
 * Vector addition
 * @param other The vector to add
 * @return The resulting vector
 */
- (Vector2 *)add:(Vector2 *)other;

/**
 * Vector subtraction
 * @param other The vector to subtract
 * @return The resulting vector
 */
- (Vector2 *)subtract:(Vector2 *)other;

/**
 * Scalar multiplication
 * @param scalar The scalar to multiply by
 * @return The resulting vector
 */
- (Vector2 *)multiplyByScalar:(double)scalar;

/**
 * Scalar division
 * @param scalar The scalar to divide by
 * @return The resulting vector
 */
- (Vector2 *)divideByScalar:(double)scalar;

/**
 * Dot product
 * @param other The other vector
 * @return The dot product result
 */
- (double)dotProduct:(Vector2 *)other;

// MARK: - Comparison

/**
 * Check if two vectors are equal
 * @param other The other vector
 * @return YES if equal, NO otherwise
 */
- (BOOL)isEqualToVector:(Vector2 *)other;

// MARK: - String Representation

/**
 * String representation of the vector
 */
- (NSString *)description;

@end

//    Mark: Vector 3 class

/**
 * Contains a 3D Vector (when (un)serialized, it will be interpreted as SingleFloat!)
 */
@interface Vector3 : Vector2

// MARK: - Properties

/**
 * The Z Coordinate of the Vector
 */
@property (nonatomic, assign) double z;

/**
 * Returns the unit vector for this vector
 */
@property (nonatomic, readonly) Vector3 *unitVector;

/**
 * Returns the norm of the vector
 */
@property (nonatomic, readonly) double norm;

/**
 * Returns the length of the vector
 */
@property (nonatomic, readonly) double length;

// MARK: - Class Methods

/**
 * Returns a zero vector
 */
+ (Vector3 *)zero;

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
 * @param dataArray Array of strings containing coordinates
 */
- (instancetype)initWithStringArray:(NSArray<NSString *> *)dataArray;

/**
 * Creates new Vector Instance from space-separated string
 * @param data Space-separated coordinate string
 */
- (instancetype)initWithString:(NSString *)data;

/**
 * Creates new Vector Instance from double array
 * @param data Array of double values
 */
- (instancetype)initWithDoubleArray:(NSArray<NSNumber *> *)data;

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector3 *)clone;

/**
 * Makes this vector a unit vector (length = 1)
 */
- (void)makeUnitVector;

/**
 * Get the inverse of this vector
 * @return The inverted vector
 */
- (Vector3 *)getInverse;

/**
 * Vector addition
 * @param other The vector to add
 * @return The resulting vector
 */
- (Vector3 *)add:(Vector3 *)other;

/**
 * Vector subtraction
 * @param other The vector to subtract
 * @return The resulting vector
 */
- (Vector3 *)subtract:(Vector3 *)other;

/**
 * Scalar multiplication
 * @param scalar The scalar to multiply by
 * @return The resulting vector
 */
- (Vector3 *)multiplyByScalar:(double)scalar;

/**
 * Scalar division
 * @param scalar The scalar to divide by
 * @return The resulting vector
 */
- (Vector3 *)divideByScalar:(double)scalar;

/**
 * Dot product (scalar product)
 * @param other The other vector
 * @return The dot product result
 */
- (double)dotProduct:(Vector3 *)other;

/**
 * Cross product
 * @param other The other vector
 * @return The cross product vector
 */
- (Vector3 *)crossProduct:(Vector3 *)other;

// MARK: - Component Access

/**
 * Get a component by index (0=x, 1=y, 2=z)
 * @param index The component index
 * @return The component value
 */
- (double)getComponent:(int)index;

/**
 * Set a component by index (0=x, 1=y, 2=z)
 * @param index The component index
 * @param value The new value
 */
- (void)setComponent:(int)index value:(double)value;

// MARK: - Comparison

/**
 * Check if two vectors are equal
 * @param other The other vector
 * @return YES if equal, NO otherwise
 */
- (BOOL)isEqualToVector:(Vector3 *)other;

// MARK: - String Representation

/**
 * String representation with high precision
 */
- (NSString *)toString2;

@end

//    Mark: Vector 4 class

/**
 * Contains a 4D Vector (when (un)serialized, it will be interpreted as SingleFloat!)
 */
@interface Vector4 : Vector3

// MARK: - Properties

/**
 * The 4th Component of a Vector (often used as focal Point)
 */
@property (nonatomic, assign) double w;

// MARK: - Class Methods

/**
 * Returns a zero vector
 */
+ (Vector4 *)zero;

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

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector4 *)clone;

/**
 * Vector addition
 * @param other The vector to add
 * @return The resulting vector
 */
- (Vector4 *)add:(Vector4 *)other;

/**
 * Vector subtraction
 * @param other The vector to subtract
 * @return The resulting vector
 */
- (Vector4 *)subtract:(Vector4 *)other;

/**
 * Scalar multiplication
 * @param scalar The scalar to multiply by
 * @return The resulting vector
 */
- (Vector4 *)multiplyByScalar:(double)scalar;

/**
 * Scalar division
 * @param scalar The scalar to divide by
 * @return The resulting vector
 */
- (Vector4 *)divideByScalar:(double)scalar;

/**
 * Dot product
 * @param other The other vector
 * @return The dot product result
 */
- (double)dotProduct:(Vector4 *)other;

// MARK: - Component Access

/**
 * Get a component by index (0=x, 1=y, 2=z, 3=w)
 * @param index The component index
 * @return The component value
 */
- (double)getComponent:(int)index;

/**
 * Set a component by index (0=x, 1=y, 2=z, 3=w)
 * @param index The component index
 * @param value The new value
 */
- (void)setComponent:(int)index value:(double)value;

// MARK: - Comparison

/**
 * Check if two vectors are equal
 * @param other The other vector
 * @return YES if equal, NO otherwise
 */
- (BOOL)isEqualToVector:(Vector4 *)other;

@end


@class BinaryReader, BinaryWriter;

/**
 * Contains a 3D Vector with integer coordinates
 */
@interface Vector3i : NSObject <NSCopying>

// MARK: - Properties

/**
 * The X Coordinate of the Vector
 */
@property (nonatomic, assign) int32_t x;

/**
 * The Y Coordinate of the Vector
 */
@property (nonatomic, assign) int32_t y;

/**
 * The Z Coordinate of the Vector
 */
@property (nonatomic, assign) int32_t z;

// MARK: - Class Methods

/**
 * Returns a zero vector
 */
+ (Vector3i *)zero;

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
- (instancetype)initWithX:(int32_t)x y:(int32_t)y z:(int32_t)z;

// MARK: - Serialization

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Operations

/**
 * Create a clone of this Vector
 */
- (Vector3i *)clone;

/**
 * Vector addition
 * @param other The vector to add
 * @return The resulting vector
 */
- (Vector3i *)add:(Vector3i *)other;

/**
 * Vector subtraction
 * @param other The vector to subtract
 * @return The resulting vector
 */
- (Vector3i *)subtract:(Vector3i *)other;

// MARK: - Comparison

/**
 * Check if two vectors are equal
 * @param other The other vector
 * @return YES if equal, NO otherwise
 */
- (BOOL)isEqualToVector:(Vector3i *)other;

@end

@class Vector2, Vector3, Vector3i, Vector4;

// MARK: - Vector2 Collection

/**
 * Type-safe NSMutableArray for Vector2 Objects
 */
@interface Vectors2 : NSMutableArray<Vector2 *>

// MARK: - Typed Accessors
- (Vector2 *)objectAtIndex:(NSUInteger)index;
- (Vector2 *)objectAtUnsignedIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector2 *)object;
- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector2 *)object;

// MARK: - Collection Operations
- (NSInteger)addVector:(Vector2 *)item;
- (void)insertVector:(Vector2 *)item atIndex:(NSUInteger)index;
- (void)removeVector:(Vector2 *)item;
- (BOOL)containsVector:(Vector2 *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying
- (Vectors2 *)clone;

@end

// MARK: - Vector3 Collection

/**
 * Type-safe NSMutableArray for Vector3 Objects
 */
@interface Vectors3 : NSMutableArray<Vector3 *>

// MARK: - Typed Accessors
- (Vector3 *)objectAtIndex:(NSUInteger)index;
- (Vector3 *)objectAtUnsignedIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3 *)object;
- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector3 *)object;

// MARK: - Collection Operations
- (NSInteger)addVector:(Vector3 *)item;
- (void)insertVector:(Vector3 *)item atIndex:(NSUInteger)index;
- (void)removeVector:(Vector3 *)item;
- (BOOL)containsVector:(Vector3 *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying
- (Vectors3 *)clone;

@end

// MARK: - Vector3i Collection

/**
 * Type-safe NSMutableArray for Vector3i Objects
 */
@interface Vectors3i : NSMutableArray<Vector3i *>

// MARK: - Typed Accessors
- (Vector3i *)objectAtIndex:(NSUInteger)index;
- (Vector3i *)objectAtUnsignedIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3i *)object;
- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector3i *)object;

// MARK: - Collection Operations
- (NSInteger)addVector:(Vector3i *)item;
- (void)insertVector:(Vector3i *)item atIndex:(NSUInteger)index;
- (void)removeVector:(Vector3i *)item;
- (BOOL)containsVector:(Vector3i *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying
- (Vectors3i *)clone;

@end

// MARK: - Vector4 Collection

/**
 * Type-safe NSMutableArray for Vector4 Objects
 */
@interface Vectors4 : NSMutableArray<Vector4 *>

// MARK: - Typed Accessors
- (Vector4 *)objectAtIndex:(NSUInteger)index;
- (Vector4 *)objectAtUnsignedIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector4 *)object;
- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector4 *)object;

// MARK: - Collection Operations
- (NSInteger)addVector:(Vector4 *)item;
- (void)insertVector:(Vector4 *)item atIndex:(NSUInteger)index;
- (void)removeVector:(Vector4 *)item;
- (BOOL)containsVector:(Vector4 *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Copying
- (Vectors4 *)clone;

@end

NS_ASSUME_NONNULL_END

