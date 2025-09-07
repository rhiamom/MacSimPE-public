//
//  StrWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
//
//***************************************************************************
//*   Copyright (C) 2005 by Ambertation                                     *
//*   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2005 by Peter L Jones (blame me for string bugs!)       *
//*   pljones@users.sf.net                                                  *
//*                                                                         *
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/

#import "StrWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "Registry.h"
#import "AbstractWrapperInfo.h"
#import "StrForm.h"
#import "MetaData.h"

@implementation StrWrapper {
    NSMutableData *_filename;
    FormatCode _format;
    NSMutableDictionary<NSNumber *, StrItemList *> *_lines;
    NSInteger _limit;
}

// MARK: - Initialization

- (instancetype)initWithLimit:(NSInteger)limit {
    self = [super init];
    if (self) {
        _filename = [[NSMutableData alloc] initWithLength:64];
        _format = FormatCodeNormal;
        _lines = [[NSMutableDictionary alloc] init];
        _limit = limit;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _filename = [[NSMutableData alloc] initWithLength:64];
        _format = FormatCodeNormal;
        _lines = [[NSMutableDictionary alloc] init];
        _limit = 0;
    }
    return self;
}

// MARK: - Core Properties

- (NSString *)fileName {
    return [Helper toStringFromBytes:(const uint8_t *)_filename.bytes length:_filename.length];
}

- (void)setFileName:(NSString *)fileName {
    // Clear the buffer
    memset(_filename.mutableBytes, 0, 64);
    
    if (fileName.length < 64) {
        const char *cString = [fileName UTF8String];
        NSUInteger length = MIN(strlen(cString), 63); // Leave room for null terminator
        memcpy(_filename.mutableBytes, cString, length);
    }
}

- (FormatCode)format {
    return _format;
}

- (void)setFormat:(FormatCode)format {
    _format = format; // should check it's valid
}

- (NSMutableDictionary<NSNumber *, StrItemList *> *)lines {
    return _lines;
}

- (void)setLines:(NSMutableDictionary<NSNumber *, StrItemList *> *)lines {
    _lines = lines;
}

// MARK: - Extended Accessor Methods

- (StrLanguageList *)languages {
    StrLanguageList *languages = [[StrLanguageList alloc] init];
    for (NSNumber *key in _lines.allKeys) {
        StrLanguage *language = [[StrLanguage alloc] initWithLanguageId:[key unsignedCharValue]];
        [languages addLanguage:language];
    }
    [languages sortLanguages];
    return languages;
}

- (void)setLanguages:(StrLanguageList *)languages {
    for (StrLanguage *language in languages) {
        NSNumber *key = @(language.languageId);
        if (_lines[key] == nil) {
            _lines[key] = [[StrItemList alloc] init];
        }
    }
}

- (StrItemList *)items {
    StrItemList *items = [[StrItemList alloc] init];
    StrLanguageList *languageList = self.languages;
    
    for (StrLanguage *language in languageList) {
        NSNumber *key = @(language.languageId);
        StrItemList *languageItems = _lines[key];
        if (languageItems != nil) {
            for (StrToken *token in languageItems) {
                [items addStrToken:token];
            }
        }
    }
    return items;
}

- (void)setItems:(StrItemList *)items {
    _lines = [[NSMutableDictionary alloc] init];
    for (StrToken *token in items) {
        [self addStrToken:token];
    }
}

// MARK: - Item Management

- (void)addStrToken:(StrToken *)item {
    NSNumber *key = @(item.language.languageId);
    StrItemList *languageList = _lines[key];
    if (languageList == nil) {
        languageList = [[StrItemList alloc] init];
        _lines[key] = languageList;
    }
    [languageList addStrToken:item];
}

- (void)removeStrToken:(StrToken *)item {
    NSNumber *key = @(item.language.languageId);
    StrItemList *languageList = _lines[key];
    if (languageList != nil) {
        [languageList removeStrToken:item];
    }
}

// MARK: - Language-Specific Access

- (StrItemList *)languageItemsForStrLanguage:(StrLanguage *)language {
    if (language == nil) {
        return [[StrItemList alloc] init];
    }
    return [self languageItemsForLanguage:(Languages)language.languageId];
}

- (StrItemList *)languageItemsForLanguage:(Languages)language {
    NSNumber *key = @(language);
    StrItemList *items = _lines[key];
    if (items == nil) {
        items = [[StrItemList alloc] init];
    }
    return items;
}

- (StrToken *)fallbackedLanguageItemForLanguage:(Languages)language atIndex:(NSInteger)index {
    StrItemList *list = [self languageItemsForLanguage:language];
    StrToken *name;
    
    if (list.length > index) {
        name = [list objectAtIndex:index];
    } else {
        name = [[StrToken alloc] initWithIndex:0 languageId:0 title:@"" description:@""];
    }
    
    if ([name.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        list = [self languageItemsForLanguage:LanguagesEnglish];
        if (list.length > index) {
            name = [list objectAtIndex:index];
        }
    }
    
    return name;
}

- (StrItemList *)fallbackedLanguageItemsForLanguage:(Languages)language {
    if (language == LanguagesEnglish) {
        return [self languageItemsForLanguage:language];
    }
    
    StrItemList *real = [[self languageItemsForLanguage:language] deepCopy];
    StrItemList *fallback = nil;
    
    if ([self.languages containsLanguage:[[StrLanguage alloc] initWithLanguageId:MetaDataLanguagesEnglish]]) {
        fallback = [self languageItemsForLanguage:LanguagesEnglish];
    } else if (self.languages.count == 1) {
        fallback = [self languageItemsForStrLanguage:[self.languages objectAtIndex:0]];
    } else {
        fallback = [self languageItemsForLanguage:LanguagesEnglish];
    }
    
    for (NSInteger i = 0; i < fallback.length; i++) {
        if (real.length <= i) {
            [real addStrToken:[fallback objectAtIndex:i]];
        } else if ([real objectAtIndex:i] == nil ||
                   [[real objectAtIndex:i].title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            [real replaceObjectAtIndex:i withObject:[fallback objectAtIndex:i]];
        }
    }
    
    return real;
}

// MARK: - Utility Methods

- (void)clearNonDefault {
    StrItemList *allItems = self.items;
    NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];
    
    for (StrToken *token in allItems) {
        if (token.language.languageId != 1) {
            [itemsToRemove addObject:token];
        }
    }
    
    for (StrToken *token in itemsToRemove) {
        [self removeStrToken:token];
    }
}

- (void)copyFromDefaultToAll {
    StrItemList *allItems = self.items;
    StrLanguage *defaultLanguage = [[StrLanguage alloc] initWithLanguageId:1];
    StrItemList *defaultItems = [self languageItemsForStrLanguage:defaultLanguage];
    
    for (StrToken *token in allItems) {
        if (token.language.languageId != 1) {
            if (token.index > 0 && token.index < defaultItems.count) {
                StrToken *defaultToken = [defaultItems objectAtIndex:token.index];
                token.title = defaultToken.title;
                token.strDescription = defaultToken.strDescription;
            }
        }
    }
}

// MARK: - IWrapper Implementation

- (BOOL)checkVersion:(uint32_t)version {
    return YES;
}

// MARK: - AbstractWrapper Implementation

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[StrForm alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:@"txt" ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    return [[AbstractWrapperInfo alloc] initWithName:@"Text List Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File contains Text Resources in various Languages."
                                             version:9
                                                icon:image];
}

- (void)unserialize:(BinaryReader *)reader {
    _lines = [[NSMutableDictionary alloc] init];
    
    if (reader.stream.length <= 0x40) {
        return;
    }
    
    NSData *fileNameData = [reader readBytes:0x40];
    _filename = [fileNameData mutableCopy];
    
    uint16_t formatCode = [reader readUInt16];
    if (formatCode != FormatCodeNormal) {
        return;
    }
    
    uint16_t count = [reader readUInt16];
    _format = (FormatCode)formatCode;
    
    if (_limit != 0 && count > _limit) {
        count = (uint16_t)_limit; // limit number of StrToken entries loaded
    }
    
    for (int i = 0; i < count; i++) {
        [StrToken unserializeFromReader:reader intoLines:_lines];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeBytes:_filename.bytes length:_filename.length];
    [writer writeUInt16:(uint16_t)_format];
    
    StrLanguageList *languageList = self.languages;
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    
    for (StrLanguage *language in languageList) {
        NSNumber *key = @(language.languageId);
        StrItemList *items = _lines[key];
        if (items != nil) {
            [allItems addObjectsFromArray:items];
        }
    }
    
    [writer writeUInt16:(uint16_t)allItems.count];
    
    for (StrToken *token in allItems) {
        [token serializeToWriter:writer];
    }
}

// MARK: - IFileWrapper Implementation

- (NSString *)description {
    NSString *base = [NSString stringWithFormat:@"filename=%@, languages=%ld, lines=%ld",
                      self.fileName, (long)self.languages.length, (long)self.items.length];
    
    Languages currentLanguage = [[Registry windowsRegistry] languageCode];
    StrItemList *fallbackItems = [self fallbackedLanguageItemsForLanguage:currentLanguage];
    
    for (StrToken *token in fallbackItems) {
        if (token.title.length > 0) {
            return [NSString stringWithFormat:@"%@, first=%@", base, token.title];
        }
    }
    
    return [NSString stringWithFormat:@"%@ (no strings)", base];
}

- (NSData *)fileSignature {
    return [NSData data]; // Empty array
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@0x53545223,  // STR#
             @0x54544173,  // Pie String (TTAB)
             @0x43545353]; // CTSS
}

@end
