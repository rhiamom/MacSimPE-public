//
//  HeaderData.m
//  SimPE for Mac
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop               *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#import "MetaData.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "HeaderIndex.h"
#import "HeaderHole.h"

@interface HeaderData ()
{
    char _id[4];
    int32_t _majorVersion;
    int32_t _minorVersion;
    int32_t _reserved00[3];
    uint32_t _created;
    int32_t _modified;
    HeaderIndex *_index;
    HeaderHole *_hole;
    IndexTypes _indexType;
    int32_t _reserved02[8];
    BOOL _lockIndexDuringLoad;
}
@end

@implementation HeaderData

- (instancetype)init {
    self = [super init];
    if (self) {
        _lockIndexDuringLoad = NO;
        _index = [[HeaderIndex alloc] initWithHeader:self];
        _hole = [[HeaderHole alloc] init];
        
        // Initialize ID to "DBPF"
        _id[0] = 'D';
        _id[1] = 'B';
        _id[2] = 'P';
        _id[3] = 'F';
        
        _majorVersion = 1;
        _minorVersion = 1;
        _index.iType = 7;
        
        _indexType = ptLongFileIndex;
        
        // Initialize arrays to zero
        memset(_reserved00, 0, sizeof(_reserved00));
        memset(_reserved02, 0, sizeof(_reserved02));
    }
    return self;
}

// MARK: - Properties
- (NSString *)identifier {
    return [NSString stringWithFormat:@"%c%c%c%c", _id[0], _id[1], _id[2], _id[3]];
}

- (int32_t)majorVersion {
    return _majorVersion;
}

- (int32_t)minorVersion {
    return _minorVersion;
}

- (int64_t)version {
    return ((int64_t)_majorVersion << 32) | (uint32_t)_minorVersion;
}

- (uint32_t)created {
    return _created;
}

- (void)setCreated:(uint32_t)created {
    _created = created;
}

- (int32_t)modified {
    return _modified;
}

- (id<IPackageHeaderIndex>)index {
    return _index;
}

- (id<IPackageHeaderHoleIndex>)holeIndex {
    return _hole;
}

- (IndexTypes)indexType {
    return _indexType;
}

- (void)setIndexType:(IndexTypes)indexType {
    _indexType = indexType;
}

- (BOOL)isVersion0101 {
    return self.version >= 0x100000001;
}

- (HeaderIndex *)headerIndex {
    return _index;
}

- (HeaderHole *)hole {
    return _hole;
}

// MARK: - File Processing Methods
- (void)loadFromReader:(BinaryReader *)reader {
    // Read ID
    for (int i = 0; i < 4; i++) {
        _id[i] = (char)[reader readChar];
    }
    
    // Validate identifier
    if (![self.identifier isEqualToString:@"DBPF"]) {
        @throw [NSException exceptionWithName:@"InvalidOperationException"
                                       reason:@"SimPe does not support this type of file."
                                     userInfo:nil];
    }
    
    _majorVersion = [reader readInt32];
    if (_majorVersion > 1) {
        @throw [NSException exceptionWithName:@"InvalidOperationException"
                                       reason:@"SimPe does not support this version of DBPF file."
                                     userInfo:nil];
    }
    
    _minorVersion = [reader readInt32];
    
    // Read reserved data
    for (int i = 0; i < 3; i++) {
        _reserved00[i] = [reader readInt32];
    }
    
    _created = [reader readUInt32];
    _modified = [reader readInt32];
    
    // Read index information
    _index.iType = [reader readInt32];
    if (!_lockIndexDuringLoad) {
        _index.count = [reader readInt32];
        _index.offset = [reader readUInt32];
        _index.size = [reader readInt32];
    } else {
        [reader readInt32]; // skip count
        [reader readInt32]; // skip offset
        [reader readInt32]; // skip size
    }
    
    // Read hole information
    _hole.count = [reader readInt32];
    _hole.offset = [reader readUInt32];
    _hole.size = [reader readInt32];
    
    // Read index type if version >= 1.1
    if (self.isVersion0101) {
        _indexType = (IndexTypes)[reader readUInt32];
    }
    
    // Read reserved data
    for (int i = 0; i < 8; i++) {
        _reserved02[i] = [reader readInt32];
    }
}

- (void)saveToWriter:(BinaryWriter *)writer {
    // Write ID
    for (int i = 0; i < 4; i++) {
        [writer writeByte:(uint8_t)_id[i]];
    }
    
    [writer writeInt32:_majorVersion];
    [writer writeInt32:_minorVersion];
    
    // Write reserved data
    for (int i = 0; i < 3; i++) {
        [writer writeInt32:_reserved00[i]];
    }
    
    [writer writeUInt32:_created];
    [writer writeInt32:_modified];
    
    // Write index information
    [writer writeInt32:_index.iType];
    [writer writeInt32:_index.count];
    [writer writeUInt32:_index.offset];
    [writer writeInt32:_index.size];
    
    // Write hole information
    [writer writeInt32:_hole.count];
    [writer writeUInt32:_hole.offset];
    [writer writeInt32:_hole.size];
    
    // Write index type if version >= 1.1
    if (self.isVersion0101) {
        [writer writeUInt32:(uint32_t)_indexType];
    }
    
    // Write reserved data
    for (int i = 0; i < 8; i++) {
        [writer writeInt32:_reserved02[i]];
    }
}

// MARK: - Cloning
- (id)clone {
    HeaderData *clone = [[HeaderData alloc] init];
    clone->_created = _created;
    memcpy(clone->_id, _id, sizeof(_id));
    clone->_indexType = _indexType;
    clone->_majorVersion = _majorVersion;
    clone->_minorVersion = _minorVersion;
    clone->_modified = _modified;
    
    memcpy(clone->_reserved00, _reserved00, sizeof(_reserved00));
    memcpy(clone->_reserved02, _reserved02, sizeof(_reserved02));
    
    return clone;
}

@end
