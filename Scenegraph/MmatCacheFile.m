//
//  MmatCacheFile.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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

#import "MmatCacheFile.h"
#import "FileIndex.h"
#import "MmatWrapper.h"
#import "MmatCacheItem.h"
#import "CacheContainer.h"
#import "CacheLists.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "FileIndexItem.h"


@interface MmatCacheFile ()
@property (nonatomic, strong) FileIndex *fileIndex;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSArray *> *defaultMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray *> *modelMap;
@end

@implementation MmatCacheFile

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.defaultType = ContainerTypeMaterialOverride;
    }
    return self;
}

// MARK: - Item Management

- (void)addItem:(MmatWrapper *)mmat {
    CacheContainer *mycc = [self useContainer:ContainerTypeMaterialOverride fileName:mmat.package.fileName];
    
    MmatCacheItem *mci = [[MmatCacheItem alloc] init];
    
    mci.defaultMaterial = mmat.defaultMaterial;
    mci.modelName = [[mmat.modelName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    mci.family = [[mmat.family stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    mci.fileDescriptor = mmat.fileDescriptor;
    
    [mycc.items addObject:mci];
}

// MARK: - Properties

- (FileIndex *)fileIndex {
    if (_fileIndex == nil) {
        [self loadOverrides];
    }
    return _fileIndex;
}

- (NSDictionary<NSNumber *, NSArray *> *)defaultMap {
    if (_defaultMap == nil) {
        [self loadOverrideMaps];
    }
    return _defaultMap;
}

- (NSDictionary<NSString *, NSArray *> *)modelMap {
    if (_modelMap == nil) {
        [self loadOverrideMaps];
    }
    return _modelMap;
}

// MARK: - Loading Methods

- (void)loadOverrides {
    self.fileIndex = [[FileIndex alloc] initWithFolders:[[NSMutableArray alloc] init]];
    self.fileIndex.duplicates = YES;
    
    for (CacheContainer *cc in self.containers) {
        if (cc.type == ContainerTypeMaterialOverride && cc.valid) {
            for (MmatCacheItem *mci in cc.items) {
                id<IPackedFileDescriptor> pfd = mci.fileDescriptor;
                pfd.filename = cc.fileName;
                [self.fileIndex addIndexFromDescriptor:pfd
                                               package:nil  // Pass nil since this is cached data without an actual package object
                                            localGroup:[FileIndexItem getLocalGroupForFilename:cc.fileName]];
            }
        }
    }
}

- (void)loadOverrideMaps {
    NSMutableDictionary<NSNumber *, NSMutableArray *> *defaultMapMutable = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, NSMutableArray *> *modelMapMutable = [[NSMutableDictionary alloc] init];
    
    // Initialize default map with true/false keys
    defaultMapMutable[@YES] = [[NSMutableArray alloc] init];
    defaultMapMutable[@NO] = [[NSMutableArray alloc] init];
    
    for (CacheContainer *cc in self.containers) {
        if (cc.type == ContainerTypeMaterialOverride && cc.valid) {
            for (MmatCacheItem *mci in cc.items) {
                // Add to default map
                NSMutableArray *defaultList = defaultMapMutable[@(mci.defaultMaterial)];
                [defaultList addObject:mci];
                
                // Add to model map
                NSMutableArray *modelList = modelMapMutable[mci.modelName];
                if (modelList == nil) {
                    modelList = [[NSMutableArray alloc] init];
                    modelMapMutable[mci.modelName] = modelList;
                }
                [modelList addObject:mci];
            }
        }
    }
    
    // Convert mutable dictionaries to immutable
    NSMutableDictionary<NSNumber *, NSArray *> *finalDefaultMap = [[NSMutableDictionary alloc] init];
    for (NSNumber *key in defaultMapMutable) {
        finalDefaultMap[key] = [defaultMapMutable[key] copy];
    }
    self.defaultMap = [finalDefaultMap copy];
    
    NSMutableDictionary<NSString *, NSArray *> *finalModelMap = [[NSMutableDictionary alloc] init];
    for (NSString *key in modelMapMutable) {
        finalModelMap[key] = [modelMapMutable[key] copy];
    }
    self.modelMap = [finalModelMap copy];
}

@end
