//
//  FileIndex.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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

#import "FileIndex.h"
#import "FileIndexItem.h"
#import "FileTableItem.h"
#import "FileTableBase.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import "MetaData.h"
#import "Helper.h"
#import "Wait.h"
#import "Localization.h"
#import "ScenegraphHelper.h"
#import "PackedFileDescriptor.h"
#import "File.h"

// MARK: - Notifications

NSString * const FileIndexDidLoadNotification = @"FileIndexDidLoad";

// MARK: - Static Variables

static NSMutableDictionary<NSString *, NSNumber *> *_localGroupMap = nil;
static NSMutableArray<NSNumber *> *_alternativeGroups = nil;

@interface FileIndex ()

// MARK: - Private Properties

/**
 * This Dictionary (FileType) contains a Dictionary (Group) of Dictionaries (Instance) of Arrays (colliding Files)
 */
@property (nonatomic, strong) NSMutableDictionary *index;

/**
 * Contains a List of all Folders you want to check
 */
@property (nonatomic, strong) NSMutableArray<FileTableItem *> *folders;

/**
 * Contains a List of the Filenames of all added packages
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *addedFilenames;

/**
 * Contains a List of FileNames that should be Ignored
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *ignoredFiles;

/**
 * Contains a list of paths that have been added
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *paths;

/**
 * Contains child file indices
 */
@property (nonatomic, strong) NSMutableArray<id<IScenegraphFileIndex>> *children;

/**
 * Parent file index
 */
@property (nonatomic, weak) FileIndex *parent;

// MARK: - State Storage

@property (nonatomic, strong) NSMutableArray<NSString *> *oldNames;
@property (nonatomic, strong) NSMutableDictionary *oldIndex;
@property (nonatomic, assign) BOOL oldDuplicates;

@end

@implementation FileIndex

// MARK: - Class Properties

+ (NSMutableDictionary<NSString *, NSNumber *> *)localGroupMap {
    if (_localGroupMap == nil) {
        _localGroupMap = [[NSMutableDictionary alloc] init];
    }
    return _localGroupMap;
}

+ (NSMutableArray<NSNumber *> *)alternativeGroups {
    if (_alternativeGroups == nil) {
        _alternativeGroups = [[NSMutableArray alloc] init];
        [_alternativeGroups addObject:@([MetaData customGroup])];
        [_alternativeGroups addObject:@([MetaData globalGroup])];
        [_alternativeGroups addObject:@([MetaData localGroup])];
    }
    return _alternativeGroups;
}

// MARK: - Initialization

- (instancetype)init {
    return [self initWithFolders:nil];
}

- (instancetype)initWithFolders:(NSMutableArray<FileTableItem *> *)folders {
    self = [super init];
    if (self) {
        _loaded = NO;
        _children = [[NSMutableArray alloc] init];
        _paths = [[NSMutableArray alloc] init];
        _ignoredFiles = [[NSMutableArray alloc] init];
        [self initializeWithFolders:folders];
    }
    return self;
}

- (void)initializeWithFolders:(NSMutableArray<FileTableItem *> *)folders {
    self.paths = [[NSMutableArray alloc] init];
    self.addedFilenames = [[NSMutableArray alloc] init];
    self.duplicates = NO;
    
    self.index = [[NSMutableDictionary alloc] init];
    [self storeCurrentState];
    
    if (folders == nil) {
        folders = [FileTableBase defaultFolders];
    }
    self.folders = folders;
}

// MARK: - Static Methods

+ (uint32_t)getLocalGroup:(id<IPackageFile>)package {
    NSString *filename = [package saveFileName];
    return [FileIndex getLocalGroupForFilename:filename];
}

+ (uint32_t)getLocalGroupForFilename:(NSString *)filename {
    // TODO: Implement when FileTable.GroupCache is translated
    // For now, return a default local group
    if (filename == nil) {
        filename = @"memoryfile";
    }
    filename = [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    // This will need to be implemented when GroupCache is translated:
    // if ([FileTable groupCache] == nil) [ScenegraphWrapperFactory loadGroupCache];
    // id<IGroupCacheItem> gci = [[FileTable groupCache] getItem:filename];
    // return [gci localGroup];
    
    // Default local group for now
    return 0x7F000000;
}

// MARK: - IScenegraphFileIndex Protocol

- (id<IScenegraphFileIndex>)clone {
    FileIndex *ret = [[FileIndex alloc] initWithFolders:[[NSMutableArray alloc] init]];
    ret.index = [self.index mutableCopy];
    ret.folders = [self.folders mutableCopy];
    ret.addedFilenames = [self.addedFilenames mutableCopy];
    ret.duplicates = self.duplicates;
    ret.loaded = self.loaded;
    return ret;
}

- (BOOL)containsPath:(NSString *)path {
    if (path == nil) return NO;
    
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        if ([fileIndex containsPath:path]) return YES;
    }
    
    return [self.paths containsObject:path];
}

- (BOOL)contains:(NSString *)filename {
    filename = [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    if ([self.addedFilenames containsObject:filename]) return YES;
    
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        if ([fileIndex contains:filename]) return YES;
    }
    
    return NO;
}

- (BOOL)containsPackage:(id<IPackageFile>)package {
    return [self contains:[package saveFileName]];
}

// MARK: - State Management

- (void)storeCurrentState {
    self.oldNames = [self.addedFilenames mutableCopy];
    self.oldIndex = [self.index mutableCopy];
    self.oldDuplicates = self.duplicates;
}

- (void)restoreLastState {
    if (self.oldNames == nil || self.oldIndex == nil) return;
    
    [self prepareAllForRemove];
    
    self.addedFilenames = self.oldNames;
    self.index = self.oldIndex;
    self.duplicates = self.oldDuplicates;
    
    self.oldNames = nil;
    self.oldIndex = nil;
    
    [self prepareAllForAdd];
}

// MARK: - Loading

- (void)load {
    if (self.loaded) return;
    
    // We do NOT use the FileTable in LocalMode - a forceReload is required
    if ([Helper localMode]) return;
    
    [self forceReload];
}

- (void)forceReload {
    self.loaded = YES;
    [self startThread];
}

- (void)startThread {
    [Wait subStartWithCount:[self.folders count]];
    [Wait setMessage:[[Localization shared] getString:@"Loading Group Cache"]];
    
    // TODO: Implement when ScenegraphWrapperFactory is translated
    // [ScenegraphWrapperFactory loadGroupCache];
    
    [self clear];
    [self loadIgnoredFiles];
    
    NSInteger count = 0;
    for (FileTableItem *item in self.folders) {
        if ([self haveToStop]) break;
        [Wait setProgress:count++];
        [self addIndexFromFolder:item];
    }
    
    [Wait subStop];
    [self onFileIndexLoad];
}

- (void)onFileIndexLoad {
    [[NSNotificationCenter defaultCenter] postNotificationName:FileIndexDidLoadNotification
                                                        object:self];
}

- (void)loadIgnoredFiles {
    [self.ignoredFiles removeAllObjects];
    
    if (self.folders != nil) {
        for (FileTableItem *item in self.folders) {
            if ([item isFile] && [item isUseable] && [item ignore]) {
                NSString *name = [[[item name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
                [self.ignoredFiles addObject:name];
            }
        }
    }
}

// MARK: - Adding Content

- (void)addIndexFromFolder:(FileTableItem *)item {
    if (![item use]) return;
    
    if (![self.paths containsObject:[item name]]) {
        [self.paths addObject:[item name]];
    }
    
    NSArray<NSString *> *files = [item getFiles];
    
    for (NSString *filename in files) {
        @try {
            [self addIndexFromPackageFile:filename];
        }
        @catch (NSException *exception) {
            NSLog(@"Error in addIndexFromPackageFile: %@ - %@", [exception name], [exception reason]);
        }
    }
    
    if ([item isRecursive]) {
        NSError *error;
        NSArray<NSString *> *directories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[item name] error:&error];
        if (directories) {
            for (NSString *directory in directories) {
                NSString *fullPath = [[item name] stringByAppendingPathComponent:directory];
                BOOL isDirectory;
                if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory) {
                    [self addIndexFromFolderPath:[@":" stringByAppendingString:fullPath]];
                }
            }
        }
    }
}

- (void)addIndexFromFolderPath:(NSString *)path {
    path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([path length] == 0) return;
    
    FileTableItem *item = [[FileTableItem alloc] initWithPath:path];
    [self addIndexFromFolder:item];
}

- (void)addIndexFromPackageFile:(NSString *)filename {
    NSString *lowercaseFilename = [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    if ([self.ignoredFiles containsObject:lowercaseFilename]) return;
    
    NSString *message = [NSString stringWithFormat:@"%@ \"%@\"",
                        [[Localization shared] getString:@"Loading"],
                        [[filename lastPathComponent] stringByDeletingPathExtension]];
    [Wait setMessage:message];
    
    @try {
        id<IPackageFile> package = [File loadFromFile:filename readOnly:NO];
        [self addIndexFromPackage:package overwrite:NO];
    }
    @catch (NSException *exception) {
        [Helper exceptionMessage:@"" exception:exception];
    }
}

- (void)addIndexFromPackage:(id<IPackageFile>)package {
    [self addIndexFromPackage:package overwrite:NO];
}

- (void)addIndexFromPackage:(id<IPackageFile>)package overwrite:(BOOL)overwrite {
    if (package == nil) return;
    
    [package setPersistent:YES];
    if ([package fileName] != nil) {
        NSString *filename = [[[package fileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([self contains:filename] && !overwrite) return;
        [self.addedFilenames addObject:filename];
    }
    
    uint32_t localGroup = [FileIndex getLocalGroup:package];
    
    for (id<IPackedFileDescriptor> descriptor in [package index]) {
        [self addIndexFromDescriptor:descriptor package:package localGroup:localGroup];
    }
    
    [package setPersistent:NO];
}

- (void)addTypesIndexFromPackage:(id<IPackageFile>)package
                            type:(uint32_t)type
                       overwrite:(BOOL)overwrite {
    if (package == nil) return;
    
    [package setPersistent:YES];
    if ([package fileName] != nil) {
        NSString *filename = [[[package fileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([self contains:filename] && !overwrite) return;
        [self.addedFilenames addObject:filename];
    }
    
    uint32_t localGroup = [FileIndex getLocalGroup:package];
    
    for (id<IPackedFileDescriptor> descriptor in [package index]) {
        if ([descriptor type] != type) continue;
        [self addIndexFromDescriptor:descriptor package:package localGroup:localGroup];
    }
    
    [package setPersistent:NO];
}

- (void)addIndexFromDescriptor:(id<IPackedFileDescriptor>)descriptor
                       package:(id<IPackageFile>)package {
    uint32_t localGroup = [FileIndex getLocalGroup:package];
    [self addIndexFromDescriptor:descriptor package:package localGroup:localGroup];
}

- (void)addIndexFromDescriptor:(id<IPackedFileDescriptor>)descriptor
                       package:(id<IPackageFile>)package
                    localGroup:(uint32_t)localGroup {
    [self prepareForAdd:descriptor];
    FileIndexItem *item = [[FileIndexItem alloc] initWithDescriptor:descriptor package:package];
    
    NSNumber *typeKey = @([item type]);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups == nil) {
        groups = [[NSMutableDictionary alloc] init];
        [self.index setObject:groups forKey:typeKey];
    }
    
    NSNumber *groupKey = @([item group]);
    NSMutableDictionary *instances = [groups objectForKey:groupKey];
    if (instances == nil) {
        instances = [[NSMutableDictionary alloc] init];
        [groups setObject:instances forKey:groupKey];
    }
    
    NSNumber *instanceKey = @([item longInstance]);
    NSMutableArray *files = [instances objectForKey:instanceKey];
    if (files == nil) {
        files = [[NSMutableArray alloc] init];
        [instances setObject:files forKey:instanceKey];
    }
    
    if (self.duplicates || ![files containsObject:item]) {
        [files addObject:item];
    }
    
    // Add it a second time if it is a local Group
    if ([descriptor group] == [MetaData localGroup]) {
        NSNumber *localGroupKey = @(localGroup);
        instances = [groups objectForKey:localGroupKey];
        if (instances == nil) {
            instances = [[NSMutableDictionary alloc] init];
            [groups setObject:instances forKey:localGroupKey];
        }
        
        files = [instances objectForKey:instanceKey];
        if (files == nil) {
            files = [[NSMutableArray alloc] init];
            [instances setObject:files forKey:instanceKey];
        }
        
        if (self.duplicates || ![files containsObject:item]) {
            [files addObject:item];
        }
    }
}

// MARK: - Removing Content

- (void)removeItem:(id<IScenegraphFileIndexItem>)item {
    id<IPackedFileDescriptor> descriptor = [item fileDescriptor];
    
    NSNumber *typeKey = @([descriptor type]);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups != nil) {
        NSNumber *groupKey = @([descriptor group]);
        NSMutableDictionary *instances = [groups objectForKey:groupKey];
        if (instances != nil) {
            NSNumber *instanceKey = @([descriptor longInstance]);
            NSMutableArray *files = [instances objectForKey:instanceKey];
            if (files != nil) {
                [files removeObject:item];
            }
        }
        
        if ([descriptor group] == [MetaData localGroup]) {
            NSNumber *localGroupKey = @([item localGroup]);
            instances = [groups objectForKey:localGroupKey];
            if (instances != nil) {
                NSNumber *instanceKey = @([descriptor longInstance]);
                NSMutableArray *files = [instances objectForKey:instanceKey];
                if (files != nil) {
                    [files removeObject:item];
                }
            }
        }
    }
    
    [self prepareForRemove:[item fileDescriptor]];
}

- (void)clear {
    [self.paths removeAllObjects];
    [self.addedFilenames removeAllObjects];
    
    [self prepareAllForRemove];
    [self.index removeAllObjects];
}

- (void)closePackage:(id<IPackageFile>)package {
    if (package == nil) return;
    NSString *filename = [package fileName];
    [package closeWithCommit:YES];
    
    if (filename == nil) return;
    NSString *lowercaseFilename = [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    [self.addedFilenames removeObject:lowercaseFilename];
}

- (void)closeAssignedPackages {
    NSMutableArray<NSString *> *files = [self.addedFilenames mutableCopy];
    [self.addedFilenames removeAllObjects];
    
    for (NSString *filename in files) {
        if (self.parent != nil) {
            if ([self.parent.addedFilenames containsObject:filename]) continue;
        }
        
        BOOL shouldClose = YES;
        if (self.children != nil) {
            for (id<IScenegraphFileIndex> fileIndex in self.children) {
                if ([fileIndex contains:filename]) {
                    shouldClose = NO;
                    break;
                }
            }
        }
        
        if (shouldClose) {
            // TODO: Implement when StreamFactory is translated
            // [StreamFactory closeStream:filename];
        }
    }
    
    [self clear];
}

// MARK: - File Finding

- (NSArray<id<IScenegraphFileIndexItem>> *)findFile:(id<IPackedFileDescriptor>)descriptor
                                            package:(id<IPackageFile>)package {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFile:descriptor package:package];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    NSNumber *typeKey = @([descriptor type]);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups != nil) {
        NSNumber *groupKey = @([descriptor group]);
        NSMutableDictionary *instances = [groups objectForKey:groupKey];
        if (instances != nil) {
            NSNumber *instanceKey = @([descriptor longInstance]);
            NSMutableArray *files = [instances objectForKey:instanceKey];
            if (files != nil) {
                [results addObjectsFromArray:files];
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileWithType:(uint32_t)type
                                                    noLocal:(BOOL)noLocal {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileWithType:type noLocal:noLocal];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    NSNumber *typeKey = @(type);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups != nil) {
        for (NSNumber *groupKey in [groups allKeys]) {
            uint32_t group = [groupKey unsignedIntValue];
            if (noLocal && group == [MetaData localGroup]) continue;
            
            NSMutableDictionary *instances = [groups objectForKey:groupKey];
            for (NSNumber *instanceKey in [instances allKeys]) {
                NSMutableArray *files = [instances objectForKey:instanceKey];
                [results addObjectsFromArray:files];
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileWithType:(uint32_t)type
                                                      group:(uint32_t)group {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileWithType:type group:group];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    NSNumber *typeKey = @(type);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups != nil) {
        NSNumber *groupKey = @(group);
        NSMutableDictionary *instances = [groups objectForKey:groupKey];
        if (instances != nil) {
            for (NSNumber *instanceKey in [instances allKeys]) {
                NSMutableArray *files = [instances objectForKey:instanceKey];
                [results addObjectsFromArray:files];
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileWithType:(uint32_t)type
                                                      group:(uint32_t)group
                                                   instance:(uint64_t)instance
                                                    package:(id<IPackageFile>)package {
    PackedFileDescriptor *descriptor = [[PackedFileDescriptor alloc] init];
    [descriptor setGroup:group];
    [descriptor setType:type];
    [descriptor setLongInstance:instance];
    
    return [self findFile:descriptor package:package];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingGroup:(id<IPackedFileDescriptor>)descriptor {
    return [self findFileDiscardingGroupWithType:[descriptor type] instance:[descriptor longInstance]];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingGroupWithType:(uint32_t)type
                                                                   instance:(uint64_t)instance {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileDiscardingGroupWithType:type instance:instance];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    NSNumber *typeKey = @(type);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups != nil) {
        for (NSNumber *groupKey in [groups allKeys]) {
            NSMutableDictionary *instances = [groups objectForKey:groupKey];
            if (instances != nil) {
                NSNumber *instanceKey = @(instance);
                NSMutableArray *files = [instances objectForKey:instanceKey];
                if (files != nil) {
                    [results addObjectsFromArray:files];
                }
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingHighInstanceWithType:(uint32_t)type
                                                                             group:(uint32_t)group
                                                                          instance:(uint32_t)instance
                                                                           package:(id<IPackageFile>)package {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileDiscardingHighInstanceWithType:type group:group instance:instance package:package];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    NSNumber *typeKey = @(type);
    NSMutableDictionary *groups = [self.index objectForKey:typeKey];
    if (groups != nil) {
        NSNumber *groupKey = @(group);
        NSMutableDictionary *instances = [groups objectForKey:groupKey];
        if (instances != nil) {
            for (NSNumber *instanceKey in [instances allKeys]) {
                uint64_t longInstance = [instanceKey unsignedLongLongValue];
                if ((longInstance & 0xffffffff) == instance) {
                    NSMutableArray *files = [instances objectForKey:instanceKey];
                    [results addObjectsFromArray:files];
                }
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileByInstance:(uint64_t)instance {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileByInstance:instance];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = [self.index objectForKey:typeKey];
        for (NSNumber *groupKey in [groups allKeys]) {
            NSMutableDictionary *instances = [groups objectForKey:groupKey];
            NSNumber *instanceKey = @(instance);
            NSMutableArray *files = [instances objectForKey:instanceKey];
            if (files != nil) {
                [results addObjectsFromArray:files];
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileByGroup:(uint32_t)group
                                                  instance:(uint64_t)instance {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileByGroup:group instance:instance];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = [self.index objectForKey:typeKey];
        NSNumber *groupKey = @(group);
        NSMutableDictionary *instances = [groups objectForKey:groupKey];
        if (instances != nil) {
            NSNumber *instanceKey = @(instance);
            NSMutableArray *files = [instances objectForKey:instanceKey];
            if (files != nil) {
                [results addObjectsFromArray:files];
            }
        }
    }
    
    return [results copy];
}

- (NSArray<id<IScenegraphFileIndexItem>> *)findFileByGroup:(uint32_t)group {
    NSMutableArray<id<IScenegraphFileIndexItem>> *results = [[NSMutableArray alloc] init];
    
    // First, scan child tables
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        NSArray<id<IScenegraphFileIndexItem>> *childResults = [fileIndex findFileByGroup:group];
        [results addObjectsFromArray:childResults];
    }
    
    // Second, scan our FileTable
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = [self.index objectForKey:typeKey];
        NSNumber *groupKey = @(group);
        NSMutableDictionary *instances = [groups objectForKey:groupKey];
        if (instances != nil) {
            for (NSNumber *instanceKey in [instances allKeys]) {
                NSMutableArray *files = [instances objectForKey:instanceKey];
                [results addObjectsFromArray:files];
            }
        }
    }
    
    return [results copy];
}

- (id<IScenegraphFileIndexItem>)findFileByName:(NSString *)filename
                                          type:(uint32_t)type
                                      defGroup:(uint32_t)defGroup
                                    beTolerant:(BOOL)beTolerant {
    // TODO: Implement when ScenegraphHelper is translated
    // id<IPackedFileDescriptor> descriptor = [ScenegraphHelper buildDescriptorWithFilename:filename type:type defGroup:defGroup];
    // id<IScenegraphFileIndexItem> result = [self findSingleFile:descriptor package:nil beTolerant:beTolerant];
    
    // if (result == nil && beTolerant) {
    //     [descriptor setSubType:0];
    //     result = [self findSingleFile:descriptor package:nil beTolerant:beTolerant];
    // }
    
    // return result;
    return nil; // Placeholder until ScenegraphHelper is translated
}

- (id<IScenegraphFileIndexItem>)findSingleFile:(id<IPackedFileDescriptor>)descriptor
                                       package:(id<IPackageFile>)package
                                    beTolerant:(BOOL)beTolerant {
    NSArray<id<IScenegraphFileIndexItem>> *results = [self findFile:descriptor package:package];
    
    // Something is wrong with the link, try to be tolerant
    if ([results count] == 0 && beTolerant) {
        // Check alternative groups
        for (NSNumber *altGroupNumber in [FileIndex alternativeGroups]) {
            uint32_t altGroup = [altGroupNumber unsignedIntValue];
            [descriptor setGroup:altGroup];
            results = [self findFile:descriptor package:package];
            if ([results count] > 0) break;
        }
        
        // Ignore group and look for any files with that instance
        if ([results count] == 0) {
            results = [self findFileDiscardingGroup:descriptor];
        }
    }
    
    if ([results count] > 0) return [results firstObject];
    return nil;
}

// MARK: - Utility Methods

- (NSArray<id<IScenegraphFileIndexItem>> *)sort:(NSArray<id<IScenegraphFileIndexItem>> *)files {
    return [files sortedArrayUsingComparator:^NSComparisonResult(id<IScenegraphFileIndexItem> obj1, id<IScenegraphFileIndexItem> obj2) {
        uint64_t instance1 = [[obj1 fileDescriptor] instance];
        uint64_t instance2 = [[obj2 fileDescriptor] instance];
        
        if (instance1 < instance2) return NSOrderedAscending;
        if (instance1 > instance2) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

- (id<IScenegraphFileIndexItem>)createFileIndexItem:(id<IPackedFileDescriptor>)descriptor
                                            package:(id<IPackageFile>)package {
    return [[FileIndexItem alloc] initWithDescriptor:descriptor package:package];
}

- (id<IScenegraphFileIndex>)createFileIndex:(NSArray<id<IPackedFileDescriptor>> *)descriptors
                                    package:(id<IPackageFile>)package {
    FileIndex *fileIndex = [[FileIndex alloc] init];
    if (descriptors != nil) {
        for (id<IPackedFileDescriptor> descriptor in descriptors) {
            [fileIndex addIndexFromDescriptor:descriptor package:package];
        }
    }
    return fileIndex;
}

- (void)updateListOfAddedFilenames {
    [self.addedFilenames removeAllObjects];
    NSMutableSet<NSString *> *knownFiles = [[NSMutableSet alloc] init];
    
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = [self.index objectForKey:typeKey];
        for (NSNumber *groupKey in [groups allKeys]) {
            NSMutableDictionary *instances = [groups objectForKey:groupKey];
            for (NSNumber *instanceKey in [instances allKeys]) {
                NSMutableArray *files = [instances objectForKey:instanceKey];
                for (FileIndexItem *item in files) {
                    NSString *filename = [[[item package] saveFileName] lowercaseString];
                    if (![knownFiles containsObject:filename]) {
                        [knownFiles addObject:filename];
                        [self.addedFilenames addObject:filename];
                    }
                }
            }
        }
    }
    
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        [fileIndex updateListOfAddedFilenames];
    }
}

// MARK: - Child Management

- (id<IScenegraphFileIndex>)addNewChild {
    FileIndex *fileIndex = [[FileIndex alloc] init];
    [self addChild:fileIndex];
    return fileIndex;
}

- (void)addChild:(id<IScenegraphFileIndex>)child {
    if (![self.children containsObject:child]) {
        if ([child isKindOfClass:[FileIndex class]]) {
            ((FileIndex *)child).parent = self;
        }
        [self.children addObject:child];
    }
}

- (void)clearChildren {
    [self.children removeAllObjects];
}

- (void)removeChild:(id<IScenegraphFileIndex>)child {
    NSUInteger count = [self.children count];
    [self.children removeObject:child];
    if (count != [self.children count]) {
        if ([child isKindOfClass:[FileIndex class]]) {
            ((FileIndex *)child).parent = nil;
        }
    }
}

// MARK: - Helper Methods

- (void)prepareAllForAdd {
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = [self.index objectForKey:typeKey];
        for (NSNumber *groupKey in [groups allKeys]) {
            NSMutableDictionary *instances = [groups objectForKey:groupKey];
            for (NSNumber *instanceKey in [instances allKeys]) {
                NSMutableArray *files = [instances objectForKey:instanceKey];
                for (id<IScenegraphFileIndexItem> item in files) {
                    [self prepareForAdd:[item fileDescriptor]];
                }
            }
        }
    }
}

- (void)prepareAllForRemove {
    for (NSNumber *typeKey in [self.index allKeys]) {
        NSMutableDictionary *groups = [self.index objectForKey:typeKey];
        for (NSNumber *groupKey in [groups allKeys]) {
            NSMutableDictionary *instances = [groups objectForKey:groupKey];
            for (NSNumber *instanceKey in [instances allKeys]) {
                NSMutableArray *files = [instances objectForKey:instanceKey];
                for (id<IScenegraphFileIndexItem> item in files) {
                    [self prepareForRemove:[item fileDescriptor]];
                }
            }
        }
    }
}

- (void)prepareForRemove:(id<IPackedFileDescriptor>)descriptor {
    // TODO: Implement when event system is translated
    // [descriptor removeClosed:self selector:@selector(closedDescriptor:)];
}

- (void)prepareForAdd:(id<IPackedFileDescriptor>)descriptor {
    // TODO: Implement when event system is translated
    // [descriptor addClosed:self selector:@selector(closedDescriptor:)];
}

- (void)closedDescriptor:(id<IPackedFileDescriptor>)descriptor {
    // TODO: This might be critical! Maybe we need to send the parent package along
    // with this data, otherwise too many files could get removed!
    NSArray<id<IScenegraphFileIndexItem>> *items = [self findFile:descriptor package:nil];
    for (id<IScenegraphFileIndexItem> item in items) {
        [self removeItem:item];
    }
}

// MARK: - Debug Methods

#ifdef DEBUG
- (NSMutableArray<NSString *> *)storedFiles {
    NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
    
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        if ([fileIndex respondsToSelector:@selector(storedFiles)]) {
            [result addObjectsFromArray:[(FileIndex *)fileIndex storedFiles]];
        }
    }
    
    [result addObjectsFromArray:self.addedFilenames];
    return result;
}

- (void)writeContentToConsole {
    // TODO: Implement debug console output when needed
    NSLog(@"FileIndex contents:");
    for (NSString *filename in self.addedFilenames) {
        NSLog(@"  %@", filename);
    }
    
    for (id<IScenegraphFileIndex> fileIndex in self.children) {
        if ([fileIndex respondsToSelector:@selector(writeContentToConsole)]) {
            [(FileIndex *)fileIndex writeContentToConsole];
        }
    }
}
#endif

// MARK: - Memory Management

- (void)dealloc {
    @try {
        [self clearChildren];
        [self clear];
    }
    @catch (NSException *exception) {
        // Ignore cleanup exceptions
    }
}

@end
