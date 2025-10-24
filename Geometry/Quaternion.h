//
//  Quaternion.h
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
#import "Vectors.h"

@class Vector3f;
@class Matrixd;
@class BinaryReader;
@class BinaryWriter;

// MARK: - Internal Enumeration

/**
 * Determines the type of the passed Arguments
 */
typedef NS_ENUM(uint8_t, QuaternionParameterType) {
    /**
     * Arguments represent a (unit-)Axis/Angle Pair
     */
    QuaternionParameterTypeUnitAxisAngle = 0x01,
    
    /**
     * Arguments represent the Imaginary coefficients of a Quaternion and the Real Part
     */
    QuaternionParameterTypeImaginaryReal = 0x02
};

// MARK: - Quaternion

/**
 * Zusammenfassung für Quaternion.
 */
@interface Quaternion : Vector4f

// MARK: - Properties

/**
 * Returns the Norm of the Quaternion
 */
@property (nonatomic, readonly) float norm;

/**
 * Returns the Length of the Quaternion
 */
@property (nonatomic, readonly) float length;

/**
 * Returns the Conjugate for this Quaternion
 */
@property (nonatomic, readonly, strong) Quaternion *conjugate;

/**
 * Returns the Imaginary Part of the Quaternion
 */
@property (nonatomic, readonly, strong) Vector3f *imaginary;

/**
 * Returns the Rotation Angle (in Radians)
 */
@property (nonatomic, readonly) float angle;

/**
 * Returns the rotation (unit-)Axis
 */
@property (nonatomic, readonly, strong) Vector3f *axis;

/**
 * Returns the Matrix for this Quaternion
 * @remarks Before the Matrix is generated, the Quaternion will get Normalized!!!
 */
@property (nonatomic, readonly, strong) Matrixd *matrix;

#ifdef DEBUG
/**
 * Returns the Euler Angles
 */
@property (nonatomic, readonly, strong) Vector3f *euler;

/**
 * Debug name for the quaternion
 */
@property (nonatomic, copy) NSString *name;
#endif

// MARK: - Class Properties

/**
 * Returns an Identity Quaternion
 */
@property (class, nonatomic, readonly, strong) Quaternion *identity;

/**
 * Returns an Empty Quaternion
 */
@property (class, nonatomic, readonly, strong) Quaternion *zero;

// MARK: - Initialization

/**
 * Creates a new Identity Quaternion
 */
- (instancetype)init;

// MARK: - Factory Methods

/**
 * Create from Axis-Angle representation
 * @param axis The (unit-)Axis
 * @param angle The rotation Angle in radians
 */
+ (instancetype)fromAxisAngle:(Vector3f *)axis angle:(float)angle;

/**
 * Create from Axis-Angle representation
 * @param x X component of axis
 * @param y Y component of axis
 * @param z Z component of axis
 * @param angle The rotation Angle in radians
 */
+ (instancetype)fromAxisAngleX:(float)x y:(float)y z:(float)z angle:(float)angle;

/**
 * Create from Imaginary-Real representation
 * @param imaginary The imaginary part
 * @param w The real part
 */
+ (instancetype)fromImaginary:(Vector3f *)imaginary real:(float)w;

/**
 * Create from Imaginary-Real representation
 * @param vector A Vector4f with x,y,z,w components
 */
+ (instancetype)fromImaginaryReal:(Vector4f *)vector;

/**
 * Create from Imaginary-Real representation
 * @param x X imaginary component
 * @param y Y imaginary component
 * @param z Z imaginary component
 * @param w Real component
 */
+ (instancetype)fromImaginaryRealX:(float)x y:(float)y z:(float)z w:(float)w;

/**
 * Create from Euler Angles
 * @param eulerAngles The Euler Angles (X=Pitch, Y=Yaw, Z=Roll)
 */
+ (instancetype)fromEulerAngles:(Vector3f *)eulerAngles;

/**
 * Create from Euler Angles
 * @param yaw Yaw angle
 * @param pitch Pitch angle
 * @param roll Roll angle
 */
+ (instancetype)fromEulerAnglesYaw:(float)yaw pitch:(float)pitch roll:(float)roll;

/**
 * Create from Rotation Matrix
 * @param rotationMatrix The rotation matrix
 */
+ (instancetype)fromRotationMatrix:(Matrixd *)rotationMatrix;

// MARK: - Angle Conversion Utilities

/**
 * Returns an Angle in Degrees
 * @param radians Angle in Radians
 * @returns Angle in Degrees
 */
+ (float)radiansToDegrees:(float)radians;

/**
 * Returns an Angle in Radians
 * @param degrees Angle in Degrees
 * @returns Angle in Radians
 */
+ (float)degreesToRadians:(float)degrees;

// MARK: - Quaternion Operations

/**
 * Multiply two quaternions
 * @param q1 First quaternion
 * @param q2 Second quaternion
 * @returns The resulting quaternion
 */
+ (Quaternion *)multiply:(Quaternion *)q1 by:(Quaternion *)q2;

/**
 * Multiply quaternion by scalar
 * @param quaternion The quaternion
 * @param scalar The scalar value
 * @returns The resulting quaternion
 */
+ (Quaternion *)multiplyQuaternion:(Quaternion *)quaternion byScalar:(float)scalar;

/**
 * Add two quaternions
 * @param q1 First quaternion
 * @param q2 Second quaternion
 * @returns The resulting quaternion
 */
+ (Quaternion *)add:(Quaternion *)q1 to:(Quaternion *)q2;

/**
 * Scalar/dot/inner product
 * @param q1 First quaternion
 * @param q2 Second quaternion
 * @returns The dot product
 */
+ (float)dotProduct:(Quaternion *)q1 with:(Quaternion *)q2;

/**
 * Cross product
 * @param q1 First quaternion
 * @param q2 Second quaternion
 * @returns The resulting quaternion
 */
+ (Quaternion *)crossProduct:(Quaternion *)q1 with:(Quaternion *)q2;

// MARK: - Instance Methods

/**
 * Returns the Inverse of this Quaternion
 */
- (Quaternion *)getInverse;

/**
 * Makes sure this Quaternion is a Unit Quaternion (Length=1)
 */
- (void)makeUnitQuaternion;

/**
 * Set the Quaternion based on an Axis-Angle pair
 * @param axis The (unit-)Axis
 * @param angle The rotation Angle in radians
 */
- (void)setFromAxisAngle:(Vector3f *)axis angle:(float)angle;

/**
 * Get the Euler Angles represented by this Quaternion
 * @returns Euler angles (X=Pitch, Y=Yaw, Z=Roll)
 */
- (Vector3f *)getEulerAngles;

/**
 * Get the Euler Angles represented by this Quaternion (YXZ order)
 * @returns Euler angles (X=Pitch, Y=Yaw, Z=Roll)
 */
- (Vector3f *)getEulerAnglesYXZ;

/**
 * Get the Euler Angles represented by this Quaternion (ZXY order)
 * @returns Euler angles (X=Pitch, Y=Yaw, Z=Roll)
 */
- (Vector3f *)getEulerAnglesZXY;

/**
 * Get the Euler Angles represented by this Quaternion (ZYX order)
 * @returns Euler angles (X=Pitch, Y=Yaw, Z=Roll)
 */
- (Vector3f *)getEulerAnglesZYX;

/**
 * Rotate the passed Vector by this Quaternion
 * @param vector Vector you want to rotate
 * @returns Rotated Vector
 * @remarks Make sure the Quaternion is normalized before you rotate a Vector!
 */
- (Vector3f *)rotateVector:(Vector3f *)vector;

/**
 * Create a clone of this Quaternion
 */
- (Quaternion *)clone;

/**
 * Returns a detailed string representation for debugging
 */
- (NSString *)toLinedString;

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

@end

// MARK: - Quaternions Collection

/**
 * Type-safe NSMutableArray for Quaternion Objects
 */
@interface Quaternions : NSMutableArray<Quaternion *>

// MARK: - Indexed Access
- (Quaternion *)objectAtIndex:(NSUInteger)index;
- (Quaternion *)objectAtUnsignedIntIndex:(uint32_t)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Quaternion *)object;
- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Quaternion *)object;

// MARK: - Collection Operations
- (NSInteger)addQuaternion:(Quaternion *)item;
- (void)insertQuaternion:(Quaternion *)item atIndex:(NSUInteger)index;
- (void)removeQuaternion:(Quaternion *)item;
- (BOOL)containsQuaternion:(Quaternion *)item;

// MARK: - Properties
@property (nonatomic, readonly) NSInteger length;

// MARK: - Cloning
- (id)copy;

@end
