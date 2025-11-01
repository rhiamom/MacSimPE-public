//
//  MmatWrapper.m
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

#import "MmatWrapper.h"
#import "GenericRcolWrapper.h"
#import "CpfUI.h"
#import "AbstractWrapperInfo.h"
#import "MetaData.h"
#import "Helper.h"
#import "ScenegraphHelper.h"
#import "FileTable.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndexItem.h"
#import <AppKit/AppKit.h>
#import "Cpfitem.h"
#import "IScenegraphFileIndex.h"

@implementation MmatWrapper

static ExecutePreviewBlock _globalCpfPreview;

// MARK: - Class Properties

+ (ExecutePreviewBlock)globalCpfPreview {
    return _globalCpfPreview;
}

+ (void)setGlobalCpfPreview:(ExecutePreviewBlock)globalCpfPreview {
    _globalCpfPreview = [globalCpfPreview copy];
}

- (NSDictionary<NSString *, NSArray<id<IPackedFileDescriptor>> *> *)referenceChains {
    // TODO: Implement this method to return the actual reference chains
    // This should analyze the file data and return a dictionary of reference arrays
    // For now, return an empty dictionary to fix the compilation error
    return @{};
}


// MARK: - IScenegraphBlock Protocol

- (void)referencedItems:(NSMutableDictionary<NSString *, NSMutableArray *> *)refmap
            parentGroup:(uint32_t)parentgroup {
    
    NSMutableArray *cresList = [[NSMutableArray alloc] init];
    NSString *modelName = [[[self getSaveItem:@"modelName"] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![[modelName lowercaseString] hasSuffix:@"_cres"]) {
        modelName = [modelName stringByAppendingString:@"_cres"];
    }
    id<IPackedFileDescriptor> cresPfd = [ScenegraphHelper buildPfdWithFilename:modelName
                                                                      type:[MetaData CRES]
                                                              defaultGroup:parentgroup];
    [cresList addObject:cresPfd];
    refmap[@"CRES"] = cresList;
    
    NSMutableArray *txmtList = [[NSMutableArray alloc] init];
    NSString *name = [[[self getSaveItem:@"name"] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![[name lowercaseString] hasSuffix:@"_txmt"]) {
        name = [name stringByAppendingString:@"_txmt"];
    }
    id<IPackedFileDescriptor> txmtPfd = [ScenegraphHelper buildPfdWithFilename:name
                                                                      type:[MetaData TXMT]
                                                              defaultGroup:parentgroup];
    [txmtList addObject:txmtPfd];
    refmap[@"TXMT"] = txmtList;
}

- (NSString *)registerWithListing:(NSMutableDictionary *)listing {
    return @"";
}

// MARK: - AbstractWrapper Overrides

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[CpfUI alloc] initWithExecutePreview:[[self class] globalCpfPreview]];
}

- (id<IWrapperInfo>)createWrapperInfo {
    NSImage *icon = [NSImage imageNamed:@"mmat"];
    if (!icon) {
        icon = [NSImage imageNamed:@"NSApplicationIcon"];
    }
    
    return [[AbstractWrapperInfo alloc] initWithName:@"MMAT Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File describes a ColorOption for a Mesh Group / Subset. It is needed to provide an additional Color for Objects."
                                             version:4
                                                icon:icon];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@(0x4C697E5A)]; // MMAT
}

// MARK: - Material File References

- (GenericRcol *)cres {
    NSDictionary *refs = [self referenceChains];
    NSArray *cresArray = refs[@"CRES"];
    if (cresArray && cresArray.count > 0) {
        NSArray<id<IPackedFileDescriptor>> *foundFiles = [self.package findFile:cresArray[0]];
        if (foundFiles && foundFiles.count > 0) {
            id<IPackedFileDescriptor> pfd = foundFiles[0];
            if (!pfd) {
                // Fallback code
                NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFileByName:((id<IPackedFileDescriptor>)cresArray[0]).filename
                                                                                   type:[MetaData CRES]];
                if (pfds.count > 0) {
                    pfd = pfds[0];
                }
            }
            
            if (pfd) {
                GenericRcol *cres = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                [cres processData:pfd package:self.package];
                return cres;
            }
            
            if (!pfd) {
                // FileTable fallback code
                id<IPackedFileDescriptor> descriptor = (id<IPackedFileDescriptor>)cresArray[0];
                NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileDiscardingGroup:descriptor];
                if (items.count > 0) {
                    GenericRcol *cres = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                    [cres processData:items[0].fileDescriptor package:items[0].package];
                    return cres;
                }
            }
        }
        return nil;
    }
}

- (GenericRcol *)txmt {
    NSDictionary *refs = [self referenceChains];
    NSArray *txmtArray = refs[@"TXMT"];
    if (txmtArray && txmtArray.count > 0) {
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFile:txmtArray[0]];
        id<IPackedFileDescriptor> pfd = pfds.firstObject;
            
        if (!pfd) {
            // Fallback code - search by filename and type
            pfds = [self.package findFileByName:((id<IPackedFileDescriptor>)txmtArray[0]).filename
                                      type:[MetaData TXMT]];
            pfd = pfds.firstObject;
        }
            
        if (!pfd) {
            // FileTable fallback code
            NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileDiscardingGroup:txmtArray[0]];
            if (items.count > 0) {
                GenericRcol *txmtWrapper = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                [txmtWrapper processData:items[0].fileDescriptor package:items[0].package];
                return txmtWrapper;
            }
        }
            
        if (pfd) {
            GenericRcol *txmtWrapper = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [txmtWrapper processData:pfd package:self.package];
            return txmtWrapper;
        }
    }
    return nil;
}

- (GenericRcol *)getTxtr:(GenericRcol *)txmt {
    if (!txmt) return nil;
    
    NSDictionary *refs = [txmt referenceChains];
    NSArray *txtrArray = refs[@"stdMatBaseTextureName"];
    if (txtrArray && txtrArray.count > 0) {
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFile:txtrArray[0]];
        id<IPackedFileDescriptor> pfd = pfds.firstObject;
        if (!pfd) {
            // Fallback code
            NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFileByName:((id<IPackedFileDescriptor>)txtrArray[0]).filename
                                                                         type:[MetaData TXTR]];
            if (pfds.count > 0) {
                pfd = pfds[0];
            }
        }
        
        if (pfd) {
            GenericRcol *txtr = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [txtr processData:pfd package:self.package];
            return txtr;
        }
        
        if (!pfd) {
            // FileTable fallback code
            NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileDiscardingGroup:txtrArray[0]];
            if (items.count > 0) {
                GenericRcol *txtr = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                [txtr processData:items[0].fileDescriptor package:items[0].package];
                return txtr;
            }
        }
    }
    
    return nil;
}

- (GenericRcol *)txtr {
    GenericRcol *txmt = [self txmt];
    return [self getTxtr:txmt];
}

- (GenericRcol *)getGmdc {
    GenericRcol *rcol = [self cres];
    if (rcol) {
        NSDictionary *refs = [rcol referenceChains];
        NSArray *shps = refs[@"Generic"];
        if (shps && shps.count > 0) {
            NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:shps[0] package:nil];
            if (items.count > 0) {
                GenericRcol *shpe = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                [shpe processData:items[0].fileDescriptor package:items[0].package];
                
                refs = [shpe referenceChains];
                NSArray *gmnds = refs[@"Models"];
                if (gmnds && gmnds.count > 0) {
                    items = [[FileTable fileIndex] findFile:gmnds[0] package:nil];
                    if (items.count > 0) {
                        GenericRcol *gmnd = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                        [gmnd processData:items[0].fileDescriptor package:items[0].package];
                        
                        refs = [gmnd referenceChains];
                        NSArray *gmdcs = refs[@"Generic"];
                        if (gmdcs && gmdcs.count > 0) {
                            items = [[FileTable fileIndex] findFile:gmdcs[0] package:nil];
                            if (items.count > 0) {
                                GenericRcol *gmdc = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                                [gmdc processData:items[0].fileDescriptor package:items[0].package];
                                return gmdc;
                            }
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (GenericRcol *)gmdc {
    return [self getGmdc];
}

- (NSString *)description {
    NSString *str = [NSString stringWithFormat:@"objectGUID=0x%@; subset=%@; references=",
                     [Helper hexStringUInt:[self objectGUID]], [self subsetName]];
    
    NSDictionary *map = [self referenceChains];
    NSMutableString *result = [str mutableCopy];
    
    for (NSString *key in map.allKeys) {
        [result appendFormat:@"%@:", key];
        NSArray *references = map[key];
        for (id<IPackedFileDescriptor> pfd in references) {
            [result appendFormat:@"%@ (%@) | ", pfd.filename, [pfd description]];
        }
        if (references.count > 0) {
            [result deleteCharactersInRange:NSMakeRange(result.length - 3, 3)]; // Remove last " | "
        }
        [result appendString:@","];
    }
    
    if (map.count > 0) {
        [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)]; // Remove last ","
    }
    
    return [result copy];
}

@end
        
