//
//  FileStream.m
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

#import "FileStream.h"

@interface FileStream ()
{
    NSFileHandle *_fileHandle;
    NSString *_name;
    FileAccess _access;
    BOOL _canRead;
    BOOL _canWrite;
}
@end

@implementation FileStream

- (instancetype)initWithPath:(NSString *)path access:(FileAccess)access {
    self = [super init];
    if (self) {
        _name = [path copy];
        _access = access;
        [self openFileWithAccess:access];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data access:(FileAccess)access {
    self = [super init];
    if (self) {
        _name = @"<memory>";
        _access = access;
        
        // Create temporary file for data
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        [data writeToFile:tempPath atomically:YES];
        _name = tempPath;
        [self openFileWithAccess:access];
    }
    return self;
}

- (void)openFileWithAccess:(FileAccess)access {
    NSError *error;
    
    switch (access) {
        case FileAccessRead:
            _fileHandle = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:_name] error:&error];
            _canRead = YES;
            _canWrite = NO;
            break;
            
        case FileAccessWrite:
            _fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:_name] error:&error];
            _canRead = NO;
            _canWrite = YES;
            break;
            
        case FileAccessReadWrite:
            _fileHandle = [NSFileHandle fileHandleForUpdatingURL:[NSURL fileURLWithPath:_name] error:&error];
            _canRead = YES;
            _canWrite = YES;
            break;
    }
    
    if (error) {
        NSLog(@"Failed to open file %@: %@", _name, error.localizedDescription);
    }
}

- (NSString *)name {
    return _name;
}

- (int64_t)length {
    if (!_fileHandle) return 0;
    
    NSError *error;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:_name error:&error];
    if (error) return 0;
    
    return [attrs[NSFileSize] longLongValue];
}

- (int64_t)position {
    if (!_fileHandle) return 0;
    return (int64_t)[_fileHandle offsetInFile];
}

- (void)setPosition:(int64_t)position {
    if (_fileHandle) {
        [_fileHandle seekToFileOffset:(unsigned long long)position];
    }
}

- (BOOL)canRead {
    return _canRead && _fileHandle != nil;
}

- (BOOL)canWrite {
    return _canWrite && _fileHandle != nil;
}

- (BOOL)canSeek {
    return _fileHandle != nil;
}

- (int64_t)seekToOffset:(int64_t)offset origin:(SeekOrigin)origin {
    if (!_fileHandle) return 0;
    
    unsigned long long newPosition;
    
    switch (origin) {
        case SeekOriginBegin:
            newPosition = (unsigned long long)offset;
            break;
        case SeekOriginCurrent:
            newPosition = [_fileHandle offsetInFile] + (unsigned long long)offset;
            break;
        case SeekOriginEnd:
            newPosition = (unsigned long long)self.length + (unsigned long long)offset;
            break;
    }
    
    [_fileHandle seekToFileOffset:newPosition];
    return (int64_t)[_fileHandle offsetInFile];
}

- (NSInteger)readBytes:(uint8_t *)buffer maxLength:(NSInteger)maxLength {
    if (!_fileHandle || !_canRead) return 0;
    
    NSError *error;
    NSData *data = [_fileHandle readDataUpToLength:maxLength error:&error];
    if (error || !data) return 0;
    
    NSInteger bytesRead = data.length;
    [data getBytes:buffer length:bytesRead];
    return bytesRead;
}

- (void)writeBytes:(const uint8_t *)buffer length:(NSInteger)length {
    if (!_fileHandle || !_canWrite) return;
    
    NSData *data = [NSData dataWithBytes:buffer length:length];
    NSError *error;
    [_fileHandle writeData:data error:&error];
    
    if (error) {
        NSLog(@"Write failed: %@", error.localizedDescription);
    }
}

- (void)close {
    if (_fileHandle) {
        NSError *error;
        [_fileHandle closeAndReturnError:&error];
        _fileHandle = nil;
    }
}

- (void)flush {
    if (_fileHandle) {
        NSError *error;
        [_fileHandle synchronizeAndReturnError:&error];
    }
}

- (void)dealloc {
    [self close];
}

@end
