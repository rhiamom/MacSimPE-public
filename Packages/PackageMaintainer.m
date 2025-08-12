//
//  PackageMaintainer.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "PackageMaintainer.h"
#import "GeneratableFile.h"
#import "IScenegraphFileIndex.h"
#import "Helper.h"
#import "FileTableBase.h"
#import "PackedFileDescriptors.h"

@interface PackageMaintainer ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, GeneratableFile *> *packageCache;
@end

@implementation PackageMaintainer

static PackageMaintainer *_maintainer = nil;

+ (PackageMaintainer *)maintainer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _maintainer = [[PackageMaintainer alloc] init];
    });
    return _maintainer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Case-insensitive dictionary for cross-platform compatibility
        _packageCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setFileIndex:(id<IScenegraphFileIndex>)fileIndex {
    if (_fileIndex == nil) {
        _fileIndex = fileIndex;
    }
}

- (void)removePackage:(GeneratableFile *)pkg {
    if (![[Registry windowsRegistry] usePackageMaintainer]) return;
    if (pkg == nil) return;
    
    [self removePackageWithFilename:[pkg fileName]];
}

- (void)removePackageWithFilename:(NSString *)filename {
    if (filename == nil) return;
    
    // Normalize key for case-insensitive lookup
    NSString *normalizedKey = [self normalizeKey:filename];
    
    GeneratableFile *pkg = self.packageCache[normalizedKey];
    if (pkg != nil) {
        [[FileTableBase fileIndex] closePackage:pkg];
        [self.packageCache removeObjectForKey:normalizedKey];
    }
}

- (void)removePackagesInPath:(NSString *)folder {
    if (folder == nil) return;
    
    NSString *normalizedFolder = [[folder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    NSMutableArray<NSString *> *keysToRemove = [NSMutableArray array];
    for (NSString *key in self.packageCache.allKeys) {
        if ([key hasPrefix:normalizedFolder]) {
            [keysToRemove addObject:key];
        }
    }
    
    for (NSString *key in keysToRemove) {
        [self removePackageWithFilename:key];
    }
}

- (void)syncFileIndex:(GeneratableFile *)pkg {
    [self.fileIndex clear];
    if ([[pkg index] count] <= [[Registry windowsRegistry] bigPackageResourceCount]) {
        [self.fileIndex addIndexFromPackage:pkg];
    }
}

- (BOOL)containsPackageWithFilename:(NSString *)filename {
    NSString *normalizedKey = [self normalizeKey:filename];
    return self.packageCache[normalizedKey] != nil;
}

- (GeneratableFile *)loadPackageFromFile:(NSString *)filename sync:(BOOL)sync {
    GeneratableFile *ret = nil;
    
    if (filename == nil) {
        ret = [GeneratableFile createNew];
    } else {
        if (![[Registry windowsRegistry] usePackageMaintainer]) {
            ret = [[GeneratableFile alloc] initWithFilename:filename];
        } else {
            NSString *normalizedKey = [self normalizeKey:filename];
            
            if (self.packageCache[normalizedKey] == nil) {
                self.packageCache[normalizedKey] = [[GeneratableFile alloc] initWithFilename:filename];
            } else if (sync) {
                GeneratableFile *existingPackage = self.packageCache[normalizedKey];
                [[FileTableBase fileIndex] closePackage:existingPackage];
                [existingPackage reloadFromFile:filename];
            }
            
            ret = self.packageCache[normalizedKey];
        }
    }
    
    if (sync) {
        [self syncFileIndex:ret];
    }
    
    return ret;
}

#pragma mark - Private Methods

- (NSString *)normalizeKey:(NSString *)key {
    if (key == nil) return nil;
    return [[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
}

@end
#import <Foundation/Foundation.h>
