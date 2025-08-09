//
//  RcolWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

#import "Rcol.h"
#import "IPackedFileDescriptor.h"
#import "IRcolBlock.h"
#import "IProviderRegistry.h"
#import "IWrapperRegistry.h"
#import "IPackedFileUI.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "TypeAlias.h"
#import "IWrapperInfo.h"
#import "AbstractWrapperInfo.h"
#import "RcolUI.h"
#import "PackedFileDescriptor.h"
#import "AbstractRcolBlock.h"
#import "Helper.h"
#import "Hashes.h"
#import "Localization.h"
#import "LoadFileWrappers.h"

@interface Rcol ()
@property (nonatomic, strong) NSData *oversize;
@property (nonatomic, strong) NSArray<NSNumber *> *index;
@property (nonatomic, strong, readwrite) NSArray<id<IPackedFileDescriptor>> *referencedFiles;
@property (nonatomic, strong, readwrite) NSArray<id<IRcolBlock>> *blocks;
@property (nonatomic, assign) uint32_t internalCount;
@property (nonatomic, assign, readwrite) BOOL duff;
@property (nonatomic, strong) NSException *lastException;
@property (nonatomic, strong, readwrite) id<IProviderRegistry> provider;
@end

@implementation Rcol

// MARK: - Class Variables

static NSMutableDictionary *_tokens = nil;
static NSMutableArray *_tokenAssemblies = nil;
static NSMutableArray *_fixList = nil;

// MARK: - Class Properties

+ (NSMutableDictionary *)tokens {
    if (_tokens == nil) {
        [self loadTokens];
    }
    return _tokens;
}

+ (NSMutableArray *)tokenAssemblies {
    if (_tokenAssemblies == nil) {
        _tokenAssemblies = [[NSMutableArray alloc] init];
        [_tokenAssemblies addObject:[NSBundle mainBundle]];
    }
    return _tokenAssemblies;
}

// MARK: - Initialization

- (instancetype)initWithProvider:(id<IProviderRegistry>)provider fast:(BOOL)fast {
    self = [super init];
    if (self) {
        _fast = fast;
        _provider = provider;
        _referencedFiles = @[];
        _index = @[];
        _blocks = @[];
        _oversize = [NSData data];
        _duff = NO;
        _lastException = nil;
    }
    return self;
}

- (instancetype)init {
    return [self initWithProvider:nil fast:NO];
}

// MARK: - Properties

- (uint32_t)count {
    return self.internalCount;
}

- (NSArray<id<IPackedFileDescriptor>> *)referencedFiles {
    return self.duff ? @[] : _referencedFiles;
}

- (void)setReferencedFiles:(NSArray<id<IPackedFileDescriptor>> *)referencedFiles {
    if (self.duff) return;
    _referencedFiles = referencedFiles;
}

- (NSArray<id<IRcolBlock>> *)blocks {
    return self.duff ? @[] : _blocks;
}

- (void)setBlocks:(NSArray<id<IRcolBlock>> *)blocks {
    if (self.duff) return;
    _blocks = blocks;
}

- (NSString *)fileName {
    if (self.duff) {
        NSString *invalidMessage = [Localization getString:@"InvalidCRES"];
        return [invalidMessage stringByReplacingOccurrencesOfString:@"{0}"
                                                         withString:self.lastException.reason ?: @"Unknown error"];
    }
    
    if (self.blocks.count > 0) {
        id<IRcolBlock> firstBlock = self.blocks[0];
        if ([firstBlock respondsToSelector:@selector(nameResource)]) {
            id nameResource = [firstBlock nameResource];
            if ([nameResource respondsToSelector:@selector(fileName)]) {
                return [nameResource fileName];
            }
        }
    }
    return @"";
}

- (void)setFileName:(NSString *)fileName {
    if (self.duff) return;
    
    if (self.blocks.count > 0) {
        id<IRcolBlock> firstBlock = self.blocks[0];
        if ([firstBlock respondsToSelector:@selector(nameResource)]) {
            id nameResource = [firstBlock nameResource];
            if ([nameResource respondsToSelector:@selector(setFileName:)]) {
                [nameResource setFileName:fileName];
            }
        }
    }
}

// MARK: - Token Management

+ (void)loadTokens {
    _tokens = [[NSMutableDictionary alloc] init];
    for (NSBundle *bundle in [self tokenAssemblies]) {
        [self loadTokensFromBundle:bundle];
    }
}

+ (void)loadTokensFromBundle:(NSBundle *)bundle {
    if (_tokens == nil) {
        _tokens = [[NSMutableDictionary alloc] init];
    }
    
    // Load plugins implementing IRcolBlock from the bundle
    NSArray *plugins = [LoadFileWrappers loadPluginsFromBundle:bundle
                                                  forProtocol:@protocol(IRcolBlock)
                                                withArguments:@[[NSNull null]]];
    
    for (id<IRcolBlock> block in plugins) {
        [block registerInListing:_tokens];
    }
}

// MARK: - AbstractWrapper Overrides

- (BOOL)checkVersion:(uint32_t)version {
    return (version == 0012 || version == 0013);
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[RcolUI alloc] init];
}

- (IWrapperInfo *)createWrapperInfo {
    NSImage *icon = [NSImage imageNamed:@"resource"];
    return [[AbstractWrapperInfo alloc] initWithName:@"RCOL Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File is part of the Scenegraph. The Scenegraph is used to build the 3D Objects in \"The Sims 2\"."
                                             version:10
                                                icon:icon];
}

// MARK: - Block Operations

- (id<IRcolBlock>)readBlockWithId:(uint32_t)blockId reader:(BinaryReader *)reader {
    long position = [reader position];
    NSString *blockName = [reader readString];
    
    Class blockClass = [[self class] tokens][blockName];
    if (blockClass == nil) {
        NSString *errorMessage = [NSString stringWithFormat:@"Unknown embedded RCOL Block Name at Offset=0x%@",
                                 [Helper hexString:(uint32_t)position]];
        NSException *innerException = [NSException exceptionWithName:@"RcolBlockException"
                                                              reason:[NSString stringWithFormat:@"RCOL Block Name: %@", blockName]
                                                            userInfo:nil];
        @throw [NSException exceptionWithName:@"RcolBlockException"
                                       reason:errorMessage
                                     userInfo:@{NSUnderlyingErrorKey: innerException}];
    }
    
    position = [reader position];
    uint32_t readId = [reader readUInt32];
    if (readId == 0xffffffff) return nil;
    
    if (blockId != readId) {
        NSString *errorMessage = [NSString stringWithFormat:@"Unexpected embedded RCOL Block ID at Offset=0x%@",
                                 [Helper hexString:(uint32_t)position]];
        NSString *detailMessage = [NSString stringWithFormat:@"Read: 0x%@; Expected: 0x%@",
                                  [Helper hexString:readId], [Helper hexString:blockId]];
        NSException *innerException = [NSException exceptionWithName:@"RcolBlockException"
                                                              reason:detailMessage
                                                            userInfo:nil];
        @throw [NSException exceptionWithName:@"RcolBlockException"
                                       reason:errorMessage
                                     userInfo:@{NSUnderlyingErrorKey: innerException}];
    }
    
    id<IRcolBlock> block = [AbstractRcolBlock createWithClass:blockClass
                                                        parent:self
                                                       blockId:readId];
    [block unserialize:reader];
    return block;
}

- (void)writeBlock:(id<IRcolBlock>)block writer:(BinaryWriter *)writer {
    [writer writeString:[block blockName]];
    [writer writeUInt32:[block blockId]];
    [block serialize:writer];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    self.duff = NO;
    self.lastException = nil;
    
    self.internalCount = [reader readUInt32];
    
    @try {
        // Read referenced files
        uint32_t refFileCount = (self.internalCount == 0xffff0001) ? [reader readUInt32] : self.internalCount;
        NSMutableArray<id<IPackedFileDescriptor>> *refFiles = [[NSMutableArray alloc] initWithCapacity:refFileCount];
        
        for (uint32_t i = 0; i < refFileCount; i++) {
            PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
            
            [pfd setGroup:[reader readUInt32]];
            [pfd setInstance:[reader readUInt32]];
            [pfd setSubtype:(self.internalCount == 0xffff0001) ? [reader readUInt32] : 0];
            [pfd setType:[reader readUInt32]];
            
            [refFiles addObject:pfd];
        }
        self.referencedFiles = [refFiles copy];
        
        // Read block indices
        uint32_t blockCount = [reader readUInt32];
        NSMutableArray<NSNumber *> *indices = [[NSMutableArray alloc] initWithCapacity:blockCount];
        for (uint32_t i = 0; i < blockCount; i++) {
            [indices addObject:@([reader readUInt32])];
        }
        self.index = [indices copy];
        
        // Read blocks
        NSMutableArray<id<IRcolBlock>> *blocks = [[NSMutableArray alloc] initWithCapacity:blockCount];
        for (uint32_t i = 0; i < blockCount; i++) {
            uint32_t blockId = [self.index[i] unsignedIntValue];
            id<IRcolBlock> block = [self readBlockWithId:blockId reader:reader];
            if (block == nil) break;
            [blocks addObject:block];
        }
        self.blocks = [blocks copy];
        
        // Read oversize data if not in fast mode
        if (!self.fast) {
            long remainingSize = [reader length] - [reader position];
            if (remainingSize > 0) {
                self.oversize = [reader readBytes:(int)remainingSize];
            } else {
                self.oversize = [NSData data];
            }
        }
    }
    @catch (NSException *exception) {
        self.duff = YES;
        self.lastException = exception;
    }
}

- (void)serialize:(BinaryWriter *)writer {
    if (self.duff) return;
    
    [writer writeUInt32:(self.internalCount == 0xffff0001) ? self.internalCount : (uint32_t)self.referencedFiles.count];
    [writer writeUInt32:(uint32_t)self.referencedFiles.count];
    
    for (id<IPackedFileDescriptor> pfd in self.referencedFiles) {
        [writer writeUInt32:[pfd group]];
        [writer writeUInt32:[pfd instance]];
        if (self.internalCount == 0xffff0001) {
            [writer writeUInt32:[pfd subtype]];
        }
        [writer writeUInt32:[pfd type]];
    }
    
    [writer writeUInt32:(uint32_t)self.blocks.count];
    for (id<IRcolBlock> block in self.blocks) {
        [writer writeUInt32:[block blockId]];
    }
    
    for (id<IRcolBlock> block in self.blocks) {
        [self writeBlock:block writer:writer];
    }
    
    [writer writeData:self.oversize];
}

// MARK: - Event Management

- (void)clearTabPageChanged {
    self.tabPageChangedBlock = nil;
}

- (void)childTabPageChanged:(id)sender {
    if (self.tabPageChangedBlock) {
        self.tabPageChangedBlock(sender);
    }
}

// MARK: - IFileWrapper Implementation

- (NSData *)fileSignature {
    return [NSData data];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[];
}

- (NSString *)getResourceNameWithTypeAlias:(TypeAlias *)typeAlias {
    if (!self.processed) {
        [self processData:self.fileDescriptor package:self.package sync:NO];
    }
    return self.fileName;
}

// MARK: - Fix Method

- (void)fix:(id<IWrapperRegistry>)registry {
    if (_fixList == nil) {
        _fixList = [[NSMutableArray alloc] init];
    }
    
    [super fix:registry];
    
    // Fix all referenced files
    for (id<IPackedFileDescriptor> localDescriptor in self.referencedFiles) {
        id<IPackedFileDescriptor> packageDescriptor = [self.package findFile:localDescriptor];
        if (packageDescriptor != nil) {
            // Prevent endless loops
            if ([_fixList containsObject:packageDescriptor]) continue;
            
            [_fixList addObject:packageDescriptor];
            id<IFileWrapper> wrapper = [registry findHandler:[packageDescriptor type]];
            if (wrapper != nil) {
                [wrapper processData:packageDescriptor package:self.package sync:YES];
                [wrapper fix:registry];
                [localDescriptor setSubtype:[[wrapper fileDescriptor] subtype]];
                [localDescriptor setGroup:[[wrapper fileDescriptor] group]];
                [localDescriptor setInstance:[[wrapper fileDescriptor] instance]];
            }
            [_fixList removeObject:packageDescriptor];
        }
    }
    
    // Fix instances
    [[self fileDescriptor] setSubtype:[Hashes subTypeHash:[Hashes stripHashFromName:self.fileName]]];
    [[self fileDescriptor] setInstance:[Hashes instanceHash:[Hashes stripHashFromName:self.fileName]]];
    
    // Commit changes
    [self synchronizeUserData];
}

// MARK: - IMultiplePackedFileWrapper

- (NSArray *)constructorArguments {
    return @[self.provider ?: [NSNull null], @(self.fast)];
}

// MARK: - Disposal

- (void)dealloc {
    for (id<IRcolBlock> block in self.blocks) {
        // Objective-C handles disposal automatically
        // If blocks need special cleanup, they should implement dealloc
    }
}

@end
