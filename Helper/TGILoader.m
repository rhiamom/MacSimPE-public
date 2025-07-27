//
//  TGILoader.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop         *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "TGILoader.h"
#import "TypeAlias.h"
#import "Helper.h"

@interface TGILoader ()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TypeAlias *> *typeMap;
@property (nonatomic, strong) NSMutableArray<TypeAlias *> *typeList;
@end

@implementation TGILoader

static TGILoader *_shared = nil;

// MARK: - Shared Instance

+ (TGILoader *)shared {
    return _shared;
}

+ (void)setShared:(TGILoader *)shared {
    _shared = shared;
}

// MARK: - Initialization

- (instancetype)initWithFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        _typeMap = [NSMutableDictionary dictionary];
        _typeList = [NSMutableArray array];
        [self loadTGI:filename];
    }
    return self;
}

- (instancetype)init {
    NSString *tgiPath = [[Helper simPeDataPath] stringByAppendingPathComponent:@"tgi.xml"];
    return [self initWithFilename:tgiPath];
}

// MARK: - File Loading

- (void)loadTGI:(NSString *)xmlFilename {
    [self.typeMap removeAllObjects];
    [self.typeList removeAllObjects];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:xmlFilename]) {
        NSString *message = [NSString stringWithFormat:@"The File \"%@\" was not found on the system", xmlFilename];
        [Helper exceptionMessageWithString:[NSString stringWithFormat:@"Unable to load TGI description: %@", message]];
        return;
    }
    
    NSError *error;
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlFilename options:0 error:&error];
    if (!xmlData) {
        [Helper exceptionMessage:@"Failed to read TGI file" error:error];
        return;
    }
    
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (!xmlDoc) {
        [Helper exceptionMessage:@"Failed to parse TGI XML file" error:error];
        return;
    }
    
    NSArray *tgiNodes = [xmlDoc nodesForXPath:@"//tgi" error:&error];
    if (!tgiNodes) {
        [Helper exceptionMessage:@"Failed to find TGI nodes in XML" error:error];
        return;
    }
    
    for (NSXMLNode *tgiNode in tgiNodes) {
        [self parseSubNode:(NSXMLElement *)tgiNode];
    }
}

- (void)parseSubNode:(NSXMLElement *)node {
    NSArray *typeNodes = [node elementsForName:@"type"];
    for (NSXMLElement *typeNode in typeNodes) {
        [self loadType:typeNode];
    }
}

- (void)loadType:(NSXMLElement *)node {
    uint32_t type = 0;
    
    NSXMLNode *valueAttr = [node attributeForName:@"value"];
    if (valueAttr) {
        NSString *valueStr = [valueAttr stringValue];
        NSScanner *scanner = [NSScanner scannerWithString:valueStr];
        unsigned int hexValue;
        if ([scanner scanHexInt:&hexValue]) {
            type = (uint32_t)hexValue;
        }
    }
    
    BOOL known = NO;
    NSString *name = @"";
    NSString *shortName = @"";
    NSString *extension = @"";
    BOOL containsFilename = NO;
    BOOL noDecompForCache = NO;
    
    NSArray *childElements = [node children];
    for (NSXMLNode *childNode in childElements) {
        if ([childNode kind] == NSXMLElementKind) {
            NSXMLElement *childElement = (NSXMLElement *)childNode;
            NSString *nodeName = [childElement name];
            
            if ([nodeName isEqualToString:@"know"]) {
                known = YES;
            } else if ([nodeName isEqualToString:@"embeddedfilename"]) {
                containsFilename = YES;
            } else if ([nodeName isEqualToString:@"name"]) {
                name = [childElement stringValue] ?: @"";
            } else if ([nodeName isEqualToString:@"shortname"]) {
                shortName = [childElement stringValue] ?: @"";
            } else if ([nodeName isEqualToString:@"extension"]) {
                extension = [childElement stringValue] ?: @"";
            } else if ([nodeName isEqualToString:@"nodecompressforcache"]) {
                noDecompForCache = YES;
            }
        }
    }
    
    // For now, we'll use the name directly without localization
    // In the future, you might want to implement localization support
    TypeAlias *typeAlias = [[TypeAlias alloc] initWithContainsFilename:containsFilename
                                                             shortName:shortName
                                                                typeId:type
                                                                  name:name
                                                             extension:extension
                                                                 known:known
                                                         noDecompForCache:noDecompForCache];
    
    self.typeMap[@(type)] = typeAlias;
    [self.typeList addObject:typeAlias];
}

// MARK: - Public Methods

- (TypeAlias *)getByType:(uint32_t)type {
    return self.typeMap[@(type)];
}

- (NSArray<TypeAlias *> *)fileTypes {
    return [self.typeList copy];
}

@end
