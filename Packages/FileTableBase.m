//
//  FileTableBase.m
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


#import "FileTableBase.h"
#import "PathProvider.h"
#import "Helper.h"
#import "FileTableItem.h"
#import "IScenegraphFileIndex.h"
#import "FileTableEnums.h"


// MARK: - FileTableBase Implementation

@implementation FileTableBase

// MARK: - Static Variables

static id<IScenegraphFileIndex> s_fileIndex = nil;
static id<IWrapperRegistry> s_wrapperRegistry = nil;
static id<IProviderRegistry> s_providerRegistry = nil;
static id<IGroupCache> s_groupCache = nil;
static NSArray<FileTableItem *> *s_defaultFolders = nil;

// MARK: - Core Properties

+ (id<IScenegraphFileIndex>)fileIndex {
    return s_fileIndex;
}

+ (void)setFileIndex:(id<IScenegraphFileIndex>)fileIndex {
    s_fileIndex = fileIndex;
}

+ (id<IWrapperRegistry>)wrapperRegistry {
    return s_wrapperRegistry;
}

+ (void)setWrapperRegistry:(id<IWrapperRegistry>)wrapperRegistry {
    s_wrapperRegistry = wrapperRegistry;
}

+ (id<IProviderRegistry>)providerRegistry {
    return s_providerRegistry;
}

+ (void)setProviderRegistry:(id<IProviderRegistry>)providerRegistry {
    s_providerRegistry = providerRegistry;
}

+ (id<IGroupCache>)groupCache {
    return s_groupCache;
}

+ (void)setGroupCache:(id<IGroupCache>)groupCache {
    s_groupCache = groupCache;
}

// MARK: - Folder Management

+ (NSArray<FileTableItem *> *)defaultFolders {
    if (!s_defaultFolders) {
        [self buildDefaultFolders];
    }
    return s_defaultFolders;
}

+ (void)buildDefaultFolders {
    NSMutableArray<FileTableItem *> *folders = [NSMutableArray array];

    @try {
        // 1) Try to load from saved configuration first
        NSArray<FileTableItem *> *configFolders = [self loadFolderConfiguration];
        if (configFolders.count > 0) {
            s_defaultFolders = configFolders;
            return;
        }

        // 2) CEP enabling files
        FileTableItem *gmnd = [[FileTableItem alloc] initWithRelativePath:@"Downloads/_EnableColorOptionsGMND.package"
                                                                     type:[[FileTableItemType alloc] initWithFileTablePath:FileTablePathsSaveGameFolder]
                                                                recursive:NO
                                                                     file:YES
                                                                  version:-1
                                                                   ignore:NO];
        [folders addObject:gmnd];

        FileTableItem *mmat = [[FileTableItem alloc] initWithRelativePath:@"$(TS2_Base)/TSData/Res/Sims3D/_EnableColorOptionsMMAT.package"
                                                                     type:[[FileTableItemType alloc] initWithFileTablePath:FileTablePathsAbsolute]
                                                                recursive:NO
                                                                     file:YES
                                                                  version:-1
                                                                   ignore:NO];
        [folders addObject:mmat];

        // 3) CEP folders
        FileTableItem *zcepDownloads = [[FileTableItem alloc] initWithRelativePath:@"zCEP-EXTRA"
                                                                              type:[[FileTableItemType alloc] initWithFileTablePath:FileTablePathsSaveGameFolder]
                                                                         recursive:YES
                                                                              file:NO
                                                                           version:-1
                                                                            ignore:NO];
        [folders addObject:zcepDownloads];

        FileTableItem *zcepBase = [[FileTableItem alloc] initWithRelativePath:@"$(TS2_Base)/TSData/Res/Catalog/zCEP-EXTRA"
                                                                         type:[[FileTableItemType alloc] initWithFileTablePath:FileTablePathsAbsolute]
                                                                    recursive:YES
                                                                         file:NO
                                                                      version:-1
                                                                       ignore:NO];
        [folders addObject:zcepBase];

        // 4) Base game folders (under $(TS2_Base))
        NSArray<NSString *> *baseGameFolders = @[
            @"TSData/Res/Catalog/Bins",
            @"TSData/Res/Sims3D",
            @"TSData/Res/Catalog/Materials",
            @"TSData/Res/Catalog/Skins",
            @"TSData/Res/Catalog/Patterns",
            @"TSData/Res/Catalog/CANHObjects",
            @"TSData/Res/Wants",
            @"TSData/Res/UI"
        ];
        for (NSString *folder in baseGameFolders) {
            BOOL isPreObject = [folder containsString:@"Bins"];
            FileTableItem *item = [[FileTableItem alloc] initWithRelativePath:[@"$(TS2_Base)/" stringByAppendingString:folder]
                                                                         type:[[FileTableItemType alloc] initWithFileTablePath:FileTablePathsAbsolute]
                                                                    recursive:YES
                                                                         file:NO
                                                                      version:-1
                                                                       ignore:isPreObject];
            [folders addObject:item];
        }

        // 5) Expansion pack folders (resolved against each EP root later)
        NSArray<NSString *> *expansionFolders = @[
            @"TSData/Res/3D",
            @"TSData/Res/Objects",
            @"TSData/Res/Catalog/Materials",
            @"TSData/Res/Catalog/Skins",
            @"TSData/Res/Catalog/Patterns",
            @"TSData/Res/Catalog/CANHObjects",
            @"TSData/Res/Wants",
            @"TSData/Res/UI"
        ];
        for (NSString *folder in expansionFolders) {
            FileTableItem *item = [[FileTableItem alloc] initWithRelativePath:folder
                                                                         type:[[FileTableItemType alloc] initWithFileTablePath:FileTablePathsAbsolute]
                                                                    recursive:YES
                                                                         file:NO
                                                                      version:-1
                                                                       ignore:NO];
            [folders addObject:item];
        }

        // 6) Save and publish
        s_defaultFolders = [folders copy];
        [self storeFolderConfiguration:s_defaultFolders];

    } @catch (NSException *ex) {
        NSLog(@"Error building default folders: %@", ex.reason);
        s_defaultFolders = [folders copy]; // keep whatever we built so far
    }
}

+ (NSArray<FileTableItem *> *)loadFolderConfiguration {
    @try {
        // Try to load from folders.xreg XML file (matching C# behavior)
        NSString *foldersPath = [DataFolder foldersXREG];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:foldersPath]) {
            // Build default XML if it doesn't exist
            [self buildFolderXml];
            foldersPath = [DataFolder foldersXREG];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:foldersPath]) {
            return nil;
        }
        
        return [self loadFoldersFromXmlFile:foldersPath];
        
    } @catch (NSException *exception) {
        NSLog(@"Error loading folder configuration: %@", [exception reason]);
        return nil;
    }
}

+ (NSArray<FileTableItem *> *)loadFoldersFromXmlFile:(NSString *)xmlPath {
    @try {
        NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
        if (xmlData.length == 0) return nil;

        NSError *error = nil;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&error];
        if (error || !document) {
            NSLog(@"[FileTableBase] XML parse error: %@", error.localizedDescription);
            return nil;
        }

        // Find /folders/filetable
        NSArray *filetableNodes = [document nodesForXPath:@"/folders/filetable" error:&error];
        if (error || filetableNodes.count == 0) return nil;

        NSXMLElement *filetableElement = (NSXMLElement *)filetableNodes.firstObject;
        NSMutableArray<FileTableItem *> *folders = [NSMutableArray array];

        for (NSXMLNode *node in filetableElement.children) {
            if (![node isKindOfClass:[NSXMLElement class]]) continue;

            NSXMLElement *element = (NSXMLElement *)node;
            NSString *nodeName = element.name;
            BOOL isPath = [nodeName isEqualToString:@"path"];
            BOOL isFile = [nodeName isEqualToString:@"file"];
            if (!isPath && !isFile) continue;

            // Attributes
            BOOL isRecursive = NO;
            BOOL ignore = NO;
            NSInteger epVersion = -1;

            NSXMLNode *recursiveAttr = [element attributeForName:@"recursive"];
            if (recursiveAttr && ![(recursiveAttr.stringValue ?: @"0") isEqualToString:@"0"]) {
                isRecursive = YES;
            }

            NSXMLNode *ignoreAttr = [element attributeForName:@"ignore"];
            if (ignoreAttr && ![(ignoreAttr.stringValue ?: @"0") isEqualToString:@"0"]) {
                ignore = YES;
            }

            NSXMLNode *versionAttr = [element attributeForName:@"version"];
            if (!versionAttr) versionAttr = [element attributeForName:@"epversion"];
            if (versionAttr) epVersion = versionAttr.stringValue.integerValue;

            // Root → FileTablePaths token
            FileTablePaths typeToken = FileTablePathsAbsolute; // default “game/absolute”
            NSXMLNode *rootAttr = [element attributeForName:@"root"];
            if (rootAttr) {
                NSString *rootValue = rootAttr.stringValue.lowercaseString;
                if ([rootValue isEqualToString:@"save"]) {
                    typeToken = FileTablePathsSaveGameFolder;
                } else if ([rootValue isEqualToString:@"simpe"]) {
                    typeToken = FileTablePathsSimPEFolder;
                } else if ([rootValue isEqualToString:@"simpedata"]) {
                    typeToken = FileTablePathsSimPEDataFolder;
                } else if ([rootValue isEqualToString:@"simpeplugin"]) {
                    typeToken = FileTablePathsSimPEPluginFolder;
                } else {
                    // "game" or unknown → treat as absolute under $(TS2_Base)
                    typeToken = FileTablePathsAbsolute;
                }
            }

            // Element value
            NSString *relativePath = [element.stringValue stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (relativePath.length == 0) continue;

            // Box the enum into the object your API expects
            FileTableItemType *typeObj = [[FileTableItemType alloc] initWithFileTablePath:typeToken];

            FileTableItem *item = [[FileTableItem alloc] initWithRelativePath:relativePath
                                                                         type:typeObj
                                                                    recursive:isRecursive
                                                                         file:isFile
                                                                      version:epVersion
                                                                       ignore:ignore];
            [folders addObject:item];
        }

        return folders.count ? [folders copy] : nil;

    } @catch (NSException *ex) {
        NSLog(@"[FileTableBase] loadFoldersFromXmlFile error: %@", ex.reason);
        return nil;
    }
}
    
        + (void)buildFolderXml {
            @try {
                NSString *foldersPath = [DataFolder foldersXREG];
                
                // Create XML document
                NSXMLElement *foldersElement = [[NSXMLElement alloc] initWithName:@"folders"];
                NSXMLElement *filetableElement = [[NSXMLElement alloc] initWithName:@"filetable"];
                [foldersElement addChild:filetableElement];
                
                // Add CEP files
                [self addXmlFileNode:filetableElement
                                root:@"save"
                                path:@"Downloads/_EnableColorOptionsGMND.package"];
                
                [self addXmlFileNode:filetableElement
                                root:@"game"
                                path:@"TSData/Res/Sims3D/_EnableColorOptionsMMAT.package"];
                
                // Add CEP folders
                [self addXmlPathNode:filetableElement
                                root:@"save"
                                path:@"zCEP-EXTRA"
                           recursive:YES
                             version:nil
                              ignore:NO];
                
                [self addXmlPathNode:filetableElement
                                root:@"game"
                                path:@"TSData/Res/Catalog/zCEP-EXTRA"
                           recursive:YES
                             version:nil
                              ignore:NO];
                
                // Add base game and expansion folders (simplified)
                NSArray *gamefolders = @[
                    @"TSData/Res/Catalog/Bins",
                    @"TSData/Res/Sims3D",
                    @"TSData/Res/3D",
                    @"TSData/Res/Objects",
                    @"TSData/Res/Catalog/Materials",
                    @"TSData/Res/Catalog/Skins",
                    @"TSData/Res/Catalog/Patterns",
                    @"TSData/Res/Catalog/CANHObjects",
                    @"TSData/Res/Wants",
                    @"TSData/Res/UI"
                ];
                
                for (NSString *folder in gamefolders) {
                    BOOL ignore = [folder containsString:@"Bins"]; // Pre-object folders
                    [self addXmlPathNode:filetableElement
                                    root:@"game"
                                    path:folder
                               recursive:YES
                                 version:nil
                                  ignore:ignore];
                }
                
                NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:foldersElement];
                [document setVersion:@"1.0"];
                [document setCharacterEncoding:@"UTF-8"];
                
                NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
                [xmlData writeToFile:foldersPath atomically:YES];
                
            } @catch (NSException *exception) {
                NSLog(@"Error building folder XML: %@", [exception reason]);
            }
        }
        
        + (void)addXmlFileNode:(NSXMLElement *)parent root:(NSString *)root path:(NSString *)path {
            NSXMLElement *fileElement = [[NSXMLElement alloc] initWithName:@"file"];
            [fileElement addAttribute:[NSXMLNode attributeWithName:@"root" stringValue:root]];
            [fileElement setStringValue:path];
            [parent addChild:fileElement];
        }
        
        + (void)addXmlPathNode:(NSXMLElement *)parent
        root:(NSString *)root
        path:(NSString *)path
        recursive:(BOOL)recursive
        version:(NSString *)version
        ignore:(BOOL)ignore {
            NSXMLElement *pathElement = [[NSXMLElement alloc] initWithName:@"path"];
            [pathElement addAttribute:[NSXMLNode attributeWithName:@"root" stringValue:root]];
            
            if (recursive) {
                [pathElement addAttribute:[NSXMLNode attributeWithName:@"recursive" stringValue:@"1"]];
            }
            if (version) {
                [pathElement addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:version]];
            }
            if (ignore) {
                [pathElement addAttribute:[NSXMLNode attributeWithName:@"ignore" stringValue:@"1"]];
            }
            
            [pathElement setStringValue:path];
            [parent addChild:pathElement];
        }
        
        + (void)storeFolderConfiguration:(NSArray<FileTableItem *> *)folders {
            @try {
                NSString *foldersPath = [DataFolder foldersXREG];
                
                // Create XML document
                NSXMLElement *foldersElement = [[NSXMLElement alloc] initWithName:@"folders"];
                NSXMLElement *filetableElement = [[NSXMLElement alloc] initWithName:@"filetable"];
                [foldersElement addChild:filetableElement];
                
                for (FileTableItem *folder in folders) {
                    NSXMLElement *itemElement = [[NSXMLElement alloc] initWithName:folder.isFile ? @"file" : @"path"];
                    
                    // Add root attribute based on type
                    NSString *rootValue = nil;
                    switch ([folder.type asFileTablePaths]) {
                        case FileTableItemTypeAbsolute:
                            rootValue = @"game"; // Default to game folder
                            break;
                        case FileTableItemTypeSaveGameFolder:
                            rootValue = @"save";
                            break;
                        case FileTableItemTypeSimPEFolder:
                            rootValue = @"simpe";
                            break;
                        case FileTableItemTypeSimPEDataFolder:
                            rootValue = @"simpeData";
                            break;
                        case FileTableItemTypeSimPEPluginFolder:
                            rootValue = @"simpePlugin";
                            break;
                    }
                    
                    if (rootValue) {
                        [itemElement addAttribute:[NSXMLNode attributeWithName:@"root" stringValue:rootValue]];
                    }
                    
                    if (folder.isRecursive) {
                        [itemElement addAttribute:[NSXMLNode attributeWithName:@"recursive" stringValue:@"1"]];
                    }
                    
                    if (folder.epVersion >= 0) {
                        [itemElement addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:[@(folder.epVersion) stringValue]]];
                    }
                    
                    if (folder.ignore) {
                        [itemElement addAttribute:[NSXMLNode attributeWithName:@"ignore" stringValue:@"1"]];
                    }
                    
                    [itemElement setStringValue:folder.relativePath];
                    [filetableElement addChild:itemElement];
                }
                
                NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:foldersElement];
                [document setVersion:@"1.0"];
                [document setCharacterEncoding:@"UTF-8"];
                
                NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
                [xmlData writeToFile:foldersPath atomically:YES];
                
            } @catch (NSException *exception) {
                NSLog(@"Error storing folder configuration: %@", [exception reason]);
            }
        }
    
+ (void)loadPackageFiles{
    // Get the index (must already be created/assigned elsewhere)
    id<IScenegraphFileIndex> idx = [self fileIndex];
    if (!idx) {
        NSLog(@"[FileTableBase] No FileIndex set; skipping loadPackageFiles.");
        return;
    }

    // Ensure we have default folders
    NSArray<FileTableItem *> *defaults = [self defaultFolders];
    if (!defaults || defaults.count == 0) {
        [self buildDefaultFolders];
        defaults = [self defaultFolders];
    }

    // Apply folders and force a reload (C# FileTable.Reload() equivalent)
    idx.baseFolders = [defaults mutableCopy];
    [idx forceReload];
}

@end
