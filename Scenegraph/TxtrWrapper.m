//
//  TxtrWrapper.m
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
//

#import "TxtrWrapper.h"
#import "AbstractWrapperInfo.h"
#import "TxtrUI.h"
#import <Foundation/Foundation.h>

@implementation Txtr

// MARK: - Initialization

- (instancetype)initWithProvider:(id<IProviderRegistry>)provider fast:(BOOL)fast {
    self = [super initWithProvider:provider fast:fast];
    if (self) {
        // Additional initialization if needed
    }
    return self;
}

// MARK: - AbstractWrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[TxtrUI alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    // Load the texture icon from the app bundle
    NSImage *icon = nil;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *iconPath = [mainBundle pathForResource:@"txtr" ofType:@"png"];
    if (iconPath) {
        icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    }
    
    return [[AbstractWrapperInfo alloc]
            initWithName:@"TXTR Wrapper"
            author:@"Pumuckl, Quaxi"
            description:@"This File is part of the Scenegraph. It contains the Texture for a Mesh Group/Subset."
            version:13
            icon:icon];
}

// MARK: - IFileWrapper Methods

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@0x1C4A276C]; // TXTR Files
}

@end
