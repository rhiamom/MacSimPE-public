//
//  IWrapperReferencedResources.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/15/25.
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

#import "IWrapperReferencedResources.h"
#import "IPackedFileDescriptorSimple.h"

// MARK: - ReferenceList Implementation

@implementation ReferenceList

// NSMutableArray already provides all the functionality we need
// This is just a type-safe wrapper

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super initWithCapacity:capacity];
    return self;
}

// Optional: Add any specialized methods for working with IPackedFileDescriptorSimple objects

- (NSArray<id<IPackedFileDescriptorSimple>> *)descriptorsOfType:(uint32_t)type {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (id<IPackedFileDescriptorSimple> descriptor in self) {
        if ([descriptor pfdType] == type) {
            [result addObject:descriptor];
        }
    }
    return [result copy];
}

- (id<IPackedFileDescriptorSimple>)descriptorWithType:(uint32_t)type
                                              subtype:(uint32_t)subtype
                                                group:(uint32_t)group
                                             instance:(uint32_t)instance {
    for (id<IPackedFileDescriptorSimple> descriptor in self) {
        if ([descriptor pfdType] == type &&
            [descriptor subType] == subtype &&
            [descriptor group] == group &&
            [descriptor instance] == instance) {
            return descriptor;
        }
    }
    return nil;
}

@end
