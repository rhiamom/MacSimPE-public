//
//  File.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
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

#import "BinaryReader.h"
#import "ClstItem.h"
#import "CompressedFileList.h"
#import "File.h"
#import "FileIndex.h"
#import "FileStream.h"
#import "GeneratableFile.h"
#import "Hashes.h"
#import "HeaderData.h"
#import "HeaderIndex.h"
#import "Helper.h"
#import "HoleIndexItem.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "MemoryStream.h"
#import "MetaData.h"
#import "PackageMaintainer.h"
#import "PackedFile.h"
#import "PackedFileDescriptor.h"
#import "PackedFileDescriptors.h"
#import "Registry.h"
#import "Stream.h"
#import "StreamMaintainer.h"

@interface File ()

@property (nonatomic, strong, nullable) BinaryReader *reader;
@property (nonatomic, assign) PackageBaseType packageType;
@property (nonatomic, strong) HeaderData *header;
@property (nonatomic, strong, nullable) PackedFileDescriptor *filelist;
@property (nonatomic, strong, nullable) CompressedFileList *filelistfile;
@property (nonatomic, strong) PackedFileDescriptors *fileindex;
@property (nonatomic, strong) NSMutableArray<HoleIndexItem *> *holeindex;
@property (nonatomic, strong, nullable) NSString *flname;
@property (nonatomic, assign) long long highestOffset;
@property (nonatomic, assign) uint32_t fhg;
@property (nonatomic, assign) BOOL lcs;
@property (nonatomic, assign) BOOL pause;
@property (nonatomic, assign) BOOL indexEvent;
@property (nonatomic, assign) BOOL addEvent;
@property (nonatomic, assign) BOOL removeEvent;

@end

@implementation File

// MARK: - Constants

const uint32_t FILELIST_TYPE = 0xE86B1EEF;

// Manual synthesize the event properties
@synthesize addedResource = _addedResource;
@synthesize endedUpdate = _endedUpdate;
@synthesize indexChanged = _indexChanged;
@synthesize removedResource = _removedResource;
@synthesize savedIndex = _savedIndex;

// MARK: - Initialization

- (instancetype)initWithBinaryReader:(BinaryReader *)br {
    self = [super init];
    if (self) {
        self.pause = NO;
        self.packageType = PackageBaseTypeStream;
        [self openByStream:br];
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        self.pause = NO;
        [self reloadFromFile:filename];
    }
    return self;
}

- (void)dealloc {
    [self closeWithTotal:YES];
}

- (void)reload {
    [self reloadFromFile:self.flname];
}

// MARK: - Properties

- (HeaderIndex *)headerIndex {
    return (HeaderIndex *)self.index;  // or however you want to implement it
}

- (BOOL)hasUserChanges {
    if (self.index == nil) return NO;
    
    for (id<IPackedFileDescriptor> pfd in self.index) {
        if ([pfd changed]) return YES;
    }
    return NO;
}

- (PackedFileDescriptors *)index {
    if (self.fileindex == nil) {
        self.fileindex = [[PackedFileDescriptors alloc] init];
    }
    return self.fileindex;
}

- (void)setIndex:(PackedFileDescriptors *)index {
    self.fileindex = index;
    ((HeaderData *)self.header).headerIndex.count = (uint32_t)[index count];
}

- (NSString *)fileName {
    return self.flname;
}

- (void)setFileName:(NSString *)fileName {
    self.flname = fileName;
    self.fhg = 0;
}

- (NSString *)saveFileName {
    if (self.flname == nil) return @"";
    return self.flname;
}

- (uint32_t)fileGroupHash {
    if (self.fhg == 0) {
        NSString *baseName = [[self.fileName lastPathComponent] stringByDeletingPathExtension];
        self.fhg = (uint32_t)([Hashes fileGroupHash:baseName] | 0x7f000000);
    }
    return self.fhg;
}

- (long long)nextFreeOffset {
    return self.highestOffset;
}

- (BOOL)loadedCompressedState {
    return self.lcs;
}

- (PackedFileDescriptor *)fileList {
    return self.filelist;
}

- (void)setFileList:(PackedFileDescriptor *)fileList {
    self.filelist = fileList;
    
    // Get the FileListFile
    if (fileList != nil) {
        self.filelistfile = [[CompressedFileList alloc] initWithDescriptor:fileList package:self];
    }
}

- (CompressedFileList *)fileListFile {
    // Get the FileListFile
    if ((self.filelist != nil) && (self.filelistfile == nil)) {
        self.filelistfile = [[CompressedFileList alloc] initWithDescriptor:self.filelist package:self];
    }
    return self.filelistfile;
}

- (id<IPackageHeader>)header {
    return self.header;
}

// MARK: - Reader Management

- (void)reloadReader {
    if (self.reader != nil) return;
    if (self.packageType == PackageBaseTypeStream) return;
    
    StreamItem *si = [StreamFactory useStream:self.flname fileAccess:[Helper integerToString:FileAccessReadWrite]];
    self.reader = [[BinaryReader alloc] initWithStream:(Stream *)si.fileStream];
}

- (BinaryReader *)reader {
    if (_reader != nil) {
        if (_reader.baseStream == nil) {
            _reader = nil;
        } else if (![_reader.baseStream canRead]) {
            _reader = nil;
        }
    }
    return _reader;
}

- (void)openReader {
    if (self.persistent) {
        StreamItem *si = [StreamFactory useStream:self.flname fileAccess:[Helper integerToString:FileAccessRead]];
        [si setFileAccess:[Helper integerToString:FileAccessRead]];
        if (si.streamState != StreamStateRemoved) {
            self.reader = [[BinaryReader alloc] initWithStream:(Stream *)si.fileStream];
        }
        return;
    }
    
    if (self.packageType == PackageBaseTypeFilename) {
        [self closeReader];
        StreamItem *si = [StreamFactory useStream:self.flname fileAccess:[Helper integerToString:FileAccessRead]];
        if (si.streamState == StreamStateRemoved) {
            @throw [NSException exceptionWithName:@"FileNotFoundException"
                                           reason:[NSString stringWithFormat:@"The File was moved or deleted while SimPE was running. Unable to find %@", self.fileName]
                                         userInfo:nil];
        }
        self.reader = [[BinaryReader alloc] initWithStream:(Stream *)si.fileStream];
    }
}

- (void)closeReader {
    if (self.persistent) return;
    
    if ((self.packageType == PackageBaseTypeFilename) && (self.reader != nil)) {
        StreamItem *si = [StreamFactory findStreamItem:(FileStream *)self.reader.baseStream];
        if (si != nil) [si close];
        self.reader = nil;
    }
}

// MARK: - File Loading

- (void)openByStream:(BinaryReader *)br {
    self.lcs = NO;
    self.highestOffset = 0;
    self.fhg = 0;
    self.reader = br;
    
    if (self.header == nil) {
        self.header = [[HeaderData alloc] init];
    }
    
    if (br != nil) {
        if ([br.baseStream length] > 0) {
            [self lockStream];
            [(HeaderData *)self.header loadFromReader:br];

            // ---- BEGIN: Repair index count (fallback when header is bogus) ----
            // Determine index entry size from header.indexType
            // Short: T(4) G(4) I32(4) Off(4) Size(4)  => 20 bytes
            // Long : T(4) G(4) I32(4) Sub(4) Off(4) Size(4) => 24 bytes
            const NSUInteger entrySize =
                (self.header.indexType == ptLongFileIndex) ? 24 : 20;

            uint64_t idxOff  = (uint64_t)self.header.index.offset;
            int64_t  idxSize = (int64_t) self.header.index.size;
            uint64_t fileLen = (uint64_t)br.baseStream.length;

            BOOL offsetOK = (idxOff > 0 && idxOff < fileLen);

            // Prefer header size if sane (fits in file and divides evenly)
            NSUInteger countFromHeader = 0;
            if (offsetOK &&
                idxSize > 0 &&
                (idxOff + (uint64_t)idxSize) <= fileLen &&
                (idxSize % (int64_t)entrySize) == 0) {
                countFromHeader = (NSUInteger)(idxSize / (int64_t)entrySize);
            }

            // Fallback: derive from EOF if header size is zero/bad
            NSUInteger countFromEOF = 0;
            if (offsetOK) {
                countFromEOF = (NSUInteger)((fileLen - idxOff) / (uint64_t)entrySize);
            }

            NSUInteger repairedCount = countFromHeader ? countFromHeader : countFromEOF;
            if (repairedCount == 0) {
                @throw [NSException exceptionWithName:@"DBPFIndexError"
                                               reason:@"Unable to determine DBPF index count (bad header or unsupported variant)."
                                             userInfo:nil];
            }

            // NOTE: self.header is typed as id<IPackageHeader>, so cast to HeaderData
            ((HeaderData *)self.header).headerIndex.count = (int32_t)repairedCount;
            // ---- END: Repair index count ----

            [self loadFileIndex];
            [self loadHoleIndex];
            [self unlockStream];
        }
    }
    
    [self closeReader];
}


- (void)reloadFromFile:(NSString *)filename {
    self.persistent = [[NSUserDefaults standardUserDefaults] boolForKey:@"Persistent"];
    StreamItem *si = [StreamFactory useStream:self.flname fileAccess:[Helper integerToString:FileAccessRead]];
    
    if (si.streamState != StreamStateRemoved) {
        [si.fileStream seekToOffset:0 origin:SeekOriginBegin];
        self.packageType = PackageBaseTypeFilename;
        self.flname = filename;
        BinaryReader *br = [[BinaryReader alloc] initWithStream:si.fileStream];
        [self openByStream:br];
    } else {
        self.packageType = PackageBaseTypeStream;
        [self openByStream:nil];
    }
}

- (void)clearFileIndex {
    if (self.fileindex != nil) {
        for (NSInteger i = self.fileindex.count - 1; i >= 0; i--) {
            [self unlinkResourceDescriptor:self.fileindex[i]];
        }
    }
    self.fileindex = [[PackedFileDescriptors alloc] init];
}

// MARK: - File Index Loading

- (void)loadFileIndex {
    self.fileindex = [[PackedFileDescriptors alloc] initWithCapacity:self.header.index.count];
    uint32_t counter = 0;
    
    [self.reader.baseStream seekToOffset:self.header.index.offset origin:SeekOriginBegin];
    
    while (counter < self.header.index.count) {
        [self loadFileIndexItem:counter];
        counter++;
    }
    
    // Load the File Index File
    if (self.fileList != nil) {
        [self setFileList:self.fileList];
    }
}

- (void)loadFileIndexItem:(uint32_t)position {
    PackedFileDescriptor *item = [[PackedFileDescriptor alloc] init];
    
    [item loadFromStream:self.header reader:self.reader];
    
    // Set up event handlers
    item.packageInternalUserDataChange = ^(id<IPackedFileDescriptor> descriptor) {
        [self resourceChanged:descriptor];
    };
    
    // TODO: Set up description changed handler
    // [item addDescriptionChangedHandler:^{ [self resourceDescriptionChanged:nil]; }];
    
    self.highestOffset = MAX(self.highestOffset, (long long)(item.offset + item.size));
    
    if (position < [self.fileindex count]) {
        [self.fileindex setObject:item atUnsignedIndex:position];
    } else {
        [self.fileindex addObject:item];
    }
    
    // Remember the filelist
    if (item.pfdType == FILELIST_TYPE) {
        self.filelist = item;
    }
}

// MARK: - Compressed State Management

- (void)loadCompressedState {
    // Load the File Index File
    if (self.fileindex != nil) {
        [self beginUpdate];
        
        // Setup the compression State
        for (PackedFileDescriptor *pfd in self.fileindex) {
            PackedFile *packedFile = [self getPackedFile:pfd data:[NSData data]];
            pfd.wasCompressed = packedFile.isCompressed;
        }
        
        // Now delete all pending Events
        [self forgetUpdate];
        [self endUpdate];
        self.lcs = YES;
    }
}

// MARK: - Hole Index Loading

- (void)loadHoleIndex {
    id<IPackageHeaderIndex> headerIndex = (id<IPackageHeaderIndex>)self.header;
    
    if (headerIndex.count == 0) {
        self.holeindex = [[NSMutableArray alloc] init];
        return;
    }
    
    self.holeindex = [[NSMutableArray alloc] initWithCapacity:headerIndex.count];
    uint32_t counter = 0;
    
    if (self.reader == nil) [self openReader];
    [self.reader.baseStream seekToOffset:headerIndex.offset origin:SeekOriginBegin];
    
    while (counter < headerIndex.count) {
        [self loadHoleIndexItem:counter];
        counter++;
    }
}


- (void)loadHoleIndexItem:(uint32_t)position {
    HoleIndexItem *item = [[HoleIndexItem alloc] init];
    
    item.offset = [self.reader readUInt32];
    item.size = [self.reader readInt32];
    
    [self.holeindex addObject:item];
}

- (HoleIndexItem *)getHoleIndex:(uint32_t)item {
    if (item >= self.holeindex.count) return nil;
    return self.holeindex[item];
}

// MARK: - File Operations

- (id<IPackedFile>)readAtIndex:(uint32_t)item {
    id<IPackedFileDescriptor> pfd = [self.fileindex objectAtUnsignedIndex:item];
    return [self readDescriptor:pfd];
}

- (id<IPackedFile>)readDescriptor:(id<IPackedFileDescriptor>)pfd {
    if ([pfd hasUserdata]) {
        // Deliver user-defined data
        id<IPackedFile> pf = [[PackedFile alloc] initWithData:[pfd userData]];
        return pf;
    } else {
        // No user-defined data available
        @synchronized (self) {
            // Reload Stream
            [self openReader];
            
            if (self.reader == nil) {
                return [[PackedFile alloc] initWithData:[NSData data]];
            }
            if (self.reader.baseStream == nil) {
                [self closeReader];
                return [[PackedFile alloc] initWithData:[NSData data]];
            }
            
            [self lockStream];
            [self.reader.baseStream seekToOffset:[pfd offset] origin:SeekOriginBegin];
            
            NSData *data;
            if ([pfd size] > 0) {
                data = [self.reader readBytes:[pfd size]];
            } else {
                data = [NSData data];
            }
            
            PackedFile *pf = [self getPackedFile:pfd data:data];
            
            [self unlockStream];
            [self closeReader];
            
            return pf;
        }
    }
}

- (PackedFile *)getPackedFile:(id<IPackedFileDescriptor>)pfd data:(NSData *)data {
    PackedFile *pf = [[PackedFile alloc] initWithData:data];
    
    @try {
        [self.reader.baseStream seekToOffset:[pfd offset] origin:SeekOriginBegin];
        pf.size = [self.reader readInt32];
        pf.signature = [self.reader readUInt16];
        
        NSData *dummyData = [self.reader readBytes:3];
        const uint8_t *dummy = dummyData.bytes;
        pf.uncsize = (uint32_t)((dummy[0] << 0x10) | (dummy[1] << 0x08) | dummy[2]);
        
        if (pf.signature == [MetaData COMPRESS_SIGNATURE]) {
            pf.headersize = 9;
        }
        
        if ((self.filelistfile != nil) && ([pfd type] != FILELIST_TYPE)) {
            NSInteger pos = [self.filelistfile findFile:pfd];
            if (pos != -1) {
                ClstItem *fi = self.filelistfile.items[pos];
                if (self.header.version == 0x100000001) {
                    pf.uncsize = fi.uncompressedSize;
                }
            }
        }
    } @catch (NSException *exception) {
        pf.size = 0;
        pf.data = [NSData data];
    }
    
    return pf;
}

- (id<IPackedFile>)getStreamPackedFile:(id<IPackedFileDescriptor>)pfd {
    NSInputStream *inputStream = (NSInputStream *)self.reader.baseStream;
    PackedFile *pf = [[PackedFile alloc] initWithInputStream:inputStream];
    
    @try {
        pf.datastart = [pfd offset];
        pf.datasize = (uint32_t)[pfd size];
        [self.reader.baseStream seekToOffset:[pfd offset] origin:SeekOriginBegin];
        pf.size = [self.reader readInt32];
        pf.signature = [self.reader readUInt16];
        
        NSData *dummyData = [self.reader readBytes:3];
        const uint8_t *dummy = dummyData.bytes;
        pf.uncsize = (uint32_t)((dummy[0] << 0x10) | (dummy[1] << 0x08) | dummy[2]);
        
        if (pf.signature == 0xFB10) {    // MetaData.COMPRESS_SIGNATURE
            pf.headersize = 9;
        }
        
        if ((self.filelistfile != nil) && ([pfd type] != FILELIST_TYPE)) {
            NSInteger pos = [self.filelistfile findFile:pfd];
            if (pos != -1) {
                ClstItem *fi = self.filelistfile.items[pos];
                if (self.header.version == 0x100000001) {
                    pf.uncsize = fi.uncompressedSize;
                }
            }
        }
    } @catch (NSException *exception) {
        pf.size = 0;
        pf.data = [NSData data];
    }
    
    [self.reader.baseStream seekToOffset:[pfd offset] origin:SeekOriginBegin];
    return pf;
}

- (id<IPackedFile>)getStream:(id<IPackedFileDescriptor>)pfd {
    return [self getStreamPackedFile:pfd];
}

// MARK: - File Management

- (id<IPackedFileDescriptor>)newDescriptorWithType:(uint32_t)type
                                           subtype:(uint32_t)subtype
                                             group:(uint32_t)group
                                          instance:(uint32_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    [pfd setType:type];
    pfd.subType = subtype;
    pfd.group = group;
    pfd.instance = instance;
    
    return pfd;
}

- (void)unlinkResourceDescriptor:(id<IPackedFileDescriptor>)pfd {
    PackedFileDescriptor *concreteDescriptor = (PackedFileDescriptor *)pfd;
    concreteDescriptor.packageInternalUserDataChange = nil;
}

- (void)removeDescriptor:(id<IPackedFileDescriptor>)pfd {
    if (self.fileindex == nil) return;
    
    [self.fileindex removeObject:pfd];
    self.header.index.count = (uint32_t)[self.fileindex count];
    
    [self unlinkResourceDescriptor:pfd];
    [self fireIndexEvent];
    [self fireRemoveEvent];
}

- (void)removeMarked {
    PackedFileDescriptors *list = [[PackedFileDescriptors alloc] init];
    
    for (id<IPackedFileDescriptor> pfd in self.fileindex) {
        if (![pfd markForDelete]) {
            [list addObject:pfd];
        } else {
            PackedFileDescriptor *concreteDescriptor = (PackedFileDescriptor *)pfd;
            concreteDescriptor.packageInternalUserDataChange = nil;
            // TODO: Remove description changed handler
        }
    }
    
    BOOL changed = ([self.fileindex count] != [list count]);
    self.fileindex = list;
    self.header.index.count = (uint32_t)[self.fileindex count];
    
    if (changed) {
        [self fireRemoveEvent];
        [self fireIndexEvent];
    }
}

- (id<IPackedFileDescriptor>)addDescriptorWithType:(uint32_t)type
                                            subtype:(uint32_t)subtype
                                              group:(uint32_t)group
                                           instance:(uint32_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    [pfd setType:type];
    pfd.subType = subtype;
    pfd.group = group;
    pfd.instance = instance;
    
    [self addDescriptor:pfd];
    
    return pfd;
}

- (void)copyDescriptors:(id<IPackageFile>)package {
    for (id<IPackedFileDescriptor> pfd in [package index]) {
        id<IPackedFileDescriptor> npfd = [pfd clone];
        [npfd setUserData:[[package readDescriptor:pfd] uncompressedData] fire:NO];
        [self addDescriptor:npfd isNew:YES];
    }
}

- (void)addDescriptors:(NSArray<id<IPackedFileDescriptor>> *)pfds {
    for (id<IPackedFileDescriptor> pfd in pfds) {
        [self addDescriptor:pfd];
    }
}

- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd {
    [self addDescriptor:pfd isNew:NO];
}

- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd isNew:(BOOL)isNew {
    if (self.fileindex == nil) {
        self.fileindex = [[PackedFileDescriptors alloc] init];
    }
    
    if (isNew) {
        PackedFileDescriptor *concreteDescriptor = (PackedFileDescriptor *)pfd;
        concreteDescriptor.offset = (uint32_t)self.nextFreeOffset;
    }
    
    PackedFileDescriptor *concreteDescriptor = (PackedFileDescriptor *)pfd;
    self.highestOffset = MAX(self.highestOffset,
                            (long long)(concreteDescriptor.offset + concreteDescriptor.size));
    
    [self.fileindex addObject:pfd];
    self.header.index.count = (uint32_t)[self.fileindex count];
    
    // Set up event handlers
    concreteDescriptor.packageInternalUserDataChange = ^(id<IPackedFileDescriptor> descriptor) {
        [self resourceChanged:descriptor];
    };
    
    // TODO: Set up description changed handler
    
    [self fireIndexEvent];
    [self fireAddEvent];
}

- (id<IPackedFileDescriptor>)getFileIndex:(uint32_t)item {
    if ((item >= [self.fileindex count]) || (item < 0)) return nil;
    return [self.fileindex objectAtUnsignedIndex:item];
}

// MARK: - Search Methods

- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(uint32_t)type {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (self.fileindex != nil) {
        for (id<IPackedFileDescriptor> pfd in self.fileindex) {
            if ([pfd type] == type) {
                [result addObject:pfd];
            }
        }
    }
    
    return [result copy];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFilesByGroup:(uint32_t)group {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (self.fileindex != nil) {
        for (id<IPackedFileDescriptor> pfd in self.fileindex) {
            if ([pfd group] == group) {
                [result addObject:pfd];
            }
        }
    }
    
    return [result copy];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileByName:(NSString *)filename {
    filename = [Hashes stripHashFromName:filename];
    uint32_t inst = [Hashes instanceHash:filename];
    uint32_t st = [Hashes subTypeHash:filename];
    
    NSArray *ret = [self findFileWithSubtype:st instance:inst];
    if (ret.count == 0) {
        ret = [self findFileWithSubtype:0 instance:inst];
    }
    return ret;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileByName:(NSString *)filename type:(uint32_t)type {
    filename = [Hashes stripHashFromName:filename];
    uint32_t inst = [Hashes instanceHash:filename];
    uint32_t st = [Hashes subTypeHash:filename];
    
    NSArray *ret = [self findFileWithType:type subtype:st instance:inst];
    if (ret.count == 0) {
        ret = [self findFileWithType:type subtype:0 instance:inst];
    }
    return ret;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileWithSubtype:(uint32_t)subtype instance:(uint32_t)instance {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (id<IPackedFileDescriptor> pfd in self.fileindex) {
        if (([pfd instance] == instance) && ([pfd subtype] == subtype)) {
            [result addObject:pfd];
        }
    }
    
    return [result copy];
}

- (NSArray<id<IPackedFileDescriptor>> *)findFileWithType:(uint32_t)type subtype:(uint32_t)subtype instance:(uint32_t)instance {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (self.fileindex != nil) {
        for (id<IPackedFileDescriptor> pfd in self.fileindex) {
            if (([pfd type] == type) && ([pfd instance] == instance) && ([pfd subtype] == subtype)) {
                [result addObject:pfd];
            }
        }
    }
    
    return [result copy];
}

- (id<IPackedFileDescriptor>)findFileMatchingDescriptor:(id<IPackedFileDescriptor>)pfd {
    return [self findFileWithType:[pfd type]
                          subtype:[pfd subtype]
                            group:[pfd group]
                         instance:[pfd instance]];
}

- (id<IPackedFileDescriptor>)findFileWithType:(uint32_t)type
                                      subtype:(uint32_t)subtype
                                        group:(uint32_t)group
                                     instance:(uint32_t)instance {
    if (self.fileindex != nil) {
        for (id<IPackedFileDescriptor> pfd in self.fileindex) {
            if (([pfd type] == type) &&
                ([pfd subtype] == subtype) &&
                ([pfd group] == group) &&
                ([pfd instance] == instance)) {
                return pfd;
            }
        }
    }
    
    return nil;
}

- (id<IPackedFileDescriptor>)findExactFile:(id<IPackedFileDescriptor>)pfd {
    if (self.fileindex != nil) {
        for (id<IPackedFileDescriptor> ipfd in self.fileindex) {
            if (ipfd == pfd) return pfd;
        }
    }
    return nil;
}

- (id<IPackedFileDescriptor>)findExactFileWithType:(uint32_t)type
                                           subtype:(uint32_t)subtype
                                             group:(uint32_t)group
                                          instance:(uint32_t)instance
                                            offset:(uint32_t)offset {
    if (self.fileindex != nil) {
        for (id<IPackedFileDescriptor> pfd in self.fileindex) {
            if (([pfd type] == type) &&
                ([pfd subtype] == subtype) &&
                ([pfd group] == group) &&
                ([pfd instance] == instance) &&
                ([pfd offset] == offset)) {
                return pfd;
            }
        }
    }
    
    return nil;
}

// MARK: - Cloning

- (id<IPackageFile>)newCloneBase {
    File *fl = [[File alloc] initWithBinaryReader:nil];
    fl.header = self.header;
    
    return fl;
}

- (id<IPackageFile>)clone {
    File *fl = (File *)[self newCloneBase];
    
    for (id<IPackedFileDescriptor> pfd in self.index) {
        id<IPackedFileDescriptor> npfd = [pfd clone];
        [npfd setUserData:[[self readDescriptor:pfd] uncompressedData] fire:NO];
        [fl addDescriptor:npfd];
    }
    
    fl.header = (HeaderData *)[self.header clone];
    fl.lcs = self.lcs;
    
    if (self.filelist != nil) {
        fl.filelist = (PackedFileDescriptor *)[fl findFileMatchingDescriptor:self.filelist];
        fl.filelistfile = [[CompressedFileList alloc] initWithIndexType:fl.header.indexType];
    }
    
    return fl;
}

// MARK: - Stream Locking (Placeholder)

- (void)lockStream {
    // TODO: Implement if needed for file locking
}

- (void)unlockStream {
    // TODO: Implement if needed for file unlocking
}

// MARK: - Events

- (void)fireIndexEvent {
    if (self.pause) {
        self.indexEvent = YES;
        return;
    }
    if (self.indexChanged) {
        self.indexChanged();
    }
}

- (void)fireAddEvent {
    if (self.pause) {
        self.addEvent = YES;
        return;
    }
    if (self.addedResource) {
        self.addedResource();
    }
}

- (void)fireRemoveEvent {
    if (self.pause) {
        self.removeEvent = YES;
        return;
    }
    if (self.removedResource) {
        self.removedResource();
    }
}

- (void)fireSavedIndexEvent {
    if (self.savedIndex) {
        self.savedIndex();
    }
}

- (void)resourceDescriptionChanged:(id)sender {
    [self fireIndexEvent];
}

// MARK: - Update Management

- (void)beginUpdate {
    if (self.pause) return;
    [self forgetUpdate];
}

- (void)forgetUpdate {
    self.indexEvent = NO;
    self.addEvent = NO;
    self.removeEvent = NO;
    self.pause = YES;
    
    if (self.index != nil) {
        for (id<IPackedFileDescriptor> pfd in self.index) {
            if (pfd != nil) {
                [pfd beginUpdate];
            }
        }
    }
}

- (void)endUpdate {
    if (!self.pause) return;
    self.pause = NO;
    
    for (id<IPackedFileDescriptor> pfd in self.index) {
        [pfd endUpdate];
    }
    
    if ((self.removeEvent || self.indexEvent || self.addEvent) && self.endedUpdate) {
        self.endedUpdate();
    }
    
    if (self.indexEvent) [self fireIndexEvent];
    if (self.removeEvent) [self fireRemoveEvent];
    if (self.addEvent) [self fireAddEvent];
}

// MARK: - Cleanup

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
    
    // Clear package maintainer cache if needed
        [PackageMaintainer.maintainer.fileIndex clear];
}

// MARK: - String Utilities

- (NSString *)charArrayToString:(NSArray<NSNumber *> *)array {
    NSMutableString *s = [[NSMutableString alloc] init];
    for (NSNumber *num in array) {
        [s appendFormat:@"%c", [num charValue]];
    }
    return [s copy];
}

// MARK: - Saving (Virtual Methods)

- (void)save {
    [self saveToFile:self.fileName];
}

- (id<IPackedFileDescriptor>)addWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.type = type;
    pfd.subtype = subtype;
    pfd.group = group;
    pfd.instance = instance;
    
    [self add:pfd];
    
    return pfd;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename {
    filename = [Hashes stripHashFromName:filename];
    uint32_t inst = [Hashes instanceHash:filename];
    uint32_t st = [Hashes subTypeHash:filename];
    
    NSArray *ret = [self findFileWithSubtype:st instance:inst];
    if (ret.count == 0) {
        ret = [self findFileWithSubtype:0 instance:inst];
    }
    return ret;
}

- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename type:(uint32_t)type {
    filename = [Hashes stripHashFromName:filename];
    uint32_t inst = [Hashes instanceHash:filename];
    uint32_t st = [Hashes subTypeHash:filename];
    
    NSArray *ret = [self findFileWithType:type subtype:st instance:inst];
    if (ret.count == 0) {
        ret = [self findFileWithType:type subtype:0 instance:inst];
    }
    return ret;
}

- (id<IPackedFileDescriptor>)findFileWithDescriptor:(id<IPackedFileDescriptor>)pfd {
    return [self findFileWithType:pfd.type subtype:pfd.subtype group:pfd.group instance:pfd.instance];
}

- (void)saveToFile:(NSString *)filename {
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:[NSString stringWithFormat:@"Can't save a object of Type %@.%@",
                                          NSStringFromClass([self class]), NSStringFromClass([self class])]
                                 userInfo:nil];
}

// MARK: - Equality and Hashing

- (NSUInteger)hash {
    if (self.fileName == nil) {
        if (self.reader == nil) {
            return [super hash];
        } else {
            return [self.reader hash];
        }
    } else {
        return [self.fileName hash];
    }
}

- (BOOL)isEqual:(id)obj {
    if (obj == nil) return NO;
    if (![obj isKindOfClass:[File class]]) return NO;
    
    File *f = (File *)obj;
    
    if (f.fileName == nil) {
        return [super isEqual:obj];
    } else if (self.fileName == nil) {
        return NO;
    }
    
    if (f.fileName == nil && self.fileName == nil) {
        if (self.reader == nil) {
            return f.reader == nil;
        }
        if (f.reader == nil) return NO;
        
        return [self.reader isEqual:f.reader];
    } else {
#if MAC
        return [[self.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                isEqualToString:[f.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
#else
        return [[[self.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString]
                isEqualToString:[[f.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString]];
#endif
    }
}

// MARK: - Static Factory Methods

+ (GeneratableFile *)loadFromFile:(NSString *)filename {
    return [[PackageMaintainer maintainer] loadPackageFromFile:filename sync:NO];
}

+ (GeneratableFile *)loadFromFile:(NSString *)filename sync:(BOOL)sync {
    return [[PackageMaintainer maintainer] loadPackageFromFile:filename sync:sync];
}

+ (GeneratableFile *)loadFromStream:(BinaryReader *)br {
    return [[GeneratableFile alloc] initWithBinaryReader:br];
}

+ (GeneratableFile *)createNew {
    GeneratableFile *tempFile = [GeneratableFile loadFromStream:nil];
    NSData *buildData = [tempFile build];
    Stream *stream = [[MemoryStream alloc] initWithData:buildData];
    BinaryReader *reader = [[BinaryReader alloc] initWithStream:stream];
    GeneratableFile *gf = [GeneratableFile loadFromStream:reader];
    
    //if ([UserVerification haveValidUserId]) {
        //gf.header.created = [UserVerification userId];
    //}
    
    return gf;
}

// MARK: - Missing IPackageFile Protocol Methods

- (void)resourceChanged:(id<IPackedFileDescriptor>)descriptor {
    // Handle resource change - this is called by PackedFileDescriptor when data changes
    [self fireIndexEvent];
}

- (void)remove:(id<IPackedFileDescriptor>)pfd {
    [self removeDescriptor:pfd];
}

- (void)add:(id<IPackedFileDescriptor>)pfd {
    [self addDescriptor:pfd];
}

- (id<IPackedFile>)read:(uint32_t)item {
    return [self readAtIndex:item];
}

- (void)saveWithFilename:(NSString *)filename {
    [self saveToFile:filename];
}
@end
