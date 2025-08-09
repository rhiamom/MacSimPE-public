//
//  Stream.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SeekOrigin) {
    SeekOriginBegin = 0,
    SeekOriginCurrent = 1,
    SeekOriginEnd = 2
};

typedef NS_ENUM(NSInteger, FileAccess) {
    FileAccessRead = 1,
    FileAccessWrite = 2,
    FileAccessReadWrite = 3
};

@interface Stream : NSObject

@property (nonatomic, readonly) int64_t length;
@property (nonatomic, assign) int64_t position;
@property (nonatomic, readonly) BOOL canRead;
@property (nonatomic, readonly) BOOL canWrite;
@property (nonatomic, readonly) BOOL canSeek;

- (int64_t)seekToOffset:(int64_t)offset origin:(SeekOrigin)origin;
- (NSInteger)readBytes:(uint8_t *)buffer maxLength:(NSInteger)maxLength;
- (void)writeBytes:(const uint8_t *)buffer length:(NSInteger)length;
- (void)close;
- (void)flush;

@end

NS_ASSUME_NONNULL_END
