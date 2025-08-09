//
//  Stream.m
//  SimPE for Mac
//
// ***************************************************************************
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

#import "Stream.h"

@implementation Stream

- (int64_t)length {
    // Base implementation - subclasses should override
    return 0;
}

- (int64_t)position {
    // Base implementation - subclasses should override
    return 0;
}

- (void)setPosition:(int64_t)position {
    // Base implementation - subclasses should override
    [self seekToOffset:position origin:SeekOriginBegin];
}

- (BOOL)canRead {
    // Base implementation - subclasses should override
    return NO;
}

- (BOOL)canWrite {
    // Base implementation - subclasses should override
    return NO;
}

- (BOOL)canSeek {
    // Base implementation - subclasses should override
    return NO;
}

- (int64_t)seekToOffset:(int64_t)offset origin:(SeekOrigin)origin {
    // Base implementation - subclasses should override
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:@"Subclasses must implement seekToOffset:origin:"
                                 userInfo:nil];
}

- (NSInteger)readBytes:(uint8_t *)buffer maxLength:(NSInteger)maxLength {
    // Base implementation - subclasses should override
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:@"Subclasses must implement readBytes:maxLength:"
                                 userInfo:nil];
}

- (void)writeBytes:(const uint8_t *)buffer length:(NSInteger)length {
    // Base implementation - subclasses should override
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:@"Subclasses must implement writeBytes:length:"
                                 userInfo:nil];
}

- (void)close {
    // Base implementation - subclasses can override
}

- (void)flush {
    // Base implementation - subclasses can override
}

@end
