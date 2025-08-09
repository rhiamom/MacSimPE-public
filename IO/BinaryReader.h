//
//  BinaryReader.h
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

#import <Foundation/Foundation.h>
#import "Stream.h"

NS_ASSUME_NONNULL_BEGIN

@interface BinaryReader : NSObject

@property (nonatomic, readonly) Stream *baseStream;

- (instancetype)initWithStream:(Stream *)stream;

- (uint8_t)readByte;
- (int8_t)readSByte;
- (uint16_t)readUInt16;
- (int16_t)readInt16;
- (uint32_t)readUInt32;
- (int32_t)readInt32;
- (uint64_t)readUInt64;
- (int64_t)readInt64;
- (float)readSingle;
- (double)readDouble;
- (BOOL)readBoolean;
- (unichar)readChar;

- (NSData *)readBytes:(NSInteger)count;
- (NSString *)readString;

- (void)close;

@end

NS_ASSUME_NONNULL_END
