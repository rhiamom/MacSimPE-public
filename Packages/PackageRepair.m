//
//  PackageRepair.m
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

#import "PackageRepair.h"
#import "IPackageFile.h"
#import "IPackageHeader.h"
#import "HeaderIndex.h"
#import "GeneratableFile.h"
#import "File.h"
#import "BinaryReader.h"
#import "PackedFileDescriptor.h"
#import "Helper.h"
#import "TGILoader.h"
#import "TypeAlias.h"
#import "WaitingScreen.h"
#import "HeaderData.h"
#import "HeaderIndex.h"

// MARK: - IndexDetails Implementation

@interface IndexDetails ()
@property (nonatomic, strong) id<IPackageHeader> packageHeader;
@end

@implementation IndexDetails

- (instancetype)initWithPackageHeader:(id<IPackageHeader>)header {
    self = [super init];
    if (self) {
        _packageHeader = header;
    }
    return self;
}

- (NSString *)identifier {
    return [self.packageHeader identifier];
}

- (NSString *)version {
    return [NSString stringWithFormat:@"0x%@", [Helper hexString:[self.packageHeader version]]];
}

- (IndexTypes)indexType {
    return [self.packageHeader indexType];
}

- (void)setIndexType:(IndexTypes)indexType {
    [self.packageHeader setIndexType:indexType];
}

- (uint32_t)ident {
    return [self.packageHeader created];
}

@end

// MARK: - IndexDetailsAdvanced Implementation

@implementation IndexDetailsAdvanced

- (NSString *)indexOffset {
    return [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.packageHeader index] offset]]];
}

- (NSString *)indexSize {
    return [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.packageHeader index] size]]];
}

- (NSInteger)resourceCount {
    return [[self.packageHeader index] count];
}

- (NSString *)indexVersion {
    return [NSString stringWithFormat:@"0x%@", [Helper hexString:[(HeaderIndex *)[self.packageHeader index] iType]]];
}

- (NSString *)indexItemSize {
    uint32_t itemSize = [[self.packageHeader index] itemSize];
    uint32_t calculatedSize = [[self.packageHeader index] size] / [[self.packageHeader index] count];
    return [NSString stringWithFormat:@"0x%@ (0x%@)",
            [Helper hexString:itemSize],
            [Helper hexString:calculatedSize]];
}

- (NSInteger)majorVersion {
    return [self.packageHeader majorVersion];
}

- (NSInteger)minorVersion {
    return [self.packageHeader minorVersion];
}

@end

// MARK: - PackageRepair Implementation

@interface PackageRepair ()
@property (nonatomic, strong) id<IPackageFile> packageFile;
@property (nonatomic, strong) NSArray<NSNumber *> *validTypes;
@end

@implementation PackageRepair

- (instancetype)initWithPackageFile:(id<IPackageFile>)packageFile {
    self = [super init];
    if (self) {
        _packageFile = packageFile;
        [self initTypes];
    }
    return self;
}

- (void)initTypes {
    NSMutableArray<NSNumber *> *types = [[NSMutableArray alloc] init];
    NSArray<TypeAlias *> *fileTypes = [[Helper tgiLoader] fileTypes];
    
    for (TypeAlias *typeAlias in fileTypes) {
        [types addObject:@([typeAlias typeID])];
    }
    
    self.validTypes = [types copy];
}

- (BOOL)couldBeIndexItem:(BinaryReader *)binaryReader
                position:(long long)position
                    step:(NSInteger)step
                  strict:(BOOL)strict {
    
    if (position < 0) {
        return NO;
    }
    
    for (NSInteger i = 0; i < 4; i++) {
        [binaryReader.baseStream setPosition:position + (i * step)];
        
        PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
        [pfd loadFromStream:[self.packageFile header] reader:binaryReader];
        
        NSNumber *typeNumber = @([pfd type]);
        if (![self.validTypes containsObject:typeNumber]) {
            return NO;
        }
        
        if ([pfd size] <= 0) {
            return NO;
        }
        
        if ([pfd offset] <= 0 || [pfd offset] >= [binaryReader.baseStream length]) {
            return NO;
        }
        
        if (strict) {
            if ([pfd type] == 0x00000000) {
                return NO;
            }
            if ([pfd type] == 0xffffffff) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (HeaderIndex *)findIndexOffset {
    HeaderIndex *headerIndex = [[HeaderIndex alloc] initWithHeader:[self.packageFile header]];
    
    // Reload reader if this is a File instance
    if ([self.packageFile isKindOfClass:[File class]]) {
        [(File *)self.packageFile reloadReader];
    }
    
    BinaryReader *binaryReader = [self.packageFile reader];
    NSInteger step = 0x18;
    
    if ([[self.packageFile header] indexType] == ptShortFileIndex) {
        step = 0x14;
    }
    
    long long position = [binaryReader.baseStream length] - (4 * step + 1);
    long long lastItem = -1;
    long long firstItem = -1;
    
    [WaitingScreen wait];
    
    @try {
        while (position > 0x04) {
            NSString *message = [NSString stringWithFormat:@"0x%@ / 0x%@",
                               [Helper hexString:(uint32_t)position],
                               [Helper hexString:(uint32_t) [binaryReader.baseStream length]]];
            [WaitingScreen updateMessage:message];
            
            BOOL hit = [self couldBeIndexItem:binaryReader
                                     position:position
                                         step:step
                                       strict:(lastItem == -1)];
            
            if (hit && lastItem == -1) {
                lastItem = [binaryReader.baseStream position];
            }
            
            if (!hit && lastItem != -1) {
                firstItem = position + step;
                break;
            }
            
            if (lastItem == -1) {
                position--;
            } else {
                position -= step;
            }
        }
    } @finally {
        [WaitingScreen stop];
    }
    
    [headerIndex setOffset:(uint32_t)firstItem];
    [headerIndex setSize:(int)(lastItem - firstItem)];
    [headerIndex setCount:[headerIndex size] / step];
    
    if (firstItem == -1) {
        headerIndex = (HeaderIndex *)[[self.packageFile header] index];
    }
    
    return headerIndex;
}

- (void)useIndexData:(HeaderIndex *)headerIndex {
   if ([headerIndex parent] == [self.packageFile header] && [self package] != nil) {
       [headerIndex useInParent];
       [[self package] reload];
   }
}

- (IndexDetails *)indexDetails {
    return [[IndexDetails alloc] initWithPackageHeader:[self.packageFile header]];
}

- (IndexDetailsAdvanced *)indexDetailsAdvanced {
    return [[IndexDetailsAdvanced alloc] initWithPackageHeader:[self.packageFile header]];
}

- (GeneratableFile *)package {
    if ([self.packageFile isKindOfClass:[GeneratableFile class]]) {
        return (GeneratableFile *)self.packageFile;
    }
    return nil;
}

@end
