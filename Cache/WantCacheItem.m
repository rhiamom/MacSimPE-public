//
//  WantCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
//
//  WantCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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

#import "WantCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PackedFileDescriptor.h"
#import "CacheException.h"
#import "IPackedFileDescriptor.h"

@implementation WantCacheItem {
    uint8_t _version;
    id<IPackedFileDescriptor> _pfd;
}

// MARK: - Constants

+ (uint8_t)VERSION {
    return 1;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = [[self class] VERSION];
        _name = @"";
        _objectType = @"";
        _folder = @"";
        _pfd = [[PackedFileDescriptor alloc] init];
        _guid = 0;
        _score = 0;
        _influence = 0;
        _icon = nil;
    }
    return self;
}

// MARK: - Properties

- (uint8_t)version {
    return _version;
}

- (id<IPackedFileDescriptor>)fileDescriptor {
    [_pfd setTag:self];
    return _pfd;
}

- (void)setFileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor {
    _pfd = fileDescriptor;
}

// MARK: - ICacheItem Protocol Methods

- (void)load:(BinaryReader *)reader {
    _version = [reader readByte];
    if (_version > [[self class] VERSION]) {
        @throw [[CacheException alloc] initWithMessage:@"Unknown CacheItem Version."
                                              filename:nil
                                               version:_version];
    }
    
    self.name = [reader readString];
    self.objectType = [reader readString];
    
    _pfd = [[PackedFileDescriptor alloc] init];
    [_pfd setType:[reader readUInt32]];
    [_pfd setGroup:[reader readUInt32]];
    [_pfd setLongInstance:[reader readUInt64]];
    
    self.influence = [reader readInt32];
    self.score = [reader readInt32];
    self.guid = [reader readUInt32];
    self.folder = [reader readString];
    
    // Load image data
    int32_t size = [reader readInt32];
    if (size == 0) {
        self.icon = nil;
    } else {
        NSData *imageData = [reader readBytes:size];
        self.icon = [[NSImage alloc] initWithData:imageData];
    }
}

- (void)save:(BinaryWriter *)writer {
    _version = [[self class] VERSION];
    [writer writeByte:_version];
    [writer writeString:self.name];
    [writer writeString:self.objectType];
    [writer writeUInt32:[_pfd type]];
    [writer writeUInt32:[_pfd group]];
    [writer writeUInt64:[_pfd longInstance]];
    [writer writeInt32:self.influence];
    [writer writeInt32:self.score];
    [writer writeUInt32:self.guid];
    [writer writeString:self.folder];
    
    // Save image data
    if (self.icon == nil) {
        [writer writeInt32:0];
    } else {
        // Convert NSImage to PNG data
        CGImageRef cgImage = [self.icon CGImageForProposedRect:NULL context:nil hints:nil];
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
        NSData *pngData = [bitmapRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        
        [writer writeInt32:(int32_t)[pngData length]];
        [writer writeData:pngData];
    }
}

// MARK: - NSObject Overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"name=%@", self.name];
}

@end
