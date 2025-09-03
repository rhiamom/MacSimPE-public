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
// ***************************************************************************

#import "Vectors.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"

@interface Vector2 ()
{
    double _x;
    double _y;
}
@end

@interface Vector3 ()
{
    double _z;
}
@end

@interface Vector4 ()
{
    double _w;
}
@end

@interface Vector3i ()
{
    int32_t _x;
    int32_t _y;
    int32_t _z;
}
@end

@implementation Vector2

// MARK: - Property Accessors

- (void)setX:(double)x {
    _x = isnan(x) ? 0.0 : x;
}

- (void)setY:(double)y {
    _y = isnan(y) ? 0.0 : y;
}

- (double)x {
    return isnan(_x) ? 0.0 : _x;
}

- (double)y {
    return isnan(_y) ? 0.0 : _y;
}

// MARK: - Class Methods

+ (Vector2 *)zero {
    return [[Vector2 alloc] initWithX:0.0 y:0.0];
}

// MARK: - Initialization

- (instancetype)init {
    return [self initWithX:0.0 y:0.0];
}

- (instancetype)initWithX:(double)x y:(double)y {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[Vector2 allocWithZone:zone] initWithX:self.x y:self.y];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    self.x = [reader readSingle];
    self.y = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeSingle:(float)self.x];
    [writer writeSingle:(float)self.y];
}

// MARK: - Operations

- (Vector2 *)clone {
    return [[Vector2 alloc] initWithX:self.x y:self.y];
}

- (Vector2 *)add:(Vector2 *)other {
    return [[Vector2 alloc] initWithX:self.x + other.x y:self.y + other.y];
}

- (Vector2 *)subtract:(Vector2 *)other {
    return [[Vector2 alloc] initWithX:self.x - other.x y:self.y - other.y];
}

- (Vector2 *)multiplyByScalar:(double)scalar {
    return [[Vector2 alloc] initWithX:self.x * scalar y:self.y * scalar];
}

- (Vector2 *)divideByScalar:(double)scalar {
    return [[Vector2 alloc] initWithX:self.x / scalar y:self.y / scalar];
}

- (double)dotProduct:(Vector2 *)other {
    return self.x * other.x + self.y * other.y;
}

// MARK: - Utility

- (double)epsilonCorrect:(double)value {
    if (fabs(value) < 0.00001) {
        return 0.0;
    }
    return value;
}

// MARK: - Comparison

- (BOOL)isEqualToVector:(Vector2 *)other {
    if (other == nil) return NO;
    return (self.x == other.x) && (self.y == other.y);
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Vector2 class]]) return NO;
    return [self isEqualToVector:object];
}

- (NSUInteger)hash {
    NSUInteger xHash = [[NSNumber numberWithDouble:self.x] hash];
    NSUInteger yHash = [[NSNumber numberWithDouble:self.y] hash];
    return xHash ^ (yHash << 1);
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%.2f; %.2f", self.x, self.y];
}

@end


@implementation Vector3

// MARK: - Property Accessors

- (void)setZ:(double)z {
    _z = isnan(z) ? 0.0 : z;
}

- (double)z {
    return isnan(_z) ? 0.0 : _z;
}

- (Vector3 *)unitVector {
    Vector3 *uv = [[Vector3 alloc] init];
    
    double l = self.length;
    if (l != 0) {
        uv.x = self.x / l;
        uv.y = self.y / l;
        uv.z = self.z / l;
    }
    
    return uv;
}

- (double)norm {
    return pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2);
}

- (double)length {
    return sqrt(self.norm);
}

// MARK: - Class Methods

+ (Vector3 *)zero {
    return [[Vector3 alloc] initWithX:0.0 y:0.0 z:0.0];
}

// MARK: - Initialization

- (instancetype)init {
    return [self initWithX:0.0 y:0.0 z:0.0];
}

- (instancetype)initWithX:(double)x y:(double)y z:(double)z {
    self = [super initWithX:x y:y];
    if (self) {
        self.z = z;
    }
    return self;
}

- (instancetype)initWithStringArray:(NSArray<NSString *> *)dataArray {
    if (dataArray.count < 3) {
        return [self init];
    }
    
    double x = [dataArray[0] doubleValue];
    double y = [dataArray[1] doubleValue];
    double z = [dataArray[2] doubleValue];
    
    return [self initWithX:x y:y z:z];
}

- (instancetype)initWithString:(NSString *)data {
    NSArray<NSString *> *components = [data componentsSeparatedByString:@" "];
    return [self initWithStringArray:components];
}

- (instancetype)initWithDoubleArray:(NSArray<NSNumber *> *)data {
    if (data.count < 3) {
        return [self init];
    }
    
    double x = data[0].doubleValue;
    double y = data[1].doubleValue;
    double z = data[2].doubleValue;
    
    return [self initWithX:x y:y z:z];
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[Vector3 allocWithZone:zone] initWithX:self.x y:self.y z:self.z];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    [super unserialize:reader];
    self.z = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [super serialize:writer];
    [writer writeSingle:(float)self.z];
}

// MARK: - Operations

- (Vector3 *)clone {
    return [[Vector3 alloc] initWithX:self.x y:self.y z:self.z];
}

- (void)makeUnitVector {
    Vector3 *uv = self.unitVector;
    self.x = uv.x;
    self.y = uv.y;
    self.z = uv.z;
}

- (Vector3 *)getInverse {
    return [self multiplyByScalar:-1.0];
}

- (Vector3 *)add:(Vector3 *)other {
    return [[Vector3 alloc] initWithX:self.x + other.x
                                    y:self.y + other.y
                                    z:self.z + other.z];
}

- (Vector3 *)subtract:(Vector3 *)other {
    return [[Vector3 alloc] initWithX:self.x - other.x
                                    y:self.y - other.y
                                    z:self.z - other.z];
}

- (Vector3 *)multiplyByScalar:(double)scalar {
    return [[Vector3 alloc] initWithX:self.x * scalar
                                    y:self.y * scalar
                                    z:self.z * scalar];
}

- (Vector3 *)divideByScalar:(double)scalar {
    return [[Vector3 alloc] initWithX:self.x / scalar
                                    y:self.y / scalar
                                    z:self.z / scalar];
}

- (double)dotProduct:(Vector3 *)other {
    return self.x * other.x + self.y * other.y + self.z * other.z;
}

- (Vector3 *)crossProduct:(Vector3 *)other {
    return [[Vector3 alloc] initWithX:self.y * other.z - self.z * other.y
                                    y:self.z * other.x - self.x * other.z
                                    z:self.x * other.y - self.y * other.x];
}

// MARK: - Component Access

- (double)getComponent:(int)index {
    switch (index) {
        case 0: return self.x;
        case 1: return self.y;
        case 2: return self.z;
        default: return 0.0;
    }
}

- (void)setComponent:(int)index value:(double)value {
    switch (index) {
        case 0: self.x = value; break;
        case 1: self.y = value; break;
        case 2: self.z = value; break;
    }
}

// MARK: - Comparison

- (BOOL)isEqualToVector:(Vector3 *)other {
    if (other == nil) return NO;
    if (![other isKindOfClass:[Vector3 class]]) return NO;
    return (self.x == other.x) && (self.y == other.y) && (self.z == other.z);
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Vector3 class]]) return NO;
    return [self isEqualToVector:object];
}

- (NSUInteger)hash {
    NSUInteger hash = [super hash];
    NSUInteger zHash = [[NSNumber numberWithDouble:self.z] hash];
    return hash ^ (zHash << 2);
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%.2f; %.2f; %.2f", self.x, self.y, self.z];
}

- (NSString *)toString2 {
    return [NSString stringWithFormat:@"%.6f %.6f %.6f", self.x, self.y, self.z];
}

@end

@implementation Vector4

// MARK: - Property Accessors

- (void)setW:(double)w {
    _w = isnan(w) ? 0.0 : w;
}

- (double)w {
    return isnan(_w) ? 0.0 : _w;
}

// MARK: - Class Methods

+ (Vector4 *)zero {
    return [[Vector4 alloc] initWithX:0.0 y:0.0 z:0.0 w:0.0];
}

// MARK: - Initialization

- (instancetype)init {
    return [self initWithX:0.0 y:0.0 z:0.0 w:0.0];
}

- (instancetype)initWithX:(double)x y:(double)y z:(double)z {
    return [self initWithX:x y:y z:z w:0.0];
}

- (instancetype)initWithX:(double)x y:(double)y z:(double)z w:(double)w {
    self = [super initWithX:x y:y z:z];
    if (self) {
        self.w = w;
    }
    return self;
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[Vector4 allocWithZone:zone] initWithX:self.x y:self.y z:self.z w:self.w];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    [super unserialize:reader];
    self.w = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [super serialize:writer];
    [writer writeSingle:(float)self.w];
}

// MARK: - Operations

- (Vector4 *)clone {
    return [[Vector4 alloc] initWithX:self.x y:self.y z:self.z w:self.w];
}

- (Vector4 *)add:(Vector4 *)other {
    return [[Vector4 alloc] initWithX:self.x + other.x
                                    y:self.y + other.y
                                    z:self.z + other.z
                                    w:self.w + other.w];
}

- (Vector4 *)subtract:(Vector4 *)other {
    return [[Vector4 alloc] initWithX:self.x - other.x
                                    y:self.y - other.y
                                    z:self.z - other.z
                                    w:self.w - other.w];
}

- (Vector4 *)multiplyByScalar:(double)scalar {
    return [[Vector4 alloc] initWithX:self.x * scalar
                                    y:self.y * scalar
                                    z:self.z * scalar
                                    w:self.w * scalar];
}

- (Vector4 *)divideByScalar:(double)scalar {
    return [[Vector4 alloc] initWithX:self.x / scalar
                                    y:self.y / scalar
                                    z:self.z / scalar
                                    w:self.w / scalar];
}

- (double)dotProduct:(Vector4 *)other {
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
}

// MARK: - Component Access

- (double)getComponent:(int)index {
    switch (index) {
        case 0: return self.x;
        case 1: return self.y;
        case 2: return self.z;
        case 3: return self.w;
        default: return 0.0;
    }
}

- (void)setComponent:(int)index value:(double)value {
    switch (index) {
        case 0: self.x = value; break;
        case 1: self.y = value; break;
        case 2: self.z = value; break;
        case 3: self.w = value; break;
    }
}

// MARK: - Comparison

- (BOOL)isEqualToVector:(Vector4 *)other {
    if (other == nil) return NO;
    if (![other isKindOfClass:[Vector4 class]]) return NO;
    return (self.x == other.x) && (self.y == other.y) && (self.z == other.z) && (self.w == other.w);
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Vector4 class]]) return NO;
    return [self isEqualToVector:object];
}

- (NSUInteger)hash {
    NSUInteger hash = [super hash];
    NSUInteger wHash = [[NSNumber numberWithDouble:self.w] hash];
    return hash ^ (wHash << 3);
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%.2f; %.2f; %.2f, %.2f", self.x, self.y, self.z, self.w];
}

@end

@implementation Vector3i

// MARK: - Class Methods

+ (Vector3i *)zero {
    return [[Vector3i alloc] initWithX:0 y:0 z:0];
}

// MARK: - Initialization

- (instancetype)init {
    return [self initWithX:0 y:0 z:0];
}

- (instancetype)initWithX:(int32_t)x y:(int32_t)y z:(int32_t)z {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}

// MARK: - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[Vector3i allocWithZone:zone] initWithX:self.x y:self.y z:self.z];
}

// MARK: - Serialization

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

// MARK: - Operations

- (Vector3i *)clone {
    return [[Vector3i alloc] initWithX:self.x y:self.y z:self.z];
}

- (Vector3i *)add:(Vector3i *)other {
    return [[Vector3i alloc] initWithX:self.x + other.x
                                     y:self.y + other.y
                                     z:self.z + other.z];
}

- (Vector3i *)subtract:(Vector3i *)other {
    return [[Vector3i alloc] initWithX:self.x - other.x
                                     y:self.y - other.y
                                     z:self.z - other.z];
}

// MARK: - Comparison

- (BOOL)isEqualToVector:(Vector3i *)other {
    if (other == nil) return NO;
    return (self.x == other.x) && (self.y == other.y) && (self.z == other.z);
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Vector3i class]]) return NO;
    return [self isEqualToVector:object];
}

- (NSUInteger)hash {
    return [@(self.x) hash] ^ ([@(self.y) hash] << 1) ^ ([@(self.z) hash] << 2);
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@",
            [Helper hexString:self.x],
            [Helper hexString:self.y],
            [Helper hexString:self.z]];
}

@end


// MARK: - Vectors2 Implementation

@implementation Vectors2

- (Vector2 *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector2 *)objectAtUnsignedIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector2 *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector2 *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector:(Vector2 *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector:(Vector2 *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector:(Vector2 *)item {
    [self removeObject:item];
}

- (BOOL)containsVector:(Vector2 *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (Vectors2 *)clone {
    Vectors2 *cloned = [[Vectors2 alloc] init];
    for (Vector2 *vector in self) {
        [cloned addVector:[vector clone]];
    }
    return cloned;
}

@end

// MARK: - Vectors3 Implementation

@implementation Vectors3

- (Vector3 *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector3 *)objectAtUnsignedIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3 *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector3 *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector:(Vector3 *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector:(Vector3 *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector:(Vector3 *)item {
    [self removeObject:item];
}

- (BOOL)containsVector:(Vector3 *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (Vectors3 *)clone {
    Vectors3 *cloned = [[Vectors3 alloc] init];
    for (Vector3 *vector in self) {
        [cloned addVector:[vector clone]];
    }
    return cloned;
}

@end

// MARK: - Vectors3i Implementation

@implementation Vectors3i

- (Vector3i *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector3i *)objectAtUnsignedIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector3i *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector3i *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector:(Vector3i *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector:(Vector3i *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector:(Vector3i *)item {
    [self removeObject:item];
}

- (BOOL)containsVector:(Vector3i *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (Vectors3i *)clone {
    Vectors3i *cloned = [[Vectors3i alloc] init];
    for (Vector3i *vector in self) {
        [cloned addVector:[vector clone]];
    }
    return cloned;
}

@end

// MARK: - Vectors4 Implementation

@implementation Vectors4

- (Vector4 *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (Vector4 *)objectAtUnsignedIndex:(uint32_t)index {
    return [super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(Vector4 *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(Vector4 *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addVector:(Vector4 *)item {
    [self addObject:item];
    return self.count - 1;
}

- (void)insertVector:(Vector4 *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removeVector:(Vector4 *)item {
    [self removeObject:item];
}

- (BOOL)containsVector:(Vector4 *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return self.count;
}

- (Vectors4 *)clone {
    Vectors4 *cloned = [[Vectors4 alloc] init];
    for (Vector4 *vector in self) {
        [cloned addVector:[vector clone]];
    }
    return cloned;
}

@end
