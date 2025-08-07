//
//  FileTableItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/6/25.
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "FileTableItem.h"
#import "Helper.h"
#import "PathProvider.h"
#import "FileTable.h"
#import "ExpansionItem.h"

@interface FileTableItem ()
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *relpath;
@end

@implementation FileTableItem

@synthesize type = _type;

// MARK: - Initialization

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _isRecursive = NO;
        _isFile = NO;
        
        if ([path hasPrefix:@":"]) {
            path = [path substringFromIndex:1];
            _isRecursive = YES;
        } else if ([path hasPrefix:@"*"]) {
            path = [path substringFromIndex:1];
            _isFile = YES;
        }
        
        _path = path;
        _relpath = path;
        _epVersion = -1;
        _type = (FileTableItemType)FileTableItemTypeAbsolute;
        _ignore = NO;
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path recursive:(BOOL)recursive file:(BOOL)file {
    return [self initWithPath:path recursive:recursive file:file version:-1 ignore:NO];
}

- (instancetype)initWithPath:(NSString *)path recursive:(BOOL)recursive file:(BOOL)file version:(NSInteger)version {
    return [self initWithPath:path recursive:recursive file:file version:version ignore:NO];
}

- (instancetype)initWithPath:(NSString *)path recursive:(BOOL)recursive file:(BOOL)file version:(NSInteger)version ignore:(BOOL)ignore {
    return [self initWithRelativePath:path type:FileTableItemTypeAbsolute recursive:recursive file:file version:version ignore:ignore];
}

- (instancetype)initWithRelativePath:(NSString *)relativePath
                                type:(FileTableItemType)type
                           recursive:(BOOL)recursive
                                file:(BOOL)file
                             version:(NSInteger)version
                              ignore:(BOOL)ignore {
    self = [super init];
    if (self) {
        _isRecursive = recursive;
        _isFile = file;
        _epVersion = version;
        _type = type;
        _ignore = ignore;
        [self setNameInternal:relativePath];
    }
    return self;
}

// MARK: - Static Methods

+ (NSString *)getRootForType:(FileTableItemType)type {
    NSString *ret = [FileTablePaths getRootForType:type];
    
    if (ret != nil) {
        if (![ret hasSuffix:[Helper PATH_SEP]]) {
            ret = [ret stringByAppendingString:[Helper PATH_SEP]];
        }
    }
    
    if ([ret isEqualToString:[Helper PATH_SEP]]) {
        ret = nil;
    }
    return ret;
}

+ (NSInteger)getEPVersionForType:(FileTableItemType)type {
    return [FileTablePaths getEPVersionForType:type];
}

// MARK: - Properties

- (BOOL)use {
    return self.isAvail && !self.ignore && self.isUseable;
}

- (BOOL)isUseable {
    return self.epVersion == -1 || self.epVersion == [PathProvider global].gameVersion;
}

- (BOOL)isAvail {
    if (!self.isUseable) return NO;
    return self.exists;
}

- (BOOL)exists {
    if (self.isFile) {
        return [[NSFileManager defaultManager] fileExistsAtPath:self.name];
    } else {
        BOOL isDirectory;
        return [[NSFileManager defaultManager] fileExistsAtPath:self.name isDirectory:&isDirectory] && isDirectory;
    }
}

- (NSString *)name {
    NSString *root = [[self class] getRootForType:self.type];
    
    if (root == nil) return self.path;
    
    NSString *trimmedPath = [self.path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedPath hasPrefix:[Helper PATH_SEP]]) {
        trimmedPath = [trimmedPath substringFromIndex:1];
    }
    NSString *ret = [root stringByAppendingPathComponent:trimmedPath];
    
    if (self.isFile) {
        if ([ret hasSuffix:[Helper PATH_SEP]]) {
            ret = [ret substringToIndex:ret.length - 1];
        }
    }
    return ret;
}

- (void)setName:(NSString *)name {
    [self setNameInternal:name];
}

- (NSString *)relativePath {
    NSString *currentPath = self.path;
    if (self.isFile) {
        if ([currentPath hasSuffix:[Helper PATH_SEP]]) {
            currentPath = [currentPath substringToIndex:currentPath.length - 1];
        }
    }
    return currentPath;
}

// MARK: - Internal Methods

- (BOOL)cutName:(NSString *)name type:(FileTableItemType)type {
    @try {
        BOOL isDirectory;
        if ([[NSFileManager defaultManager] fileExistsAtPath:name isDirectory:&isDirectory] && isDirectory) {
            if (![Helper isAbsolutePath:name]) return NO;
        }
    } @catch (NSException *exception) {
#ifdef DEBUG
        [Helper exceptionMessage:exception];
#endif
    }
    
    NSString *root = [[self class] getRootForType:type];
    if (root == nil || [root isEqualToString:@""] || [root isEqualToString:[Helper PATH_SEP]]) {
        return NO;
    }
    
    root = [Helper compareableFileName:[Helper toLongPathName:root]];
    if (![root hasSuffix:[Helper PATH_SEP]]) {
        root = [root stringByAppendingString:[Helper PATH_SEP]];
    }
    
    NSString *ename = [Helper compareableFileName:name];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![ename hasSuffix:[Helper PATH_SEP]]) {
        ename = [ename stringByAppendingString:[Helper PATH_SEP]];
        name = [name stringByAppendingString:[Helper PATH_SEP]];
    }
    
    if ([ename hasPrefix:root]) {
        self.path = [name substringFromIndex:root.length];
        if (!self.isFile) {
            if ([self.path hasPrefix:[Helper PATH_SEP]]) {
                self.path = [self.path substringFromIndex:1];
            }
        }
        self.type = type;
        return YES;
    }
    
    return NO;
}

- (void)setNameInternal:(NSString *)name {
    NSString *n = name;
    
    // Check expansions
    NSArray<ExpansionItem *> *expansions = [PathProvider global].expansions;
    for (ExpansionItem *ei in expansions) {
        if ([self cutName:n type:ei.expansion]) return;
    }
    
    if ([self cutName:n type:FileTableItemTypeSaveGameFolder]) return;
    if ([self cutName:n type:FileTableItemTypeSimPEDataFolder]) return;
    if ([self cutName:n type:FileTableItemTypeSimPEFolder]) return;
    if ([self cutName:n type:FileTableItemTypeSimPEPluginFolder]) return;
    
    self.path = name;
}

// MARK: - Instance Methods

- (void)setRecursive:(BOOL)state {
    self.isRecursive = state;
}

- (void)setFile:(BOOL)state {
    self.isFile = state;
}

- (NSArray<NSString *> *)getFiles {
    if (!self.isUseable || !self.isAvail) {
        return @[];
    } else if (self.isFile) {
        return @[self.name];
    } else {
        NSString *n = self.name;
        NSError *error;
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:n error:&error];
        if (error) {
            return @[];
        }
        
        NSMutableArray *packageFiles = [[NSMutableArray alloc] init];
        for (NSString *file in contents) {
            if ([[file pathExtension] isEqualToString:@"package"]) {
                [packageFiles addObject:[n stringByAppendingPathComponent:file]];
            }
        }
        return [packageFiles copy];
    }
}

- (NSString *)description {
    NSMutableString *n = [[NSMutableString alloc] init];
    
    if (self.isFile) {
        [n appendString:@"File: "];
    } else if (self.isRecursive) {
        [n appendString:@"RecursiveFolder: "];
    } else {
        [n appendString:@"Folder: "];
    }
    
    if (!self.isUseable) {
        n = [[@"(Unused) " stringByAppendingString:n] mutableCopy];
    } else if (!self.isAvail) {
        n = [[@"(Missing) " stringByAppendingString:n] mutableCopy];
    }
    
    [n appendFormat:@"{%@}%@", [FileTablePaths stringForType:self.type], self.path];
    
    if (self.epVersion != -1) {
        [n appendFormat:@" (Only when GameVersion=%ld)", (long)self.epVersion];
    }
    
    return [n copy];
}

@end
