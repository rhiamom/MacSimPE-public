//
//  RcolCacheItem..m
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

#import "RcolCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PackedFileDescriptor.h"
#import "CacheException.h"
#import "IPackedFileDescriptor.h"
#import "ICacheItem.h"

@implementation RcolCacheItem {
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
        _resourceName = @"";
        _modelName = @"";
        _rcolType = RcolCacheItemTypeUnknown;
        
        _pfd = [[PackedFileDescriptor alloc] init];
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
    
    self.resourceName = [reader readString];
    _rcolType = (RcolCacheItemType)[reader readByte];
    
    _pfd = [[PackedFileDescriptor alloc] init];
    [_pfd setType:[reader readUInt32]];
    [_pfd setGroup:[reader readUInt32]];
    [_pfd setLongInstance:[reader readUInt64]];
}

- (void)save:(BinaryWriter *)writer {
    _version = [[self class] VERSION];
    [writer writeByte:_version];
    [writer writeString:self.resourceName];
    [writer writeByte:(uint8_t)_rcolType];
    [writer writeUInt32:[_pfd type]];
    [writer writeUInt32:[_pfd group]];
    [writer writeUInt64:[_pfd longInstance]];
}

// MARK: - NSObject Overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"modelname=%@, type=%d, name=%@",
            self.modelName, (int)self.rcolType, self.resourceName];
}

@end
