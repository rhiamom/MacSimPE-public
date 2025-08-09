//
//  BinaryReader.m
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

#import "BinaryReader.h"

@interface BinaryReader ()
{
    Stream *_baseStream;
}
@end

@implementation BinaryReader

- (instancetype)initWithStream:(Stream *)stream {
    self = [super init];
    if (self) {
        _baseStream = stream;
    }
    return self;
}

- (Stream *)baseStream {
    return _baseStream;
}

- (uint8_t)readByte {
    uint8_t value;
    if ([_baseStream readBytes:&value maxLength:1] != 1) {
        @throw [NSException exceptionWithName:@"EndOfStreamException"
                                       reason:@"Attempted to read past end of stream"
                                     userInfo:nil];
    }
    return value;
}

- (int8_t)readSByte {
    return (int8_t)[self readByte];
}

- (uint16_t)readUInt16 {
    uint8_t bytes[2];
    if ([_baseStream readBytes:bytes maxLength:2] != 2) {
        @throw [NSException exceptionWithName:@"EndOfStreamException"
                                       reason:@"Attempted to read past end of stream"
                                     userInfo:nil];
    }
    // Little-endian
    return (uint16_t)(bytes[0] | (bytes[1] << 8));
}

- (int16_t)readInt16 {
    return (int16_t)[self readUInt16];
}

- (uint32_t)readUInt32 {
    uint8_t bytes[4];
    if ([_baseStream readBytes:bytes maxLength:4] != 4) {
        @throw [NSException exceptionWithName:@"EndOfStreamException"
                                       reason:@"Attempted to read past end of stream"
                                     userInfo:nil];
    }
    // Little-endian
    return (uint32_t)(bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24));
}

- (int32_t)readInt32 {
    return (int32_t)[self readUInt32];
}

- (uint64_t)readUInt64 {
    uint32_t low = [self readUInt32];
    uint32_t high = [self readUInt32];
    return ((uint64_t)high << 32) | low;
}

- (int64_t)readInt64 {
    return (int64_t)[self readUInt64];
}

- (float)readSingle {
    uint32_t intValue = [self readUInt32];
    return *(float*)&intValue;
}

- (double)readDouble {
    uint64_t intValue = [self readUInt64];
    return *(double*)&intValue;
}

- (BOOL)readBoolean {
    return [self readByte] != 0;
}

- (unichar)readChar {
    return (unichar)[self readUInt16];
}

- (NSData *)readBytes:(NSInteger)count {
    if (count <= 0) return [NSData data];
    
    NSMutableData *data = [NSMutableData dataWithLength:count];
    NSInteger bytesRead = [_baseStream readBytes:data.mutableBytes maxLength:count];
    
    if (bytesRead != count) {
        [data setLength:bytesRead];
    }
    
    return data;
}

- (NSString *)readString {
    // Read 7-bit encoded length first (like .NET BinaryReader)
    NSInteger length = 0;
    NSInteger shift = 0;
    uint8_t byte;
    
    do {
        byte = [self readByte];
        length |= (byte & 0x7F) << shift;
        shift += 7;
    } while ((byte & 0x80) != 0);
    
    if (length == 0) return @"";
    
    NSData *stringData = [self readBytes:length];
    return [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
}

- (void)close {
    [_baseStream close];
}

@end
