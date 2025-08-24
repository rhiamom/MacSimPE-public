//
//  cLevelInfo.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/23/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
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

#import "cLevelInfo.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "MemoryStream.h"
#import "Stream.h"
#import "cSGResource.h"
#import "RcolWrapper.h"
#import "Helper.h"

@implementation LevelInfo {
    NSData *_data;
    NSSize _textureSize;
    TxtrFormats _format;
    NSInteger _zLevel;
    NSImage *_img;
    MipMapType _dataType;
}

// MARK: - Properties

@synthesize zLevel = _zLevel;
@synthesize format = _format;

- (NSSize)textureSize {
    return _textureSize;
}

- (NSImage *)texture {
    if (_img == nil && _data != nil) {
        MemoryStream *memoryStream = [[MemoryStream alloc] initWithData:_data];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:memoryStream];
        _img = [ImageLoader loadWithTextureSize:self.textureSize
                                         length:_data.length
                                         format:_format
                                         reader:reader
                                          index:1
                                       mapCount:-1];
    }
    return _img;
}

- (NSData *)data {
    return _data;
}

- (void)setData:(NSData *)data {
    _dataType = MipMapTypeSimPEPlainData;
    _data = data;
    _img = nil; // Clear cached image
}

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _textureSize = NSMakeSize(0, 0);
        _zLevel = 0;
        self.sgres = [[SGResource alloc] initWithParent:nil];
        self.blockId = 0xED534136;
        _data = [[NSData alloc] init];
        _dataType = MipMapTypeSimPEPlainData;
    }
    return self;
}

// MARK: - Texture Management

- (void)setTexture:(NSImage *)texture {
    _dataType = MipMapTypeTexture;
    _data = nil;
    _img = texture;
}

// MARK: - IRcolBlock Protocol Implementation

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    NSString *s = [reader readString];
    
    uint32_t blockId = [reader readUInt32];
    self.sgres.blockId = blockId;
    [self.sgres unserialize:reader];
    
    int32_t w = [reader readInt32];
    int32_t h = [reader readInt32];
    _textureSize = NSMakeSize(w, h);
    _zLevel = [reader readInt32];
    
    int32_t size = [reader readInt32];
    
    if (self.parent.fast) {
        [reader.baseStream seekToOffset:size origin:SeekOriginCurrent];
        _textureSize = NSMakeSize(0, 0);
        _img = nil;
        return;
    }
    
    // Determine format based on size - Pumckl Contribution
    _format = TxtrFormatsDXT1Format; // Default
    
    if (size == 4 * w * h) {
        _format = TxtrFormatsRaw32Bit;
    } else if (size == 3 * w * h) {
        _format = TxtrFormatsRaw24Bit;
    } else if (size == w * h) { // Could be RAW8, DXT3 or DXT5
        // It seems to be difficult to determine the right format
        if ([self.sgres.fileName rangeOfString:@"bump"].location != NSNotFound) {
            // It's a bump-map
            _format = TxtrFormatsRaw8Bit;
        } else {
            // I expect the upper left 4x4 corner of the picture have
            // all the same alpha so I can determine if it's DXT5
            // I guess, it's somewhat dirty but what can I do else?
            int64_t pos = reader.baseStream.position;
            uint64_t alpha = [reader readUInt64]; // Read the first 8 bytes of the image
            reader.baseStream.position = pos;
            
            // On DXT5 if all alpha are the same the bytes 0 or 1 are not zero
            // and the bytes 2-7 (codebits) are all zero
            if (((alpha & 0xffffffffffff0000ULL) == 0) && ((alpha & 0xffff) != 0)) {
                _format = TxtrFormatsDXT5Format;
            } else {
                _format = TxtrFormatsDXT3Format;
            }
        }
    } else {
        _format = TxtrFormatsDXT1Format; // size < w*h
    }
    
    int64_t p1 = reader.baseStream.position;
    size = (int32_t)(reader.baseStream.length - p1);
    
    // Always use SimPE_PlainData for consistency with the C# version's else block
    _dataType = MipMapTypeSimPEPlainData;
    
    _data = [reader readBytes:size];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    NSString *s = [self.sgres registerWithParent:nil];
    [writer writeString:s];
    [writer writeUInt32:self.sgres.blockId];
    [self.sgres serialize:writer];
    
    [writer writeInt32:(int32_t)_textureSize.width];
    [writer writeInt32:(int32_t)_textureSize.height];
    [writer writeInt32:(int32_t)_zLevel];
    
    if (_dataType == MipMapTypeTexture) {
        _data = [ImageLoader saveWithFormat:_format image:_img];
    }
    
    if (_data == nil) {
        _data = [[NSData alloc] init];
    }
    
    [writer writeInt32:(int32_t)_data.length];
    [writer writeData:_data];
}

// MARK: - IDisposable Implementation

- (void)dispose {
    // Cleanup if needed
    _img = nil;
    _data = nil;
}

@end
