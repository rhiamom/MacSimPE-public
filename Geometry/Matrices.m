//
//  Matrices.m
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

#import "Matrices.h"
#import "Vectors.h"
#import <math.h>

// MARK: - GeometryException Implementation

@implementation GeometryException

+ (instancetype)exceptionWithReason:(NSString *)reason {
    return [GeometryException exceptionWithName:@"GeometryException"
                                         reason:reason
                                       userInfo:nil];
}

@end

// MARK: - Matrixd Implementation

@interface Matrixd ()
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *matrixData;
@end

@implementation Matrixd

// MARK: - Initialization

- (instancetype)initWithRows:(NSInteger)rows columns:(NSInteger)columns {
    self = [super init];
    if (self) {
        if (rows < 1) rows = 1;
        if (columns < 1) columns = 1;
        
        _matrixData = [[NSMutableArray alloc] initWithCapacity:rows];
        for (NSInteger i = 0; i < rows; i++) {
            NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:columns];
            for (NSInteger j = 0; j < columns; j++) {
                [row addObject:@0.0];
            }
            [_matrixData addObject:row];
        }
    }
    return self;
}

- (instancetype)initWithVector3f:(Vector3f *)vector {
    self = [self initWithRows:3 columns:1];
    if (self) {
        [self setValue:vector.x atRow:0 column:0];
        [self setValue:vector.y atRow:1 column:0];
        [self setValue:vector.z atRow:2 column:0];
    }
    return self;
}

- (instancetype)initWithVector4f:(Vector4f *)vector {
    self = [self initWithRows:4 columns:1];
    if (self) {
        [self setValue:vector.x atRow:0 column:0];
        [self setValue:vector.y atRow:1 column:0];
        [self setValue:vector.z atRow:2 column:0];
        [self setValue:vector.w atRow:3 column:0];
    }
    return self;
}

// MARK: - Properties

- (NSInteger)rows {
    return self.matrixData.count;
}

- (NSInteger)columns {
    if (self.rows == 0) return 0;
    return self.matrixData[0].count;
}

- (double)trace {
    if (self.rows != self.columns) {
        @throw [GeometryException exceptionWithReason:[NSString stringWithFormat:@"Unable to get Trace for a non Square Matrix (%@)", self]];
    }
    
    double result = 0;
    for (NSInteger i = 0; i < self.rows; i++) {
        result += [self valueAtRow:i column:i];
    }
    return result;
}

- (BOOL)isIdentity {
    if (self.rows != self.columns) return NO;
    
    for (NSInteger i = 0; i < self.rows; i++) {
        for (NSInteger j = 0; j < self.columns; j++) {
            double expected = (i == j) ? 1.0 : 0.0;
            if ([self valueAtRow:i column:j] != expected) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)isInvertible {
    return ([self determinant] != 0);
}

- (BOOL)isOrthogonal {
    if (self.rows != self.columns) return NO;
    
    Matrixd *transpose = [self getTranspose];
    Matrixd *product1 = [self multiplyByMatrix:transpose];
    if (![product1 isIdentity]) return NO;
    
    Matrixd *product2 = [transpose multiplyByMatrix:self];
    if (![product2 isIdentity]) return NO;
    
    return YES;
}

// MARK: - Element Access

- (double)valueAtRow:(NSInteger)row column:(NSInteger)column {
    return [self.matrixData[row][column] doubleValue];
}

- (void)setValue:(double)value atRow:(NSInteger)row column:(NSInteger)column {
    self.matrixData[row][column] = @(value);
}

// MARK: - Vector Conversion

- (Vector3f *)getVector {
    if ((self.rows != 3 || self.columns != 1) && (self.rows != 1 || self.columns != 3)) {
        return nil;
    }
    
    if (self.rows == 3) {
        return [[Vector3f alloc] initWithX:[self valueAtRow:0 column:0]
                                         y:[self valueAtRow:1 column:0]
                                         z:[self valueAtRow:2 column:0]];
    } else {
        return [[Vector3f alloc] initWithX:[self valueAtRow:0 column:0]
                                         y:[self valueAtRow:0 column:1]
                                         z:[self valueAtRow:0 column:2]];
    }
}

- (Vector4f *)getVector4 {
    if ((self.rows != 4 || self.columns != 1) && (self.rows != 1 || self.columns != 4)) {
        return nil;
    }
    
    if (self.rows == 4) {
        return [[Vector4f alloc] initWithX:[self valueAtRow:0 column:0]
                                         y:[self valueAtRow:1 column:0]
                                         z:[self valueAtRow:2 column:0]
                                         w:[self valueAtRow:3 column:0]];
    } else {
        return [[Vector4f alloc] initWithX:[self valueAtRow:0 column:0]
                                         y:[self valueAtRow:0 column:1]
                                         z:[self valueAtRow:0 column:2]
                                         w:[self valueAtRow:0 column:3]];
    }
}

// MARK: - Matrix Operations

- (Matrixd *)getTranspose {
    Matrixd *result = [[Matrixd alloc] initWithRows:self.columns columns:self.rows];
    
    for (NSInteger r = 0; r < self.rows; r++) {
        for (NSInteger c = 0; c < self.columns; c++) {
            [result setValue:[self valueAtRow:r column:c] atRow:c column:r];
        }
    }
    
    return result;
}

- (Matrixd *)getInverse {
    if ([self determinant] == 0) {
        @throw [GeometryException exceptionWithReason:@"Attempt to invert a singular matrix."];
    }
    
    // Inverse of a 2x2 matrix
    if (self.rows == 2 && self.columns == 2) {
        Matrixd *tempMatrix = [[Matrixd alloc] initWithRows:2 columns:2];
        
        [tempMatrix setValue:[self valueAtRow:1 column:1] atRow:0 column:0];
        [tempMatrix setValue:-[self valueAtRow:0 column:1] atRow:0 column:1];
        [tempMatrix setValue:-[self valueAtRow:1 column:0] atRow:1 column:0];
        [tempMatrix setValue:[self valueAtRow:0 column:0] atRow:1 column:1];
        
        return [tempMatrix divideByScalar:[self determinant]];
    }
    
    return [[self adjoint] divideByScalar:[self determinant]];
}

- (double)determinant {
    if (self.rows != self.columns) {
        @throw [GeometryException exceptionWithReason:[NSString stringWithFormat:@"You can only compute the Determinant of a Square Matrix. (%@)", self]];
    }
    
    double d = 0;
    
    // Get the determinant of a 2x2 matrix
    if (self.rows == 2 && self.columns == 2) {
        d = ([self valueAtRow:0 column:0] * [self valueAtRow:1 column:1]) -
        ([self valueAtRow:0 column:1] * [self valueAtRow:1 column:0]);
        return d;
    }
    
    // Get the determinant of a 3x3 matrix
    if (self.rows == 3 && self.columns == 3) {
        d = ([self valueAtRow:0 column:0] * [self valueAtRow:1 column:1] * [self valueAtRow:2 column:2])
        + ([self valueAtRow:0 column:1] * [self valueAtRow:1 column:2] * [self valueAtRow:2 column:0])
        + ([self valueAtRow:0 column:2] * [self valueAtRow:1 column:0] * [self valueAtRow:2 column:1])
        - ([self valueAtRow:0 column:2] * [self valueAtRow:1 column:1] * [self valueAtRow:2 column:0])
        - ([self valueAtRow:0 column:1] * [self valueAtRow:1 column:0] * [self valueAtRow:2 column:2])
        - ([self valueAtRow:0 column:0] * [self valueAtRow:1 column:2] * [self valueAtRow:2 column:1]);
        return d;
    }
    
    // Find the determinant with respect to the first row
    for (NSInteger j = 0; j < self.columns; j++) {
        Matrixd *tempMatrix = [self minorWithRow:0 column:j];
        // Recursively add the determinants
        d += pow(-1, j) * [self valueAtRow:0 column:j] * [tempMatrix determinant];
    }
    
    return d;
}

- (Matrixd *)adjoint {
    if (self.rows < 2 || self.columns < 2) {
        @throw [GeometryException exceptionWithReason:[NSString stringWithFormat:@"Adjoint matrix is not available. (%@)", self]];
    }
    
    Matrixd *adjMatrix = [[Matrixd alloc] initWithRows:self.columns columns:self.rows];
    
    for (NSInteger i = 0; i < self.rows; i++) {
        for (NSInteger j = 0; j < self.columns; j++) {
            Matrixd *tempMatrix = [self minorWithRow:i column:j];
            // Put the determinant of the minor in the transposed position
            [adjMatrix setValue:(pow(-1, i + j) * [tempMatrix determinant]) atRow:j column:i];
        }
    }
    
    return adjMatrix;
}

- (Matrixd *)minorWithRow:(NSInteger)row column:(NSInteger)column {
    if (self.rows < 2 || self.columns < 2) {
        @throw [GeometryException exceptionWithReason:[NSString stringWithFormat:@"Minor not available. (%@)", self]];
    }
    
    Matrixd *minor = [[Matrixd alloc] initWithRows:(self.rows - 1) columns:(self.columns - 1)];
    
    // Find the minor with respect to the specified element
    for (NSInteger k = 0; k < minor.rows; k++) {
        NSInteger i = (k >= row) ? k + 1 : k;
        
        for (NSInteger l = 0; l < minor.columns; l++) {
            NSInteger j = (l >= column) ? l + 1 : l;
            [minor setValue:[self valueAtRow:i column:j] atRow:k column:l];
        }
    }
    
    return minor;
}

- (Matrixd *)to33Matrix {
    Matrixd *result = [Matrixd identityWithRows:3 columns:3];
    
    NSInteger maxRows = MIN(3, self.rows);
    NSInteger maxCols = MIN(3, self.columns);
    
    for (NSInteger r = 0; r < maxRows; r++) {
        for (NSInteger c = 0; c < maxCols; c++) {
            [result setValue:[self valueAtRow:r column:c] atRow:r column:c];
        }
    }
    
    return result;
}

// MARK: - Matrix Arithmetic

- (Matrixd *)multiplyByMatrix:(Matrixd *)other {
    if (self.columns != other.rows) {
        @throw [GeometryException exceptionWithReason:[NSString stringWithFormat:@"Unable to multiplicate Matrices (%@ * %@)", self, other]];
    }
    
    Matrixd *result = [[Matrixd alloc] initWithRows:self.rows columns:other.columns];
    
    for (NSInteger r = 0; r < result.rows; r++) {
        for (NSInteger c = 0; c < result.columns; c++) {
            double sum = 0;
            
            for (NSInteger i = 0; i < self.columns; i++) {
                sum += [self valueAtRow:r column:i] * [other valueAtRow:i column:c];
            }
            
            [result setValue:sum atRow:r column:c];
        }
    }
    
    return result;
}

- (Matrixd *)multiplyByScalar:(double)scalar {
    Matrixd *result = [[Matrixd alloc] initWithRows:self.rows columns:self.columns];
    
    for (NSInteger r = 0; r < self.rows; r++) {
        for (NSInteger c = 0; c < self.columns; c++) {
            [result setValue:([self valueAtRow:r column:c] * scalar) atRow:r column:c];
        }
    }
    
    return result;
}

- (Matrixd *)divideByScalar:(double)scalar {
    if (scalar == 0) {
        @throw [GeometryException exceptionWithReason:@"Unable to divide by Zero."];
    }
    
    return [self multiplyByScalar:(1.0 / scalar)];
}

- (Matrixd *)addMatrix:(Matrixd *)other {
    if (self.rows != other.rows || self.columns != other.columns) {
        @throw [GeometryException exceptionWithReason:@"Attempt to add matrixes of different sizes."];
    }
    
    Matrixd *result = [[Matrixd alloc] initWithRows:self.rows columns:self.columns];
    
    for (NSInteger i = 0; i < self.rows; i++) {
        for (NSInteger j = 0; j < self.columns; j++) {
            [result setValue:([self valueAtRow:i column:j] + [other valueAtRow:i column:j])
                       atRow:i column:j];
        }
    }
    
    return result;
}

- (Matrixd *)subtractMatrix:(Matrixd *)other {
    if (self.rows != other.rows || self.columns != other.columns) {
        @throw [GeometryException exceptionWithReason:@"Attempt to subtract matrixes of different sizes."];
    }
    
    Matrixd *result = [[Matrixd alloc] initWithRows:self.rows columns:self.columns];
    
    for (NSInteger i = 0; i < self.rows; i++) {
        for (NSInteger j = 0; j < self.columns; j++) {
            [result setValue:([self valueAtRow:i column:j] - [other valueAtRow:i column:j])
                       atRow:i column:j];
        }
    }
    
    return result;
}

- (Matrixd *)powerOf:(NSInteger)power {
    if (self.rows != self.columns) {
        @throw [GeometryException exceptionWithReason:@"Attempt to find the power of a non square matrix"];
    }
    
    Matrixd *result = self;
    
    for (NSInteger i = 1; i < power; i++) {
        result = [result multiplyByMatrix:self];
    }
    
    return result;
}

// MARK: - Vector Operations

- (Vector3f *)multiplyByVector3f:(Vector3f *)vector {
    Matrixd *vectorMatrix = [[Matrixd alloc] initWithVector3f:vector];
    Matrixd *result = [self multiplyByMatrix:vectorMatrix];
    return [result getVector];
}

- (Vector4f *)multiplyByVector4f:(Vector4f *)vector {
    Matrixd *vectorMatrix = [[Matrixd alloc] initWithVector4f:vector];
    Matrixd *result = [self multiplyByMatrix:vectorMatrix];
    return [result getVector4];
}

// MARK: - Class Factory Methods

+ (instancetype)identityWithRows:(NSInteger)rows columns:(NSInteger)columns {
    Matrixd *identity = [[Matrixd alloc] initWithRows:rows columns:columns];
    
    for (NSInteger r = 0; r < rows; r++) {
        for (NSInteger c = 0; c < columns; c++) {
            double value = (r == c) ? 1.0 : 0.0;
            [identity setValue:value atRow:r column:c];
        }
    }
    
    return identity;
}

+ (instancetype)translation:(Vector3f *)vector {
    return [self translationX:vector.x y:vector.y z:vector.z];
}

+ (instancetype)translationX:(double)x y:(double)y z:(double)z {
    Matrixd *matrix = [[Matrixd alloc] initWithRows:4 columns:4];
    
    [matrix setValue:1 atRow:0 column:0]; [matrix setValue:0 atRow:0 column:1]; [matrix setValue:0 atRow:0 column:2]; [matrix setValue:x atRow:0 column:3];
    [matrix setValue:0 atRow:1 column:0]; [matrix setValue:1 atRow:1 column:1]; [matrix setValue:0 atRow:1 column:2]; [matrix setValue:y atRow:1 column:3];
    [matrix setValue:0 atRow:2 column:0]; [matrix setValue:0 atRow:2 column:1]; [matrix setValue:1 atRow:2 column:2]; [matrix setValue:z atRow:2 column:3];
    [matrix setValue:0 atRow:3 column:0]; [matrix setValue:0 atRow:3 column:1]; [matrix setValue:0 atRow:3 column:2]; [matrix setValue:1 atRow:3 column:3];
    
    return matrix;
}

+ (instancetype)scale:(double)scale {
    return [self scaleX:scale y:scale z:scale];
}

+ (instancetype)scaleX:(double)x y:(double)y z:(double)z {
    Matrixd *matrix = [[Matrixd alloc] initWithRows:4 columns:4];
    
    [matrix setValue:x atRow:0 column:0]; [matrix setValue:0 atRow:0 column:1]; [matrix setValue:0 atRow:0 column:2]; [matrix setValue:0 atRow:0 column:3];
    [matrix setValue:0 atRow:1 column:0]; [matrix setValue:y atRow:1 column:1]; [matrix setValue:0 atRow:1 column:2]; [matrix setValue:0 atRow:1 column:3];
    [matrix setValue:0 atRow:2 column:0]; [matrix setValue:0 atRow:2 column:1]; [matrix setValue:z atRow:2 column:2]; [matrix setValue:0 atRow:2 column:3];
    [matrix setValue:0 atRow:3 column:0]; [matrix setValue:0 atRow:3 column:1]; [matrix setValue:0 atRow:3 column:2]; [matrix setValue:1 atRow:3 column:3];
    
    return matrix;
}

+ (instancetype)rotateYaw:(double)yaw pitch:(double)pitch roll:(double)roll {
    Matrixd *rotY = [self rotateY:yaw];
    Matrixd *rotX = [self rotateX:pitch];
    Matrixd *rotZ = [self rotateZ:roll];
    return [[rotY multiplyByMatrix:rotX] multiplyByMatrix:rotZ];
}

+ (instancetype)rotateX:(double)angle {
    Matrixd *matrix = [self identityWithRows:4 columns:4];
    
    [matrix setValue:cos(angle) atRow:1 column:1];
    [matrix setValue:-sin(angle) atRow:1 column:2];
    [matrix setValue:sin(angle) atRow:2 column:1];
    [matrix setValue:cos(angle) atRow:2 column:2];
    
    return matrix;
}

+ (instancetype)rotateY:(double)angle {
    Matrixd *matrix = [self identityWithRows:4 columns:4];
    
    [matrix setValue:cos(angle) atRow:0 column:0];
    [matrix setValue:sin(angle) atRow:0 column:2];
    [matrix setValue:-sin(angle) atRow:2 column:0];
    [matrix setValue:cos(angle) atRow:2 column:2];
    
    return matrix;
}

+ (instancetype)rotateZ:(double)angle {
    Matrixd *matrix = [self identityWithRows:4 columns:4];
    
    [matrix setValue:cos(angle) atRow:0 column:0];
    [matrix setValue:-sin(angle) atRow:0 column:1];
    [matrix setValue:sin(angle) atRow:1 column:0];
    [matrix setValue:cos(angle) atRow:1 column:1];
    
    return matrix;
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%ldx%ld-Matrix", (long)self.rows, (long)self.columns];
}

- (NSString *)stringWithFull:(BOOL)full {
    if (!full) return [self description];
    
    NSMutableString *s = [[NSMutableString alloc] init];
    
    for (NSInteger r = 0; r < self.rows; r++) {
        for (NSInteger c = 0; c < self.columns; c++) {
            [s appendFormat:@"%.3f | ", [self valueAtRow:r column:c]];
        }
        [s appendString:@"\n"];
    }
    
    return s;
}

// MARK: - NSObject Overrides

- (NSUInteger)hash {
    double result = 0;
    
    for (NSInteger i = 0; i < self.rows; i++) {
        for (NSInteger j = 0; j < self.columns; j++) {
            result += [self valueAtRow:i column:j];
        }
    }
    
    return (NSUInteger)result;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Matrixd class]]) return NO;
    
    Matrixd *other = (Matrixd *)object;
    if (self.rows != other.rows || self.columns != other.columns) return NO;
    
    for (NSInteger i = 0; i < self.rows; i++) {
        for (NSInteger j = 0; j < self.columns; j++) {
            if ([self valueAtRow:i column:j] != [other valueAtRow:i column:j]) {
                return NO;
            }
        }
    }
    
    return YES;
}

@end
