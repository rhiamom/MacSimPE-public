//
//  PackedFileItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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

#import "PackedFileItem.h"
#import "CpfWrapper.h"
#import "CpfItem.h"
#import "PackedFileWrapper.h"
#import "GenericRcolWrapper.h"
#import "cMaterialDefinition.h"
#import "FileTable.h"
#import "MetaData.h"
#import "Helper.h"
#import "Localization.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import "IPackageFile.h"

@implementation SkinChain

- (instancetype)initWithCpf:(Cpf *)cpf {
    self = [super init];
    if (self) {
        _cpf = cpf;
    }
    return self;
}

- (uint32_t)category {
    @try {
        if (self.cpf) {
            CpfItem *item = [self.cpf getItem:@"category"];
            if (item) {
                return item.uintegerValue;
            }
        }
    }
    @catch (NSException *exception) {
        // Return default value
    }
    return 0;
}

- (uint32_t)age {
    @try {
        if (self.cpf) {
            CpfItem *item = [self.cpf getItem:@"age"];
            if (item) {
                return item.uintegerValue;
            }
        }
    }
    @catch (NSException *exception) {
        // Return default value
    }
    return 0;
}

- (NSString *)name {
    @try {
        if (self.cpf) {
            CpfItem *item = [self.cpf getItem:@"name"];
            if (item) {
                return item.stringValue;
            }
        }
    }
    @catch (NSException *exception) {
        // Return default value
    }
    return @"";
}

- (RefFile *)referenceFile {
    if (self.cpf) {
        @try {
            id<IPackedFileDescriptor> descriptor = [self.cpf.package findFileWithType:0xAC506764
                                                                              subType:self.cpf.fileDescriptor.subType
                                                                                group:self.cpf.fileDescriptor.group
                                                                             instance:self.cpf.fileDescriptor.instance];
            if (descriptor) {
                RefFile *refFile = [[RefFile alloc] init];
                [refFile processData:descriptor package:self.cpf.package];
                return refFile;
            }
        }
        @catch (NSException *exception) {
            // Return nil
        }
    }
    return nil;
}

- (GenericRcol *)loadRcol:(uint32_t)type descriptor:(id<IPackedFileDescriptor>)descriptor {
    if (descriptor.type == type) {
        NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:descriptor package:nil];
        if (items.count > 0) {
            GenericRcol *rcol = [[GenericRcol alloc] initWithWrapper:nil editable:NO];
            [rcol processData:items[0] editable:NO];
            return rcol;
        }
    }
    return nil;
}

- (GenericRcol *)loadTXTR:(GenericRcol *)txmt {
    if (!txmt) return nil;
    
    @try {
        MaterialDefinition *materialDef = (MaterialDefinition *)txmt.blocks[0];
        NSString *txtrName = [[materialDef findProperty:@"stdMatBaseTextureName"].value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
        
        if (![txtrName hasSuffix:@"_txtr"]) {
            txtrName = [txtrName stringByAppendingString:@"_txtr"];
        }
        
        id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:txtrName
                                                                             type:[MetaData TXTR]
                                                                            group:[MetaData LOCAL_GROUP]
                                                                           global:YES];
        if (item) {
            GenericRcol *rcol = [[GenericRcol alloc] initWithWrapper:nil editable:NO];
            [rcol processData:item editable:NO];
            return rcol;
        }
    }
    @catch (NSException *exception) {
        // Return nil
    }
    
    return nil;
}

- (NSArray<GenericRcol *> *)txmts {
    RefFile *refFile = self.referenceFile;
    NSMutableArray<GenericRcol *> *list = [[NSMutableArray alloc] init];
    
    if (refFile) {
        @try {
            for (id<IPackedFileDescriptor> descriptor in refFile.items) {
                GenericRcol *rcol = [self loadRcol:[MetaData TXMT] descriptor:descriptor];
                if (rcol) {
                    [list addObject:rcol];
                }
            }
        }
        @catch (NSException *exception) {
            // Continue with empty list
        }
    }
    
    return [list copy];
}

- (NSArray<GenericRcol *> *)txtrs {
    NSArray<GenericRcol *> *txmts = self.txmts;
    NSMutableArray<GenericRcol *> *list = [[NSMutableArray alloc] init];
    
    for (GenericRcol *txmt in txmts) {
        GenericRcol *rcol = [self loadTXTR:txmt];
        if (rcol) {
            [list addObject:rcol];
        }
    }
    
    return [list copy];
}

- (GenericRcol *)txmt {
    RefFile *refFile = self.referenceFile;
    
    if (refFile && self.cpf) {
        CpfItem *overrideItem = [self.cpf getItem:@"override0resourcekeyidx"];
        if (overrideItem) {
            uint32_t resourceKeyIndex = overrideItem.uintegerValue;
            if (resourceKeyIndex < refFile.items.count) {
                id<IPackedFileDescriptor> descriptor = refFile.items[resourceKeyIndex];
                return [self loadRcol:[MetaData TXMT] descriptor:descriptor];
            }
        }
    }
    
    NSArray<GenericRcol *> *txmts = self.txmts;
    if (txmts.count > 0) {
        return txmts[0];
    }
    
    return nil;
}

- (GenericRcol *)txtr {
    GenericRcol *rcol = [self loadTXTR:self.txmt];
    if (rcol) return rcol;
    
    NSArray<GenericRcol *> *txtrs = self.txtrs;
    if (txtrs.count > 0) {
        return txtrs[0];
    }
    
    return nil;
}

- (NSString *)categoryNames {
    NSMutableString *categoryString = [[NSMutableString alloc] init];
    uint32_t categoryValue = self.category;
    
    // Get all SkinCategories enum values and check flags
    NSArray *skinCategories = @[@1, @2, @4, @8, @16]; // Example values
    NSArray *categoryNames = @[@"Baby", @"Child", @"Teen", @"Adult", @"Elder"]; // Example names
    
    for (NSUInteger i = 0; i < skinCategories.count; i++) {
        uint32_t categoryFlag = [skinCategories[i] unsignedIntValue];
        if ((categoryValue & categoryFlag) == categoryFlag) {
            if (categoryString.length > 0) {
                [categoryString appendString:@", "];
            }
            [categoryString appendString:categoryNames[i]];
        }
    }
    
    return [categoryString copy];
}

- (NSString *)ageNames {
    NSMutableString *ageString = [[NSMutableString alloc] init];
    uint32_t ageValue = self.age;
    
    // Get all Ages enum values and check flags
    NSArray *ages = @[@1, @2, @4, @8, @16]; // Example values
    NSArray *ageNames = @[@"Baby", @"Toddler", @"Child", @"Teen", @"Adult"]; // Example names
    
    for (NSUInteger i = 0; i < ages.count; i++) {
        uint32_t ageFlag = [ages[i] unsignedIntValue];
        if ((ageValue & ageFlag) == ageFlag) {
            if (ageString.length > 0) {
                [ageString appendString:@", "];
            }
            [ageString appendString:ageNames[i]];
        }
    }
    
    return [ageString copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Category=%@; Age=%@; Name=%@",
            self.categoryNames, self.ageNames, self.name];
}

@end

@implementation RefFileItem

- (instancetype)initWithParent:(RefFile *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)descriptor parent:(RefFile *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        self.group = descriptor.group;
        self.type = descriptor.type;
        self.subType = descriptor.subType;
        self.instance = descriptor.instance;
    }
    return self;
}

- (SkinChain *)skin {
    if (!_skin && (self.type == [MetaData GZPS]) && self.parent) {
        @try {
            [[FileTable fileIndex] load];
            NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:self package:self.parent.package];
            
            if (items.count > 0) {
                Cpf *cpf = [[Cpf alloc] init];
                [cpf processData:items[0]];
                _skin = [[SkinChain alloc] initWithCpf:cpf];
            }
        }
        @catch (NSException *exception) {
            // Leave _skin as nil
        }
    }
    return _skin;
}

- (NSString *)description {
    NSString *baseName = [super description];
    
    if (self.skin) {
        NSString *skinInfo = [NSString stringWithFormat:@"Category=%@; Age=%@; Name=%@",
                             self.skin.categoryNames, self.skin.ageNames, self.skin.name];
        return [NSString stringWithFormat:@"%@ (%@)", skinInfo, baseName];
    }
    
    return baseName;
}

@end

@implementation CpfListItem {
    NSString *_name;
    uint32_t _category;
}

- (instancetype)initWithCpf:(Cpf *)cpf {
    self = [super initWithCpf:cpf];
    if (self) {
        _name = [[Localization manager] getString:@"Unknown"];
        _category = 0;
        
        if (cpf) {
            for (CpfItem *item in cpf.items) {
                if ([item.name.lowercaseString isEqualToString:@"name"]) {
                    _name = item.stringValue;
                }
                if ([item.name.lowercaseString isEqualToString:@"category"]) {
                    _category = item.uintegerValue;
                }
            }
        }
        
        _name = [_name stringByReplacingOccurrencesOfString:@"CASIE_" withString:@""];
    }
    return self;
}

- (NSString *)name {
    return _name;
}

- (Cpf *)file {
    return self.cpf;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%@: %@", [Helper hexString:(uint16_t)_category], _name];
}

@end
#import <Foundation/Foundation.h>
