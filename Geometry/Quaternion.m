//
//  Quaternion.m
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

#import "Quaternion.h"
#import "Vectors.h"
#import "Matrices.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import <math.h>

@interface Quaternion ()
- (instancetype)initWithType:(QuaternionParameterType)parameterType x:(double)x y:(double)y z:(double)z w:(double)w;
- (instancetype)initWithType:(QuaternionParameterType)parameterType vector:(Vector3f *)vector angle:(double)angle;
- (void)makeRobust;
- (void)doMakeRobust;
- (double)makeRobustAngle:(double)radians;
- (double)normalizeRad:(double)radians;
- (double)clip1:(double)value;
- (BOOL)isNear:(double)value near:(double)near delta:(double)delta;
- (void)loadCorrection;
@end

@implementation Quaternion

// MARK: - Internal Initializers

- (instancetype)initWithType:(QuaternionParameterType)parameterType x:(double)x y:(double)y z:(double)z w:(double)w {
    self = [super init];
    if (self) {
        if (parameterType == QuaternionParameterTypeImaginaryReal) {
            self.x = x;
            self.y = y;
            self.z = z;
            self.w = w;
        } else if (parameterType == QuaternionParameterTypeUnitAxisAngle) {
            [self setFromAxisAngle:[[Vector3f alloc] initWithX:x y:y z:z] angle:w];
        }
    }
    return self;
}

- (instancetype)initWithType:(QuaternionParameterType)parameterType vector:(Vector3f *)vector angle:(double)angle {
    self = [super init];
    if (self) {
        if (parameterType == QuaternionParameterTypeImaginaryReal) {
            self.x = vector.x;
            self.y = vector.y;
            self.z = vector.z;
            self.w = angle;
        } else if (parameterType == QuaternionParameterTypeUnitAxisAngle) {
            [self setFromAxisAngle:vector angle:angle];
        }
    }
    return self;
}

// MARK: - Public Initializers

- (instancetype)init {
    return [super init];
}

// MARK: - Properties

- (double)norm {
    double n = [self.imaginary norm] + pow(self.w, 2);
    return n;
}

- (double)length {
    return sqrt(self.norm);
}

- (Quaternion *)conjugate {
    Vector3f *negativeImaginary = [self.imaginary multiplyByScalar:-1.0];
    return [[Quaternion alloc] initWithType:QuaternionParameterTypeImaginaryReal vector:negativeImaginary angle:self.w];
}

- (Vector3f *)imaginary {
    return [[Vector3f alloc] initWithX:self.x y:self.y z:self.z];
}

- (double)angle {
    [self makeRobust];
    [self makeUnitQuaternion];
    return acos(self.w) * 2.0;
}

- (Vector3f *)axis {
    [self makeRobust];
    [self makeUnitQuaternion];
    
    double sina = sqrt(1 - pow(self.w, 2));
    
    if (sina == 0) {
        return [[Vector3f alloc] initWithX:0 y:0 z:0];
    }
    
    return [[Vector3f alloc] initWithX:(self.x / sina) y:(self.y / sina) z:(self.z / sina)];
}

- (Matrixd *)matrix {
    [self makeRobust];
    [self makeUnitQuaternion];
    
    Matrixd *m = [[Matrixd alloc] initWithRows:4 columns:4];
    double sx = pow(self.x, 2);
    double sy = pow(self.y, 2);
    double sz = pow(self.z, 2);
    
    [m setValue:(1 - 2*(sy + sz)) atRow:0 column:0];
    [m setValue:(2*(self.x * self.y - self.w * self.z)) atRow:0 column:1];
    [m setValue:(2*(self.x * self.z + self.w * self.y)) atRow:0 column:2];
    [m setValue:0 atRow:0 column:3];
    
    [m setValue:(2*(self.x * self.y + self.w * self.z)) atRow:1 column:0];
    [m setValue:(1 - 2*(sx + sz)) atRow:1 column:1];
    [m setValue:(2*(self.y * self.z - self.w * self.x)) atRow:1 column:2];
    [m setValue:0 atRow:1 column:3];
    
    [m setValue:(2*(self.x * self.z - self.w * self.y)) atRow:2 column:0];
    [m setValue:(2*(self.y * self.z + self.w * self.x)) atRow:2 column:1];
    [m setValue:(1 - 2*(sx + sy)) atRow:2 column:2];
    [m setValue:0 atRow:2 column:3];
    
    [m setValue:0 atRow:3 column:0];
    [m setValue:0 atRow:3 column:1];
    [m setValue:0 atRow:3 column:2];
    [m setValue:1 atRow:3 column:3];
    
    return m;
}

#ifdef DEBUG
- (Vector3f *)euler {
    return [self getEulerAngles];
}
#endif

// MARK: - Class Properties

+ (Quaternion *)identity {
    return [[Quaternion alloc] initWithType:QuaternionParameterTypeImaginaryReal x:0 y:0 z:0 w:1];
}

+ (Quaternion *)zero {
    return [[Quaternion alloc] initWithType:QuaternionParameterTypeImaginaryReal x:0 y:0 z:0 w:0];
}

// MARK: - Factory Methods

+ (instancetype)fromAxisAngle:(Vector3f *)axis angle:(double)angle {
    [axis makeUnitVector];
    return [[self alloc] initWithType:QuaternionParameterTypeUnitAxisAngle x:axis.x y:axis.y z:axis.z w:angle];
}

+ (instancetype)fromAxisAngleX:(double)x y:(double)y z:(double)z angle:(double)angle {
    return [[self alloc] initWithType:QuaternionParameterTypeUnitAxisAngle x:x y:y z:z w:angle];
}

+ (instancetype)fromImaginary:(Vector3f *)imaginary real:(double)w {
    return [[self alloc] initWithType:QuaternionParameterTypeImaginaryReal x:imaginary.x y:imaginary.y z:imaginary.z w:w];
}

+ (instancetype)fromImaginaryReal:(Vector4f *)vector {
    return [[self alloc] initWithType:QuaternionParameterTypeImaginaryReal x:vector.x y:vector.y z:vector.z w:vector.w];
}

+ (instancetype)fromImaginaryRealX:(double)x y:(double)y z:(double)z w:(double)w {
    return [[self alloc] initWithType:QuaternionParameterTypeImaginaryReal x:x y:y z:z w:w];
}

+ (instancetype)fromEulerAngles:(Vector3f *)eulerAngles {
    Matrixd *rotZ = [Matrixd rotateZ:eulerAngles.z];
    Matrixd *rotY = [Matrixd rotateY:eulerAngles.y];
    Matrixd *rotX = [Matrixd rotateX:eulerAngles.x];
    Matrixd *rotation = [[rotZ multiplyByMatrix:rotY] multiplyByMatrix:rotX];
    return [self fromRotationMatrix:rotation];
}

+ (instancetype)fromEulerAnglesYaw:(double)yaw pitch:(double)pitch roll:(double)roll {
    Vector3f *euler = [[Vector3f alloc] initWithX:pitch y:yaw z:roll];
    return [self fromEulerAngles:euler];
}

+ (instancetype)fromRotationMatrix:(Matrixd *)rotationMatrix {
    double x = 0, y = 0, z = 0, w = 0;
    
    double trace = [rotationMatrix trace];
    if (trace > 0) {
        w = sqrt(trace) / 2;
        x = ([rotationMatrix valueAtRow:2 column:1] - [rotationMatrix valueAtRow:1 column:2]) / (4 * w);
        y = ([rotationMatrix valueAtRow:0 column:2] - [rotationMatrix valueAtRow:2 column:0]) / (4 * w);
        z = ([rotationMatrix valueAtRow:1 column:0] - [rotationMatrix valueAtRow:0 column:1]) / (4 * w);
    } else {
        double r00 = [rotationMatrix valueAtRow:0 column:0];
        double r11 = [rotationMatrix valueAtRow:1 column:1];
        double r22 = [rotationMatrix valueAtRow:2 column:2];
        
        if (r00 >= r11 && r00 >= r22) {
            x = sqrt(r00 - r11 - r22 + 1) / 2;
            w = ([rotationMatrix valueAtRow:1 column:2] - [rotationMatrix valueAtRow:2 column:1]) / (4 * x);
            y = ([rotationMatrix valueAtRow:0 column:1] - [rotationMatrix valueAtRow:1 column:0]) / (4 * x);
            z = ([rotationMatrix valueAtRow:2 column:0] - [rotationMatrix valueAtRow:0 column:2]) / (4 * x);
        } else if (r11 >= r00 && r11 >= r22) {
            y = sqrt(r11 - r00 - r22 + 1) / 2;
            w = ([rotationMatrix valueAtRow:2 column:0] - [rotationMatrix valueAtRow:0 column:2]) / (4 * y);
            x = ([rotationMatrix valueAtRow:0 column:1] - [rotationMatrix valueAtRow:1 column:0]) / (4 * y);
            z = ([rotationMatrix valueAtRow:1 column:2] - [rotationMatrix valueAtRow:2 column:1]) / (4 * y);
        } else if (r22 >= r00 && r22 >= r11) {
            z = sqrt(r22 - r00 - r11 + 1) / 2;
            w = ([rotationMatrix valueAtRow:0 column:1] - [rotationMatrix valueAtRow:1 column:0]) / (4 * z);
            x = ([rotationMatrix valueAtRow:2 column:0] - [rotationMatrix valueAtRow:0 column:2]) / (4 * z);
            y = ([rotationMatrix valueAtRow:1 column:2] - [rotationMatrix valueAtRow:2 column:1]) / (4 * z);
        }
    }
    
    Quaternion *result = [Quaternion fromImaginaryRealX:x y:y z:z w:w];
    [result makeRobust];
    [result makeUnitQuaternion];
    return result;
}

// MARK: - Angle Conversion Utilities

+ (double)radiansToDegrees:(double)radians {
    return (radians * 180.0) / M_PI;
}

+ (double)degreesToRadians:(double)degrees {
    return (degrees * M_PI) / 180.0;
}

// MARK: - Quaternion Operations

+ (Quaternion *)multiply:(Quaternion *)q1 by:(Quaternion *)q2 {
    Vector3f *q1Imaginary = q1.imaginary;
    Vector3f *q2Imaginary = q2.imaginary;
    
    Vector3f *crossProduct = [q1Imaginary crossProduct:q2Imaginary];
    Vector3f *q2ScaledByQ1W = [q1Imaginary multiplyByScalar:q2.w];
    Vector3f *q1ScaledByQ2W = [q2Imaginary multiplyByScalar:q1.w];
    
    Vector3f *imaginaryResult = [[crossProduct addVector:q2ScaledByQ1W] addVector:q1ScaledByQ2W];
    double realResult = q1.w * q2.w - [q1Imaginary dotProduct:q2Imaginary];
    
    return [Quaternion fromImaginary:imaginaryResult real:realResult];
}

+ (Quaternion *)multiplyQuaternion:(Quaternion *)quaternion byScalar:(double)scalar {
    Vector3f *scaledImaginary = [quaternion.imaginary multiplyByScalar:scalar];
    return [Quaternion fromImaginary:scaledImaginary real:(quaternion.w * scalar)];
}

+ (Quaternion *)add:(Quaternion *)q1 to:(Quaternion *)q2 {
    Vector3f *imaginarySum = [q1.imaginary addVector:q2.imaginary];
    return [Quaternion fromImaginary:imaginarySum real:(q1.w + q2.w)];
}

+ (double)dotProduct:(Quaternion *)q1 with:(Quaternion *)q2 {
    return q1.w * q2.w + [q1.imaginary dotProduct:q2.imaginary];
}

+ (Quaternion *)crossProduct:(Quaternion *)q1 with:(Quaternion *)q2 {
    Vector3f *crossResult = [q2.imaginary crossProduct:q1.imaginary];
    return [Quaternion fromImaginary:crossResult real:0];
}

// MARK: - Instance Methods

- (Quaternion *)getInverse {
    return [Quaternion multiplyQuaternion:self.conjugate byScalar:(1.0 / self.norm)];
}

- (void)makeUnitQuaternion {
    double length = self.length;
    if (length != 0) {
        self.x = self.x / length;
        self.y = self.y / length;
        self.z = self.z / length;
        self.w = self.w / length;
    }
}

- (void)setFromAxisAngle:(Vector3f *)axis angle:(double)angle {
    [axis makeUnitVector];
    
    double sina = sin(angle / 2.0);
    self.x = axis.x * sina;
    self.y = axis.y * sina;
    self.z = axis.z * sina;
    
    self.w = cos(angle / 2.0);
    [self makeRobust];
    [self makeUnitQuaternion];
}

- (Vector3f *)getEulerAngles {
    Quaternion *q = [self clone];
    [q doMakeRobust];
    Vector3f *v = [q getEulerAnglesZYX];
    
    v.x = [self makeRobustAngle:v.x];
    v.y = [self makeRobustAngle:v.y];
    v.z = [self makeRobustAngle:v.z];
    return v;
}

- (Vector3f *)getEulerAnglesYXZ {
    Matrixd *m = self.matrix;
    Vector3f *v = [[Vector3f alloc] initWithX:0 y:0 z:0];
    
    v.x = asin(-[self clip1:[m valueAtRow:1 column:2]]);
    if (v.x < M_PI / 2.0) {
        if (v.x > -M_PI / 2.0) {
            v.y = atan2([self clip1:[m valueAtRow:0 column:2]], [self clip1:[m valueAtRow:2 column:2]]);
            v.z = atan2([self clip1:[m valueAtRow:1 column:0]], [self clip1:[m valueAtRow:1 column:1]]);
        } else {
            v.y = -1 * atan2(-[self clip1:[m valueAtRow:0 column:1]], [self clip1:[m valueAtRow:0 column:0]]);
        }
    } else {
        v.y = atan2(-[self clip1:[m valueAtRow:0 column:1]], [self clip1:[m valueAtRow:0 column:0]]);
    }
    
    return v;
}

- (Vector3f *)getEulerAnglesZXY {
    Matrixd *m = self.matrix;
    Vector3f *v = [[Vector3f alloc] initWithX:0 y:0 z:0];
    
    v.x = asin([m valueAtRow:2 column:1]);
    if (v.x < M_PI / 2.0) {
        if (v.x > -M_PI / 2.0) {
            v.z = atan2(-[m valueAtRow:0 column:1], [m valueAtRow:1 column:1]);
            v.y = atan2(-[m valueAtRow:2 column:0], [m valueAtRow:2 column:2]);
        } else {
            v.z = -1 * atan2(-[m valueAtRow:0 column:2], [m valueAtRow:0 column:0]);
        }
    } else {
        v.z = atan2([m valueAtRow:0 column:2], [m valueAtRow:0 column:0]);
    }
    
    return v;
}

- (Vector3f *)getEulerAnglesZYX {
    Matrixd *m = self.matrix;
    Vector3f *v = [[Vector3f alloc] initWithX:0 y:0 z:0];
    
    v.y = asin(-[m valueAtRow:2 column:0]);
    if (v.y < M_PI / 2.0) {
        if (v.y > -M_PI / 2.0) {
            v.z = atan2([m valueAtRow:1 column:0], [m valueAtRow:0 column:0]);
            v.x = atan2([m valueAtRow:2 column:1], [m valueAtRow:2 column:2]);
        } else {
            v.z = -1 * atan2(-[m valueAtRow:0 column:1], [m valueAtRow:0 column:2]);
        }
    } else {
        v.z = atan2(-[m valueAtRow:0 column:1], [m valueAtRow:0 column:2]);
    }
    
    return v;
}

- (Vector3f *)rotateVector:(Vector3f *)vector {
    Quaternion *vq = [[Quaternion alloc] initWithType:QuaternionParameterTypeImaginaryReal x:vector.x y:vector.y z:vector.z w:0];
    Quaternion *result = [Quaternion multiply:self by:[Quaternion multiply:vq by:self.conjugate]];
    return [[Vector3f alloc] initWithX:result.x y:result.y z:result.z];
}

- (Quaternion *)clone {
    Quaternion *q = [[Quaternion alloc] initWithType:QuaternionParameterTypeImaginaryReal x:self.x y:self.y z:self.z w:self.w];
    return q;
}

- (NSString *)toLinedString {
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"X: %f\n", self.x];
    [s appendFormat:@"Y: %f\n", self.y];
    [s appendFormat:@"Z: %f\n", self.z];
    [s appendFormat:@"W: %f\n", self.w];
    [s appendString:@"-----\n"];
    [s appendFormat:@"X: %f\n", self.axis.x];
    [s appendFormat:@"Y: %f\n", self.axis.y];
    [s appendFormat:@"Z: %f\n", self.axis.z];
    [s appendFormat:@"A: %f\n", [Quaternion radiansToDegrees:self.angle]];
    [s appendString:@"-----\n"];
    Vector3f *euler = [self getEulerAngles];
    [s appendFormat:@"Y: %f\n", [Quaternion radiansToDegrees:euler.y]];
    [s appendFormat:@"P: %f\n", [Quaternion radiansToDegrees:euler.x]];
    [s appendFormat:@"R: %f\n", [Quaternion radiansToDegrees:euler.z]];
    return s;
}

- (NSString *)description {
    Vector3f *axis = self.axis;
    Vector3f *euler = [self getEulerAngles];
    return [NSString stringWithFormat:@"%@ (X=%.2f, Y=%.2f, Z=%.2f, a=%.1f    euler=y:%.1f; p:%.1f; r:%.1f)",
            [super description],
            axis.x, axis.y, axis.z,
            [Quaternion radiansToDegrees:self.angle],
            [Quaternion radiansToDegrees:euler.y],
            [Quaternion radiansToDegrees:euler.x],
            [Quaternion radiansToDegrees:euler.z]];
}

// MARK: - Private Helper Methods

- (void)makeRobust {
    // Implementation placeholder - complex mathematical robustness checks
}

- (void)doMakeRobust {
    // Implementation placeholder - robust mathematical corrections
}

- (double)makeRobustAngle:(double)radians {
    return radians; // Simplified - original had complex robustness logic
}

- (double)normalizeRad:(double)radians {
    while (radians > M_PI) radians -= 2 * M_PI;
    while (radians < -M_PI) radians += 2 * M_PI;
    return radians;
}

- (double)clip1:(double)value {
    if (value < -1) return -1;
    if (value > 1) return 1;
    return value;
}

- (BOOL)isNear:(double)value near:(double)near delta:(double)delta {
    return (fabs(fabs(value) - near) < delta);
}

- (void)loadCorrection {
    // Original C# had coordinate system corrections for file format compatibility
    // Implementation would depend on specific coordinate system requirements
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    [super unserialize:reader];
    [self loadCorrection];
}

- (void)serialize:(BinaryWriter *)writer {
    [self loadCorrection];
    [super serialize:writer];
    [self loadCorrection];
}

@end

// MARK: - Quaternions Collection Implementation

@implementation Quaternions

- (Quaternion *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Quaternion *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Quaternion *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Quaternion *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addQuaternion:(Quaternion *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertQuaternion:(Quaternion *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeQuaternion:(Quaternion *)item {
    [self removeObject:item];
}

- (BOOL)containsQuaternion:(Quaternion *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (id)copy {
    Quaternions *cloned = [[Quaternions alloc] init];
    for (Quaternion *quaternion in self) {
        [cloned addQuaternion:[quaternion clone]];
    }
    return cloned;
}

@end
