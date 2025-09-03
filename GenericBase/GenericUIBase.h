//
//  GenericUIBase.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/2/25.
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class GenericElements;

NS_ASSUME_NONNULL_BEGIN

/**
 * Abstract Base for some PackedFile handlers
 */
@interface GenericUIBase : NSObject

// MARK: - Class Properties

/**
 * The Form containing the Panel
 */
@property (class, nonatomic, strong, nullable) GenericElements *form;

// MARK: - Initialization

/**
 * Constructor for the Class
 */
- (instancetype)init;

// MARK: - Cleanup

/**
 * Cleanup method (equivalent to C# Dispose)
 */
- (void)dispose;

@end

NS_ASSUME_NONNULL_END

//
//  GenericUIBase.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/2/25.
//

#import "GenericUIBase.h"
#import "GenericElements.h"

@implementation GenericUIBase

// MARK: - Class Property Implementation

static GenericElements * _Nullable _form = nil;

+ (GenericElements * _Nullable)form {
    return _form;
}

+ (void)setForm:(GenericElements * _Nullable)form {
    _form = form;
}


// MARK: - Initialization

- (instancetype _Nonnull)init {
    self = [super init];
    if (self) {
        if (_form == nil) {
            _form = [[GenericElements alloc] init];
        }
    }
    return self;
}

// MARK: - Cleanup

- (void)dispose {
    // Virtual method - can be overridden by subclasses
    // Default implementation does nothing
}

@end
