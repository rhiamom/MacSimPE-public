//
//  FixObject.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

#import "FixObject.h"
#import "MetaData.h"
#import "Hashes.h"
#import "Helper.h"
#import "FileTable.h"
#import "WaitingScreen.h"
#import "RenameForm.h"
#import "RcolWrapper.h"
#import "GenericRcolWrapper.h"
#import "cMaterialDefinition.h"
#import "cShape.h"
#import "cImageData.h"
#import "LifoWrapper.h"
#import "cLevelInfo.h"
#import "ResourceNode.h"
#import "GeometryNode.h"
#import "DirectionalLight.h"
#import "StrWrapper.h"
#import "StrToken.h"
#import "NrefWrapper.h"
#import "ExtObjdWrapper.h"
#import "MmatWrapper.h"
#import "CpfWrapper.h"
#import "CpfItem.h"
#import "RefFile.h"
#import "ShapeRefNode.h"
#import "PackedFileDescriptor.h"


@interface FixObject ()
@property (nonatomic, strong) NSMutableArray *types;
@end

@implementation FixObject

static NSMutableArray *_staticTypes = nil;

- (instancetype)initWithPackage:(id<IPackageFile>)package
                        version:(FixVersion)version
           removeNonDefaultText:(BOOL)removeNonDefaultText {
    self = [super initWithPackage:package];
    if (self) {
        self.fixVersion = version;
        self.removeNonDefaultTextReferences = removeNonDefaultText;
        
        if (_staticTypes == nil) {
            _staticTypes = [[NSMutableArray alloc] init];
            [_staticTypes addObject:@([MetaData TXMT])];
            [_staticTypes addObject:@([MetaData TXTR])];
            [_staticTypes addObject:@([MetaData LIFO])];
            [_staticTypes addObject:@([MetaData GMND])];
        }
        self.types = _staticTypes;
    }
    return self;
}

+ (NSString *)getUniqueTxmtName:(NSString *)name
                         unique:(NSString *)unique
                     subsetName:(NSString *)subsetName
                      extension:(BOOL)extension {
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    name = [RenameForm replaceOldUnique:name newUnique:@"" extension:NO];
    
    if ([[name lowercaseString] hasSuffix:@"_txmt"]) {
        name = [name substringToIndex:name.length - 5];
    }
    
    NSArray<NSString *> *parts = [name componentsSeparatedByString:@"_"];
    if (parts.count > 0) {
        name = @"";
        BOOL first = YES;
        for (NSString *s in parts) {
            if (!first) name = [name stringByAppendingString:@"_"];
            name = [name stringByAppendingString:s];
            if (first) {
                first = NO;
                name = [name stringByAppendingFormat:@"-%@", unique];
            }
        }
    } else {
        name = [name stringByAppendingString:unique];
    }
    
    if (extension) name = [name stringByAppendingString:@"_txmt"];
    return name;
}

- (NSString *)findReplacementName:(NSMutableDictionary *)map rcol:(Rcol *)rcol {
    NSString *name = [Hashes stripHashFromName:[[rcol.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString]];
    NSString *newName = map[name];
    NSString *ext = [[[MetaData findTypeAlias:rcol.fileDescriptor.type].shortName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if (newName == nil) {
        newName = [Hashes stripHashFromName:[NSString stringWithFormat:@"%@_%@", name, ext]];
        newName = map[newName];
    }
    
    if (newName == nil) newName = name;
    return newName;
}

- (void)fixTxtrRef:(NSString *)propName
              matd:(MaterialDefinition *)matd
               map:(NSMutableDictionary *)map
              rcol:(Rcol *)rcol {
    NSString *reference = [[[matd getProperty:propName].value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    NSString *newRef = map[[NSString stringWithFormat:@"%@_txtr", [Hashes stripHashFromName:reference]]];
    
    if (newRef != nil) {
        newRef = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], [Hashes stripHashFromName:newRef]];
        [matd getProperty:propName].value = [newRef substringToIndex:newRef.length - 5];
    }
    
    for (NSInteger i = 0; i < matd.listing.count; i++) {
        newRef = map[[NSString stringWithFormat:@"%@_txtr", [Hashes stripHashFromName:[matd.listing[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]]];
        if (newRef != nil) {
            matd.listing[i] = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], [Hashes stripHashFromName:[newRef substringToIndex:newRef.length - 5]]];
        }
    }
    
    NSString *name = [Hashes stripHashFromName:rcol.fileName];
    if (name.length > 5) name = [name substringToIndex:name.length - 5];
    matd.fileDescription = name;
}

- (void)fixResource:(NSMutableDictionary *)map rcol:(Rcol *)rcol {
    switch (rcol.fileDescriptor.type) {
        case [MetaData TXMT]: {
            MaterialDefinition *matd = (MaterialDefinition *)rcol.blocks[0];
            [self fixTxtrRef:@"stdMatBaseTextureName" matd:matd map:map rcol:rcol];
            [self fixTxtrRef:@"stdMatNormalMapTextureName" matd:matd map:map rcol:rcol];
            break;
        }
            
        case [MetaData SHPE]: {
            Shape *shp = (Shape *)rcol.blocks[0];
            for (ShapeItem *item in shp.items) {
                NSString *newRef = map[[Hashes stripHashFromName:[item.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]];
                if (newRef != nil) {
                    item.fileName = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], newRef];
                }
            }
            
            for (ShapePart *part in shp.parts) {
                NSString *newRef = map[[NSString stringWithFormat:@"%@_txmt", [Hashes stripHashFromName:[part.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]]];
                if (newRef != nil) {
                    part.fileName = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], [newRef substringToIndex:newRef.length - 5]];
                }
            }
            break;
        }
            
        case [MetaData TXTR]: {
            ImageData *imageData = (ImageData *)rcol.blocks[0];
            for (MipMapBlock *mmb in imageData.mipMapBlocks) {
                for (MipMap *mm in mmb.mipMaps) {
                    if (mm.texture == nil) {
                        NSArray<id<IPackedFileDescriptor>> *pfd = [self.package findFile:mm.lifoFile type:0xED534136];
                        if (pfd.count > 0) {
                            Lifo *lifo = [[Lifo alloc] initWithProvider:nil fast:NO];
                            [lifo processData:pfd[0] package:self.package];
                            LevelInfo *li = (LevelInfo *)lifo.blocks[0];
                            
                            mm.texture = nil;
                            mm.data = li.data;
                            
                            pfd[0].markForDelete = YES;
                        } else {
                            NSString *newRef = [Hashes stripHashFromName:map[[mm.lifoFile stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]];
                            if (newRef != nil) {
                                mm.lifoFile = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], newRef];
                            }
                        }
                    }
                }
            }
            break;
        }
            
        case [MetaData CRES]: {
            ResourceNode *rn = (ResourceNode *)rcol.blocks[0];
            NSString *name = [Hashes stripHashFromName:rcol.fileName];
            
            if (self.fixVersion == FixVersionUniversityReady2) {
                rn.graphNode.fileName = name;
            } else if (self.fixVersion == FixVersionUniversityReady) {
                rn.graphNode.fileName = [NSString stringWithFormat:@"##0x1c050000!%@", name];
            }
            break;
        }
            
        case [MetaData GMND]: {
            GeometryNode *gn = (GeometryNode *)rcol.blocks[0];
            NSString *name = [Hashes stripHashFromName:rcol.fileName];
            
            if (self.fixVersion == FixVersionUniversityReady2) {
                gn.objectGraphNode.fileName = name;
            } else if (self.fixVersion == FixVersionUniversityReady) {
                gn.objectGraphNode.fileName = [NSString stringWithFormat:@"##0x1c050000!%@", name];
            }
            break;
        }
            
        case [MetaData LDIR]:
        case [MetaData LAMB]:
        case [MetaData LPNT]:
        case [MetaData LSPT]: {
            DirectionalLight *dl = (DirectionalLight *)rcol.blocks[0];
            dl.lightT.nameResource.fileName = dl.nameResource.fileName;
            break;
        }
    }
}

- (void)fixNames:(NSMutableDictionary *)map {
    for (NSNumber *typeNum in [MetaData rcolList]) {
        uint32_t type = typeNum.unsignedIntValue;
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:type];
        for (id<IPackedFileDescriptor> pfd in pfds) {
            Rcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:self.package];
            
            NSString *name = [Hashes stripHashFromName:[self findReplacementName:map rcol:rcol]];
            rcol.fileName = name;
            
            [self fixResource:map rcol:rcol];
            [rcol synchronizeUserData];
        }
    }
}

- (void)cleanUp {
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Cleaning up"];
    
    NSArray<id<IPackedFileDescriptor>> *mmatPfds = [self.package findFiles:[MetaData MMAT]];
    NSMutableArray *mmats = [[NSMutableArray alloc] init];
    
    for (id<IPackedFileDescriptor> pfd in mmatPfds) {
        CpfWrapper *mmat = [[CpfWrapper alloc] init];
        [mmat processData:pfd package:self.package];
        
        NSString *content = [Scenegraph mmatContent:mmat];
        
        if (![mmats containsObject:content]) {
            NSString *txmtName = [NSString stringWithFormat:@"%@_txmt", [Hashes stripHashFromName:[[mmat getSaveItem:@"name"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]];
            NSString *cresName = [Hashes stripHashFromName:[[mmat getSaveItem:@"modelName"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString];
            
            if ([self.package findFile:[Hashes stripHashFromName:txmtName] type:0x49596978].count < 1) pfd.markForDelete = YES;
            if ([self.package findFile:[Hashes stripHashFromName:cresName] type:0xE519C933].count < 1) pfd.markForDelete = YES;
            
            if (!pfd.markForDelete) [mmats addObject:content];
        } else {
            pfd.markForDelete = YES;
        }
    }
}

- (void)fixGroup {
    uint32_t RCOLs[] = {
        0xFB00791E, // ANIM
        0x4D51F042, // CINE
        0xE519C933, // CRES
        0xAC4F8687, // GMDC
        0x7BA3838C, // GMND
        0xC9C81B9B, // LGHT
        0xC9C81BA3, // LGHT
        0xC9C81BA9, // LGHT
        0xC9C81BAD, // LGHT
        0xED534136, // LIFO
        0xFC6EB1F7, // SHPE
        0x49596978, // TXMT, MATD
        0x1C4A276C  // TXTR
    };
    
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Fixing Groups"];
    
    for (id<IPackedFileDescriptor> pfd in self.package.index) {
        BOOL rcolCheck = [self.types containsObject:@(pfd.type)];
        if (self.fixVersion == FixVersionUniversityReady) {
            rcolCheck = [[MetaData rcolList] containsObject:@(pfd.type)];
        }
        
        if ([[MetaData rcolList] containsObject:@(pfd.type)]) {
            GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:self.package];
            
            for (id<IPackedFileDescriptor> p in rcol.referencedFiles) {
                if (self.fixVersion == FixVersionUniversityReady2) {
                    if ([self.types containsObject:@(p.type)]) {
                        p.group = [MetaData CUSTOM_GROUP];
                    } else {
                        p.group = [MetaData LOCAL_GROUP];
                    }
                } else {
                    if ([[MetaData rcolList] containsObject:@(p.type)]) {
                        if (p.type != [MetaData ANIM]) {
                            p.group = [MetaData CUSTOM_GROUP];
                        } else {
                            p.group = [MetaData GLOBAL_GROUP];
                        }
                    } else {
                        p.group = [MetaData LOCAL_GROUP];
                    }
                }
            }
            [rcol synchronizeUserData];
        }
        
        if (rcolCheck) {
            if (pfd.type != [MetaData ANIM]) {
                pfd.group = [MetaData CUSTOM_GROUP];
            } else {
                pfd.group = [MetaData GLOBAL_GROUP];
            }
        } else {
            pfd.group = [MetaData LOCAL_GROUP];
        }
    }
    
    if ([self.package findFiles:[MetaData XFNC]].count > 0) {
        [self fixFence];
    }
}

- (NSMutableDictionary *)getNameMap:(BOOL)uniqueName {
    return [RenameForm execute:self.package uniqueName:uniqueName version:&_fixVersion];
}

- (NSString *)buildRefString:(id<IPackedFileDescriptor>)pfd {
    return [NSString stringWithFormat:@"%@%@%@%@",
            [Helper hexString:pfd.group],
            [Helper hexString:pfd.type],
            [Helper hexString:pfd.instance],
            [Helper hexString:pfd.subtype]];
}

- (void)fix:(NSMutableDictionary *)map uniqueFamily:(BOOL)uniqueFamily {
    NSString *groupHash = [NSString stringWithFormat:@"##0x%@!", [Helper hexString:[MetaData CUSTOM_GROUP]]];
    
    NSMutableDictionary *refMap = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *completeRefMap = [[NSMutableDictionary alloc] init];
    
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Fixing Names"];
    [self fixNames:map];
    
    for (NSNumber *typeNum in [MetaData rcolList]) {
        uint32_t type = typeNum.unsignedIntValue;
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:type];
        
        for (id<IPackedFileDescriptor> pfd in pfds) {
            Rcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:self.package];
            
            for (id<IPackedFileDescriptor> rpfd in rcol.referencedFiles) {
                NSString *refStr = [self buildRefString:rpfd];
                if (refMap[refStr] == nil) refMap[refStr] = [NSNull null];
            }
        }
    }
    
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Updating TGI Values"];
    for (NSNumber *typeNum in [MetaData rcolList]) {
        uint32_t type = typeNum.unsignedIntValue;
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:type];
        
        for (id<IPackedFileDescriptor> pfd in pfds) {
            NSString *refStr = [self buildRefString:pfd];
            Rcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:self.package];
            
            rcol.fileDescriptor.instance = [Hashes instanceHash:[Hashes stripHashFromName:rcol.fileName]];
            rcol.fileDescriptor.subtype = [Hashes subtypeHash:[Hashes stripHashFromName:rcol.fileName]];
            
            if (refMap[refStr] != nil) refMap[refStr] = rcol.fileDescriptor;
            completeRefMap[refStr] = rcol.fileDescriptor;
        }
    }
    
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Updating TGI References"];
    for (NSNumber *typeNum in [MetaData rcolList]) {
        uint32_t type = typeNum.unsignedIntValue;
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:type];
        
        for (id<IPackedFileDescriptor> pfd in pfds) {
            Rcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:self.package];
            
            for (id<IPackedFileDescriptor> rpfd in rcol.referencedFiles) {
                NSString *refStr = [NSString stringWithFormat:@"%@%@%@%@",
                                    [Helper hexString:rpfd.group],
                                    [Helper hexString:rpfd.type],
                                    [Helper hexString:rpfd.instance],
                                    [Helper hexString:rpfd.subtype]];
                
                if (self.fixVersion == FixVersionUniversityReady2) {
                    if ([self.types containsObject:@(rpfd.type)]) {
                        rpfd.group = [MetaData CUSTOM_GROUP];
                    } else {
                        rpfd.group = [MetaData LOCAL_GROUP];
                    }
                } else {
                    if (rpfd.type != [MetaData ANIM]) {
                        rpfd.group = [MetaData CUSTOM_GROUP];
                    } else {
                        rpfd.group = [MetaData GLOBAL_GROUP];
                    }
                }
                
                if (refMap[refStr] != nil && refMap[refStr] != [NSNull null]) {
                    id<IPackedFileDescriptor> npfd = refMap[refStr];
                    rpfd.instance = npfd.instance;
                    rpfd.subtype = npfd.subtype;
                }
            }
            
            [rcol synchronizeUserData];
        }
    }
    
    [self fixXObject:map refMap:completeRefMap groupHash:groupHash];
    [self fixSkin:map refMap:completeRefMap groupHash:groupHash];
    [self fixMmat:map uniqueFamily:uniqueFamily groupHash:groupHash];
    [self fixObjd];
    
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Updating Root"];
    NSArray<id<IPackedFileDescriptor>> *stringPfds = [self.package findFiles:[MetaData STRING_FILE]];
    NSString *modelName = nil;
    
    for (id<IPackedFileDescriptor> pfd in stringPfds) {
        StrWrapper *str = [[StrWrapper alloc] init];
        [str processData:pfd package:self.package];
        
        for (StrToken *item in str.items) {
            NSString *name = [Hashes stripHashFromName:[item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString];
            
            if ([name isEqualToString:@""]) continue;
            
            if (pfd.instance == 0x88) {
                if (![name hasSuffix:@"_txmt"]) name = [name stringByAppendingString:@"_txmt"];
            } else if (pfd.instance == 0x85) {
                if (![name hasSuffix:@"_cres"]) name = [name stringByAppendingString:@"_cres"];
            } else if ((pfd.instance == 0x81) || (pfd.instance == 0x82) || (pfd.instance == 0x86) || (pfd.instance == 0x192)) {
                if (![name hasSuffix:@"_anim"]) name = [name stringByAppendingString:@"_anim"];
            } else {
                continue;
            }
            
            NSString *newRef = map[name];
            if (newRef != nil) {
                item.title = [Hashes stripHashFromName:[newRef substringToIndex:newRef.length - 5]];
            } else {
                item.title = [Hashes stripHashFromName:item.title];
            }
            
            if (((self.fixVersion == FixVersionUniversityReady) || (pfd.instance == 0x88)) && (newRef != nil)) {
                item.title = [Hashes stripHashFromName:item.title];
                
                if (!((pfd.instance == 0x81) || (pfd.instance == 0x82) || (pfd.instance == 0x86) || (pfd.instance == 0x192))) {
                    item.title = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], item.title];
                }
            } else {
                uint32_t tp = [MetaData ANIM];
                if (pfd.instance == 0x88) tp = [MetaData TXMT];
                else if (pfd.instance == 0x85) tp = [MetaData CRES];
                
                id<IScenegraphFileIndexItem> fii = [[FileTable fileIndex] findFileByName:item.title type:tp defGroup:[MetaData LOCAL_GROUP] beTolerant:YES];
                if (fii != nil) {
                    if (fii.fileDescriptor.group == [MetaData CUSTOM_GROUP]) {
                        item.title = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], [Hashes stripHashFromName:item.title]];
                    }
                }
            }
            
            if ((modelName == nil) && (item.language.languageId == 1) && (pfd.instance == 0x85)) {
                modelName = [[name uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
            }
        }
        
        if (self.removeNonDefaultTextReferences) {
            if (pfd.instance == 0x88 || pfd.instance == 0x85 || (pfd.instance == 0x81) || (pfd.instance == 0x82) || (pfd.instance == 0x86) || (pfd.instance == 0x192)) {
                [str clearNonDefault];
            }
        }
        
        [str synchronizeUserData];
    }
    
    if (modelName != nil) {
        NSArray<id<IPackedFileDescriptor>> *nrefPfds = [self.package findFiles:0x4E524546];
        for (id<IPackedFileDescriptor> pfd in nrefPfds) {
            NrefWrapper *nref = [[NrefWrapper alloc] init];
            [nref processData:pfd package:self.package];
            
            if (self.fixVersion == FixVersionUniversityReady) {
                nref.fileName = [NSString stringWithFormat:@"SIMPE_%@", modelName];
            } else {
                nref.fileName = [NSString stringWithFormat:@"SIMPE_v2_%@", modelName];
            }
            
            [nref synchronizeUserData];
        }
    }
}

- (void)fixObjd {
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Updating Object Descriptions"];
    
    NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:[MetaData OBJD_FILE]];
    BOOL updateRugs = NO;
    
    for (id<IPackedFileDescriptor> pfd in pfds) {
        ExtObjdWrapper *objd = [[ExtObjdWrapper alloc] init];
        [objd processData:pfd package:self.package];
        
        if (objd.functionSubSort == ObjFunctionSubSortDecorativeRugs) {
            updateRugs = YES;
            break;
        }
    }
    
    if (updateRugs) {
        for (id<IPackedFileDescriptor> pfd in pfds) {
            ExtObjdWrapper *objd = [[ExtObjdWrapper alloc] init];
            [objd processData:pfd package:self.package];
            
            if (objd.type == ObjectTypesTiles) {
                objd.type = ObjectTypesNormal;
                [objd synchronizeUserData:YES updateThumbnails:YES];
            }
        }
    }
}

- (void)fixMmat:(NSMutableDictionary *)map
   uniqueFamily:(BOOL)uniqueFamily
      groupHash:(NSString *)groupHash {
    
    if ([WaitingScreen running]) [WaitingScreen updateMessage:@"Updating Material Overrides"];
    
    NSArray<id<IPackedFileDescriptor>> *mmatPfds = [self.package findFiles:[MetaData MMAT]];
    NSMutableDictionary *familyMap = [[NSMutableDictionary alloc] init];
    uint32_t minInst = 0x5000;
    
    for (id<IPackedFileDescriptor> pfd in mmatPfds) {
        MmatWrapper *mmat = [[MmatWrapper alloc] init];
        [mmat processData:pfd package:self.package];
        
        pfd.instance = minInst++;
        
        if (uniqueFamily) {
            NSString *family = [mmat getSaveItem:@"family"].stringValue;
            NSString *newFamily = familyMap[family];
            
            if (newFamily == nil) {
                newFamily = [[NSUUID UUID] UUIDString];
                familyMap[family] = newFamily;
            }
            
            mmat.family = newFamily;
        }
        
        NSString *newRef = map[[NSString stringWithFormat:@"%@_txmt", [Hashes stripHashFromName:[[mmat getSaveItem:@"name"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]]];
        if (newRef != nil) {
            newRef = [Hashes stripHashFromName:newRef];
            newRef = [newRef substringToIndex:newRef.length - 5];
            mmat.name = [NSString stringWithFormat:@"%@%@", groupHash, newRef];
        } else {
            mmat.name = [NSString stringWithFormat:@"%@%@", groupHash, [Hashes stripHashFromName:[mmat getSaveItem:@"name"].stringValue]];
        }
        
        newRef = map[[Hashes stripHashFromName:[mmat.modelName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]];
        if (newRef != nil) {
            newRef = [Hashes stripHashFromName:newRef];
            mmat.modelName = newRef;
        } else {
            mmat.modelName = [Hashes stripHashFromName:mmat.modelName];
        }
        
        if (self.fixVersion == FixVersionUniversityReady) {
            id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:mmat.modelName type:[MetaData CRES] defGroup:[MetaData GLOBAL_GROUP] beTolerant:YES];
            
            BOOL addFlag = YES;
            if (item != nil) {
                if (item.fileDescriptor.group == [MetaData GLOBAL_GROUP]) addFlag = NO;
            }
            
            if (addFlag) {
                mmat.modelName = [NSString stringWithFormat:@"##0x%@!%@", [Helper hexString:[MetaData CUSTOM_GROUP]], mmat.modelName];
            }
        }
        
        [mmat synchronizeUserData];
    }
}

- (void)fixCpfProperties:(CpfWrapper *)cpf
              properties:(NSArray<NSString *> *)props
                 nameMap:(NSMutableDictionary *)nameMap
                  prefix:(NSString *)prefix
                  suffix:(NSString *)suffix {
    for (NSString *p in props) {
        CpfItem *item = [cpf getItem:p];
        if (item == nil) continue;
        
        NSString *name = [Hashes stripHashFromName:[item.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString];
        if (![name hasSuffix:suffix]) name = [name stringByAppendingString:suffix];
        NSString *newName = nameMap[name];
        
        if (newName != nil) {
            if ([newName hasSuffix:suffix]) newName = [newName substringToIndex:newName.length - suffix.length];
            item.stringValue = [NSString stringWithFormat:@"%@%@", prefix, newName];
        }
    }
}

- (void)fixCpfPropertiesWithValue:(CpfWrapper *)cpf
                       properties:(NSArray<NSString *> *)props
                            value:(uint32_t)value {
    for (NSString *p in props) {
        CpfItem *item = [cpf getItem:p];
        if (item == nil) continue;
        
        item.uintegerValue = value;
    }
}

- (CpfItem *)fixCpfProperty:(CpfWrapper *)cpf
                   property:(NSString *)prop
                      value:(uint32_t)value {
    CpfItem *item = [cpf getItem:prop];
    if (item == nil) return nil;
    
    item.uintegerValue = value;
    return item;
}

- (void)fixFence {
    NSMutableDictionary *shpNameMap = [[NSMutableDictionary alloc] init];
    GenericRcol *rcol = [[GenericRcol alloc] init];
    uint32_t types[] = {[MetaData SHPE], [MetaData CRES]};
    
    for (int i = 0; i < 2; i++) {
        uint32_t t = types[i];
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:t];
        
        for (id<IPackedFileDescriptor> pfd in pfds) {
            if (t == [MetaData CRES] || t == [MetaData GMND]) {
                [rcol processData:pfd package:self.package];
                
                NSString *shpName = nil;
                
                if (t == [MetaData CRES]) {
                    ResourceNode *rn = (ResourceNode *)rcol.blocks[0];
                    rn.graphNode.fileName = [Hashes stripHashFromName:rn.graphNode.fileName];
                    
                    for (id<IRcolBlock> irb in rcol.blocks) {
                        if ([irb isKindOfClass:[ShapeRefNode class]]) {
                            ShapeRefNode *srn = (ShapeRefNode *)irb;
                            shpName = [[[rcol.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString stringByReplacingOccurrencesOfString:@"_cres" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];
                            shpName = [shpName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            srn.storedTransformNode.objectGraphNode.fileName = shpName;
                            shpName = [NSString stringWithFormat:@"%@_%@_shpe", [rcol.fileName stringByReplacingOccurrencesOfString:@"_cres" withString:@""], shpName];
                        }
                    }
                } else if (t == [MetaData GMND]) {
                    GeometryNode *gn = (GeometryNode *)rcol.blocks[0];
                    gn.objectGraphNode.fileName = [Hashes stripHashFromName:gn.objectGraphNode.fileName];
                }
                
                for (id<IPackedFileDescriptor> rpfd in rcol.referencedFiles) {
                    if (rpfd.type == [MetaData SHPE]) {
                        shpNameMap[@(rpfd.longInstance)] = shpName;
                        rpfd.instance = [Hashes instanceHash:shpName];
                        rpfd.subtype = [Hashes subtypeHash:shpName];
                    }
                    
                    rpfd.group = [MetaData GLOBAL_GROUP];
                }
                
                [rcol synchronizeUserData];
            }
            
            pfd.group = [MetaData GLOBAL_GROUP];
        }
    }
    
    NSArray<id<IPackedFileDescriptor>> *shapePfds = [self.package findFiles:[MetaData SHPE]];
    for (id<IPackedFileDescriptor> pfd in shapePfds) {
        if (shpNameMap[@(pfd.longInstance)] == nil) continue;
        [rcol processData:pfd package:self.package];
        rcol.fileName = shpNameMap[@(pfd.longInstance)];
        rcol.fileDescriptor.instance = [Hashes instanceHash:rcol.fileName];
        rcol.fileDescriptor.subtype = [Hashes subtypeHash:rcol.fileName];
        
        [rcol synchronizeUserData];
    }
}

- (void)fixSkin:(NSMutableDictionary *)nameMap
         refMap:(NSMutableDictionary *)refMap
      groupHash:(NSString *)groupHash {
    CpfWrapper *cpf = [[CpfWrapper alloc] init];
    
    uint32_t types[] = {[MetaData XOBJ], [MetaData XFLR], [MetaData XFNC], [MetaData XROF], [MetaData XNGB]};
    NSArray<NSString *> *txtrProps = @[@"textureedges", @"texturetop", @"texturetopbump", @"texturetrim", @"textureunder", @"texturetname"];
    NSArray<NSString *> *txmtProps = @[@"material", @"diagrail", @"post", @"rail"];
    NSArray<NSString *> *cresProps = @[@"diagrail", @"post", @"rail"];
    NSArray<NSString *> *cresPropsNgb = @[@"modelname"];
    NSArray<NSString *> *groups = @[@"stringsetgroupid", @"resourcegroupid"];
    NSArray<NSString *> *setToGuid = @[];
    
    for (int i = 0; i < 5; i++) {
        uint32_t t = types[i];
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:t];
        
        for (id<IPackedFileDescriptor> pfd in pfds) {
            [cpf processData:pfd package:self.package];
            uint32_t guid = arc4random();
            
            NSString *pfx = groupHash;
            if (t == [MetaData XFNC]) pfx = @"";
            
            [self fixCpfProperties:cpf properties:txtrProps nameMap:nameMap prefix:pfx suffix:@"_txtr"];
            [self fixCpfProperties:cpf properties:txmtProps nameMap:nameMap prefix:pfx suffix:@"_txmt"];
            [self fixCpfProperties:cpf properties:cresProps nameMap:nameMap prefix:pfx suffix:@"_cres"];
            
            if (pfd.type == [MetaData XNGB]) {
                [self fixCpfProperties:cpf properties:cresPropsNgb nameMap:nameMap prefix:pfx suffix:@"_cres"];
            }
            
            [self fixCpfPropertiesWithValue:cpf properties:groups value:[MetaData LOCAL_GROUP]];
            [self fixCpfPropertiesWithValue:cpf properties:setToGuid value:guid];
            
#ifdef DEBUG
            [self fixCpfProperty:cpf property:@"guid" value:(uint32_t)((guid & 0x00fffffe) | 0xfb000001)];
#else
            [self fixCpfProperty:cpf property:@"guid" value:(uint32_t)((guid & 0xfffffffe) | 0x00000001)];
#endif
            
            [cpf synchronizeUserData];
        }
    }
}

- (void)fixXObject:(NSMutableDictionary *)nameMap
            refMap:(NSMutableDictionary *)refMap
         groupHash:(NSString *)groupHash {
    uint32_t types[] = {[MetaData REF_FILE]};
    
    RefFile *fl = [[RefFile alloc] init];
    
    for (int i = 0; i < 1; i++) {
        uint32_t t = types[i];
        NSArray<id<IPackedFileDescriptor>> *pfds = [self.package findFiles:t];
        for (id<IPackedFileDescriptor> pfd in pfds) {
            [fl processData:pfd package:self.package];
            
            for (PackedFileDescriptor *rfi in fl.items) {
                NSString *name = [self buildRefString:rfi];
                id<IPackedFileDescriptor> npfd = refMap[name];
                if (npfd != nil) {
                    rfi.group = npfd.group;
                    rfi.longInstance = npfd.longInstance;
                }
            }
            
            [fl synchronizeUserData];
        }
    }
}

@end
