//
//  ObjectCloner.m
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

#import "ObjectCloner.h"
#import "GeneratableFile.h"
#import "Scenegraph.h"
#import "ExtObjdWrapper.h"
#import "MmatWrapper.h"
#import "GenericRcolWrapper.h"
#import "cShape.h"
#import "StrWrapper.h"
#import "StrItem.h"
#import "MetaData.h"
#import "FileTable.h"
#import "WaitingScreen.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IPackedFile.h"

// MARK: - StrInstanceAlias Implementation

@implementation StrInstanceAlias

- (instancetype)initWithInstance:(uint32_t)instance type:(uint32_t)type extension:(NSString *)extension {
    self = [super initWithId:instance name:extension tag:@[@(type)]];
    if (self) {
        // Additional initialization if needed
    }
    return self;
}

- (uint32_t)type {
    return [self.tag[0] unsignedIntValue];
}

- (uint32_t)instance {
    return (uint32_t)self.aliasId;
}

- (NSString *)extension {
    return self.name;
}

@end

// MARK: - CloneSettings Implementation

@implementation CloneSettings

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set defaults matching C# constructor
        StrInstanceAlias *defaultAlias = [[StrInstanceAlias alloc] initWithInstance:0x88
                                                                               type:[MetaData TXMT]
                                                                          extension:@"_txmt"];
        self.strInstances = @[defaultAlias];
        
        self.pullResourcesByStr = YES;
        self.includeWallmask = YES;
        self.throwExceptions = YES;
        self.updateMmatGuids = YES;
        self.onlyDefaultMmats = YES;
        self.includeAnimationResources = NO;
        self.keepOriginalMesh = NO;
        self.baseResource = BaseResourceTypeObjd;
    }
    return self;
}

@end

// MARK: - ObjectCloner Implementation

@interface ObjectCloner ()
@property (nonatomic, strong) id<IPackageFile> package;
@end

@implementation ObjectCloner

// MARK: - Initialization

- (instancetype)initWithPackage:(id<IPackageFile>)package {
    self = [super init];
    if (self) {
        self.package = package;
        self.setup = [[CloneSettings alloc] init];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.package = [GeneratableFile loadFromStream:nil];
        self.setup = [[CloneSettings alloc] init];
    }
    return self;
}

// MARK: - Static Utility Methods

+ (NSArray<id<IPackedFileDescriptor>> *)findStateMatchingMatd:(NSString *)name package:(id<IPackageFile>)package {
    NSArray<id<IPackedFileDescriptor>> *pfds = nil;
    NSString *searchName = name;
    
    // Handle state matching patterns from C#
    if ([name hasSuffix:@"_clean"]) {
        searchName = [[name substringToIndex:name.length - 6] stringByAppendingString:@"_dirty"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_dirty"]) {
        searchName = [[name substringToIndex:name.length - 6] stringByAppendingString:@"_clean"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_lit"]) {
        searchName = [[name substringToIndex:name.length - 4] stringByAppendingString:@"_unlit"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_unlit"]) {
        searchName = [[name substringToIndex:name.length - 6] stringByAppendingString:@"_lit"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_on"]) {
        searchName = [[name substringToIndex:name.length - 3] stringByAppendingString:@"_off"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_off"]) {
        searchName = [[name substringToIndex:name.length - 4] stringByAppendingString:@"_on"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_shadeinside"]) {
        searchName = [[name substringToIndex:name.length - 12] stringByAppendingString:@"_shadeoutside"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    } else if ([name hasSuffix:@"_shadeoutside"]) {
        searchName = [[name substringToIndex:name.length - 13] stringByAppendingString:@"_shadeinside"];
        pfds = [package findFile:[searchName stringByAppendingString:@"_txmt"] type:0x49596978];
    }
    
    return pfds;
}

// MARK: - GUID Management

- (uint32_t)getPrimaryGuid {
    uint32_t guid = 0;
    NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFile:[MetaData OBJD_FILE] group:0 instance:0x41A7];
    
    if (pfds.count == 0) {
        pfds = [self.package findFiles:[MetaData OBJD_FILE]];
    }
    
    if (pfds.count > 0) {
        ExtObjd *objd = [[ExtObjd alloc] init];
        [objd processData:pfds[0] package:self.package];
        guid = objd.guid;
    }
    
    return guid;
}

- (NSArray<NSNumber *> *)getGuidList {
    NSMutableArray<NSNumber *> *list = [[NSMutableArray alloc] init];
    NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:[MetaData OBJD_FILE]];
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        ExtObjd *objd = [[ExtObjd alloc] init];
        [objd processData:pfd package:self.package];
        [list addObject:@(objd.guid)];
    }
    
    return [list copy];
}

- (void)updateMmatGuids:(NSArray<NSNumber *> *)guids primary:(uint32_t)primary {
    if (primary == 0) return;
    
    NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:[MetaData MMAT]];
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        MmatWrapper *mmat = [[MmatWrapper alloc] init];
        [mmat processData:pfd package:self.package];
        
        // The C# code comments out this section because it causes problems with slave Objects
        // Keeping the same logic here for consistency
        /*
         if (![guids containsObject:@(mmat.objectGUID)]) {
         mmat.objectGUID = primary;
         [mmat synchronizeUserData];
         }
         */
    }
}

// MARK: - Model Cloning

- (void)rcolModelClone:(NSString *)modelname {
    if (modelname == nil) return;
    [self rcolModelClone:@[modelname]];
}

- (void)rcolModelClone:(NSArray<NSString *> *)modelnames {
    [self rcolModelClone:modelnames exclude:@[]];
}

- (void)rcolModelClone:(NSArray<NSString *> *)modelnames exclude:(NSArray<NSString *> *)exclude {
    if (modelnames == nil) return;
    
    [Scenegraph setFileExcludeList:[Scenegraph.defaultFileExcludeList mutableCopy]];
    
    [[FileTable fileIndex] load];
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Walking Scenegraph"];
    }
    
    Scenegraph *sg = [[Scenegraph alloc] initWithModelnames:modelnames
                                                excludeList:exclude
                                                   settings:self.setup];
    
    if ((self.setup.baseResource & BaseResourceTypeRef) == BaseResourceTypeRef) {
        if ([WaitingScreen running]) {
            [WaitingScreen updateMessage:@"Reading 3IDR References"];
        }
        [sg addFrom3IDR:self.package];
    }
    
    if ((self.setup.baseResource & BaseResourceTypeXml) == BaseResourceTypeXml) {
        if ([WaitingScreen running]) {
            [WaitingScreen updateMessage:@"Reading XObject Definition"];
        }
        [sg addFromXml:self.package];
    }
    
    if (self.setup.includeWallmask) {
        if ([WaitingScreen running]) {
            [WaitingScreen updateMessage:@"Scanning for Wallmasks"];
        }
        [sg addWallmasks:modelnames];
    }
    
    if (self.setup.pullResourcesByStr) {
        if ([WaitingScreen running]) {
            [WaitingScreen updateMessage:@"Scanning for #Str-linked Resources"];
        }
        [sg addStrLinked:self.package instances:self.setup.strInstances];
    }
    
    if (self.setup.includeAnimationResources) {
        if ([WaitingScreen running]) {
            [WaitingScreen updateMessage:@"Scanning for Animations"];
        }
        [sg addAnims:[self getAnimNames]];
    }
    
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Collect Slave TXMTs"];
    }
    [sg addSlaveTxmts:[sg getSlaveSubsets]];
    
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Building Package"];
    }
    [sg buildPackage:self.package];
    
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Collect MMAT Files"];
    }
    [sg addMaterialOverrides:self.package
                 onlyDefault:self.setup.onlyDefaultMmats
                    subitems:YES
                   exception:self.setup.throwExceptions];
    
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Collect Slave TXMTs"];
    }
    [Scenegraph addSlaveTxmts:self.package slaves:[Scenegraph getSlaveSubsets:self.package]];
    
    if (self.setup.updateMmatGuids) {
        if ([WaitingScreen running]) {
            [WaitingScreen updateMessage:@"Fixing MMAT Files"];
        }
        [self updateMmatGuids:[self getGuidList] primary:[self getPrimaryGuid]];
    }
}

// MARK: - Name Extraction

- (NSArray<NSString *> *)getNames:(NSArray<NSNumber *> *)instances extension:(nullable NSString *)extension {
    NSMutableArray<NSString *> *list = [[NSMutableArray alloc] init];
    
    NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:[MetaData STRING_FILE]];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        BOOL shouldProcess = NO;
        for (NSNumber *instanceNum in instances) {
            if (pfd.instance == [instanceNum unsignedIntValue]) {
                shouldProcess = YES;
                break;
            }
        }
        
        if (shouldProcess) {
            Str *str = [[Str alloc] init];
            [str processData:pfd package:self.package];
            
            for (StrToken *si in str.items) {
                NSString *s = [si.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (s.length > 0) {
                    if (extension != nil) {
                        if (![[s lowercaseString] hasSuffix:extension]) {
                            s = [s stringByAppendingString:extension];
                        }
                    }
                    [list addObject:s];
                }
            }
        }
    }
    
    return [list copy];
}

- (NSArray<NSString *> *)getAnimNames {
    NSArray<NSNumber *> *instances = @[@0x81, @0x82, @0x86, @0x192];
    return [self getNames:instances extension:@"_anim"];
}

// MARK: - Parent File Management

- (void)addParentFiles:(NSArray<NSString *> *)orgModelnames package:(id<IPackageFile>)targetPackage {
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Loading Parent Files"];
    }
    
    NSMutableArray<NSString *> *names = [orgModelnames mutableCopy];
    
    NSArray<NSNumber *> *types = @[
        @([MetaData MMAT]),
        @([MetaData TXMT]),
        @([MetaData TXTR]),
        @([MetaData LIFO])
    ];
    
    for (NSNumber *typeNum in types) {
        uint32_t type = [typeNum unsignedIntValue];
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:type];
        
        for (id<IPackedFileDescriptor> pfd in pfds) {
            if ([targetPackage findFile:pfd] != nil) continue;
            
            id<IPackedFile> file = [self.package read:pfd];
            pfd.userData = file.uncompressedData;
            
            // Update the modelName in the MMAT
            if ((pfd.type == [MetaData MMAT]) && (names.count > 0)) {
                MmatWrapper *mmat = [[MmatWrapper alloc] init];
                [mmat processData:pfd package:self.package];
                
                NSString *n = [mmat.modelName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
                if (![n hasSuffix:@"_cres"]) {
                    n = [n stringByAppendingString:@"_cres"];
                }
                
                if (![names containsObject:n]) {
                    n = names[0];
                    mmat.modelName = n;
                    [mmat synchronizeUserData];
                }
            }
            
            [targetPackage add:pfd];
        }
    }
}

- (void)removeSubsetReferences:(NSArray<NSString *> *)exclude modelnames:(nullable NSArray<NSString *> *)modelnames {
    if ([WaitingScreen running]) {
        [WaitingScreen updateMessage:@"Removing unwanted Subsets"];
    }
    
    // Build the ModelName List
    NSMutableArray<NSString *> *mn = [[NSMutableArray alloc] init];
    if (modelnames != nil) {
        for (NSString *s in modelnames) {
            NSString *n = s;
            if ([s hasSuffix:@"_cres"]) {
                n = [s substringToIndex:s.length - 5];
            }
            [mn addObject:n];
        }
    }
    
    BOOL deleted = NO;
    NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:[MetaData SHPE]];
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        [rcol processData:pfd package:self.package];
        
        Shape *shape = (Shape *)rcol.blocks[0];
        for (ShapePart *p in shape.parts) {
            NSString *s = [p.subset stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
            BOOL remove = [exclude containsObject:s];
            
            if ((modelnames != nil) && !remove) {
                remove = YES;
                NSString *fl = [p.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
                
                for (NSString *n in mn) {
                    if ([fl hasPrefix:n]) {
                        remove = NO;
                        break;
                    }
                }
            }
            
            if (remove) {
                NSString *n = [p.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
                if (![n hasSuffix:@"_txmt"]) {
                    n = [n stringByAppendingString:@"_txmt"];
                }
                
                NSMutableArray *names = [[NSMutableArray alloc] init];
                NSArray<id<IPackedFileDescriptor>> *rpfds = [self.package findFile:n type:[MetaData TXMT]];
                
                for (id<IPackedFileDescriptor> rpfd in rpfds) {
                    [names addObject:rpfd];
                }
                
                NSInteger pos = 0;
                while (pos < names.count) {
                    id<IPackedFileDescriptor> rpfd = names[pos++];
                    rpfd = [self.package findFile:rpfd];
                    
                    if (rpfd != nil) {
                        rpfd.markForDelete = YES;
                        deleted = YES;
                        
                        GenericRcol *fl = [[GenericRcol alloc] initWithProvider:nil fast:NO];
                        [fl processData:rpfd package:self.package];
                        
                        NSDictionary *ht = fl.referenceChains;
                        for (NSString *k in ht.allKeys) {
                            NSArray *refs = ht[k];
                            for (id<IPackedFileDescriptor> lpfd in refs) {
                                if (![names containsObject:lpfd]) {
                                    [names addObject:lpfd];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Now remove all deleted Files from the Index
    if (deleted) {
        [self.package removeMarked];
    }
}

@end
