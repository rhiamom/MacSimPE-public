//
//  AbstractCresChildren.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

#import "AbstractCresChildren.h"
#import "Containers.h"
#import "cTransformNode.h"
#import "VectorTransformation.h"
#import "RcolWrapper.h"
#import "IRcolBlock.h"
#import "Quaternion.h"
#import "cObjectGraphNode.h"

@implementation AbstractCresChildren

// MARK: - Abstract Methods (Must be implemented by subclasses)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (NSString *)getName {
    return self.transformNode.objectGraphNode.fileName;
}
#pragma clang diagnostic pop

- (IntArrayList *)childBlocks {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses must implement childBlocks"
                                 userInfo:nil];
}

- (NSInteger)imageIndex {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses must implement imageIndex"
                                 userInfo:nil];
}

- (TransformNode *)storedTransformNode {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses must implement storedTransformNode"
                                 userInfo:nil];
}

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        [self reset];
    }
    return self;
}

// MARK: - ICresChildren Protocol Implementation

- (id<ICresChildren>)getBlock:(NSInteger)index {
    if (self.parent == nil) return nil;
    
    if (index < 0) return nil;
    if (index >= self.parent.blocks.count) return nil;
    
    id object = self.parent.blocks[index];
    
    if ([object conformsToProtocol:@protocol(ICresChildren)]) {
        return (id<ICresChildren>)object;
    }
    
    return nil;
}

- (NSInteger)index {
    if (self.parent == nil) return -1;
    
    for (NSInteger i = 0; i < self.parent.blocks.count; i++) {
        if (self.parent.blocks[i] == self) return i;
    }
    return -1;
}

- (IntArrayList *)getParentBlocks {
    IntArrayList *l = [[IntArrayList alloc] init];
    
    for (NSInteger i = 0; i < self.parent.blocks.count; i++) {
        id<IRcolBlock> irb = (id<IRcolBlock>)self.parent.blocks[i];
        
        if ([irb conformsToProtocol:@protocol(ICresChildren)]) {
            id<ICresChildren> icc = (id<ICresChildren>)irb;
            if ([icc.childBlocks containsInt:(int)self.index]) {  // Cast NSInteger to int
                [l addInt:(int)i];  // Cast NSInteger to int
            }
        }
    }
    return l;
}

- (id<ICresChildren>)getFirstParent {
    IntArrayList *l = [self getParentBlocks];
    if (l.length == 0) return nil;
    return (id<ICresChildren>)self.parent.blocks[[l intAtIndex:0]];
}

// MARK: - Hierarchy Transformations

- (VectorTransformations *)getAbsoluteTransformation:(id<ICresChildren>)node
                               vectorTransformations:(VectorTransformations *)v {
    if (v == nil) v = [[VectorTransformations alloc] init];
    if (node == nil) return v;
    if (node.storedTransformNode == nil) return v;
    if ([self.seenBones containsObject:@(node.index)]) return v;
    
    [self.seenBones addObject:@(node.index)];
    
    [v addTransformation:node.storedTransformNode.transformation];  // Use addTransformation: instead of add:
    v = [self getAbsoluteTransformation:[node getFirstParent] vectorTransformations:v];
    
    return v;
}

- (VectorTransformations *)getHierarchyTransformations {
    self.seenBones = [[NSMutableArray alloc] init];
    return [self getAbsoluteTransformation:self vectorTransformations:nil];
}

- (VectorTransformation *)getEffectiveTransformation {
    VectorTransformations *list = [self getHierarchyTransformations];
    VectorTransformation *v = [[VectorTransformation alloc] init];
    
#ifdef DEBUG
    NSString *debugPath = @"/tmp/effect.txt";
    NSString *debugContent = @"";
#endif
    
    @try {
#ifdef DEBUG
        debugContent = [debugContent stringByAppendingString:@"-----------------------------------\n"];
        debugContent = [debugContent stringByAppendingFormat:@"    %@\n", [v description]];
#endif
        
        VectorTransformation *l = nil;
        for (NSInteger i = list.length - 1; i >= 0; i--) {
            VectorTransformation *t = [list objectAtIndex:i];  // Use objectAtIndex: instead of get:
            [t.rotation makeUnitQuaternion];
            
            v.rotation = [Quaternion multiply:v.rotation by:t.rotation];  // Use class method for multiply
            v.translation = [[t.rotation rotateVector:v.translation] subtract:[t.rotation rotateVector:t.translation]];  // Use rotateVector: instead of rotate:
            
#ifdef DEBUG
            debugContent = [debugContent stringByAppendingFormat:@"++++%@ %@\n", [t description], t.name];
            debugContent = [debugContent stringByAppendingFormat:@"    %@\n", [v description]];
#endif
            
            l = t;
        }
    }
    @finally {
#ifdef DEBUG
        [debugContent writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
    }
    
    return v;
}
// MARK: - NSFastEnumeration Support

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained _Nullable [_Nonnull])buffer
                                    count:(NSUInteger)len {
    if (state->state == 0) {
        state->state = 1;
        state->mutationsPtr = &state->extra[0];
        self.pos = 0;
    }
    
    NSUInteger count = 0;
    while (count < len && self.pos < self.childBlocks.count) {
        id<ICresChildren> block = [self getBlock:[self.childBlocks intAtIndex:self.pos]];
        if (block != nil) {
            buffer[count] = (id)block;  // Cast to __unsafe_unretained id
            count++;
        }
        self.pos++;
    }
    
    state->itemsPtr = (__unsafe_unretained id *)buffer;  // Cast the buffer pointer
    return count;
}

- (void)reset {
    self.pos = -1;
}

@end
