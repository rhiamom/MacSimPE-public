//
//  cImageData.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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
// ***************************************************************************/

#import "cImageData.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "ExceptionForm.h"
#import "ImageLoader.h"
#import "FileTable.h"
#import "FileIndex.h"
#import "GenericRcolWrapper.h"
#import "cLevelInfo.h"
#import "cSGResource.h"
#import "RcolWrapper.h"
#import "MetaData.h"
#import "ScenegraphHelper.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import "MemoryStream.h"
#import "PackedFileDescriptor.h"


// MARK: - MipMap Implementation

@implementation MipMap {
    NSData *_data;
    NSImage *_image;
    MipMapType _dataType;
    NSString *_lifoFile;
    __weak ImageData *_parent;
    NSInteger _index;
    NSInteger _mapCount;
}

@synthesize dataType = _dataType;
@synthesize parent = _parent;

- (instancetype)initWithParent:(ImageData *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _dataType = MipMapTypeSimPEPlainData;
        _data = [[NSData alloc] init];
    }
    return self;
}

- (void)reloadTexture {
    if ((_dataType != MipMapTypeLifoReference) && (_data != nil)) {
        MemoryStream *memoryStream = [[MemoryStream alloc] initWithData:_data];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:memoryStream];
        _image = [ImageLoader loadWithTextureSize:self.parent.textureSize
                                           length:_data.length
                                           format:self.parent.format
                                           reader:reader
                                            index:_index
                                         mapCount:_mapCount];
    }
}

- (NSImage *)texture {
    if (_image == nil) {
        [self reloadTexture];
    }
    return _image;
}

- (void)setTexture:(NSImage *)texture {
    if (texture != nil) {
        _dataType = MipMapTypeTexture;
    }
    _image = texture;
}

- (NSData *)data {
    return _data;
}

- (void)setData:(NSData *)data {
    if (data != nil) {
        _dataType = MipMapTypeSimPEPlainData;
    }
    _data = data;
}

- (NSString *)lifoFile {
    return _lifoFile;
}

- (void)setLifoFile:(NSString *)lifoFile {
    if (lifoFile != nil) {
        _dataType = MipMapTypeLifoReference;
    }
    _lifoFile = lifoFile;
}

- (void)unserialize:(BinaryReader *)reader index:(NSInteger)index mapCount:(NSInteger)mapCount {
    _index = index;
    _mapCount = mapCount;
    _dataType = (MipMapType)[reader readByte];
    
    switch (_dataType) {
        case MipMapTypeTexture: {
            uint32_t imgSize = [reader readUInt32];
            int64_t pos = reader.baseStream.position;
            
            if (!self.parent.parent.fast) {
                @try {
                    _data = [reader readBytes:imgSize];
                    _dataType = MipMapTypeSimPEPlainData;
                    _image = nil;
                } @catch (NSException *exception) {
                    [ExceptionForm executeWithMessage:@"" exception:exception];
                }
            }
            
            // Read any remaining bytes to maintain proper stream position
            NSInteger remaining = MAX(0, pos + imgSize - reader.baseStream.position);
            if (remaining > 0) {
                [reader readBytes:remaining];
            }
            [reader.baseStream seekToOffset:pos + imgSize origin:SeekOriginBegin];
            break;
        }
        case MipMapTypeLifoReference: {
            _lifoFile = [reader readString];
            break;
        }
        default: {
            NSString *errorMsg = [NSString stringWithFormat:@"Unknown MipMap Datatype 0x%@",
                                 [Helper hexString:(uint8_t)_dataType]];
            @throw [NSException exceptionWithName:@"InvalidDataTypeException"
                                           reason:errorMsg
                                         userInfo:nil];
        }
    }
}

- (void)serialize:(BinaryWriter *)writer {
    MipMapType writeType = (_dataType == MipMapTypeSimPEPlainData) ? MipMapTypeTexture : _dataType;
    [writer writeUInt8:(uint8_t)writeType];
    
    switch (_dataType) {
        case MipMapTypeSimPEPlainData:
        case MipMapTypeTexture: {
            @try {
                if (_dataType == MipMapTypeTexture) {
                    _data = [ImageLoader saveWithFormat:self.parent.format image:_image];
                }
            } @catch (NSException *exception) {
                [ExceptionForm executeWithMessage:@"" exception:exception];
            }
            
            if (_data == nil) {
                _data = [[NSData alloc] init];
            }
            
            [writer writeUInt32:(uint32_t)_data.length];
            [writer writeData:_data];
            break;
        }
        case MipMapTypeLifoReference: {
            [writer writeString:_lifoFile];
            break;
        }
        default: {
            NSString *errorMsg = [NSString stringWithFormat:@"Unknown MipMap Datatype 0x%@",
                                 [Helper hexString:(uint8_t)_dataType]];
            @throw [NSException exceptionWithName:@"InvalidDataTypeException"
                                           reason:errorMsg
                                         userInfo:nil];
        }
    }
}

- (void)getReferencedLifo {
    if (_dataType == MipMapTypeLifoReference) {
        id<IScenegraphFileIndex> nfi = [FileTable.fileIndex addNewChild];
        [nfi addIndexFromPackage:self.parent.parent.package];
        BOOL success = [self getReferencedLifoNoLoad];
        [FileTable.fileIndex removeChild:nfi];
        [nfi clear];
        
        if (!success && ![FileTable.fileIndex loaded]) {
            [FileTable.fileIndex load];
            [self getReferencedLifoNoLoad];
        }
    }
}

- (BOOL)getReferencedLifoNoLoad {
    if (_dataType == MipMapTypeLifoReference) {
        id<IScenegraphFileIndexItem> item = [FileTableBase.fileIndex findFileByName:_lifoFile
                                                                               type:[MetaData LIFO]
                                                                           defGroup:[MetaData LOCAL_GROUP]
                                                                         beTolerant:YES];
        GenericRcol *rcol = nil;  // Declare the variable at the top
        
        if (item != nil) {
            // We have a global LIFO (loads faster)
            rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:item.fileDescriptor package:item.package]; // Use correct method signature
        } else {
            // The lifo wasn't found globally, so look in local package
            id<IPackageFile> pkg = self.parent.parent.package;
            NSArray<id<IPackedFileDescriptor>> *pfds = [pkg findFileByName:_lifoFile type:[MetaData LIFO]];  // Fixed method name
            if (pfds.count > 0) {
                rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                [rcol processData:pfds[0] package:pkg]; // Use correct method signature
            }
        }
        
        // Process the Lifo File if found
        if (rcol != nil) {
            LevelInfo *li = (LevelInfo *)rcol.blocks[0];
            _image = nil;
            self.data = li.data;
            return YES;
        }
    } else {
        return YES;
    }
    
    return NO;
}

- (NSString *)description {
    if (_dataType == MipMapTypeLifoReference) {
        return _lifoFile;
    }
    
    NSString *name;
    if (_image == nil) {
        name = @"";
    } else {
        name = [NSString stringWithFormat:@"Image %.0fx%.0f - ",
                _image.size.width, _image.size.height];
    }
    
    name = [name stringByAppendingString:self.parent.nameResource.fileName];
    return name;
}

- (void)dispose {
    _data = [[NSData alloc] init];
    _image = nil;
}

@end

// MARK: - MipMapBlock Implementation

@implementation MipMapBlock {
    NSMutableArray<MipMap *> *_mipMaps;
    __weak ImageData *_parent;
    uint32_t _creator;
    uint32_t _unknown1;
}

@synthesize parent = _parent;
@synthesize creator = _creator;
@synthesize unknown1 = _unknown1;

- (instancetype)initWithParent:(ImageData *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _mipMaps = [[NSMutableArray alloc] init];
        _creator = 0xffffffff;
        _unknown1 = 0x41200000;
    }
    return self;
}

- (NSArray<MipMap *> *)mipMaps {
    return [_mipMaps copy];
}

- (void)setMipMaps:(NSArray<MipMap *> *)mipMaps {
    _mipMaps = [mipMaps mutableCopy];
}

- (void)addDDSData:(NSArray<DDSData *> *)data {
    NSMutableArray<MipMap *> *newMipMaps = [[NSMutableArray alloc] initWithCapacity:data.count];
    
    // Process in reverse order
    for (NSInteger i = data.count - 1; i >= 0; i--) {
        DDSData *item = data[i];
        MipMap *mm = [[MipMap alloc] initWithParent:_parent];
        mm.texture = item.texture;
        mm.data = item.data;
        [newMipMaps addObject:mm];
    }
    
    _mipMaps = newMipMaps;
}

- (void)unserialize:(BinaryReader *)reader {
    uint32_t innerCount;
    
    switch (_parent.version) {
        case 0x09:
            innerCount = [reader readUInt32];
            break;
        case 0x07:
            innerCount = _parent.mipMapLevels;
            break;
        default: {
            NSString *errorMsg = [NSString stringWithFormat:@"Unknown MipMap version 0x%@",
                                 [Helper hexString:_parent.version]];
            @throw [NSException exceptionWithName:@"UnknownVersionException"
                                           reason:errorMsg
                                         userInfo:nil];
        }
    }
    
    _mipMaps = [[NSMutableArray alloc] initWithCapacity:innerCount];
    for (uint32_t i = 0; i < innerCount; i++) {
        MipMap *mipMap = [[MipMap alloc] initWithParent:_parent];
        [mipMap unserialize:reader index:i mapCount:innerCount];
        [_mipMaps addObject:mipMap];
    }
    
    _creator = [reader readUInt32];
    if ((_parent.version == 0x08) || (_parent.version == 0x09)) {
        _unknown1 = [reader readUInt32];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    switch (_parent.version) {
        case 0x09:
            [writer writeUInt32:(uint32_t)_mipMaps.count];
            break;
    }
    
    for (MipMap *mipMap in _mipMaps) {
        [mipMap serialize:writer];
    }
    
    [writer writeUInt32:_creator];
    if (_parent.version == 0x09) {
        [writer writeUInt32:_unknown1];
    }
}

- (MipMap *)largestTexture {
    MipMap *largest = nil;
    
    for (MipMap *mm in _mipMaps) {
        if (mm.dataType != MipMapTypeLifoReference) {
            NSImage *img = mm.texture;
            if (largest != nil) {
                if (largest.texture.size.width < img.size.width) {
                    largest = mm;
                }
            } else {
                largest = mm;
            }
        }
    }
    
    return largest;
}

- (MipMap *)getLargestTexture:(NSSize)size {
    MipMap *largest = nil;
    
    for (MipMap *mm in _mipMaps) {
        if (mm.dataType != MipMapTypeLifoReference) {
            NSImage *img = mm.texture;
            if (largest != nil) {
                if (largest.texture.size.width < img.size.width) {
                    largest = mm;
                }
            } else {
                largest = mm;
            }
            
            if ((img.size.width > size.width) || (img.size.height > size.height)) {
                break;
            }
        }
    }
    
    return largest;
}

- (void)getReferencedLifos {
    for (MipMap *mm in _mipMaps) {
        [mm getReferencedLifo];
    }
}

- (NSString *)description {
    if (_mipMaps.count == 1) {
        return [NSString stringWithFormat:@"0x%@ - 0x%@ (1 Item)",
                [Helper hexString:_creator], [Helper hexString:_unknown1]];
    }
    return [NSString stringWithFormat:@"0x%@ - 0x%@ (%lu Items)",
            [Helper hexString:_creator], [Helper hexString:_unknown1],
            (unsigned long)_mipMaps.count];
}

- (void)dispose {
    for (MipMap *mm in _mipMaps) {
        [mm dispose];
    }
    [_mipMaps removeAllObjects];
}

@end

// MARK: - ImageData Implementation

@implementation ImageData {
    NSSize _textureSize;
    TxtrFormats _format;
    uint32_t _mipMapLevels;
    float _unknown0;
    uint32_t _unknown1;
    NSString *_fileNameRepeat;
    NSMutableArray<MipMapBlock *> *_mipMapBlocks;
}

@synthesize textureSize = _textureSize;
@synthesize format = _format;
@synthesize mipMapLevels = _mipMapLevels;
@synthesize unknown0 = _unknown0;
@synthesize unknown1 = _unknown1;
@synthesize fileNameRepeat = _fileNameRepeat;

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _textureSize = NSMakeSize(1, 1);
        _mipMapBlocks = [[NSMutableArray alloc] init];
        MipMapBlock *block = [[MipMapBlock alloc] initWithParent:self];
        [_mipMapBlocks addObject:block];
        _mipMapLevels = 1;
        self.sgres = [[SGResource alloc] initWithParent:nil];
        self.blockId = 0x1c4a276c;
        _fileNameRepeat = @"";
        self.version = 0x09;
        _unknown0 = 1.0f;
        _format = TxtrFormatsExtRaw24Bit;
    }
    return self;
}

- (NSArray<MipMapBlock *> *)mipMapBlocks {
    return [_mipMapBlocks copy];
}

- (void)setMipMapBlocks:(NSArray<MipMapBlock *> *)mipMapBlocks {
    _mipMapBlocks = [mipMapBlocks mutableCopy];
}

- (void)setFormat:(TxtrFormats)format {
    if (_format != format) {
        // When the Format changes we need to get the Picture data FIRST
        for (MipMapBlock *mmp in _mipMapBlocks) {
            for (MipMap *mm in mmp.mipMaps) {
                NSImage *img = mm.texture;
                mm.texture = img;
            }
        }
    }
    _format = format;
}

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    (void)[reader readString];  // advance past unused string
    
    self.sgres.blockId = [reader readUInt32];
    [self.sgres unserialize:reader];
    
    if (self.parent.fast) {
      
        _textureSize = NSMakeSize(0, 0);
        _mipMapBlocks = [[NSMutableArray alloc] init];
        return;
    }
    
    int32_t w = [reader readInt32];
    int32_t h = [reader readInt32];
    _textureSize = NSMakeSize(w, h);
    
    _format = (TxtrFormats)[reader readUInt32];
    _mipMapLevels = [reader readUInt32];
    _unknown0 = [reader readSingle];
    
    uint32_t blockCount = [reader readUInt32];
    _mipMapBlocks = [[NSMutableArray alloc] initWithCapacity:blockCount];
    
    _unknown1 = [reader readUInt32];
    
    if (self.version == 0x09) {
        _fileNameRepeat = [reader readString];
    }
    
    for (uint32_t i = 0; i < blockCount; i++) {
        MipMapBlock *block = [[MipMapBlock alloc] initWithParent:self];
        [block unserialize:reader];
        [_mipMapBlocks addObject:block];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    switch (self.version) {
        case 0x07:
            if (_mipMapBlocks.count > 0) {
                _mipMapLevels = (uint32_t)_mipMapBlocks[0].mipMaps.count;
            } else {
                _mipMapLevels = 0;
            }
            break;
    }
    
    [writer writeUInt32:self.version];
    NSString *s = [self.sgres register:nil];
    [writer writeString:s];
    
    [writer writeUInt32:self.sgres.blockId];
    [self.sgres serialize:writer];
    
    [writer writeInt32:(int32_t)_textureSize.width];
    [writer writeInt32:(int32_t)_textureSize.height];
    
    [writer writeUInt32:(uint32_t)_format];
    [writer writeUInt32:_mipMapLevels];
    [writer writeSingle:_unknown0];
    [writer writeUInt32:(uint32_t)_mipMapBlocks.count];
    [writer writeUInt32:_unknown1];
    
    if (self.version == 0x09) {
        [writer writeString:_fileNameRepeat];
    }
    
    for (MipMapBlock *block in _mipMapBlocks) {
        [block serialize:writer];
    }
}

- (void)referencedItems:(NSMutableDictionary *)refMap parentGroup:(uint32_t)parentGroup {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (MipMapBlock *mmp in _mipMapBlocks) {
        for (MipMap *mm in mmp.mipMaps) {
            if (mm.dataType == MipMapTypeLifoReference) {
                PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
                                pfd.type = [MetaData LIFO];
                                pfd.group = parentGroup;
                                pfd.filename = mm.lifoFile;
                                // Note: We may need to set other properties like instance if needed
                                
                                [list addObject:pfd];
                            }
                        }
                    }
                    
                    refMap[@"LIFO"] = list;
}

- (MipMap *)largestTexture {
    if (_mipMapBlocks.count == 0) {
        return nil;
    }
    
    return _mipMapBlocks[0].largestTexture;
}

- (MipMap *)getLargestTexture:(NSSize)size {
    if (_mipMapBlocks.count == 0) {
        return nil;
    }
    
    return [_mipMapBlocks[0] getLargestTexture:size];
}

- (void)getReferencedLifos {
    for (MipMapBlock *mmp in _mipMapBlocks) {
        [mmp getReferencedLifos];
    }
}

- (void)dispose {
    for (MipMapBlock *mmb in _mipMapBlocks) {
        [mmb dispose];
    }
    [_mipMapBlocks removeAllObjects];
}

@end
