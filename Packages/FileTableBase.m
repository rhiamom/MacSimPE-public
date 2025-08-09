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
    NSMutableArray<FileTableItem *> *folders = [[NSMutableArray alloc] init];
    
    @try {
        // First try to load from configuration
        NSArray<FileTableItem *> *configFolders = [self loadFolderConfiguration];
        if (configFolders && [configFolders count] > 0) {
            s_defaultFolders = configFolders;
            return;
        }
        
        // Build default configuration (simplified from C# XML approach)
        
        // CEP enabling files
        [[FileTableItem alloc] initWithRelativePath:@"Downloads/_EnableColorOptionsGMND.package"
                                                                  type:FileTableItemTypeSaveGameFolder
                                                           recursive:NO
                                                                file:YES
                                                             version:-1
                                                                ignore:NO];
        
        [[FileTableItem alloc] initWithRelativePath:@"TSData/Res/Sims3D/_EnableColorOptionsMMAT.package"
                                                                  type:FileTableItemTypeAbsolute
                                                            recursive:NO
                                                                 file:YES
                                                              version:-1
                                                               ignore:NO];
        
        // CEP folders
        [[FileTableItem alloc] initWithRelativePath:@"zCEP-EXTRA"
                                                                  type:FileTableItemTypeSaveGameFolder
                                                             recursive:YES
                                                                  file:NO
                                                               version:-1
                                                                ignore:NO];
        
        [[FileTableItem alloc] initWithRelativePath:@"TSData/Res/Catalog/zCEP-EXTRA"
                                                                  type:FileTableItemTypeAbsolute
                                                             recursive:YES
                                                                  file:NO
                                                               version:-1
                                                                ignore:NO];
        
        // Base game folders - simplified approach
        NSArray *baseGameFolders = @[
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
            [[FileTableItem alloc] initWithRelativePath:folder
                                                                      type:FileTableItemTypeAbsolute
                                                                 recursive:YES
                                                                      file:NO
                                                                   version:-1
                                                                    ignore:isPreObject]; // Pre-object folders are often ignored
        }
        
        // Expansion pack folders - simplified
        NSArray *expansionFolders = @[
            @"TSData/Res/3D",
            @"TSData/Res/Objects", // For certain expansions
            @"TSData/Res/Catalog/Materials",
            @"TSData/Res/Catalog/Skins",
            @"TSData/Res/Catalog/Patterns",
            @"TSData/Res/Catalog/CANHObjects",
            @"TSData/Res/Wants",
            @"TSData/Res/UI"
        ];
        
        for (NSString *folder in expansionFolders) {
            [[FileTableItem alloc] initWithRelativePath:folder
                                                   type:FileTableItemTypeAbsolute
                                              recursive:YES
                                                   file:NO
                                                version:-1
                                                 ignore:NO];
        }
        
        s_defaultFolders = [folders copy];
        
        // Save the default configuration
        [self storeFolderConfiguration:s_defaultFolders];
        
    } @catch (NSException *exception) {
        NSLog(@"Error building default folders: %@", [exception reason]);
        s_defaultFolders = [folders copy]; // Use what we have
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
        if (!xmlData) {
            return nil;
        }
        
        NSError *error = nil;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&error];
        if (error) {
            NSLog(@"Error parsing XML: %@", [error localizedDescription]);
            return nil;
        }
        
        NSMutableArray<FileTableItem *> *folders = [[NSMutableArray alloc] init];
        
        // Navigate to /folders/filetable
        NSArray *filetableNodes = [document nodesForXPath:@"/folders/filetable" error:&error];
        if (error || [filetableNodes count] == 0) {
            return nil;
        }
        
        NSXMLElement *filetableElement = (NSXMLElement *)[filetableNodes firstObject];
        NSArray *pathNodes = [filetableElement children];
        
        for (NSXMLNode *node in pathNodes) {
            if (![node isKindOfClass:[NSXMLElement class]]) continue;
            
            NSXMLElement *element = (NSXMLElement *)node;
            NSString *nodeName = [element name];
            
            if (![nodeName isEqualToString:@"path"] && ![nodeName isEqualToString:@"file"]) {
                continue;
            }
            
            // Parse attributes
            BOOL isFile = [nodeName isEqualToString:@"file"];
            BOOL isRecursive = NO;
            BOOL ignore = NO;
            NSInteger epVersion = -1;
            FileTableItemType type = FileTableItemTypeAbsolute;
            
            NSXMLNode *recursiveAttr = [element attributeForName:@"recursive"];
            if (recursiveAttr && ![[recursiveAttr stringValue] isEqualToString:@"0"]) {
                isRecursive = YES;
            }
            
            NSXMLNode *ignoreAttr = [element attributeForName:@"ignore"];
            if (ignoreAttr && ![[ignoreAttr stringValue] isEqualToString:@"0"]) {
                ignore = YES;
            }
            
            NSXMLNode *versionAttr = [element attributeForName:@"version"];
            if (!versionAttr) {
                versionAttr = [element attributeForName:@"epversion"];
            }
            if (versionAttr) {
                epVersion = [[versionAttr stringValue] integerValue];
            }
            
            NSXMLNode *rootAttr = [element attributeForName:@"root"];
            if (rootAttr) {
                NSString *rootValue = [[rootAttr stringValue] lowercaseString];
                
                if ([rootValue isEqualToString:@"save"]) {
                    type = FileTableItemTypeSaveGameFolder;
                } else if ([rootValue isEqualToString:@"simpe"]) {
                    type = FileTableItemTypeSimPEFolder;
                } else if ([rootValue isEqualToString:@"simpedata"]) {
                    type = FileTableItemTypeSimPEDataFolder;
                } else if ([rootValue isEqualToString:@"simpeplugin"]) {
                    type = FileTableItemTypeSimPEPluginFolder;
                }
                // Note: Expansion pack handling would need ExpansionItem lookup here
            }
            
            NSString *relativePath = [element stringValue];
            if (!relativePath) continue;
            
            FileTableItem *item = [[FileTableItem alloc] initWithRelativePath:relativePath
                                                                          type:type
                                                                     recursive:isRecursive
                                                                          file:isFile
                                                                       version:epVersion
                                                                        ignore:ignore];
            [folders addObject:item];
        }
        
        return [folders copy];
        
    } @catch (NSException *exception) {
        NSLog(@"Error loading folders from XML: %@", [exception reason]);
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
            switch (folder.type) {
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

+ (void)loadPackageFiles
{
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
