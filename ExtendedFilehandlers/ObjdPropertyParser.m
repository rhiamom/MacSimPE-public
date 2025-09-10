//
//  ObjdPropertyParser.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/9/25.
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
// ***************************************************************************/

#import "ObjdPropertyParser.h"

@interface ObjdPropertyParser()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PropertyDescription *> *typemapInternal;

@end

@implementation ObjdPropertyParser

// MARK: - Initialization

- (instancetype)initWithPath:(NSString *)filename {
    self = [super initWithPath:filename];
    if (self) {
        _typemapInternal = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// MARK: - Properties

- (NSDictionary<NSNumber *, PropertyDescription *> *)typemap {
    if (self.properties == nil) {
        // This will trigger loading if not already loaded
        [self properties];
    }
    return [_typemapInternal copy];
}

// MARK: - Property Description Access

- (nullable PropertyDescription *)getDescriptor:(uint16_t)index {
    if (self.properties == nil) {
        // This will trigger loading if not already loaded
        [self properties];
    }
    return _typemapInternal[@(index)];
}

// MARK: - Property Building (Override)

- (nullable id)buildValue:(NSString *)typeName stringValue:(nullable NSString *)value {
    return [super buildValue:typeName stringValue:value];
}

// MARK: - Property Handling (Override)

- (void)handleProperty:(NSXMLElement *)node propertyDescription:(PropertyDescription *)pd {
    [super handleProperty:node propertyDescription:pd];
    
    for (NSXMLNode *subnode in [node children]) {
        if ([[subnode name] isEqualToString:@"index"]) {
            @try {
                uint16_t index = (uint16_t)[[subnode stringValue] intValue];
                if (![_typemapInternal.allKeys containsObject:@(index)]) {
                    _typemapInternal[@(index)] = pd;
                }
            }
            @catch (NSException *exception) {
                // Ignore parsing errors, similar to the C# empty catch block
            }
        }
    }
}

@end
