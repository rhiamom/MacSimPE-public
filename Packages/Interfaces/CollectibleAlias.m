//
//  CollectibleAlias.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
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

#import "CollectibleAlias.h"
#import "Helper.h"

@implementation CollectibleAlias

// MARK: - Initialization

- (instancetype)initWithId:(uint64_t)itemId
                        nr:(NSInteger)nr
                      name:(NSString *)name
                     image:(NSImage *)image {
    self = [super init];
    if (self) {
        _itemId = itemId;
        _nr = nr;
        _name = [name copy];
        
        if (image == nil) {
            // Create a default 32x32 image when none is provided
            _image = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
            [_image lockFocus];
            [[NSColor clearColor] setFill];
            NSRectFill(NSMakeRect(0, 0, 32, 32));
            [_image unlockFocus];
        } else {
            _image = image;
        }
    }
    return self;
}

// MARK: - NSObject Overrides

- (NSString *)description {
#ifdef DEBUG
    return [NSString stringWithFormat:@"%@ (0x%@, %ld)",
            self.name,
            [Helper hexStringWithPadding:self.itemId padding:0],
            (long)self.nr];
#else
    return self.name;
#endif
}

@end
