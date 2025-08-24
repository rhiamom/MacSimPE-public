//
//  NmapItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "NmapItem.h"
#import "NmapWrapper.h"
#import "Helper.h"

@implementation NmapItem

// MARK: - Initialization

- (instancetype)initWithParent:(Nmap *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

// MARK: - NSObject Methods

- (NSString *)description {
    NSString *name = [NSString stringWithFormat:@"%@: 0x%@ - 0x%@",
                      self.filename,
                      [Helper hexStringUInt:self.group],
                      [Helper hexStringUInt:self.instance]];
    return name;
}

@end

#import "NmapItem.h"
#import "Nmap.h"
#import "Helper.h"

@implementation NmapItem

// MARK: - Initialization

- (instancetype)initWithParent:(Nmap *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

// MARK: - NSObject Methods

- (NSString *)description {
    NSString *name = [NSString stringWithFormat:@"%@: 0x%@ - 0x%@",
                      self.filename,
                      [Helper hexStringUInt:self.group],
                      [Helper hexStringUInt:self.instance]];
    return name;
}

@end
