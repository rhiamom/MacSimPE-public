//
//  Vectors.m
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
// **************************************************************************/

#import "Vectors.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import <math.h>

// MARK: - Vector2f Implementation

@implementation Vector2f

@synthesize x = _x;
@synthesize y = _y;

- (double)x {
    if (isnan(_x)) {
        return 0;
    }
    return _x;
}

- (void)setX:(double)x {
    _x = x;
}

- (double)y {
    if (isnan(_y)) {
        return 0;
    }
    return _y;
}

- (void)setY:(double)y {
    _y = y;
}

+ (Vector2f *)zero {
    return [[Vector2f alloc] initWithX:0 y:0];
}

- (instancetype)init {
    return [self initWithX:0 y:0];
}

- (instancetype)initWithX:(double)x y:(double)y {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (double)epsilonCorrect:(double)v {
    if (fabs(v) < 0.00001) {
        return 0;
    }
    return v;
}

- (void)unserialize:(BinaryReader *)reader {
    self.x = [reader readSingle];
    self.y = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeSingle:(float)self.x];
    [writer writeSingle:(float)self.y];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%.2f; %.2f", self.x, self.y];
}

- (Vector2f *)clone {
    return [[Vector2f alloc] initWithX:self.x y:self.y];
}

@end

// MARK: - Vector3f Implementation

@implementation Vector3f

@synthesize z = _z;

- (double)z {
    if (isnan(_z)) {
        return 0;
    }
    return _z;
}

- (void)setZ:(double)z {
    _z = z;
}

- (Vector3f *)unitVector {
    Vector3f *uv = [[Vector3f alloc] init];
    
    double l = self.length;
    if (l != 0) {
        uv.x = self.x / l;
        uv.y = self.y / l;
        uv.z = self.z / l;
    }
    return uv;
}

- (double)norm {
    double n = pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2);
    return n;
}

- (double)length {
    return sqrt(self.norm);
}

+ (Vector3f *)zero {
    return [[Vector3f alloc] initWithX:0 y:0 z:0];
}

- (instancetype)init {
    return [self initWithX:0 y:0 z:0];
}

- (instancetype)initWithX:(double)x y:(double)y z:(double)z {
    self = [super initWithX:x y:y];
    if (self) {
        self.z = z;
    }
    return self;
}

- (instancetype)initWithStringArray:(NSArray<NSString *> *)dataArray {
    self = [super init];
    if (self) {
        self.x = [dataArray[0] doubleValue];
        self.y = [dataArray[1] doubleValue];
        self.z = [dataArray[2] doubleValue];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)data {
    NSArray<NSString *> *dataArray = [data componentsSeparatedByString:@" "];
    return [self initWithStringArray:dataArray];
}

- (instancetype)initWithDoubleArray:(NSArray<NSNumber *> *)data {
    self = [super init];
    if (self) {
        self.x = [data[0] doubleValue];
        self.y = [data[1] doubleValue];
        self.z = [data[2] doubleValue];
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    [super unserialize:reader];
    self.z = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [super serialize:writer];
    [writer writeSingle:(float)self.z];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; %.2f", [super description], self.z];
}

- (void)makeUnitVector {
    Vector3f *uv = self.unitVector;
    self.x = uv.x;
    self.y = uv.y;
    self.z = uv.z;
}

- (Vector3f *)getInverse {
    return [self multiplyByScalar:-1.0];
}

- (Vector3f *)add:(Vector3f *)other {
    return [[Vector3f alloc] initWithX:self.x + other.x
                                     y:self.y + other.y
                                     z:self.z + other.z];
}

- (Vector3f *)subtract:(Vector3f *)other {
    return [[Vector3f alloc] initWithX:self.x - other.x
                                     y:self.y - other.y
                                     z:self.z - other.z];
}

- (Vector3f *)multiplyByScalar:(double)scalar {
    return [[Vector3f alloc] initWithX:self.x * scalar
                                     y:self.y * scalar
                                     z:self.z * scalar];
}

- (Vector3f *)divideByScalar:(double)scalar {
    return [[Vector3f alloc] initWithX:self.x / scalar
                                     y:self.y / scalar
                                     z:self.z / scalar];
}

- (double)dotProduct:(Vector3f *)other {
    return self.x * other.x + self.y * other.y + self.z * other.z;
}

- (Vector3f *)crossProduct:(Vector3f *)other {
    return [[Vector3f alloc] initWithX:self.y * other.z - self.z * other.y
                                     y:self.z * other.x - self.x * other.z
                                     z:self.x * other.y - self.y * other.x];
}

- (BOOL)isEqualToVector:(Vector3f *)other {
    if (!other) {
        return NO;
    }
    return (self.x == other.x) && (self.y == other.y) && (self.z == other.z);
}

- (double)getComponent:(int)index {
    if (index == 0) return self.x;
    if (index == 1) return self.y;
    if (index == 2) return self.z;
    return 0;
}

- (void)setComponent:(int)index value:(double)val {
    if (index == 0) self.x = val;
    if (index == 1) self.y = val;
    if (index == 2) self.z = val;
}

- (NSString *)toString2 {
    return [NSString stringWithFormat:@"%.6f %.6f %.6f", self.x, self.y, self.z];
}

- (Vector3f *)clone {
    return [[Vector3f alloc] initWithX:self.x y:self.y z:self.z];
}

- (NSUInteger)hash {
    return [super hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Vector3f class]]) {
        return [self isEqualToVector:(Vector3f *)object];
    }
    return [super isEqual:object];
}

@end

// MARK: - Vector3i Implementation

@implementation Vector3i

- (instancetype)init {
    return [self initWithX:0 y:0 z:0];
}

- (instancetype)initWithX:(int)x y:(int)y z:(int)z {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.x = [reader readInt32];
    self.y = [reader readInt32];
    self.z = [reader readInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeInt32:self.x];
    [writer writeInt32:self.y];
    [writer writeInt32:self.z];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@",
            [Helper hexString:self.x],
            [Helper hexString:self.y],
            [Helper hexString:self.z]];
}

@end

// MARK: - Vector4f Implementation

@implementation Vector4f

@synthesize w = _w;

- (double)w {
    if (isnan(_w)) {
        return 0;
    }
    return _w;
}

- (void)setW:(double)w {
    _w = w;
}

+ (Vector4f *)zero {
    return [[Vector4f alloc] initWithX:0 y:0 z:0 w:0];
}

- (instancetype)init {
    return [self initWithX:0 y:0 z:0 w:0];
}

- (instancetype)initWithX:(double)x y:(double)y z:(double)z {
    return [self initWithX:x y:y z:z w:0];
}

- (instancetype)initWithX:(double)x y:(double)y z:(double)z w:(double)w {
    self = [super initWithX:x y:y z:z];
    if (self) {
        self.w = w;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    [super unserialize:reader];
    self.w = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [super serialize:writer];
    [writer writeSingle:(float)self.w];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %.2f", [super description], self.w];
}

- (double)getComponent:(int)index {
    if (index == 3) return self.w;
    return [super getComponent:index];
}

- (void)setComponent:(int)index value:(double)val {
    [super setComponent:index value:val];
    if (index == 3) self.w = val;
}

- (Vector4f *)clone {
    return [[Vector4f alloc] initWithX:self.x y:self.y z:self.z w:self.w];
}

@end

// MARK: - Container Classes Implementation

@implementation Vectors3i

- (Vector3i *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector3i *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3i *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector3i *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector3i:(Vector3i *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector3i:(Vector3i *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector3i:(Vector3i *)item {
    [self removeObject:item];
}

- (BOOL)containsVector3i:(Vector3i *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (id)copy {
    Vectors3i *list = [[Vectors3i alloc] init];
    for (Vector3i *item in self) {
        [list addVector3i:item];
    }
    return list;
}

@end

@implementation Vectors3f

- (Vector3f *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector3f *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3f *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector3f *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector3f:(Vector3f *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector3f:(Vector3f *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector3f:(Vector3f *)item {
    [self removeObject:item];
}

- (BOOL)containsVector3f:(Vector3f *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (id)copy {
    Vectors3f *list = [[Vectors3f alloc] init];
    for (Vector3f *item in self) {
        [list addVector3f:item];
    }
    return list;
}

@end

@implementation Vectors2f

- (Vector2f *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector2f *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector2f *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector2f *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector2f:(Vector2f *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector2f:(Vector2f *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector2f:(Vector2f *)item {
    [self removeObject:item];
}

- (BOOL)containsVector2f:(Vector2f *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (id)copy {
    Vectors2f *list = [[Vectors2f alloc] init];
    for (Vector2f *item in self) {
        [list addVector2f:item];
    }
    return list;
}

@end

@implementation Vectors4f

- (Vector4f *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector4f *)objectAtUnsignedIntIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector4f *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(Vector4f *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector4f:(Vector4f *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector4f:(Vector4f *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector4f:(Vector4f *)item {
    [self removeObject:item];
}

- (BOOL)containsVector4f:(Vector4f *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (id)copy {
    Vectors4f *list = [[Vectors4f alloc] init];
    for (Vector4f *item in self) {
        [list addVector4f:item];
    }
    return list;
}

@end
