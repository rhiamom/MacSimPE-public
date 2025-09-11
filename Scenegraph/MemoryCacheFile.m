//
//  MemoryCacheFile.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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

#import "MemoryCacheFile.h"
#import "MemoryCacheItem.h"
#import "FileIndex.h"
#import "FileTable.h"
#import "Helper.h"
#import "Wait.h"
#import "ExtObjdWrapper.h"
#import "CacheContainer.h"
#import "MetaData.h"
#import "StrWrapper.h"
#import "StrItem.h"
#import "PictureWrapper.h"
#import "Registry.h"
#import "Localization.h"
#import "Alias.h"
#import "IScenegraphFileIndex.h"
#import "IScenegraphFileIndexItem.h"
#import "IPackedFileDescriptor.h"
#import "IAlias.h"
#import "IPackageFile.h"
#import "CacheLists.h"

@interface MemoryCacheFile ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, MemoryCacheItem *> *internalMap;
@property (nonatomic, strong) NSMutableArray<MemoryCacheItem *> *internalList;
@property (nonatomic, strong) FileIndex *internalFileIndex;

@end

@implementation MemoryCacheFile

// MARK: - Class Methods

+ (MemoryCacheFile *)initCacheFile {
    [[FileTable fileIndex] load];
    return [self initCacheFile:[FileTable fileIndex]];
}

+ (MemoryCacheFile *)initCacheFile:(id<IScenegraphFileIndex>)fileIndex {
    [Wait subStart];
    [Wait setMessage:@"Loading Memorycache"];
    
    MemoryCacheFile *cacheFile = [[MemoryCacheFile alloc] init];
    
    [cacheFile load:[Helper simPeLanguageCache] withProgress:YES];
    [cacheFile reloadCache:fileIndex save:YES];
    
    [Wait subStop];
    
    return cacheFile;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.defaultType = ContainerTypeMemory;
    }
    return self;
}

// MARK: - Properties

- (NSDictionary<NSNumber *, MemoryCacheItem *> *)map {
    if (self.internalMap == nil) {
        [self loadMem];
    }
    return [self.internalMap copy];
}

- (NSArray<MemoryCacheItem *> *)list {
    if (self.internalList == nil) {
        [self loadMemList];
    }
    return [self.internalList copy];
}

- (FileIndex *)fileIndex {
    if (self.internalFileIndex == nil) {
        [self loadMemTable];
    }
    return self.internalFileIndex;
}

// MARK: - Cache Management

- (void)reloadCache {
    [self reloadCacheWithSave:YES];
}

- (void)reloadCacheWithSave:(BOOL)save {
    [[FileTable fileIndex] load];
    [self reloadCache:[FileTable fileIndex] save:save];
}

- (void)reloadCache:(id<IScenegraphFileIndex>)fileIndex save:(BOOL)save {
    NSArray<id<IScenegraphFileIndexItem>> *items = [fileIndex findFileWithType:[MetaData OBJD_FILE] noLocal:NO];
    
    BOOL added = NO;
    [Wait setMaxProgress:(NSInteger)items.count];
    [Wait setMessage:@"Updating Cache"];
    NSInteger count = 0;
    
    for (id<IScenegraphFileIndexItem> item in items) {
        NSArray<id<IScenegraphFileIndexItem>> *cacheItems = [self.fileIndex findFile:[item getLocalFileDescriptor] package:nil];
        if (cacheItems.count == 0) {
            @try {
                ExtObjd *objd = [[ExtObjd alloc] init];
                [objd processData:item];
                
                [self addItem:objd];
                added = YES;
            } @catch (NSException *exception) {
                NSLog(@"Error processing OBJD item: %@", exception.reason);
            }
        }
        [Wait setProgress:count++];
    }
    
    if (added) {
        self.internalMap = nil;
        [Wait setMessage:@"Saving Cache"];
        if (save) {
            [self save:self.fileName];
        }
        [self loadMemTable];
        [self loadMemList];
    }
}

// MARK: - Item Management

- (MemoryCacheItem *)addItem:(ExtObjd *)objd {
    CacheContainer *myContainer = [self useContainer:ContainerTypeMemory fileName:objd.package.fileName];
    
    MemoryCacheItem *mci = [[MemoryCacheItem alloc] init];
    mci.fileDescriptor = objd.fileDescriptor;
    mci.guid = objd.guid;
    mci.objectType = objd.type;
    mci.objdName = objd.fileName;
    mci.parentCacheContainer = myContainer;
    
    // Try to get localized name from CTSS file
    @try {
        NSArray<id<IScenegraphFileIndexItem>> *stringItems = [[FileTable fileIndex] findFileWithType:[MetaData CTSS_FILE]
                                                                                               group:objd.fileDescriptor.group
                                                                                            instance:objd.ctssInstance
                                                                                             package:nil];
        if (stringItems.count > 0) {
            StrWrapper *str = [[StrWrapper alloc] init];
            [str processData:stringItems[0]];
            StrItemList *strs = [str languageItemsForLanguage:[[Registry windowsRegistry] languageCode]];;
            
            if (strs.length > 0) {
                mci.name = [strs objectAtIndex:0].title;
            }
            
            // Not found? Try English
            if (mci.name.length == 0) {
                strs = [str languageItemsForLanguage:1];
                if (strs.length > 0) {
                    mci.name = [strs objectAtIndex:0].title;
                }
            }
        }
    } @catch (NSException *exception) {
        // Ignore string loading errors
    }
    
    // Try to get value names from STRING file
    @try {
        NSArray<id<IScenegraphFileIndexItem>> *stringItems = [[FileTable fileIndex] findFileWithType:[MetaData STRING_FILE]
                                                                                               group:objd.fileDescriptor.group
                                                                                            instance:0x100
                                                                                             package:nil];
        if (stringItems.count > 0) {
            StrWrapper *str = [[StrWrapper alloc] init];
            [str processData:stringItems[0]];
            StrItemList *strs = [str languageItemsForLanguage:LanguagesEnglish];
            
            NSMutableArray *valueNames = [[NSMutableArray alloc] initWithCapacity:strs.count];
            for (NSInteger i = 0; i < strs.count; i++) {
                [valueNames addObject:[strs objectAtIndex:i].title];
            }
            mci.valueNames = [valueNames copy];
        }
    } @catch (NSException *exception) {
        // Ignore string loading errors
    }
    
    // Still no name? Use filename
    if (mci.name.length == 0) {
        mci.name = objd.fileName;
    }
    
    // Try to load icon
    PictureWrapper *pic = [[PictureWrapper alloc] init];
    NSArray<id<IScenegraphFileIndexItem>> *imageItems = [[FileTable fileIndex] findFileWithType:[MetaData SIM_IMAGE_FILE]
                                                                                          group:objd.fileDescriptor.group
                                                                                       instance:1
                                                                                        package:nil];
    if (imageItems.count > 0) {
        @try {
            [pic processData:imageItems[0]];
            mci.icon = pic.image;
            [Wait setImage:mci.icon];
        } @catch (NSException *exception) {
            // Ignore image loading errors
        }
    }
    
    [Wait setMessage:mci.name];
    [myContainer.items addCacheItem:mci];
    
    return mci;
}

// MARK: - Data Loading

- (void)loadMem {
    self.internalMap = [[NSMutableDictionary alloc] init];
    
    for (CacheContainer *cc in self.containers) {
        if (cc.type == ContainerTypeMemory && cc.valid) {
            for (MemoryCacheItem *mci in cc.items) {
                self.internalMap[@(mci.guid)] = mci;
            }
        }
    }
}

- (void)loadMemList {
    self.internalList = [[NSMutableArray alloc] init];
    
    for (CacheContainer *cc in self.containers) {
        if (cc.type == ContainerTypeMemory && cc.valid) {
            for (MemoryCacheItem *mci in cc.items) {
                [self.internalList addObject:mci];
            }
        }
    }
}

- (void)loadMemTable {
    self.internalFileIndex = [[FileIndex alloc] init];
    self.internalFileIndex.duplicates = NO;
    
    for (CacheContainer *cc in self.containers) {
        if (cc.type == ContainerTypeMemory && cc.valid) {
            for (MemoryCacheItem *mci in cc.items) {
                id<IPackedFileDescriptor> pfd = mci.fileDescriptor;
                pfd.filename = cc.fileName;
                [self.internalFileIndex addIndexFromDescriptor:pfd
                                                       package:nil
                                                    localGroup:[FileIndex getLocalGroupForFilename:pfd.filename]];
            }
        }
    }
}

// MARK: - Item Lookup

- (MemoryCacheItem *)findItem:(uint32_t)guid {
    return self.map[@(guid)];
}

- (id<IAlias>)findObject:(uint32_t)guid {
    MemoryCacheItem *mci = [self findItem:guid];
    Alias *alias;
    
    if (mci == nil) {
        alias = [[Alias alloc] initWithId:guid name:[[Localization shared] getString:@"Unknown"]];
    } else {
        alias = [[Alias alloc] initWithId:guid name:mci.name];
    }
    
    NSMutableArray *tagArray = [[NSMutableArray alloc] initWithCapacity:3];
    if (mci != nil) {
        [tagArray addObject:mci.fileDescriptor];
        [tagArray addObject:@(mci.objectType)];
        if (mci.icon != nil) {
            [tagArray addObject:mci.icon];
        }
    }
    alias.tag = [tagArray copy];
    
    return alias;
}

@end
