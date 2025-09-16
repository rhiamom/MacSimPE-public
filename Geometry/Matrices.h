//
//  Matrices.h
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
@class Vector4f;

// MARK: - GeometryException

/**
 * Exception for geometry-related errors
 */
@interface GeometryException : NSException

+ (instancetype)exceptionWithReason:(NSString *)reason;

@end

// MARK: - Matrixd

/**
 * Zusammenfassung für Matrices.
 */
@interface Matrixd : NSObject

// MARK: - Properties

/**
 * Number of stored Rows
 */
@property (nonatomic, readonly) NSInteger rows;

/**
 * Number of stored Columns
 */
@property (nonatomic, readonly) NSInteger columns;

/**
 * Returns the Trace of the Matrix
 * @throws GeometryException Thrown if the matrix is not a square Matrix
 */
@property (nonatomic, readonly) double trace;

/**
 * Returns true, if this is the identity matrix
 */
@property (nonatomic, readonly, getter=isIdentity) BOOL identity;

/**
 * True if this Matrix is invertible
 */
@property (nonatomic, readonly, getter=isInvertible) BOOL invertible;

/**
 * True if the Matrix is Orthogonal
 */
@property (nonatomic, readonly, getter=isOrthogonal) BOOL orthogonal;

// MARK: - Initialization

/**
 * Representation of a Matrix
 * @param rows Number of Rows
 * @param columns Number of Columns
 * @remarks Minimum is a 1x1 (rowxcol)Matrix
 */
- (instancetype)initWithRows:(NSInteger)rows columns:(NSInteger)columns;

/**
 * Create a new 3x1 Matrix
 * @param vector the vector that should be represented as a Matrix
 */
- (instancetype)initWithVector3f:(Vector3f *)vector;

/**
 * Create a new 4x1 Matrix
 * @param vector the vector that should be represented as a Matrix
 */
- (instancetype)initWithVector4f:(Vector4f *)vector;

// MARK: - Element Access

/**
 * Get/Set matrix element at row, column
 * @param row Row index (0-based)
 * @param column Column index (0-based)
 */
- (double)valueAtRow:(NSInteger)row column:(NSInteger)column;
- (void)setValue:(double)value atRow:(NSInteger)row column:(NSInteger)column;

// MARK: - Vector Conversion

/**
 * Returns the Vector stored in this matrix or nil if not possible!
 */
- (Vector3f *)getVector;

/**
 * Returns the Vector4f stored in this matrix or nil if not possible!
 */
- (Vector4f *)getVector4;

// MARK: - Matrix Operations

/**
 * Create the Transpose of this Matrix
 */
- (Matrixd *)getTranspose;

/**
 * Returns the Inverse of this Matrix
 * @throws GeometryException Thrown if the Matrix is Singular (Determinant==0)
 */
- (Matrixd *)getInverse;

/**
 * Calculate the determinant of a Matrix
 * @throws GeometryException Thrown, if the Matrix is not a Square Matrix
 */
- (double)determinant;

/**
 * Calculate the Adjoint of a Matrix
 * @throws GeometryException Thrown if Rows or Columns is less than 2.
 */
- (Matrixd *)adjoint;

/**
 * Create the Minor/cofactor Matrix
 * @param row row that should be removed
 * @param column column that should be removed
 * @throws GeometryException Thrown if Rows or Columns is less than 2.
 * @returns The Minor Matrix for the given row/column
 */
- (Matrixd *)minorWithRow:(NSInteger)row column:(NSInteger)column;

/**
 * Convert to 3x3 matrix (truncating or padding as needed)
 */
- (Matrixd *)to33Matrix;

// MARK: - Matrix Arithmetic

/**
 * Matrix Multiplication
 * @param other The matrix to multiply with
 * @throws GeometryException Thrown if Number of Rows in self is not equal to Number of Columns in other
 */
- (Matrixd *)multiplyByMatrix:(Matrixd *)other;

/**
 * Scalar Matrix Multiplication
 * @param scalar The scalar to multiply with
 */
- (Matrixd *)multiplyByScalar:(double)scalar;

/**
 * Scalar Matrix Division
 * @param scalar The scalar to divide by
 * @throws GeometryException Thrown if User attempts to divide By Zero
 */
- (Matrixd *)divideByScalar:(double)scalar;

/**
 * Matrix Addition
 * @param other The matrix to add
 * @throws GeometryException Thrown if the Matrices have different Sizes
 */
- (Matrixd *)addMatrix:(Matrixd *)other;

/**
 * Matrix Subtraction
 * @param other The matrix to subtract
 * @throws GeometryException Thrown if the Matrices have different Sizes
 */
- (Matrixd *)subtractMatrix:(Matrixd *)other;

/**
 * Calculates the n-th Power
 * @param power The power to raise to
 * @throws GeometryException Thrown if this is not a Square Matrix
 */
- (Matrixd *)powerOf:(NSInteger)power;

// MARK: - Vector Operations

/**
 * Matrix-Vector Multiplication
 * @param vector The vector to multiply
 */
- (Vector3f *)multiplyByVector3f:(Vector3f *)vector;

/**
 * Matrix-Vector Multiplication
 * @param vector The vector to multiply
 */
- (Vector4f *)multiplyByVector4f:(Vector4f *)vector;

// MARK: - Class Factory Methods

/**
 * Create an identity Matrix
 * @param rows Number of rows
 * @param columns Number of columns
 */
+ (instancetype)identityWithRows:(NSInteger)rows columns:(NSInteger)columns;

/**
 * Create a Translation Matrix
 * @param vector The Translation Vector
 */
+ (instancetype)translation:(Vector3f *)vector;

/**
 * Create a Translation Matrix
 * @param x Translation in x
 * @param y Translation in y
 * @param z Translation in z
 */
+ (instancetype)translationX:(double)x y:(double)y z:(double)z;

/**
 * Create a UniformScale Matrix
 * @param scale Scale factor
 */
+ (instancetype)scale:(double)scale;

/**
 * Create a Scale Matrix
 * @param x Scale in x
 * @param y Scale in y
 * @param z Scale in z
 */
+ (instancetype)scaleX:(double)x y:(double)y z:(double)z;

/**
 * Create rotation matrix with yaw, pitch, roll
 * @param yaw Y-Component of a Rotation Vector
 * @param pitch X-Component of a Rotation Vector
 * @param roll Z-Component of a Rotation Vector
 */
+ (instancetype)rotateYaw:(double)yaw pitch:(double)pitch roll:(double)roll;

/**
 * Rotation around the X-Axis
 * @param angle Rotation angle in radians
 */
+ (instancetype)rotateX:(double)angle;

/**
 * Rotation around the Y-Axis
 * @param angle Rotation angle in radians
 */
+ (instancetype)rotateY:(double)angle;

/**
 * Rotation around the Z-Axis
 * @param angle Rotation angle in radians
 */
+ (instancetype)rotateZ:(double)angle;

// MARK: - String Representation

/**
 * Returns detailed string representation
 * @param full If YES, shows all matrix elements
 */
- (NSString *)stringWithFull:(BOOL)full;

@end
