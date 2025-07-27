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

#import "File.h"
#import "Stream.h"
#import "MemoryStream.h"
#import "FileStream.h"
#import "BinaryReader.h"
#import "HeaderData.h"
#import "HoleIndexItem.h"
#import "PackedFileDescriptor.h"
#import "HoleIndexItem.h"
#import "IPackageHeaderIndex.h"
#import "ClstWrapper.h"
#import <Foundation/Foundation.h>
#import "Registry.h"

const uint32_t FILELIST_TYPE = 0xE86B1EEF;

@interface File () {
    // Private instance variables (matching C# fields)
    BinaryReader *_reader;
    PackageBaseType _pType;
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
        if (_reader.baseStream == nil) {
            _reader = nil;
        } else {
            if (![_reader.baseStream canRead]) {
                _reader = nil;
            }
        }
    }
    return _reader;
}

- (BOOL)persistent {
    return _persistent;
}

- (void)setPersistent:(BOOL)persistent {
    // The C# implementation is commented out, so we just set the value
    _persistent = persistent;
    
    /*
    // This is the commented-out C# logic:
    // if (!persistent && value) this.OpenReader();
    // else if (persistent && !value) this.CloseReader();
    // persistent = value;
    */
}

- (PackageBaseType)pType {
    return _pType;
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
        NSString *fileNameWithoutExtension = [self.fileName stringByDeletingPathExtension];
        _fhg = (uint32_t)([Hashes fileGroupHash:fileNameWithoutExtension] | 0x7f000000);
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
        _pType = PackageBaseTypeStream;
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
    return [PackageMaintainer.maintainer loadPackageFromFile:filename sync:NO];
}

+ (instancetype)loadFromFile:(NSString *)filename sync:(BOOL)sync {
    return [PackageMaintainer.maintainer loadPackageFromFile:filename sync:sync];
}

+ (instancetype)loadFromStream:(BinaryReader *)br {
    return [[GeneratableFile alloc] initWithBinaryReader:br];
}

+ (instancetype)createNew {
    GeneratableFile *gf = [GeneratableFile loadFromStream:[[BinaryReader alloc] initWithStream:[[GeneratableFile loadFromStream:nil] build]]];
    if ([UserVerification haveValidUserId]) {
        gf.header.created = [UserVerification userId];
    }
    return gf;
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
    _persistent = [AppPreferences persistent]; // Get from settings
    StreamItem *si = [StreamFactory useStream:filename access:FileAccessRead];
    
    if (si.streamState != StreamStateRemoved) {
        [si.fileStream seekToOffset:0 origin:SeekOriginBegin];
        _pType = PackageBaseTypeFilename;
        _flname = filename;
        BinaryReader *br = [[BinaryReader alloc] initWithStream:si.fileStream];
        [self openByStream:br];
    } else {
        _pType = PackageBaseTypeStream;
        [self openByStream:nil];
    }
}

- (void)reloadReader {
    if (_reader != nil) return;
    if (_pType == PackageBaseTypeStream) return;
    
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
    
    if (_pType == PackageBaseTypeFilename) {
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
    
    if ((_pType == PackageBaseTypeFilename) && (_reader != nil)) {
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
    NSInteger count = _header.index.count;
    NSMutableArray<id<IPackedFileDescriptor>> *newFileIndex = [[NSMutableArray alloc] initWithCapacity:count];
    
    [_reader.baseStream seekToOffset:_header.index.offset origin:SeekOriginBegin];
    
    for (NSInteger i = 0; i < count; i++) {
        [self loadFileIndexItem:i intoArray:newFileIndex];
    }
    
    _fileindex = [newFileIndex copy];
    
    if (self.fileList != nil) {
        self.fileListFile = [[CompressedFileList alloc] initWithFileList:self.fileList package:self];
    }
}

- (void)loadFileIndexItem:(NSInteger)position intoArray:(NSMutableArray<id<IPackedFileDescriptor>> *)array {
    PackedFileDescriptor *item = [[PackedFileDescriptor alloc] init];
    
    [item loadFromStream:_header reader:_reader];
    
    _higestoffset = MAX(_higestoffset, item.offset + item.size);
    
    [array addObject:item];
    
    if (item.pfdType == FILELIST_TYPE) {
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
    
    if ([PackageMaintainer.maintainer.fileIndex containsObject:self.saveFileName]) {
        [PackageMaintainer.maintainer.fileIndex clear];
    }
}

#pragma mark - Missing IPackageFile Protocol Methods

- (id<IPackageFile>)clone {
    File *fl = (File *)[self newCloneBase];
    for (id<IPackedFileDescriptor> pfd in self.index) {
        id<IPackedFileDescriptor> npfd = [pfd clone];
        npfd.userData = [self readDescriptor:pfd].uncompressedData;
        
        [fl addDescriptor:npfd];
    }

    fl->_header = (HeaderData *)[self.header clone];
    fl->_lcs = self->_lcs;
    if (self->_filelist != nil) {
        fl->_filelist = (PackedFileDescriptor *)[fl findFileWithDescriptor:self->_filelist];
        fl->_filelistfile = [[CompressedFileList alloc] initWithIndexType:fl.header.indexType];
    }

    return (id<IPackageFile>)fl;
}

- (id<IPackedFileDescriptor>)getFileIndex:(uint32_t)index {
    if ((index >= _fileindex.count) || (index < 0)) return nil;
    return _fileindex[index];
}

- (void)remove:(id<IPackedFileDescriptor>)pfd {
    if (_fileindex == nil) return;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < _fileindex.count; i++) {
        if (_fileindex[i] != pfd) {
            [list addObject:_fileindex[i]];
        }
    }
    
    NSArray *newindex = [list copy];
    _header.index.count = newindex.count;
    _fileindex = newindex;

    [self unlinkResourceDescriptor:pfd];
    
    [self fireIndexEvent];
    [self fireRemoveEvent];
}

- (void)removeMarked {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (id<IPackedFileDescriptor> pfd in _fileindex) {
        if (![pfd markForDelete]) {
            [list addObject:pfd];
        } else {
            ((PackedFileDescriptor *)pfd).packageInternalUserDataChange = nil;
            [pfd removeDescriptionChangedTarget:self action:@selector(resourceDescriptionChanged:)];
        }
    }

    NSArray *pfds = [list copy];

    BOOL changed = (_fileindex.count != pfds.count);
    _fileindex = pfds;
    _header.index.count = _fileindex.count;

    if (changed) {
        [self fireRemoveEvent];
        [self fireIndexEvent];
    }
}

- (void)addDescriptors:(NSArray<id<IPackedFileDescriptor>> *)pfds {
    for (id<IPackedFileDescriptor> pfd in pfds) {
        [self addDescriptor:pfd];
    }
}

- (id<IPackedFileDescriptor>)addWithType:(uint32_t)pfdType subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.pfdType = pfdType;
    pfd.subType = subtype;
    pfd.group = group;
    pfd.instance = instance;

    [self addDescriptor:pfd];

    return pfd;
}

- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd {
    [self addDescriptor:pfd isNew:NO];
}

- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd isNew:(BOOL)isNew {
    NSArray<id<IPackedFileDescriptor>> *newindex = nil;
    if (_fileindex != nil) {
        NSMutableArray *mutableArray = [_fileindex mutableCopy];
        [mutableArray addObject:pfd];
        newindex = [mutableArray copy];
    } else {
        newindex = @[pfd];
    }

    if (isNew) {
        ((PackedFileDescriptor *)pfd).offset = (uint32_t)_higestoffset;
    }

    _higestoffset = MAX(_higestoffset, ((PackedFileDescriptor *)pfd).offset + ((PackedFileDescriptor *)pfd).size);
    _header.index.count = newindex.count;
    _fileindex = newindex;

    ((PackedFileDescriptor *)pfd).packageInternalUserDataChange = ^(id<IPackedFileDescriptor> sender) {
        [self resourceChanged:sender];
    };
    [pfd addDescriptionChangedTarget:self action:@selector(resourceDescriptionChanged:)];
    [self fireIndexEvent];
    [self fireAddEvent];
}

- (void)copyDescriptors:(id<IPackageFile>)package {
    for (id<IPackedFileDescriptor> pfd in package.index) {
        id<IPackedFileDescriptor> npfd = [pfd clone];
        npfd.userData = [package readDescriptor:pfd].uncompressedData;
        [self addDescriptor:npfd isNew:YES];
    }
}

- (id<IPackedFileDescriptor>)newDescriptorWithType:(uint32_t)pfdType subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.pfdType = pfdType;
    pfd.subtype = subtype;
    pfd.group = group;
    pfd.instance = instance;

    return pfd;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename {
    filename = [Hashes stripHashFromName:filename];
    uint32_t inst = [Hashes instanceHash:filename];
    uint32_t st = [Hashes subTypeHash:filename];

    NSArray<id<IPackedFileDescriptor>> *ret = [self findFileWithSubtype:st instance:inst];
    if (ret.count == 0) {
        ret = [self findFileWithSubtype:0 instance:inst];
    }
    return ret;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename type:(uint32_t)pfdType {
    filename = [Hashes stripHashFromName:filename];
    uint32_t inst = [Hashes instanceHash:filename];
    uint32_t st = [Hashes subTypeHash:filename];

    NSArray<id<IPackedFileDescriptor>> *ret = [self findFileWithType:pfdType subtype:st instance:inst];
    if (ret.count == 0) {
        ret = [self findFileWithType:pfdType subtype:0 instance:inst];
    }
    return ret;
}
- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(uint32_t)pfdType {
    NSMutableArray *list = [[NSMutableArray alloc] init];

    if (_fileindex != nil) {
        for (NSInteger i = 0; i < _fileindex.count; i++) {
            id<IPackedFileDescriptor> pfd = _fileindex[i];
            if (pfd.pfdType == pfdType) {
                [list addObject:pfd];
            }
        }
    }

    return [list copy];
}


- (NSArray<id<IPackedFileDescriptor>> *)findFileWithSubtype:(uint32_t)subtype instance:(uint32_t)instance {
    NSMutableArray *list = [[NSMutableArray alloc] init];

    for (id<IPackedFileDescriptor> pfd in _fileindex) {
        if ((pfd.instance == instance) && (pfd.subType == subtype)) {
            [list addObject:pfd];
        }
    }

    return [list copy];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileWithType:(uint32_t)pfdType subtype:(uint32_t)subtype instance:(uint32_t)instance {
    NSMutableArray *list = [[NSMutableArray alloc] init];

    if (_fileindex != nil) {
        for (id<IPackedFileDescriptor> pfd in _fileindex) {
            if ((pfd.pfdType == pfdType) && (pfd.instance == instance) && (pfd.subType == subtype)) {
                [list addObject:pfd];
            }
        }
    }

    return [list copy];
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

