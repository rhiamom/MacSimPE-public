//
//  BinaryWriter.m
//  SimPE for Mac
//
//  Properly translated from BinaryWriter.swift
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

#import "BinaryWriter.h"
#import "Stream.h"
#import "FileStream.h"
#import "MemoryStream.h"

@interface BinaryWriter ()
@property (nonatomic, strong, readwrite) Stream *stream;
@property (nonatomic, strong, readwrite, nullable) FileStream *fileStream;
@property (nonatomic, strong, readwrite, nullable) MemoryStream *memoryStream;
@end

@implementation BinaryWriter

// MARK: - Initialization

- (instancetype)initWithStream:(Stream *)stream {
    self = [super init];
    if (self) {
        _stream = stream;
        
        // Initialize the specific stream properties based on the stream type
        if ([stream isKindOfClass:[FileStream class]]) {
            _fileStream = (FileStream *)stream;
            _memoryStream = nil;
        } else if ([stream isKindOfClass:[MemoryStream class]]) {
            _fileStream = nil;
            _memoryStream = (MemoryStream *)stream;
        } else {
            // Handle other stream types or set both to nil
            _fileStream = nil;
            _memoryStream = nil;
        }
    }
    return self;
}

- (instancetype)initWithFileStream:(FileStream *)fileStream {
    return [self initWithStream:fileStream];
}

- (instancetype)initWithMemoryStream:(MemoryStream *)memoryStream {
    return [self initWithStream:memoryStream];
}

- (instancetype)initWithData:(NSMutableData *)data {
    MemoryStream *memoryStream = [[MemoryStream alloc] initWithData:data];
    return [self initWithMemoryStream:memoryStream];
}

// MARK: - Properties

- (NSInteger)position {
    if (self.stream) {
        return (NSInteger)[self.stream position];
    }
    return 0;
}

- (NSInteger)length {
    if (self.stream) {
        return (NSInteger)[self.stream length];
    }
    return 0;
}

// MARK: - Basic Write Methods

- (void)writeUInt8:(uint8_t)value {
    NSData *data = [NSData dataWithBytes:&value length:1];
    [self writeData:data];
}

- (void)writeInt8:(int8_t)value {
    [self writeUInt8:(uint8_t)value];
}

- (void)writeUInt16:(uint16_t)value {
    // Little-endian format
    uint8_t bytes[2];
    bytes[0] = value & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    NSData *data = [NSData dataWithBytes:bytes length:2];
    [self writeData:data];
}

- (void)writeInt16:(int16_t)value {
    [self writeUInt16:(uint16_t)value];
}

- (void)writeUInt32:(uint32_t)value {
    // Little-endian format
    uint8_t bytes[4];
    bytes[0] = value & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    bytes[2] = (value >> 16) & 0xFF;
    bytes[3] = (value >> 24) & 0xFF;
    NSData *data = [NSData dataWithBytes:bytes length:4];
    [self writeData:data];
}

- (void)writeInt32:(int32_t)value {
    [self writeUInt32:(uint32_t)value];
}

- (void)writeUInt64:(uint64_t)value {
    // Write as two 32-bit values (little-endian)
    uint32_t low = (uint32_t)(value & 0xFFFFFFFF);
    uint32_t high = (uint32_t)((value >> 32) & 0xFFFFFFFF);
    [self writeUInt32:low];
    [self writeUInt32:high];
}

- (void)writeInt64:(int64_t)value {
    [self writeUInt64:(uint64_t)value];
}

- (void)writeFloat:(float)value {
    // Convert float to uint32 bits and write in little-endian
    uint32_t intValue;
    memcpy(&intValue, &value, sizeof(uint32_t));
    [self writeUInt32:intValue];
}

- (void)writeSingle:(float)value {
    [self writeFloat:value];
}

- (void)writeDouble:(double)value {
    // Convert double to uint64 bits and write in little-endian
    uint64_t intValue;
    memcpy(&intValue, &value, sizeof(uint64_t));
    [self writeUInt64:intValue];
}

- (void)writeBoolean:(BOOL)value {
    uint8_t byteValue = value ? 1 : 0;
    [self writeUInt8:byteValue];
}

// MARK: - Data Writing Methods

- (void)writeData:(NSData *)data {
    if (self.stream) {
        if ([self.stream canWrite]) {
            [self.stream writeBytes:(const uint8_t *)[data bytes] length:[data length]];
        } else {
            @throw [NSException exceptionWithName:@"StreamNotWritable"
                                           reason:@"Stream is not writable"
                                         userInfo:nil];
        }
    } else {
        @throw [NSException exceptionWithName:@"NoStream"
                                       reason:@"No valid stream available for writing"
                                     userInfo:nil];
    }
}

- (void)writeBytes:(const uint8_t *)bytes length:(NSInteger)length {
    NSData *data = [NSData dataWithBytes:bytes length:length];
    [self writeData:data];
}

- (void)writeByteArray:(NSArray<NSNumber *> *)bytes {
    NSMutableData *data = [NSMutableData dataWithCapacity:[bytes count]];
    for (NSNumber *byteNum in bytes) {
        uint8_t byte = [byteNum unsignedCharValue];
        [data appendBytes:&byte length:1];
    }
    [self writeData:data];
}

- (void)writeString:(NSString *)string {
    if (!string) {
        string = @"";
    }
    
    // Write null-terminated string (C-style) like the Swift version
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (stringData) {
        [self writeData:stringData];
    }
    [self writeUInt8:0]; // null terminator
}

- (void)writeByte:(uint8_t)byte {
    [self writeBytes:&byte length:1];
}
// MARK: - Stream Control

- (void)seekToPosition:(NSInteger)position {
    if (self.stream) {
        [self.stream seekToOffset:(int64_t)position origin:SeekOriginBegin];
    }
}

- (void)flush {
    if (self.stream) {
        [self.stream flush];
    }
}

- (void)close {
    if (self.stream) {
        [self.stream close];
    }
}

@end
