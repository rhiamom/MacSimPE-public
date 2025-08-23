//
//  SkinProvider.m
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

#import "SkinProvider.h"
#import "MetaData.h"
#import "CpfWrapper.h"
#import "CpfItem.h"
#import "PackedFileWrapper.h"
#import "GenericRcolWrapper.h"
#import "Nmap.h"
#import "Txtr.h"
#import "ImageData.h"
#import "MaterialDefinition.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "File.h"
#import "PathProvider.h"
#import "ExpansionItem.h"
#import "Registry.h"
#import "Helper.h"

@implementation Skins

// MARK: - Initialization

- (instancetype)init {
    self = [super initWithPackage:nil];
    if (self) {
        // Properties will be initialized lazily
    }
    return self;
}

// MARK: - Package Loading Methods

- (void)loadSkinFromPackage:(id<IPackageFile>)package {
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:0xEBCF3E27];
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        @try {
            Cpf *cpf = [[Cpf alloc] init];
            [cpf processData:pfd package:package];
            [self.sets addObject:cpf];
        }
        @catch (NSException *exception) {
            // Silently ignore exceptions during loading
        }
    }
}

- (void)loadSkinImageFromPackage:(id<IPackageFile>)package {
    // Load Reference Files
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:0xAC506764];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        @try {
            RefFile *refFile = [[RefFile alloc] init];
            [refFile processData:pfd package:package];
            [self.refs addObject:refFile];
        }
        @catch (NSException *exception) {
            // Silently ignore exceptions during loading
        }
    }
    
    // Load Material Definition Files
    pfds = [package findFiles:0x49596978];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        @try {
            GenericRcol *matd = [[GenericRcol alloc] initWithProvider:nil fast:YES];
            [matd processData:pfd package:package];
            [self.matds addObject:matd];
        }
        @catch (NSException *exception) {
            // Silently ignore exceptions during loading
        }
    }
    
    // Material Files with Name Map processing
    NSArray<id<IPackedFileDescriptor>> *nmapPfds = [package findFiles:[MetaData NAME_MAP]];
    pfds = [package findFiles:0x49596978];
    Nmap *nmap = [[Nmap alloc] initWithProvider:nil];
    if ([nmapPfds count] > 0) {
        [nmap processData:[nmapPfds firstObject] package:package];
    }
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        @try {
            GenericRcol *matd = [[GenericRcol alloc] initWithProvider:nil fast:YES];
            BOOL check = NO;
            
            // Check against name map items
            for (id<IPackedFileDescriptor> epfd in [nmap items]) {
                if ([epfd group] == [pfd group] && [epfd instance] == [pfd instance]) {
                    [matd setFileDescriptor:pfd];
                    [matd setPackage:package];
                    [self.matds addObject:matd];
                    check = YES;
                    break;
                }
            }
            
            // Not found in the FileMap, so process normally
            if (!check) {
                [matd processData:pfd package:package];
                [self.matds addObject:matd];
            }
        }
        @catch (NSException *exception) {
            // Silently ignore exceptions during loading
        }
    }
    
    // Texture Files
    nmapPfds = [package findFiles:[MetaData NAME_MAP]];
    pfds = [package findFiles:0x1C4A276C];
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        @try {
            Txtr *txtr = [[Txtr alloc] initWithProvider:nil fast:YES];
            BOOL check = NO;
            
            // Check against name map items
            for (id<IPackedFileDescriptor> epfd in [nmap items]) {
                if ([epfd group] == [pfd group] && [epfd instance] == [pfd instance]) {
                    [txtr setFileDescriptor:pfd];
                    [txtr setPackage:package];
                    [self.txtrs setObject:txtr forKey:[epfd filename]];
                    check = YES;
                    break;
                }
            }
            
            // Not found in the FileMap, so process normally
            if (!check) {
                [txtr processData:pfd package:package];
                for (ImageData *imageData in [txtr blocks]) {
                    NSString *key = [[[imageData nameResource] fileName] lowercaseString];
                    [self.txtrs setObject:txtr forKey:key];
                }
            }
        }
        @catch (NSException *exception) {
            // Silently ignore exceptions during loading
        }
    }
}

- (void)loadSkins {
    [self loadPackage];
    
    self.sets = [[NSMutableArray alloc] init];
    [self loadSkinFromPackage:self.basePackage];
    [self loadUserPackages];
}

- (void)loadSkinImages {
    [self loadPackage];
    
    self.matds = [[NSMutableArray alloc] init];
    self.refs = [[NSMutableArray alloc] init];
    self.txtrs = [[NSMutableDictionary alloc] init];
    
    [self loadUserImagePackages];
}

- (void)loadUserPackages {
    NSString *downloadsPath = [NSString pathWithComponents:@[[PathProvider simSavegameFolder], @"Downloads"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsPath]) return;
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsPath error:nil];
    NSArray *packageFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension.lowercaseString == 'package'"]];
    
    for (NSString *fileName in packageFiles) {
        NSString *fullPath = [downloadsPath stringByAppendingPathComponent:fileName];
        File *package = [File loadFromFile:fullPath];
        [self loadSkinFromPackage:package];
    }
}

- (void)loadUserImagePackages {
    NSString *downloadsPath = [NSString pathWithComponents:@[[PathProvider simSavegameFolder], @"Downloads"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsPath]) return;
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsPath error:nil];
    NSArray *packageFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension.lowercaseString == 'package'"]];
    
    for (NSString *fileName in packageFiles) {
        NSString *fullPath = [downloadsPath stringByAppendingPathComponent:fileName];
        File *package = [File loadFromFile:fullPath];
        [self loadSkinImageFromPackage:package];
    }
}

// MARK: - ISkinProvider Protocol Implementation

- (void)loadPackage {
    if (self.basePackage == nil) {
        ExpansionItem *baseGame = [[PathProvider global] getExpansion:ExpansionsBaseGame];
        NSString *skinsPath = [NSString pathWithComponents:@[[baseGame installFolder], @"TSData", @"Res", @"Catalog", @"Skins", @"Skins.package"]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:skinsPath]) {
            self.basePackage = [File loadFromFile:skinsPath];
        } else {
            self.basePackage = nil;
        }
    }
}

- (NSMutableArray *)storedSkins {
    [self loadPackage];
    if (self.sets == nil) {
        [self loadSkins];
    }
    return self.sets;
}

- (id)findSet:(id<IPackedFileDescriptor>)spfd {
    if (self.sets == nil) {
        [self loadSkins];
    }
    if (self.sets == nil) return nil;
    
    for (Cpf *cpf in self.sets) {
        id<IPackedFileDescriptor> pfd = [cpf fileDescriptor];
        if ([pfd group] == [spfd group] &&
            [pfd subtype] == [spfd subtype] &&
            [pfd instance] == [spfd instance] &&
            [pfd type] == [spfd type]) {
            return cpf;
        }
    }
    
    return nil;
}

- (NSString *)findTxtrNameFromObject:(id)ocpf {
    Cpf *cpf = (Cpf *)ocpf;
    CpfItem *item = [cpf getSaveItem:@"name"];
    
    if ([cpf package] != self.basePackage) {
        NSString *name = [self findTxtrName:[cpf fileDescriptor]];
        return [self findUserTxtr:name];
    } else {
        NSString *name = [self findTxtrNameFromMaterial:[NSString stringWithFormat:@"%@_txmt", [item stringValue]]];
        return [self findTxtr:name];
    }
}

- (NSString *)findTxtrNameFromMaterial:(NSString *)matdName {
    if (matdName == nil) return nil;
    
    ExpansionItem *baseGame = [[PathProvider global] getExpansion:ExpansionsBaseGame];
    NSString *sims02Path = [NSString pathWithComponents:@[[baseGame installFolder], @"TSData", @"Res", @"Sims3D", @"Sims02.package"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sims02Path]) {
        File *package = [File loadFromFile:sims02Path];
        NSArray<id<IPackedFileDescriptor>> *pfds = [package findFile:[matdName stringByReplacingOccurrencesOfString:@"CASIE_" withString:@""] type:0x49596978];
        
        if ([pfds count] == 0) {
            pfds = [package findFile:matdName type:0x49596978];
        }
        
        // Look for the right one
        for (id<IPackedFileDescriptor> pfd in pfds) {
            GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:package];
            
            NSString *rcolFileName = [[rcol fileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
            NSString *searchName1 = [matdName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
            NSString *searchName2 = [[matdName stringByReplacingOccurrencesOfString:@"CASIE_" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
            
            if ([rcolFileName isEqualToString:searchName1] || [rcolFileName isEqualToString:searchName2]) {
                for (MaterialDefinition *md in [rcol blocks]) {
                    NSString *textureName = [[md getProperty:@"stdMatBaseTextureName"] value];
                    return [NSString stringWithFormat:@"%@_txtr", textureName];
                }
            }
        }
    }
    
    return nil;
}

- (NSString *)findTxtrName:(id<IPackedFileDescriptor>)spfd {
    if (self.matds == nil) {
        [self loadSkinImages];
    }
    if (self.matds == nil) return @"";
    if (self.refs == nil) return @"";
    
    for (RefFile *refFile in self.refs) {
        id<IPackedFileDescriptor> pfd = [refFile fileDescriptor];
        if ([pfd group] == [spfd group] &&
            [pfd subtype] == [spfd subtype] &&
            [pfd instance] == [spfd instance]) {
            
            for (id<IPackedFileDescriptor> refPfd in [refFile items]) {
                // Found a MATD Reference File
                if ([refPfd type] == 0x49596978) {
                    for (GenericRcol *matd in self.matds) {
                        id<IPackedFileDescriptor> matdPfd = [matd fileDescriptor];
                        if ([matdPfd group] == [refPfd group] &&
                            [matdPfd subtype] == [refPfd subtype] &&
                            [matdPfd instance] == [refPfd instance]) {
                            
                            for (MaterialDefinition *md in [matd blocks]) {
                                return [[md getProperty:@"stdMatBaseTextureName"] value];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return @"";
}

- (id)findTxtr:(NSString *)name {
    if (name == nil) return nil;
    
    ExpansionItem *baseGame = [[PathProvider global] getExpansion:ExpansionsBaseGame];
    NSString *sims07Path = [NSString pathWithComponents:@[[baseGame installFolder], @"TSData", @"Res", @"Sims3D", @"Sims07.package"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sims07Path]) {
        File *package = [File loadFromFile:sims07Path];
        NSArray<id<IPackedFileDescriptor>> *pfds = [package findFile:name type:0x1C4A276C];
        
        // Look for the right one
        for (id<IPackedFileDescriptor> pfd in pfds) {
            Txtr *rcol = [[Txtr alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:package];
            
            NSString *rcolFileName = [[rcol fileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
            NSString *searchName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
            
            if ([rcolFileName isEqualToString:searchName]) {
                return rcol;
            }
        }
    }
    
    return nil;
}

- (id)findUserTxtr:(NSString *)name {
    if (self.txtrs == nil) {
        [self loadSkinImages];
    }
    if (self.txtrs == nil) return nil;
    
    NSString *lowercaseName = [name lowercaseString];
    Txtr *txtr = [self.txtrs objectForKey:lowercaseName];
    if (txtr == nil) {
        txtr = [self.txtrs objectForKey:[NSString stringWithFormat:@"%@_txtr", lowercaseName]];
    }
    if (txtr == nil) return nil;
    
    if ([txtr fast]) {
        [txtr setFast:NO];
        File *package = [File loadFromFile:[[txtr package] fileName]];
        id<IPackedFileDescriptor> pfd = [package findFile:[[txtr fileDescriptor] type]
                                                  subtype:[[txtr fileDescriptor] subtype]
                                                    group:[[txtr fileDescriptor] group]
                                                 instance:[[txtr fileDescriptor] instance]];
        [txtr processData:pfd package:package];
    }
    
    return txtr;
}

// MARK: - SimCommonPackage Override

- (void)onChangedPackage {
    self.sets = nil;
    self.matds = nil;
    self.txtrs = nil;
    self.refs = nil;
}

@end
#import <Foundation/Foundation.h>
