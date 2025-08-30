//
//  LifoWrapper.m
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


#import "LifoWrapper.h"
#import "LifoUI.h"
#import "AbstractWrapperInfo.h"

@implementation Lifo

// MARK: - Initialization

- (instancetype)initWithProvider:(id<IProviderRegistry>)provider fast:(BOOL)fast {
    self = [super initWithProvider:provider fast:fast];
    if (self) {
        // Initialize LIFO-specific properties here if needed
    }
    return self;
}

// MARK: - AbstractWrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[LifoUI alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"LIFO Wrapper"
                                              author:@"Pumuckl, Quaxi"
                                         description:@"---"
                                             version:5];
}

// MARK: - File Type Information

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@(0xED534136)]; // LIFO Files
}

@end
