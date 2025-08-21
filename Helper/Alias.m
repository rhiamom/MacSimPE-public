//
//  Alias.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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


#import "Alias.h"
#import "Helper.h"

// MARK: - StaticAlias Implementation

@implementation StaticAlias {
    uint32_t _typeID;
}

- (instancetype)initWithId:(uint32_t)val name:(NSString *)name {
    return [self initWithId:val name:name tag:nil];
}

- (instancetype)initWithId:(uint32_t)val name:(NSString *)name tag:(NSArray *)tag {
    self = [super init];
    if (self) {
        _typeID = val;
        _name = [name copy];
        _tag = tag;
    }
    return self;
}

- (uint32_t)typeID {
    return _typeID;
}

- (NSString *)description {
    return self.name ?: [NSString stringWithFormat:@"0x%08X", self.typeID];
}

- (void)dealloc {
    // Cleanup
    _tag = nil;
    _name = nil;
}

@end

// MARK: - Alias Implementation

@implementation Alias {
    NSString *_template;
}

+ (NSString *)defaultTemplate {
#ifdef DEBUG
    return @"{name} (0x{id})";
#else
    return @"{name} (0x{id})";
#endif
}

- (instancetype)initWithId:(uint32_t)val name:(NSString *)name {
    return [self initWithId:val name:name template:[Alias defaultTemplate]];
}

- (instancetype)initWithId:(uint32_t)val name:(NSString *)name tag:(NSArray *)tag {
    return [self initWithId:val name:name tag:tag template:[Alias defaultTemplate]];
}

- (instancetype)initWithId:(uint32_t)val name:(NSString *)name template:(NSString *)template {
    return [self initWithId:val name:name tag:nil template:template];
}

- (instancetype)initWithId:(uint32_t)val name:(NSString *)name tag:(NSArray *)tag template:(NSString *)template {
    self = [super initWithId:val name:name tag:tag];
    if (self) {
        _template = [template copy];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *ret = [_template mutableCopy];
    
    [ret replaceOccurrencesOfString:@"{name}"
                         withString:self.name ?: @""
                            options:0
                              range:NSMakeRange(0, ret.length)];
    
    [ret replaceOccurrencesOfString:@"{id}"
                         withString:[NSString stringWithFormat:@"%X", self.typeID]
                            options:0
                              range:NSMakeRange(0, ret.length)];
    
    if (self.tag) {
        for (NSUInteger i = 0; i < self.tag.count; i++) {
            id object = self.tag[i];
            NSString *placeholder = [NSString stringWithFormat:@"{%lu}", (unsigned long)i];
            NSString *value = object ? [object description] : @"";
            
            [ret replaceOccurrencesOfString:placeholder
                                 withString:value
                                    options:0
                                      range:NSMakeRange(0, ret.length)];
        }
    }
    
    return [ret copy];
}

+ (NSArray<id<IAlias>> *)loadFromXml:(NSString *)filename {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return @[];
    }
    
    @try {
        NSError *error;
        NSData *xmlData = [NSData dataWithContentsOfFile:filename];
        if (!xmlData) return @[];
        
        NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&error];
        if (!xmlDoc) return @[];
        
        NSArray *aliasNodes = [xmlDoc nodesForXPath:@"//alias" error:&error];
        if (!aliasNodes) return @[];
        
        NSMutableArray<id<IAlias>> *list = [NSMutableArray array];
        
        for (NSXMLElement *aliasNode in aliasNodes) {
            NSArray *itemNodes = [aliasNode nodesForXPath:@"item" error:&error];
            
            for (NSXMLElement *itemNode in itemNodes) {
                NSXMLNode *valueAttr = [itemNode attributeForName:@"value"];
                if (!valueAttr) continue;
                
                NSString *valueString = [valueAttr stringValue];
                if (!valueString) continue;
                
                valueString = [valueString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                uint32_t val = 0;
                if ([valueString hasPrefix:@"0x"]) {
                    NSScanner *scanner = [NSScanner scannerWithString:valueString];
                    [scanner setScanLocation:2]; // Skip "0x"
                    unsigned int hexValue;
                    if ([scanner scanHexInt:&hexValue]) {
                        val = (uint32_t)hexValue;
                    }
                } else {
                    val = (uint32_t)[valueString integerValue];
                }
                
                NSString *name = [itemNode stringValue];
                if (name) {
                    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    Alias *alias = [[Alias alloc] initWithId:val name:name];
                    [list addObject:alias];
                }
            }
        }
        
        return [list copy];
        
    } @catch (NSException *exception) {
        [Helper exceptionMessageWithString:[NSString stringWithFormat:@"Error loading XML: %@", exception.reason]];
    }
    
    return @[];
}

@end
