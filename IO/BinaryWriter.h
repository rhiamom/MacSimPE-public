//
//  BinaryWriter.h
//  SimPE for Mac
//
//  Properly translated from BinaryWriter.swift - REPLACES OLD VERSION
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

#import <Foundation/Foundation.h>

@class Stream;
@class FileStream;
@class MemoryStream;

NS_ASSUME_NONNULL_BEGIN

@interface BinaryWriter : NSObject

// MARK: - Properties
@property (nonatomic, readonly) Stream *stream;
@property (nonatomic, readonly, nullable) FileStream *fileStream;
@property (nonatomic, readonly, nullable) MemoryStream *memoryStream;
@property (nonatomic, readonly) NSInteger position;
@property (nonatomic, readonly) NSInteger length;

// MARK: - Initialization
- (instancetype)initWithStream:(Stream *)stream;
- (instancetype)initWithFileStream:(FileStream *)fileStream;
- (instancetype)initWithMemoryStream:(MemoryStream *)memoryStream;
- (instancetype)initWithData:(NSMutableData *)data;

// MARK: - Basic Write Methods
- (void)writeUInt8:(uint8_t)value;
- (void)writeInt8:(int8_t)value;
- (void)writeUInt16:(uint16_t)value;
- (void)writeInt16:(int16_t)value;
- (void)writeUInt32:(uint32_t)value;
- (void)writeInt32:(int32_t)value;
- (void)writeUInt64:(uint64_t)value;
- (void)writeInt64:(int64_t)value;
- (void)writeFloat:(float)value;
- (void)writeSingle:(float)value;
- (void)writeDouble:(double)value;
- (void)writeBoolean:(BOOL)value;

// MARK: - Data Writing Methods
- (void)writeData:(NSData *)data;
- (void)writeBytes:(const uint8_t *)bytes length:(NSInteger)length;
- (void)writeByteArray:(NSArray<NSNumber *> *)bytes;
- (void)writeString:(NSString *)string;
- (void)writeByte:(uint8_t)byte;
- (void)skipBytes:(NSInteger)count;

// MARK: - Stream Control
- (void)seekToPosition:(NSInteger)position;
- (void)flush;
- (void)close;

@end

NS_ASSUME_NONNULL_END
