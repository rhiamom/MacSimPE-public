//
//  CpfWrapper.m
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
// ***************************************************************************

#import "CpfWrapper.h"
#import "CpfItem.h"
#import "TypeAlias.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "AbstractWrapperInfo.h"
#import "CpfUI.h"
#import "MetaData.h"

@implementation Cpf {
    NSData *_fileId;
    NSMutableArray<CpfItem *> *_items;
}

static const uint8_t kSignature[6] = {0xE0, 0x50, 0xE7, 0xCB, 0x02, 0x00};

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileId = [NSData dataWithBytes:kSignature length:6];
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (NSData *)fileId {
    return _fileId;
}

- (NSArray<CpfItem *> *)items {
    return [_items copy];
}

- (void)setItems:(NSArray<CpfItem *> *)items {
    _items = [items mutableCopy];
}

- (NSData *)fileSignature {
    return [NSData dataWithBytes:kSignature length:6];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[
        @0xEBCF3E27, // Property Set
        @0x0C560F39, // Binary Index
        @0xEBFEE33F,
        @0x2C1FD8A1,
        @([MetaData XOBJ]),     // Object XML
        @0x4C158081, // Skintone XML
        @0x0C1FE246, // Meshoverlay XML
        @0x8C1580B5, // Hairtone XML
        @0x8C93BF6C, // Face Region
        @0x6C93B566, // Face Neutral
        @0x0C93E3DE, // Face Modifier
        @0x8C93E35C, // Face Arch
        @([MetaData XROF]),     // Roofs
        @([MetaData XFLR]),     // Floors
        @([MetaData XFNC]),     // Fences
        @([MetaData XNGB]),     // Hood Objects
        @0xD1954460  // Pet Body Options
    ];
}

#pragma mark - Item Management

- (void)addItem:(CpfItem *)item {
    [self addItem:item allowDuplicate:YES];
}

- (void)addItem:(CpfItem *)item allowDuplicate:(BOOL)allowDuplicate {
    if (!item) return;
    
    CpfItem *existingItem = nil;
    if (!allowDuplicate) {
        existingItem = [self getItem:item.name];
    }
    
    if (existingItem) {
        existingItem.datatype = item.datatype;
        existingItem.value = item.value;
    } else {
        [_items addObject:item];
    }
}

- (CpfItem *)getItem:(NSString *)name {
    for (CpfItem *item in _items) {
        if ([item.name isEqualToString:name]) {
            return item;
        }
    }
    return nil;
}

- (CpfItem *)getSaveItem:(NSString *)name {
    CpfItem *result = [self getItem:name];
    if (!result) {
        return [[CpfItem alloc] init];
    }
    return result;
}

#pragma mark - AbstractWrapper Overrides

- (BOOL)checkVersion:(uint32_t)version {
    return (version == 9 || version == 10);
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[CpfUI alloc] initWithWrapper:nil];
}

- (id<IWrapperInfo>)createWrapperInfo {
    NSImage *icon = [NSImage imageNamed:@"cpf"];
    if (!icon) {
        // Try to load from bundle resource
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        icon = [bundle imageForResource:@"cpf"];
    }
    
    return [[AbstractWrapperInfo alloc]
            initWithName:@"CPF Wrapper"
            author:@"Quaxi"
            description:@"This File is a structured Text File (like an .ini or .xml File), that contains Key Value Pairs."
            version:8
            icon:icon];
}

- (NSString *)getResourceName:(TypeAlias *)typeAlias {
    if (!self.processed) {
        [self processData:self.fileDescriptor package:self.package];
    }
    
    CpfItem *nameItem = [self getItem:@"name"];
    if (!nameItem) {
        return [super getResourceName:typeAlias];
    }
    return nameItem.stringValue;
}

#ifdef DEBUG
- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] init];
    
    [desc appendFormat:@"%@; ", [self getSaveItem:@"name"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"age"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"gender"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"fitness"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"override0subset"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"category"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"outfit"].stringValue];
    [desc appendFormat:@"%@; ", [self getSaveItem:@"flags"].stringValue];
    
    return [desc copy];
}
#endif

#pragma mark - Serialization

- (void)unserializeXml:(BinaryReader *)reader {
    [reader.baseStream seekToOffset:0 origin:SeekOriginBegin];
    
    // Read all data from the stream
        NSMutableData *allData = [[NSMutableData alloc] init];
        uint8_t buffer[1024];
        NSInteger bytesRead;
        while ((bytesRead = [reader.baseStream readBytes:buffer maxLength:1024]) > 0) {
            [allData appendBytes:buffer length:bytesRead];
        }
    NSString *xmlString = [[NSString alloc] initWithData:allData encoding:NSUTF8StringEncoding];
    
    // Replace & with &amp; but preserve existing &amp;
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"& " withString:@"&amp; "];
    
    NSError *error = nil;
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithXMLString:xmlString
                                                                 options:0
                                                                   error:&error];
    
    if (!xmlDocument) {
        NSLog(@"Failed to parse XML: %@", error.localizedDescription);
        return;
    }
    
    NSArray<NSXMLElement *> *propertySetElements = [xmlDocument.rootElement elementsForName:@"cGZPropertySetString"];
    NSMutableArray<CpfItem *> *itemList = [[NSMutableArray alloc] init];
    
    for (NSXMLElement *propertySetElement in propertySetElements) {
        for (NSXMLNode *subnode in propertySetElement.children) {
            if (![subnode isKindOfClass:[NSXMLElement class]]) continue;
            
            NSXMLElement *subelement = (NSXMLElement *)subnode;
            CpfItem *item = [[CpfItem alloc] init];
            
            NSString *localName = [subelement.name lowercaseString];
            
            if ([localName isEqualToString:@"anyuint32"]) {
                item.datatype = DataTypesUInteger;
                NSString *text = subelement.stringValue;
                if ([text containsString:@"-"]) {
                    item.uintegerValue = (uint32_t)[text intValue];
                } else if ([text containsString:@"0x"]) {
                    item.uintegerValue = (uint32_t)strtoul([text UTF8String], NULL, 16);
                } else {
                    item.uintegerValue = (uint32_t)[text intValue];
                }
            } else if ([localName isEqualToString:@"anyint32"] || [localName isEqualToString:@"anysint32"]) {
                item.datatype = DataTypesInteger;
                NSString *text = subelement.stringValue;
                if ([text containsString:@"0x"]) {
                    item.integerValue = (int32_t)strtol([text UTF8String], NULL, 16);
                } else {
                    item.integerValue = [text intValue];
                }
            } else if ([localName isEqualToString:@"anystring"]) {
                item.datatype = DataTypesString;
                item.stringValue = subelement.stringValue;
            } else if ([localName isEqualToString:@"anyfloat32"]) {
                item.datatype = DataTypesSingle;
                item.singleValue = [subelement.stringValue floatValue];
            } else if ([localName isEqualToString:@"anyboolean"]) {
                item.datatype = DataTypesBoolean;
                NSString *text = [subelement.stringValue lowercaseString];
                if ([text isEqualToString:@"true"]) {
                    item.booleanValue = YES;
                } else if ([text isEqualToString:@"false"]) {
                    item.booleanValue = NO;
                } else {
                    item.booleanValue = ([text intValue] != 0);
                }
            } else if ([localName isEqualToString:@"#comment"]) {
                continue;
            }
            
            NSXMLNode *keyAttribute = [subelement attributeForName:@"key"];
            if (keyAttribute) {
                item.name = keyAttribute.stringValue;
                [itemList addObject:item];
            }
        }
    }
    
    _items = itemList;
}

- (void)unserialize:(BinaryReader *)reader {
    NSData *idData = [reader readBytes:6];
    _fileId = idData;
    
    const uint8_t *bytes = (const uint8_t *)idData.bytes;
    if (bytes[0] != kSignature[0]) {
        _fileId = [NSData dataWithBytes:kSignature length:6];
        [self unserializeXml:reader];
        return;
    }
    
    uint32_t itemCount = [reader readUInt32];
    _items = [[NSMutableArray alloc] initWithCapacity:itemCount];
    
    for (uint32_t i = 0; i < itemCount; i++) {
        CpfItem *item = [[CpfItem alloc] init];
        [item unserialize:reader];
        [_items addObject:item];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    if (_fileId.length != 6) {
        _fileId = [NSData dataWithBytes:kSignature length:6];
    }
    
    [writer writeData:_fileId];
    [writer writeUInt32:(uint32_t)_items.count];
    
    for (CpfItem *item in _items) {
        [item serialize:writer];
    }
}

#pragma mark - IFileWrapper Protocol

- (BOOL)canHandleType:(uint32_t)type {
    for (NSNumber *assignableType in self.assignableTypes) {
        if ([assignableType unsignedIntValue] == type) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - IMultiplePackedFileWrapper Protocol

- (NSArray *)getConstructorArguments {
    return @[];
}

#pragma mark - Memory Management

- (void)dispose {
    for (CpfItem *item in _items) {
        [item dispose];
    }
    
    [_items removeAllObjects];
    _items = nil;
}

@end
