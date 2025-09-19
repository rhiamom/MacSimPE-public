//
//  Scenegraph.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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

#import "Scenegraph.h"
#import "GeneratableFile.h"
#import "GenericRcolWrapper.h"
#import "ObjectCloner.h"
#import "MmatCacheFile.h"
#import "PackedFileDescriptor.h"
#import "MmatWrapper.h"
#import "CpfWrapper.h"
#import "StrWrapper.h"
#import "StrItem.h"
#import "NmapWrapper.h"
#import "NmapItem.h"
#import "PackedFileWrapper.h"
#import "cDataListExtension.h"
#import "cExtension.h"
#import "Helper.h"
#import "Hashes.h"
#import "MetaData.h"
#import "FileTable.h"
#import "WaitingScreen.h"
#import "Registry.h"
#import "ScenegraphException.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import "IScenegraphFileIndex.h"
#import "IRcolBlock.h"
#import "CpfItem.h"

@interface Scenegraph ()

// MARK: - Private Properties
@property (nonatomic, strong) NSMutableArray<NSString *> *modelnames;
@property (nonatomic, strong) NSMutableArray<GenericRcol *> *files;
@property (nonatomic, strong) NSMutableArray<id<IScenegraphFileIndexItem>> *itemlist;
@property (nonatomic, strong) NSMutableArray<NSString *> *excludedReferences;
@property (nonatomic, strong) CloneSettings *settings;

@end

// MARK: - Static Properties

static NSMutableArray<NSString *> *_fileExcludeList = nil;
static MmatCacheFile *_cacheFile = nil;

@implementation Scenegraph

// MARK: - Class Properties

+ (NSMutableArray<NSString *> *)fileExcludeList {
    if (_fileExcludeList == nil) {
        _fileExcludeList = [[NSMutableArray alloc] init];
    }
    return _fileExcludeList;
}

+ (void)setFileExcludeList:(NSMutableArray<NSString *> *)fileExcludeList {
    _fileExcludeList = fileExcludeList;
}

+ (NSArray<NSString *> *)defaultFileExcludeList {
    return @[@"simple_mirror_reflection_txmt"];
}

// MARK: - Initialization

- (instancetype)initWithModelname:(NSString *)modelname {
    return [self initWithModelnames:@[modelname] excludeList:@[] settings:[[CloneSettings alloc] init]];
}

- (instancetype)initWithModelnames:(NSArray<NSString *> *)modelnames {
    return [self initWithModelnames:modelnames excludeList:@[] settings:[[CloneSettings alloc] init]];
}

- (instancetype)initWithModelnames:(NSArray<NSString *> *)modelnames
                       excludeList:(NSArray<NSString *> *)excludeList
                          settings:(CloneSettings *)settings {
    self = [super init];
    if (self) {
        self.settings = settings;
        [self initWithModelnames:modelnames excludeList:excludeList];
    }
    return self;
}

- (void)initWithModelnames:(NSArray<NSString *> *)modelnames excludeList:(NSArray<NSString *> *)excludeList {
    self.excludedReferences = [excludeList mutableCopy];
    self.modelnames = [[NSMutableArray alloc] init];
    
    NSMutableArray *cresFiles = [self loadCres:modelnames];
    
    self.files = [[NSMutableArray alloc] init];
    self.itemlist = [[NSMutableArray alloc] init];
    
    for (id<IScenegraphFileIndexItem> item in cresFiles) {
        GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        [sub processData:item];
        [self.class loadReferenced:self.modelnames
                           exclude:self.excludedReferences
                              list:self.files
                          itemlist:self.itemlist
                              rcol:sub
                              item:item
                         recursive:YES
                          settings:self.settings];
    }
    
    for (NSString *modelname in modelnames) {
        [self.modelnames addObject:modelname];
    }
}

// MARK: - Static Utility Methods

+ (void)cloneDescriptorForItem:(id<IScenegraphFileIndexItem>)item {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.type = item.fileDescriptor.type;
    pfd.group = item.fileDescriptor.group;
    pfd.longInstance = item.fileDescriptor.longInstance;
    pfd.offset = item.fileDescriptor.offset;
    pfd.size = item.fileDescriptor.size;
    pfd.userData = item.fileDescriptor.userData;
    
    item.fileDescriptor = pfd;
}

+ (PackedFileDescriptor *)cloneDescriptor:(id<IPackedFileDescriptor>)original {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.type = original.type;
    pfd.group = original.group;
    pfd.longInstance = original.longInstance;
    
    return pfd;
}

+ (NSArray<NSString *> *)findModelNames:(id<IPackageFile>)package {
    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] init];
    
    // Find from STRING files
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFileWithType:[MetaData STRING_FILE]
                                                                 subtype:0
                                                                instance:0x85];
    if (pfds.count > 0) {  // Changed: items.count -> pfds.count
        for (id<IPackedFileDescriptor> pfd in pfds) {  // Changed: item -> pfd, items -> pfds
            StrWrapper *str = [[StrWrapper alloc] init];
            [str processData:pfd package:package];  // Changed: item.fileDescriptor -> pfd, item.package -> package
            
            for (StrToken *token in str.items) {
                NSString *mname = [Hashes stripHashFromName:[token.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString];
                if (![mname hasSuffix:@"_cres"]) {
                    mname = [mname stringByAppendingString:@"_cres"];
                }
                if (mname.length > 0 && ![names containsObject:mname]) {
                    [names addObject:mname];
                }
            }
        }
    }
    
    // Find from MMAT files
    // Find from MMAT files
    NSArray<id<IPackedFileDescriptor>> *mmatPfds = [package findFiles:[MetaData MMAT]];
    if (mmatPfds.count > 0) {
        for (id<IPackedFileDescriptor> pfd in mmatPfds) {
            Cpf *cpf = [[Cpf alloc] init];
            [cpf processData:pfd package:package];
            
            NSString *mname = [Hashes stripHashFromName:[[cpf getSaveItem:@"modelName"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString];
            if (![mname hasSuffix:@"_cres"]) {
                mname = [mname stringByAppendingString:@"_cres"];
            }
            if (mname.length > 0 && ![names containsObject:mname]) {
                [names addObject:mname];
            }
        }
    }
    
    return [names copy];
}

+ (NSString *)mmatContent:(Cpf *)mmat {
    NSString *modelName = [mmat getSaveItem:@"modelName"].stringValue;
    NSString *subsetName = [mmat getSaveItem:@"subsetName"].stringValue;
    NSString *name = [mmat getSaveItem:@"name"].stringValue;
    NSString *objectStateIndex = [Helper hexString:[mmat getSaveItem:@"objectStateIndex"].uintegerValue];
    NSString *materialStateFlags = [Helper hexString:[mmat getSaveItem:@"materialStateFlags"].uintegerValue];
    NSString *objectGUID = [Helper hexString:[mmat getSaveItem:@"objectGUID"].uintegerValue];
    
    return [NSString stringWithFormat:@"%@%@%@%@%@%@", modelName, subsetName, name, objectStateIndex, materialStateFlags, objectGUID];
}

// MARK: - Loading Methods

- (NSMutableArray *)loadCres:(NSArray<NSString *> *)modelnames {
    NSMutableArray *cres = [[NSMutableArray alloc] init];
    
    for (NSString *modelname in modelnames) {
        NSString *processedName = [modelname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
        if (![processedName hasSuffix:@"_cres"]) {
            processedName = [processedName stringByAppendingString:@"_cres"];
        }
        
        id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:processedName
                                                                             type:[MetaData CRES]
                                                                            group:[MetaData LOCAL_GROUP]
                                                                     searchGlobal:YES];
        if (item != nil) {
            [cres addObject:item];
        }
    }
    
    return cres;
}

+ (void)loadReferenced:(NSMutableArray<NSString *> *)modelnames
               exclude:(NSMutableArray<NSString *> *)exclude
                  list:(NSMutableArray<GenericRcol *> *)list
              itemlist:(NSMutableArray<id<IScenegraphFileIndexItem>> *)itemlist
                  rcol:(GenericRcol *)rcol
                  item:(id<IScenegraphFileIndexItem>)item
             recursive:(BOOL)recursive
              settings:(CloneSettings *)settings {
    
    // If we load a CRES, we also have to add the Modelname!
    if (rcol.fileDescriptor.type == [MetaData CRES]) {
        [modelnames addObject:[rcol.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString];
    }
    
    [list addObject:rcol];
    [itemlist addObject:item];
    
    NSDictionary *referenceChains = rcol.referenceChains;
    for (NSString *key in referenceChains.allKeys) {
        if ([exclude containsObject:key]) continue;
        
        NSArray *descriptors = referenceChains[key];
        for (id<IPackedFileDescriptor> pfd in descriptors) {
            if (settings != nil) {
                if (settings.keepOriginalMesh) {
                    if (pfd.type == [MetaData GMND]) continue;
                    if (pfd.type == [MetaData GMDC]) continue;
                }
            }
            
            id<IScenegraphFileIndexItem> subitem = [[FileTable fileIndex] findSingleFile:pfd package:nil searchGlobal:YES];
            
            if (subitem != nil) {
                if (![itemlist containsObject:subitem]) {
                    @try {
                        GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                        [sub processData:subitem.fileDescriptor package:subitem.package fast:NO];
                        
                        if ([[self fileExcludeList] containsObject:[sub.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString]) {
                            continue;
                        }
                        
                        if (recursive) {
                            [self loadReferenced:modelnames
                                         exclude:exclude
                                            list:list
                                        itemlist:itemlist
                                            rcol:sub
                                            item:subitem
                                       recursive:YES
                                        settings:settings];
                        }
                    }
                    @catch (NSException *ex) {
                        CorruptedFileException *corruptedException = [[CorruptedFileException alloc] initWithItem:subitem exception:ex];
                        [Helper exceptionMessage:@"" exception:corruptedException];
                    }
                }
            }
        }
    }
}

// MARK: - Cache Handling

+ (void)loadCache {
    if (_cacheFile != nil) return;
    
    _cacheFile = [[MmatCacheFile alloc] init];
    if ([[Registry windowsRegistry] useCache]) {
        [_cacheFile load:[Helper simPeCache]];
    }
}

+ (void)saveCache {
    if ([[Registry windowsRegistry] useCache]) {
        [_cacheFile save:[Helper simPeCache]];
    }
}

// MARK: - Material Override Methods

- (void)addMaterialOverrides:(id<IPackageFile>)package
                 onlyDefault:(BOOL)onlyDefault
                    subitems:(BOOL)subitems
                   exception:(BOOL)shouldThrowException {
    
    [self.class loadCache];
    
    NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:[MetaData MMAT] searchGlobal:YES];
    NSMutableArray *itemlist = [[NSMutableArray alloc] init];
    NSMutableArray *contentlist = [[NSMutableArray alloc] init];
    NSMutableArray *defaultfam = [[NSMutableArray alloc] init];
    NSMutableArray *guids = [[NSMutableArray alloc] init];
    
    // Create an UpTo Date Cache
    BOOL chgcache = NO;
    for (id<IScenegraphFileIndexItem> item in items) {
        NSString *pname = [item.package.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
        NSArray<id<IScenegraphFileIndexItem>> *citems = [_cacheFile.fileIndex findFile:item.fileDescriptor package:item.package];
        BOOL have = NO;
        
        for (id<IScenegraphFileIndexItem> citem in citems) {
            if ([citem.fileDescriptor.filename isEqualToString:pname]) {
                have = YES;
                break;
            }
        }
        
        // Not in cache, so add that File
        if (!have) {
            MmatWrapper *mmat = [[MmatWrapper alloc] init];
            [mmat processData:item.fileDescriptor package:item.package];
            
            [_cacheFile addItem:mmat];
            chgcache = YES;
        }
    }
    
    if (chgcache) {
        [self.class saveCache];
    }
    
    // Collect a list of Default Material Override family values first
    if (onlyDefault) {
        NSArray *defaultItems = [_cacheFile.defaultMap objectForKey:@YES];
        for (id cacheItem in defaultItems) {
            if ([cacheItem respondsToSelector:@selector(family)]) {
                [defaultfam addObject:[cacheItem family]];
            }
        }
    }
    
    // Now do the real collect
    for (NSString *modelname in self.modelnames) {
        NSString *key = [modelname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
        NSArray *cacheList = [_cacheFile.modelMap objectForKey:key];
        
        if (cacheList != nil) {
            for (id cacheItem in cacheList) {
                if (onlyDefault && ![defaultfam containsObject:[cacheItem family]]) continue;
                
                NSArray<id<IScenegraphFileIndexItem>> *foundItems = [[FileTable fileIndex] findFile:[cacheItem fileDescriptor] package:nil];
                
                for (id<IScenegraphFileIndexItem> foundItem in foundItems) {
                    if ([itemlist containsObject:foundItem]) continue;
                    [itemlist addObject:foundItem];
                    
                    MmatWrapper *mmat = [[MmatWrapper alloc] init];
                    [mmat processData:foundItem];
                    
                    NSString *content = [self.class mmatContent:mmat];
                    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
                    
                    if (![contentlist containsObject:content]) {
                        mmat.fileDescriptor = [self.class cloneDescriptor:mmat.fileDescriptor];
                        [mmat synchronizeUserData];
                        
                        if (subitems) {
                            if ([package findFile:mmat.fileDescriptor] == nil) {
                                [package add:mmat.fileDescriptor];
                            }
                            
                            // Handle TXMT references
                            NSString *txmtName = [[mmat getSaveItem:@"name"].stringValue stringByAppendingString:@"_txmt"];
                            id<IScenegraphFileIndexItem> txmtItem = [[FileTable fileIndex] findFileByName:txmtName
                                                                                                     type:[MetaData TXMT]
                                                                                                    group:[MetaData LOCAL_GROUP]
                                                                                             searchGlobal:YES];
                            
                            if (txmtItem != nil) {
                                @try {
                                    GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                                    [sub processData:txmtItem.fileDescriptor package:txmtItem.package fast:NO];
                                    NSMutableArray *newfiles = [[NSMutableArray alloc] init];
                                    [self.class loadReferenced:self.modelnames
                                                       exclude:self.excludedReferences
                                                          list:newfiles
                                                      itemlist:itemlist
                                                          rcol:sub
                                                          item:txmtItem
                                                     recursive:YES
                                                      settings:self.settings];
                                    [self.class buildPackage:newfiles package:package];
                                }
                                @catch (NSException *ex) {
                                    CorruptedFileException *corruptedException = [[CorruptedFileException alloc] initWithItem:txmtItem exception:ex];
                                    [Helper exceptionMessage:@"" exception:corruptedException];
                                }
                            }
                        } else {
                            if ([package findFile:mmat.fileDescriptor] == nil) {
                                NSString *txmtname = [[mmat getSaveItem:@"name"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                if (![txmtname hasSuffix:@"_txmt"]) {
                                    txmtname = [txmtname stringByAppendingString:@"_txmt"];
                                }
                                
                                if ([[package findFile:txmtname type:[MetaData TXMT]] count] > 0) {
                                    [package add:mmat.fileDescriptor];
                                }
                            }
                        }
                        [contentlist addObject:content];
                    }
                }
            }
        }
    }
}

// MARK: - Subset Methods

+ (NSArray<NSString *> *)getRecolorableSubsets:(id<IPackageFile>)package {
    return [self getSubsets:package blockname:@"tsdesignmodeenabled"];
}

+ (NSArray<NSString *> *)getParentSubsets:(id<IPackageFile>)package {
    return [self getSubsets:package blockname:@"tsMaterialsMeshName"];
}

+ (NSArray<NSString *> *)getSubsets:(id<IPackageFile>)package blockname:(nullable NSString *)blockname {
    if (blockname == nil) blockname = @"";
    NSMutableArray<NSString *> *list = [[NSMutableArray alloc] init];
    
    if (package == nil) return [list copy];
    
    blockname = [blockname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    NSArray<id<IPackedFileDescriptor>> *gmnds = [package findFiles:[MetaData GMND]];
    
    for (id<IPackedFileDescriptor> pfd in gmnds) {
        GenericRcol *gmnd = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        [gmnd processData:pfd package:package];
        
        for (id<IRcolBlock> irb in gmnd.blocks) {
            if ([irb.blockName isEqualToString:@"cDataListExtension"]) {
                DataListExtension *dle = (DataListExtension *)irb;
                if ([dle.extension.varName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:blockname]) {
                    for (ExtensionItem *ei in dle.extension.items) {
                        [list addObject:[ei.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString];
                    }
                }
            }
        }
    }
    
    return [list copy];
}

+ (void)getSlaveSubsets:(GenericRcol *)gmnd map:(NSMutableDictionary *)map {
    for (id<IRcolBlock> irb in gmnd.blocks) {
        if ([irb.blockName isEqualToString:@"cDataListExtension"]) {
            DataListExtension *dle = (DataListExtension *)irb;
            if ([[dle.extension.varName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:@"tsdesignmodeslavesubsets"]) {
                for (ExtensionItem *ei in dle.extension.items) {
                    NSArray<NSString *> *slaves = [ei.string componentsSeparatedByString:@","];
                    NSMutableArray<NSString *> *slavelist = [[NSMutableArray alloc] init];
                    for (NSString *s in slaves) {
                        [slavelist addObject:[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString];
                    }
                    
                    map[[ei.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString] = [slavelist copy];
                }
            }
        }
    }
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)getSlaveSubsets {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (GenericRcol *gmnd in self.files) {
        if (gmnd.fileDescriptor.type == [MetaData GMND]) {
            [self.class getSlaveSubsets:gmnd map:map];
        }
    }
    return [map copy];
}

+ (NSDictionary<NSString *, NSArray<NSString *> *> *)getSlaveSubsets:(id<IPackageFile>)package {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    NSArray<id<IPackedFileDescriptor>> *gmnds = [package findFiles:[MetaData GMND]];
    
    for (id<IPackedFileDescriptor> pfd in gmnds) {
        GenericRcol *gmnd = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        [gmnd processData:pfd package:package];
        
        [self getSlaveSubsets:gmnd map:map];
    }
    
    return [map copy];
}

+ (NSDictionary *)getMmatMap:(id<IPackageFile>)package {
    if (package == nil) return [[NSDictionary alloc] init];
    
    NSArray<id<IPackedFileDescriptor>> *mmats = [package findFiles:[MetaData MMAT]];
    NSMutableDictionary *ht = [[NSMutableDictionary alloc] init];
    
    for (id<IPackedFileDescriptor> pfd in mmats) {
        MmatWrapper *mmat = [[MmatWrapper alloc] init];
        [mmat processData:pfd package:package];
        
        NSString *subset = [[mmat getSaveItem:@"subsetName"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
        NSString *family = [mmat getSaveItem:@"family"].stringValue;
        
        // Get the available families
        NSMutableDictionary *families = ht[subset];
        if (families == nil) {
            families = [[NSMutableDictionary alloc] init];
            ht[subset] = families;
        }
        
        // Get listing of the current Family
        NSMutableArray *list = families[family];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
            families[family] = list;
        }
        
        // Add the MMAT File
        [list addObject:mmat];
    }
    
    return [ht copy];
}

// MARK: - Slave TXMT Methods

+ (void)addSlaveTxmts:(NSMutableArray<NSString *> *)modelnames
              exclude:(NSMutableArray<NSString *> *)exclude
                 list:(NSMutableArray<GenericRcol *> *)list
             itemlist:(NSMutableArray<id<IScenegraphFileIndexItem>> *)itemlist
                 rcol:(Rcol *)rcol
               slaves:(NSDictionary *)slaves {
    
    NSString *name = [rcol.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    
    for (NSString *k in slaves.allKeys) {
        NSArray<NSString *> *slaveArray = slaves[k];
        for (NSString *sub in slaveArray) {
            NSString *pattern = [NSString stringWithFormat:@"_%@_", k];
            NSString *replacement = [NSString stringWithFormat:@"_%@_", sub];
            NSString *slavename = [name stringByReplacingOccurrencesOfString:pattern withString:replacement];
            
            if (![slavename isEqualToString:name]) {
                id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:slavename
                                                                                     type:[MetaData TXMT]
                                                                                    group:[MetaData LOCAL_GROUP]
                                                                             searchGlobal:YES];
                if (item != nil) {
                    GenericRcol *txmt = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                    [txmt processData:item];
                    txmt.fileDescriptor = [Scenegraph cloneDescriptor:item.fileDescriptor];
                    
                    [Scenegraph loadReferenced:modelnames
                                       exclude:exclude
                                          list:list
                                      itemlist:itemlist
                                          rcol:txmt
                                          item:item
                                     recursive:YES
                                      settings:nil];
                }
            }
        }
    }
}

- (void)addSlaveTxmts:(NSDictionary *)slaves {
    for (NSInteger i = self.files.count - 1; i >= 0; i--) {
        GenericRcol *rcol = self.files[i];
        
        if (rcol.fileDescriptor.type == [MetaData TXMT]) {
            [self.class addSlaveTxmts:self.modelnames
                              exclude:self.excludedReferences
                                 list:self.files
                             itemlist:self.itemlist
                                 rcol:rcol
                               slaves:slaves];
        }
    }
}

+ (void)addSlaveTxmts:(id<IPackageFile>)package slaves:(NSDictionary *)slaves {
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:[MetaData TXMT]];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        [rcol processData:pfd package:package];
        
        if (rcol.fileDescriptor.type == [MetaData TXMT]) {
            [self addSlaveTxmts:[[NSMutableArray alloc] init]
                        exclude:[[NSMutableArray alloc] init]
                           list:files
                       itemlist:items
                           rcol:rcol
                         slaves:slaves];
        }
    }
    
    for (GenericRcol *rcol in files) {
        if ([package findFile:rcol.fileDescriptor] == nil) {
            rcol.fileDescriptor = [rcol.fileDescriptor clone];
            [rcol synchronizeUserData];
            [package add:rcol.fileDescriptor];
        }
    }
}

// MARK: - Package Building

- (GeneratableFile *)buildPackage {
    GeneratableFile *pkg = [GeneratableFile loadFromFile:@"simpe_memory"];
    [self buildPackage:pkg];
    return pkg;
}

- (void)buildPackage:(id<IPackageFile>)package {
    [self.class buildPackage:self.files package:package];
}

+ (void)buildPackage:(NSArray<GenericRcol *> *)files package:(id<IPackageFile>)package {
    for (GenericRcol *rcol in files) {
        rcol.fileDescriptor = [self cloneDescriptor:rcol.fileDescriptor];
        [rcol synchronizeUserData];
        
        if ([package findFile:rcol.fileDescriptor] == nil) {
            [package add:rcol.fileDescriptor];
        }
    }
}

// MARK: - Additional Resource Loading Methods

+ (NSArray<NSString *> *)loadParentModelNames:(id<IPackageFile>)package delete:(BOOL)shouldDelete {
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Loading Parent Modelnames"];
    }
    
    NSMutableArray<NSString *> *list = [[NSMutableArray alloc] init];
    
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:[MetaData GMND]];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        [rcol processData:pfd package:package];
        
        for (id<IRcolBlock> irb in rcol.blocks) {
            if ([[irb.blockName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:@"cdatalistextension"]) {
                DataListExtension *dle = (DataListExtension *)irb;
                if ([[dle.extension.varName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:@"tsmaterialsmeshname"]) {
                    for (ExtensionItem *ei in dle.extension.items) {
                        NSString *mname = [ei.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
                        if ([mname hasSuffix:@"_cres"]) {
                            mname = [mname stringByAppendingString:@"_cres"];
                        }
                        
                        if (![list containsObject:mname]) {
                            [list addObject:mname];
                        }
                    }
                    
                    if (shouldDelete) {
                        dle.extension.items = @[];
                        [rcol synchronizeUserData];
                    }
                    break;
                }
            }
        }
    }
    
    return [list copy];
}

// MARK: - Wallmask Methods

- (NSMutableArray *)loadWallmask:(NSString *)modelname {
    NSMutableArray *txmt = [[NSMutableArray alloc] init];
    
    modelname = [modelname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    if ([modelname hasSuffix:@"_cres"]) {
        modelname = [modelname substringToIndex:modelname.length - 5];
    }
    
    // No Modelname => no Wallmask
    if (modelname.length == 0) return txmt;
    
    // This applies to all found NameMaps for TXTR Files
    NSMutableArray *foundnames = [[NSMutableArray alloc] init];
    NSArray<id<IScenegraphFileIndexItem>> *namemapitems = [[FileTable fileIndex] findFile:[MetaData NAME_MAP]
                                                                                    group:0x52737256
                                                                                 instance:[MetaData TXMT]
                                                                                  package:nil];
    
    for (id<IScenegraphFileIndexItem> namemap in namemapitems) {
        Nmap *nmap = [[Nmap alloc] initWithProvider:nil];
        [nmap processData:namemap];
        
        for (NmapItem *ni in nmap.items) {
            NSString *name = [ni.filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
            if ([name hasPrefix:modelname] && [name hasSuffix:@"_wallmask_txmt"]) {
                id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:name
                                                                                     type:[MetaData TXMT]
                                                                                    group:ni.group
                                                                             searchGlobal:YES];
                
                if (item != nil) {
                    if (![foundnames containsObject:item.fileDescriptor]) {
                        [foundnames addObject:item.fileDescriptor];
                        [txmt addObject:item];
                    }
                }
            }
        }
    }
    
    return txmt;
}

- (void)addWallmasks:(NSArray<NSString *> *)modelnames {
    for (NSString *modelname in modelnames) {
        NSMutableArray *txmt = [self loadWallmask:modelname];
        
        for (id<IScenegraphFileIndexItem> item in txmt) {
            GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [sub processData:item];
            [self.class loadReferenced:self.modelnames
                               exclude:self.excludedReferences
                                  list:self.files
                              itemlist:self.itemlist
                                  rcol:sub
                                  item:item
                             recursive:YES
                              settings:self.settings];
        }
    }
}

// MARK: - Animation Methods

- (NSMutableArray *)loadAnim:(NSString *)name {
    NSMutableArray *anim = [[NSMutableArray alloc] init];
    
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    if (![name hasSuffix:@"_anim"]) {
        name = [name stringByAppendingString:@"_anim"];
    }
    
    id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:name
                                                                         type:[MetaData ANIM]
                                                                        group:[MetaData LOCAL_GROUP]
                                                                 searchGlobal:YES];
    if (item != nil) {
        [anim addObject:item];
    }
    
    return anim;
}

- (void)addAnims:(NSArray<NSString *> *)names {
    for (NSString *name in names) {
        NSMutableArray *anim = [self loadAnim:name];
        
        for (id<IScenegraphFileIndexItem> item in anim) {
            GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [sub processData:item];
            [self.class loadReferenced:self.modelnames
                               exclude:self.excludedReferences
                                  list:self.files
                              itemlist:self.itemlist
                                  rcol:sub
                                  item:item
                             recursive:YES
                              settings:self.settings];
        }
    }
}

// MARK: - 3IDR Methods

- (void)addFrom3IDR:(id<IPackageFile>)package {
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:[MetaData REF_FILE]];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        RefFile *refFile = [[RefFile alloc] init];
        [refFile processData:pfd package:package];
        
        for (id<IPackedFileDescriptor> p in refFile.items) {
            NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:p package:nil];
            for (id<IScenegraphFileIndexItem> item in items) {
                @try {
                    GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                    [sub processData:item];
                    [self.class loadReferenced:self.modelnames
                                       exclude:self.excludedReferences
                                          list:self.files
                                      itemlist:self.itemlist
                                          rcol:sub
                                          item:item
                                     recursive:YES
                                      settings:self.settings];
                }
                @catch (NSException *ex) {
                    if ([Helper debugMode]) {
                        [Helper exceptionMessage:@"" exception:ex];
                    }
                }
            }
        }
    }
}

// MARK: - XML Methods

- (void)addFromXml:(id<IPackageFile>)package {
    NSArray<id<IPackedFileDescriptor>> *index = [[package index] copy];
    for (id<IPackedFileDescriptor> pfd in index) {
        Cpf *cpf = [[Cpf alloc] init];
        if (![cpf canHandleType:pfd.type]) continue;
        
        [cpf processData:pfd package:package];
        
        // xobj
        [self addFromXmlItem:[cpf getItem:@"material"] suffix:@"_txmt" type:[MetaData TXMT]];
        
        // hood object
        if (pfd.type == [MetaData XNGB]) {
            [self addFromXmlItem:[cpf getItem:@"modelname"] suffix:@"_cres" type:[MetaData CRES]];
        }
        
        // fences
        [self addFromXmlItem:[cpf getItem:@"diagrail"] suffix:@"_cres" type:[MetaData CRES]];
        [self addFromXmlItem:[cpf getItem:@"post"] suffix:@"_cres" type:[MetaData CRES]];
        [self addFromXmlItem:[cpf getItem:@"rail"] suffix:@"_cres" type:[MetaData CRES]];
        [self addFromXmlItem:[cpf getItem:@"diagrail"] suffix:@"_txmt" type:[MetaData TXMT]];
        [self addFromXmlItem:[cpf getItem:@"post"] suffix:@"_txmt" type:[MetaData TXMT]];
        [self addFromXmlItem:[cpf getItem:@"rail"] suffix:@"_txmt" type:[MetaData TXMT]];
        
        // terrain
        [self addFromXmlItem:[cpf getItem:@"texturetname"] suffix:@"_txtr" type:[MetaData TXTR]];
        [self addFromXmlItem:[cpf getItem:@"texturetname"] suffix:@"_detail_txtr" type:[MetaData TXTR]];
        [self addFromXmlItem:[cpf getItem:@"texturetname"] suffix:@"-bump_txtr" type:[MetaData TXTR]];
        
        // roof
        [self addFromXmlItem:[cpf getItem:@"textureedges"] suffix:@"_txtr" type:[MetaData TXTR]];
        [self addFromXmlItem:[cpf getItem:@"texturetop"] suffix:@"_txtr" type:[MetaData TXTR]];
        [self addFromXmlItem:[cpf getItem:@"texturetopbump"] suffix:@"_txtr" type:[MetaData TXTR]];
        [self addFromXmlItem:[cpf getItem:@"texturetrim"] suffix:@"_txtr" type:[MetaData TXTR]];
        [self addFromXmlItem:[cpf getItem:@"textureunder"] suffix:@"_txtr" type:[MetaData TXTR]];
        
        NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:[[cpf getSaveItem:@"stringsetrestypeid"] uintegerValue]
                                                                                 group:[[cpf getSaveItem:@"stringsetgroupid"] uintegerValue]
                                                                              instance:[[cpf getSaveItem:@"stringsetid"] uintegerValue]
                                                                               package:nil];
        [self addFromXmlItems:items];
    }
}

- (void)addFromXmlItem:(CpfItem *)item suffix:(NSString *)suffix type:(uint32_t)type {
    if (item == nil) return;
    [self addFromXmlName:[item.stringValue stringByAppendingString:suffix] type:type];
}

- (void)addFromXmlName:(NSString *)name type:(uint32_t)type {
    id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:name
                                                                         type:type
                                                                        group:[MetaData LOCAL_GROUP]
                                                                 searchGlobal:YES];
    [self addFromXmlItem:item];
}

- (void)addFromXmlItem:(id<IScenegraphFileIndexItem>)item {
    if (item == nil) return;
    [self addFromXmlItems:@[item]];
}

- (void)addFromXmlItems:(NSArray<id<IScenegraphFileIndexItem>> *)items {
    for (id<IScenegraphFileIndexItem> item in items) {
        @try {
            GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [sub processData:item];
            [self.class loadReferenced:self.modelnames
                               exclude:self.excludedReferences
                                  list:self.files
                              itemlist:self.itemlist
                                  rcol:sub
                                  item:item
                             recursive:YES
                              settings:self.settings];
        }
        @catch (NSException *ex) {
            if ([Helper debugMode]) {
                [Helper exceptionMessage:@"" exception:ex];
            }
        }
    }
}

// MARK: - String-Linked Resource Methods

- (NSMutableArray *)loadStrLinked:(id<IPackageFile>)package instance:(id)instanceAlias {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // This method would need the StrInstanceAlias structure to be properly implemented
    // For now, returning empty array as placeholder
    return list;
}

- (void)addStrLinked:(id<IPackageFile>)package instances:(NSArray *)instances {
    for (id instanceAlias in instances) {
        NSMutableArray *rcols = [self loadStrLinked:package instance:instanceAlias];
        
        for (id<IScenegraphFileIndexItem> item in rcols) {
            GenericRcol *sub = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [sub processData:item];
            [self.class loadReferenced:self.modelnames
                               exclude:self.excludedReferences
                                  list:self.files
                              itemlist:self.itemlist
                                  rcol:sub
                                  item:item
                             recursive:YES
                              settings:self.settings];
        }
    }
}

@end
