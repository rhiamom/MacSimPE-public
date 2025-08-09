//
//  MemoryStream.m
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

#import "MemoryStream.h"

@interface MemoryStream ()
{
    NSMutableData *_buffer;
    int64_t _position;
}
@end

@implementation MemoryStream

- (instancetype)init {
    return [self initWithCapacity:0];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _buffer = [data mutableCopy];
        _position = 0;
    }
    return self;
}

- (instancetype)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    if (self) {
        _buffer = [[NSMutableData alloc] initWithCapacity:capacity];
        _position = 0;
    }
    return self;
}

- (NSData *)data {
    return [_buffer copy];
}

- (int64_t)length {
    return _buffer.length;
}

- (int64_t)position {
    return _position;
}

- (void)setPosition:(int64_t)position {
    _position = MAX(0, MIN(position, (int64_t)_buffer.length));
}

- (BOOL)canRead {
    return YES;
}

- (BOOL)canWrite {
    return YES;
}

- (BOOL)canSeek {
    return YES;
}

- (int64_t)seekToOffset:(int64_t)offset origin:(SeekOrigin)origin {
    switch (origin) {
        case SeekOriginBegin:
            _position = offset;
            break;
        case SeekOriginCurrent:
            _position += offset;
            break;
        case SeekOriginEnd:
            _position = (int64_t)_buffer.length + offset;
            break;
    }
    
    _position = MAX(0, MIN(_position, (int64_t)_buffer.length));
    return _position;
}

- (NSInteger)readBytes:(uint8_t *)buffer maxLength:(NSInteger)maxLength {
    if (_position >= (int64_t)_buffer.length) return 0;
    
    NSInteger available = (NSInteger)((int64_t)_buffer.length - _position);
    NSInteger toRead = MIN(maxLength, available);
    
    [_buffer getBytes:buffer range:NSMakeRange((NSUInteger)_position, toRead)];
    _position += toRead;
    
    return toRead;
}

- (void)writeBytes:(const uint8_t *)buffer length:(NSInteger)length {
    // Extend buffer if needed
    NSInteger requiredLength = (NSInteger)_position + length;
    if (requiredLength > (NSInteger)_buffer.length) {
        [_buffer setLength:requiredLength];
    }
    
    [_buffer replaceBytesInRange:NSMakeRange((NSUInteger)_position, length) withBytes:buffer];
    _position += length;
}

- (NSData *)toData {
    return [self data];
}

@end
