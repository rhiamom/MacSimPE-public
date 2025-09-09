//
//  LotProvider.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/20/25.
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

#import "LotProvider.h"
#import "MetaData.h"
#import "IScenegraphFileIndex.h"
#import "IScenegraphFileIndexItem.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "FileIndex.h"
#import "FileIndexItem.h"
#import "GeneratableFile.h"
#import "Str.h"
#import "StrItemList.h"
#import "PictureWrapper.h"
#import "Helper.h"
#import "Registry.h"
#import "Wait.h"
#import "Localization.h"

// MARK: - LotItem Implementation

@implementation LotItem

// MARK: - Initialization

- (instancetype)initWithInstance:(uint32_t)instance
                            name:(NSString *)name
                           image:(NSImage *)image
                   fileIndexItem:(id<IScenegraphFileIndexItem>)fileIndexItem {
    self = [super init];
    if (self) {
        _instance = instance;
        _name = name;
        _image = image;
        _fileIndexItem = fileIndexItem;
        _owner = 0;
        _tags = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - ILotItem Protocol Implementation

- (id)findTag:(Class)type {
    for (id obj in self.tags) {
        if (obj == nil) continue;
        if ([obj isKindOfClass:type]) {
            return obj;
        }
    }
    return nil;
}

- (NSString *)lotName {
    id<IScenegraphFileIndexItem> strItem = [self strFileIndexItem];
    if (strItem != nil) {
        Str *str = [[Str alloc] init];
        [str processData:strItem];
        StrItemList *items = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
        
        if ([items length] > 0) {
            NSString *result = [[items objectAtIndex:0] title];
            return result;
        }
    }
    
    return self.name;
}

- (id<IScenegraphFileIndexItem>)ltxtFileIndexItem {
    return self.fileIndexItem;
}

- (void)setLtxtFileIndexItem:(id<IScenegraphFileIndexItem>)ltxtFileIndexItem {
    self.fileIndexItem = ltxtFileIndexItem;
}

- (id<IScenegraphFileIndexItem>)bnfoFileIndexItem {
    if ([self ltxtFileIndexItem] == nil) return nil;
    
    id<IPackedFileDescriptor> pfd = [[[self ltxtFileIndexItem] package] findFile:0x104F6A6E
                                                                         subtype:0
                                                                           group:[MetaData LOCAL_GROUP]
                                                                        instance:self.instance];
    if (pfd == nil) return nil;
    
    return [[FileIndexItem alloc] initWithDescriptor:pfd package:[[self ltxtFileIndexItem] package]];
}

- (id<IScenegraphFileIndexItem>)strFileIndexItem {
    if ([self ltxtFileIndexItem] == nil) return nil;
    
    id<IPackedFileDescriptor> pfd = [[[self ltxtFileIndexItem] package] findFile:[MetaData STRING_FILE]
                                                                         subtype:0
                                                                           group:[MetaData LOCAL_GROUP]
                                                                        instance:(self.instance | 0x8000)];
    if (pfd == nil) return nil;
    
    return [[FileIndexItem alloc] initWithDescriptor:pfd package:[[self ltxtFileIndexItem] package]];
}

// MARK: - NSObject Overrides

- (NSUInteger)hash {
    return (NSUInteger)self.instance;
}

- (NSString *)description {
    return [self lotName];
}

@end

// MARK: - LotProvider Implementation

@implementation LotProvider

// MARK: - Initialization

- (instancetype)initWithFolder:(NSString *)folder {
    self = [super init];
    if (self) {
        self.baseFolder = folder;
        self.sync = [[NSObject alloc] init];
        
        NSMutableArray *folders = [[NSMutableArray alloc] init];
        
        self.lotfi = [[FileIndex alloc] initWithFolders:folders];
        self.ngbhfi = [self.lotfi addNewChild];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFolder:@""];
}

// MARK: - ILotProvider Protocol Implementation

- (NSString *)baseFolder {
    return self.dir;
}

- (void)setBaseFolder:(NSString *)baseFolder {
    if (![self.dir isEqualToString:baseFolder]) {
        [self waitForEnd];
        self.content = nil;
    }
    self.dir = baseFolder;
    
    // Extract neighborhood name from path
    NSArray *pathComponents = [baseFolder pathComponents];
    if ([pathComponents count] > 1) {
        self.ngbh = pathComponents[[pathComponents count] - 2];
    } else {
        self.ngbh = nil;
    }
}

- (NSMutableDictionary *)storedData {
    if (self.content == nil) {
        [self loadLotsFromFolder];
    }
    return self.content;
}

- (NSArray<NSString *> *)getNames {
    NSDictionary *storedData = [self storedData];
    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] initWithCapacity:[storedData count]];
    
    for (LotItem *lotItem in [storedData allValues]) {
        [names addObject:[lotItem name]];
    }
    
    return [names copy];
}

- (id<ILotItem>)findLot:(uint32_t)instance {
    id obj = [[self storedData] objectForKey:@(instance)];
    if (obj == nil) {
        return [[LotItem alloc] initWithInstance:instance
                                            name:[Localization getString:@"Unknown"]
                                           image:nil
                                   fileIndexItem:nil];
    }
    return (id<ILotItem>)obj;
}

- (NSArray<id<ILotItem>> *)findLotsOwnedBySim:(uint32_t)simInstance {
    NSMutableArray<id<ILotItem>> *ownedLots = [[NSMutableArray alloc] init];
    
    NSDictionary *storedData = [self storedData];
    for (id<ILotItem> item in [storedData allValues]) {
        if ([item owner] == simInstance) {
            [ownedLots addObject:item];
        }
    }
    
    return [ownedLots copy];
}

// MARK: - Helper Methods

- (uint32_t)getInstanceFromFilename:(NSString *)filename {
    NSString *name = [[[filename lastPathComponent] stringByDeletingPathExtension] lowercaseString];
    NSRange lotRange = [name rangeOfString:@"_lot"];
    
    if (lotRange.location != NSNotFound) {
        NSString *instanceStr = [name substringFromIndex:lotRange.location + 4];
        return [Helper stringToUInt32:instanceStr default:0 base:10];
    }
    
    return 0;
}

- (void)addHoodsToFileIndex {
    NSString *parentDir = [[self.dir stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSString *searchPattern = [NSString stringWithFormat:@"%@_*.package", self.ngbh];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:parentDir error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE %@", searchPattern];
    NSArray *matchingFiles = [files filteredArrayUsingPredicate:predicate];
    
    for (NSString *fileName in matchingFiles) {
        NSString *fullPath = [parentDir stringByAppendingPathComponent:fileName];
        GeneratableFile *pkg = [GeneratableFile loadFromFile:fullPath];
        [self.ngbhfi addTypesIndexFromPackage:pkg type:0x0BF999E7 fast:NO];
    }
}

- (void)addLotsToFileIndex {
    NSString *searchPattern = [NSString stringWithFormat:@"%@*_Lot*.package", self.ngbh];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.dir error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE %@", searchPattern];
    NSArray *matchingFiles = [files filteredArrayUsingPredicate:predicate];
    
    for (NSString *fileName in matchingFiles) {
        NSString *fullPath = [self.dir stringByAppendingPathComponent:fileName];
        GeneratableFile *pkg = [GeneratableFile loadFromFile:fullPath];
        [self.ngbhfi addTypesIndexFromPackage:pkg type:0x856DDBAC fast:NO];
    }
}

- (void)loadLotsFromFolder {
    [self waitForEnd];
    self.content = [[NSMutableDictionary alloc] init];
    
    if ([Helper startedGui] == ExecutableClassic) return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.dir]) return;
    
    [Wait subStart];
    [self.ngbhfi clear];
    
    [self addLotsToFileIndex];
    [self addHoodsToFileIndex];
    [Wait subStop];
    
    [self executeThread:ThreadPriorityHigh name:@"Lot Provider" sync:YES events:YES];
}

// MARK: - StoppableThread Override

- (void)startThread {
    [self.lotfi load];
    NSArray<id<IScenegraphFileIndexItem>> *items = [self.lotfi findFile:0x856DDBAC
                                                                   group:[MetaData LOCAL_GROUP]
                                                                instance:0x35CA0002
                                                                filename:nil];
    
    BOOL wasRunning = [Wait running];
    if (!wasRunning) {
        [Wait start];
    }
    [Wait subStart:[items count]];
    
    @try {
        NSInteger ct = 0;
        NSInteger step = MAX(2, [Wait maxProgress] / 100);
        
        for (id<IScenegraphFileIndexItem> item in items) {
            if ([self haveToStop]) {
                break;
            }
            
            id<IPackageFile> pkg = [item package];
            
            // Get lot name from string resource
            id<IPackedFileDescriptor> pfd = [pkg findFile:[MetaData STRING_FILE]
                                                  subtype:0
                                                    group:[MetaData LOCAL_GROUP]
                                                 instance:0x00000A46];
            NSString *name = [Localization getString:@"Unknown"];
            if (pfd != nil) {
                Str *str = [[Str alloc] init];
                [str processData:pfd package:pkg];
                
                StrItemList *list = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
                if ([list count] > 0) {
                    name = [[list objectAtIndex:0] title];
                }
            }
            
            // Get lot image
            PictureWrapper *pic = [[PictureWrapper alloc] init];
            [pic processData:item];
            
            uint32_t instance = [self getInstanceFromFilename:[pkg saveFileName]];
            
            // Find associated LTXT file
            NSArray<id<IScenegraphFileIndexItem>> *ltxtItems = [self.ngbhfi findFile:0x0BF999E7
                                                                               group:[MetaData LOCAL_GROUP]
                                                                            instance:instance
                                                                            filename:nil];
            id<IScenegraphFileIndexItem> ltxt = nil;
            if ([ltxtItems count] > 0) {
                ltxt = [ltxtItems firstObject];
            }
            
            LotItem *lotItem = [[LotItem alloc] initWithInstance:instance
                                                            name:name
                                                           image:[pic image]
                                                   fileIndexItem:ltxt];
            
            // Notify delegate
            if ([self.delegate respondsToSelector:@selector(lotProvider:loadingLot:)]) {
                [self.delegate lotProvider:self loadingLot:lotItem];
            }
            
            [self.content setObject:lotItem forKey:@(lotItem.instance)];
            ct++;
            
            if (ct % step == 0) {
                [Wait setMessage:name];
                [Wait setProgress:ct];
            }
        }
    }
    @catch (NSException *exception) {
#if !DEBUG
        [Helper exceptionMessage:[exception localizedDescription]];
#endif
    }
    @finally {
        [Wait subStop];
        if (!wasRunning) {
            [Wait stop];
        }
    }
}

@end
