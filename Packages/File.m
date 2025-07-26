//
//  File.m
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
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

#import "File.h"
#import "Stream.h"
#import "MemoryStream.h"
#import "FileStream.h"
#import "BinaryReader.h"
#import "HeaderData.h"
#import "HoleIndexItem.h"
#import "PackedFileDescriptor.h"
#import "HoleIndexItem.h"

@interface File () {
    // Private instance variables (matching C# fields)
    BinaryReader *_reader;
    PackageBaseType _type;
    HeaderData *_header;
    PackedFileDescriptor *_filelist;
    CompressedFileList *_filelistfile;
    NSArray<id<IPackedFileDescriptor>> *_fileindex;
    NSArray<HoleIndexItem *> *_holeindex;
    NSString *_flname;
    BOOL _persistent;
    BOOL _lcs;
    uint64_t _higestoffset;
    uint32_t _fhg;
    
    // Event handling flags
    BOOL _pause;
    BOOL _indexevent;
    BOOL _addevent;
    BOOL _remevent;
}
@end

@implementation File

// MARK: - Properties
- (BinaryReader *)reader {
    if (_reader != nil) {
        // Check if reader is still valid (equivalent to C# logic)
        // TODO: Add stream validation
    }
    return _reader;
}

- (BOOL)persistent {
    return _persistent;
}

- (void)setPersistent:(BOOL)persistent {
    _persistent = persistent;
    // TODO: Add reader management logic
}

- (PackageBaseType)type {
    return _type;
}

- (id<IPackageHeader>)header {
    return _header;
}

- (NSArray<id<IPackedFileDescriptor>> *)index {
    if (_fileindex == nil) {
        _fileindex = @[];
    }
    return _fileindex;
}

- (BOOL)hasUserChanges {
    if (self.index == nil) return NO;
    
    for (id<IPackedFileDescriptor> pfd in self.index) {
        if ([pfd changed]) return YES;
    }
    return NO;
}

- (NSString *)fileName {
    return _flname;
}

- (void)setFileName:(NSString *)fileName {
    _flname = fileName;
    _fhg = 0; // Reset file group hash
}

- (NSString *)saveFileName {
    if (_flname == nil) return @"";
    return _flname;
}

- (uint32_t)fileGroupHash {
    if (_fhg == 0) {
        // TODO: Calculate hash from filename
        // _fhg = (uint32_t)(Hashes.FileGroupHash(Path.GetFileNameWithoutExtension(FileName)) | 0x7f000000);
    }
    return _fhg;
}

- (BOOL)loadedCompressedState {
    return _lcs;
}

- (PackedFileDescriptor *)fileList {
    return _filelist;
}

- (CompressedFileList *)fileListFile {
    return _filelistfile;
}

// MARK: - Initialization
- (instancetype)initWithBinaryReader:(BinaryReader *)br {
    self = [super init];
    if (self) {
        _pause = NO;
        _type = PackageBaseTypeStream;
        [self openByStream:br];
    }
    return self;
}

- (instancetype)initWithFileName:(NSString *)filename {
    self = [super init];
    if (self) {
        _pause = NO;
        [self reloadFromFile:filename];
    }
    return self;
}

+ (instancetype)loadFromFile:(NSString *)filename {
    // TODO: Use PackageMaintainer
    return [[self alloc] initWithFileName:filename];
}

+ (instancetype)loadFromFile:(NSString *)filename sync:(BOOL)sync {
    // TODO: Use PackageMaintainer with sync parameter
    return [[self alloc] initWithFileName:filename];
}

+ (instancetype)loadFromStream:(BinaryReader *)br {
    // TODO: Return GeneratableFile instead
    return [[self alloc] initWithBinaryReader:br];
}

+ (instancetype)createNew {
    // TODO: Implement new empty package creation
    return [[self alloc] initWithBinaryReader:nil];
}

// MARK: - Basic Methods (stubs for now)
// Replace the stub methods in File.m with these implementations:

// MARK: - Core Loading Methods
- (void)openByStream:(BinaryReader *)br {
    _lcs = NO;
    _higestoffset = 0;
    _fhg = 0;
    _reader = br;
    
    if (_header == nil) {
        _header = [[HeaderData alloc] init];
    }
    
    if (br != nil) {
        if ([br.baseStream length] > 0) {
            [self lockStream];
            [_header loadFromReader:br];
            [self loadFileIndex];
            [self loadHoleIndex];
            [self unlockStream];
        }
    }
    
    [self closeReader];
}

- (void)reloadFromFile:(NSString *)filename {
    _persistent = NO; // TODO: Get from settings
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:filename options:0 error:&error];
    
    if (data != nil) {
        _type = PackageBaseTypeFilename;
        _flname = filename;
        
        MemoryStream *stream = [[MemoryStream alloc] initWithData:data];
        BinaryReader *br = [[BinaryReader alloc] initWithStream:stream];
        [self openByStream:br];
    } else {
        _type = PackageBaseTypeStream;
        [self openByStream:nil];
    }
}

- (void)reloadReader {
    if (_reader != nil) return;
    if (_type == PackageBaseTypeStream) return;
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:_flname options:0 error:&error];
    if (data != nil) {
        FileStream *fileStream = [[FileStream alloc] initWithData:data access:FileAccessReadWrite];
        _reader = [[BinaryReader alloc] initWithStream:fileStream];
    }
}

// MARK: - Reader Management
- (void)openReader {
    if (_persistent) {
        [self reloadReader];
        return;
    }
    
    if (_type == PackageBaseTypeFilename) {
        [self closeReader];
        
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:_flname options:0 error:&error];
        if (data == nil) {
            @throw [NSException exceptionWithName:@"FileNotFoundException"
                                           reason:[NSString stringWithFormat:@"Unable to find %@", self.fileName]
                                         userInfo:nil];
        }
        
        FileStream *fileStream = [[FileStream alloc] initWithData:data access:FileAccessRead];
        _reader = [[BinaryReader alloc] initWithStream:fileStream];
    }
}

- (void)closeReader {
    if (_persistent) return;
    
    if ((_type == PackageBaseTypeFilename) && (_reader != nil)) {
        [_reader close];
        _reader = nil;
    }
}

// MARK: - Stream Locking
- (void)lockStream {
    // File locking not typically needed on macOS
}

- (void)unlockStream {
    // Corresponding unlock
}

// MARK: - File Index Loading
- (void)loadFileIndex {
    NSInteger count = [_header.index count];
    NSMutableArray<id<IPackedFileDescriptor>> *newFileIndex = [[NSMutableArray alloc] initWithCapacity:count];
    
    [_reader.baseStream seekToOffset:_header.index.offset origin:SeekOriginBegin];
    
    for (NSInteger i = 0; i < count; i++) {
        [self loadFileIndexItem:i intoArray:newFileIndex];
    }
    
    _fileindex = [newFileIndex copy];
    
    if (self.fileList != nil) {
        self.fileList = self.fileList;
    }
}

- (void)loadFileIndexItem:(NSInteger)position intoArray:(NSMutableArray<id<IPackedFileDescriptor>> *)array {
    PackedFileDescriptor *item = [[PackedFileDescriptor alloc] init];
    
    [item loadFromStream:_header reader:_reader];
    
    _higestoffset = MAX(_higestoffset, item.offset + item.size);
    
    [array addObject:item];
    
    if (item.type == FILELIST_TYPE) {
        _filelist = item;
    }
}

// MARK: - Hole Index Loading
- (void)loadHoleIndex {
    NSInteger count = [_header.hole count];
    NSMutableArray<HoleIndexItem *> *newHoleIndex = [[NSMutableArray alloc] initWithCapacity:count];
    
    if (_reader == nil) [self openReader];
    [_reader.baseStream seekToOffset:_header.hole.offset origin:SeekOriginBegin];
    
    for (NSInteger i = 0; i < count; i++) {
        [self loadHoleIndexItem:i intoArray:newHoleIndex];
    }
    
    _holeindex = [newHoleIndex copy];
}

- (void)loadHoleIndexItem:(NSInteger)position intoArray:(NSMutableArray<HoleIndexItem *> *)array {
    HoleIndexItem *item = [[HoleIndexItem alloc] init];
    
    item.offset = [_reader readUInt32];
    item.size = [_reader readInt32];
    
    [array addObject:item];
}

- (void)close {
    [self closeWithTotal:NO];
}

- (void)closeWithTotal:(BOOL)total {
    if (self.reader != nil) {
        [self.reader close];
    }
    
    if (total) {
        if (self.index != nil) {
            for (id<IPackedFileDescriptor> pfd in self.index) {
                if (pfd != nil) {
                    [pfd markInvalid];
                }
            }
        }
    }
    
    // TODO: Add PackageMaintainer cleanup if needed
}

#pragma mark - Missing IPackageFile Protocol Methods

- (id<IPackageFile>)clone {
    // TODO: Implement clone method
    return nil;
}

- (id<IPackedFileDescriptor>)getFileIndex:(uint32_t)index {
    // TODO: Implement
    return nil;
}

- (void)remove:(id<IPackedFileDescriptor>)pfd {
    // TODO: Implement
}

- (void)removeMarked {
    // TODO: Implement
}

- (void)addDescriptors:(NSArray<id<IPackedFileDescriptor>> *)pfds {
    // TODO: Implement
}

- (id<IPackedFileDescriptor>)addWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance {
    // TODO: Implement
    return nil;
}

- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd {
    // TODO: Implement
}

- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd isNew:(BOOL)isNew {
    // TODO: Implement
}

- (void)copyDescriptors:(id<IPackageFile>)package {
    // TODO: Implement
}

- (id<IPackedFileDescriptor>)newDescriptorWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance {
    // TODO: Implement
    return nil;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename {
    // TODO: Implement
    return @[];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename type:(uint32_t)type {
    // TODO: Implement
    return @[];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(uint32_t)type {
    // TODO: Implement
    return @[];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileWithSubtype:(uint32_t)subtype instance:(uint32_t)instance {
    // TODO: Implement
    return @[];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileWithType:(uint32_t)type subtype:(uint32_t)subtype instance:(uint32_t)instance {
    // TODO: Implement
    return @[];
}

- (id<IPackedFileDescriptor>)findFileWithDescriptor:(id<IPackedFileDescriptor>)pfd {
    // TODO: Implement
    return nil;
}

- (id<IPackedFileDescriptor>)findFileWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance {
    // TODO: Implement
    return nil;
}

- (id<IPackedFileDescriptor>)findExactFile:(id<IPackedFileDescriptor>)pfd {
    // TODO: Implement
    return nil;
}

- (id<IPackedFileDescriptor>)findExactFileWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance offset:(uint32_t)offset {
    // TODO: Implement
    return nil;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFilesByGroup:(uint32_t)group {
    // TODO: Implement
    return @[];
}

- (id<IPackedFile>)read:(uint32_t)item {
    // TODO: Implement
    return nil;
}

- (id<IPackedFile>)readDescriptor:(id<IPackedFileDescriptor>)pfd {
    // TODO: Implement
    return nil;
}

- (id<IPackedFile>)getStream:(id<IPackedFileDescriptor>)pfd {
    // TODO: Implement
    return nil;
}

- (void)save {
    // TODO: Implement
}

- (void)saveWithFilename:(NSString *)filename {
    // TODO: Implement
}

- (void)beginUpdate {
    // TODO: Implement
}

- (void)forgetUpdate {
    // TODO: Implement
}

- (void)endUpdate {
    // TODO: Implement
}
    
    // MARK: - Dealloc
    - (void)dealloc {
        [self closeWithTotal:YES];
    }

@end

