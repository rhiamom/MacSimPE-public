//
//  Warning.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "WarningException.h"

@interface Warning ()
@property (nonatomic, strong, readwrite) NSString *message;
@property (nonatomic, strong, readwrite) NSString *details;
@property (nonatomic, strong, readwrite) NSException *innerException;
@end

@implementation Warning

// MARK: - Initialization

- (instancetype)initWithMessage:(NSString *)message details:(NSString *)details {
    return [self initWithMessage:message details:details exception:nil];
}

- (instancetype)initWithMessage:(NSString *)message
                        details:(NSString *)details
                      exception:(NSException *)innerException {
    self = [super init];
    if (self) {
        _message = message ? [message copy] : @"";
        _details = details ? [details copy] : @"";
        _innerException = innerException;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                    exception:(NSException *)exception {
    return [self initWithMessage:title details:description exception:exception];
}

// MARK: - Properties

- (NSString *)details {
    if (_details == nil) return @"";
    return _details;
}

// MARK: - Description

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"Warning: %@", self.message];
    
    if (self.details && ![self.details isEqualToString:@""]) {
        [desc appendFormat:@"\nDetails: %@", self.details];
    }
    
    if (self.innerException) {
        [desc appendFormat:@"\nInner Exception: %@", self.innerException];
    }
    
    return [desc copy];
}

@end
