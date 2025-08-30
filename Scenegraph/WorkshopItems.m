//
//  WorkshopItems.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/26/25.
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

#import "WorkshopItems.h"
#import "CpfWrapper.h"
#import "Helper.h"

@interface WorkshopMMAT ()

// MARK: - Private Properties

@property (nonatomic, strong) NSMutableArray<Cpf *> *mmatsMutable;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *objectStateIndexMutable;

@end

@implementation WorkshopMMAT

// MARK: - Initialization

- (instancetype)initWithSubset:(NSString *)subset {
    self = [super init];
    if (self) {
        _subset = [subset copy];
        _mmatsMutable = [[NSMutableArray alloc] init];
        _objectStateIndexMutable = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - Property Getters

- (NSArray<Cpf *> *)mmats {
    return [_mmatsMutable copy];
}

- (NSArray<NSNumber *> *)objectStateIndex {
    return [_objectStateIndexMutable copy];
}

// MARK: - MMAT Management

- (BOOL)addMMAT:(Cpf *)mmat {
    // Get the objectStateIndex value from the MMAT
    CpfItem *objectStateIndexItem = [mmat getItem:@"objectStateIndex"];
    if (objectStateIndexItem != nil) {
        uint32_t objectStateIndexValue = [objectStateIndexItem uIntegerValue];
        
        // Only add if the objectStateIndex doesn't already exist
        if ([self addObjectStateIndex:objectStateIndexValue]) {
            [_mmatsMutable addObject:mmat];
            return YES;
        }
    }
    
    return NO;
}

// MARK: - ObjectStateIndex Management

- (BOOL)addObjectStateIndex:(uint32_t)val {
    NSNumber *valueNumber = @(val);
    
    // Check if value already exists
    for (NSNumber *existingValue in _objectStateIndexMutable) {
        if ([existingValue unsignedIntValue] == val) {
            return NO; // Value already exists
        }
    }
    
    // Add the new value
    [_objectStateIndexMutable addObject:valueNumber];
    return YES;
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%lu)",
            self.subset,
            (unsigned long)self.objectStateIndexMutable.count];
}

@end
