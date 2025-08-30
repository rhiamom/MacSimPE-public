//
//  CacheException.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/29/25.
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

#import "CacheException.h"

@implementation CacheException

// MARK: - Initialization

- (instancetype)initWithMessage:(NSString *)message
                       filename:(nullable NSString *)filename
                        version:(uint8_t)version {
    // Build the formatted message like the C# version
    NSString *formattedMessage;
    if (filename) {
        formattedMessage = [NSString stringWithFormat:@"%@ (file=%@, version=%d)", message, filename, version];
    } else {
        formattedMessage = [NSString stringWithFormat:@"%@ (file=%@, version=%d)", message, @"(null)", version];
    }
    
    // Initialize with NSException's designated initializer
    self = [super initWithName:NSStringFromClass([self class])
                        reason:formattedMessage
                      userInfo:nil];
    
    if (self) {
        _filename = [filename copy];
        _version = version;
    }
    
    return self;
}

// MARK: - Convenience Methods

+ (void)raiseWithMessage:(NSString *)message
                filename:(nullable NSString *)filename
                 version:(uint8_t)version {
    CacheException *exception = [[CacheException alloc] initWithMessage:message
                                                                filename:filename
                                                                 version:version];
    @throw exception;
}

// MARK: - NSCopying (inherited from NSException)

- (id)copyWithZone:(NSZone *)zone {
    CacheException *copy = [super copyWithZone:zone];
    if (copy) {
        copy->_filename = [self.filename copyWithZone:zone];
        copy->_version = self.version;
    }
    return copy;
}

// MARK: - Description

- (NSString *)description {
    return [self reason];
}

@end
