//
//  StrItem.m
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

#import "StrItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "StreamHelper.h"
#import "Helper.h"
#import "Localization.h"
#import "MetaData.h"

// MARK: - StrLanguage Implementation

@implementation StrLanguage

- (instancetype)initWithLanguageId:(uint8_t)languageId {
    self = [super init];
    if (self) {
        _languageId = languageId;
    }
    return self;
}

- (NSString *)name {
    NSString *enumName = [Helper toString:@((Languages)_languageId)];
    NSString *localizedString = [[Localization shared] getString:enumName];
    if (localizedString != nil) {
        return localizedString;
    }
    return enumName;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%@ - %@", [Helper hexString:_languageId], self.name];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[StrLanguage class]]) {
        return (_languageId == ((StrLanguage *)object).languageId);
    }
    return [super isEqual:object];
}

- (NSUInteger)hash {
    return _languageId;
}

+ (NSComparisonResult)compareLanguage:(id)firstObject withLanguage:(id)secondObject {
    NSInteger a, b;
    
    if ([firstObject isKindOfClass:[StrLanguage class]]) {
        a = ((StrLanguage *)firstObject).languageId;
    } else if ([firstObject isKindOfClass:[NSNumber class]]) {
        a = [(NSNumber *)firstObject integerValue];
    } else {
        return NSOrderedSame;
    }
    
    if ([secondObject isKindOfClass:[StrLanguage class]]) {
        b = ((StrLanguage *)secondObject).languageId;
    } else if ([secondObject isKindOfClass:[NSNumber class]]) {
        b = [(NSNumber *)secondObject integerValue];
    } else {
        return NSOrderedSame;
    }
    
    if (a < b) return NSOrderedAscending;
    if (a > b) return NSOrderedDescending;
    return NSOrderedSame;
}

@end

// MARK: - StrLanguageList Implementation

@implementation StrLanguageList

- (StrLanguage *)objectAtIndex:(NSUInteger)index {
    return (StrLanguage *)[super objectAtIndex:index];
}

- (StrLanguage *)objectAtUnsignedIntIndex:(uint32_t)index {
    return (StrLanguage *)[super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(StrLanguage *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(StrLanguage *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addLanguage:(StrLanguage *)strLanguage {
    [self addObject:strLanguage];
    return self.count - 1;
}

- (void)insertLanguage:(StrLanguage *)strLanguage atIndex:(NSUInteger)index {
    [self insertObject:strLanguage atIndex:index];
}

- (void)removeLanguage:(StrLanguage *)strLanguage {
    [self removeObject:strLanguage];
}

- (BOOL)containsLanguage:(StrLanguage *)strLanguage {
    return [self containsObject:strLanguage];
}

- (NSInteger)length {
    return self.count;
}

- (void)sortLanguages {
    [self sortUsingComparator:^NSComparisonResult(StrLanguage *obj1, StrLanguage *obj2) {
        return [StrLanguage compareLanguage:obj1 withLanguage:obj2];
    }];
}

@end

// MARK: - StrToken Implementation

@implementation StrToken {
    NSInteger _index;
    StrLanguage *_language;
    NSString *_title;
    NSString *_strDescription;
    BOOL _isDirty;
}

- (instancetype)initWithIndex:(NSInteger)index
                   languageId:(uint8_t)languageId
                        title:(NSString *)title
                  description:(NSString *)description {
    self = [super init];
    if (self) {
        _index = index;
        _language = [[StrLanguage alloc] initWithLanguageId:languageId];
        _title = [title copy];
        _strDescription = [description copy];
        _isDirty = NO;
    }
    return self;
}

- (NSInteger)index {
    return _index;
}

- (StrLanguage *)language {
    return _language;
}

- (NSString *)title {
    return _title;
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = [title copy];
        _isDirty = YES;
    }
}

- (NSString *)strDescription {
    return _strDescription;
}

- (void)setStrDescription:(NSString *)strDescription {
    if (![_strDescription isEqualToString:strDescription]) {
        _strDescription = [strDescription copy];
        _isDirty = YES;
    }
}

- (BOOL)isDirty {
    return _isDirty;
}

+ (void)unserializeFromReader:(BinaryReader *)reader intoLines:(NSMutableDictionary *)lines {
    StrLanguage *languageId = [[StrLanguage alloc] initWithLanguageId:[reader readByte]];
    NSString *title = [StreamHelper readPChar:reader];
    NSString *desc = [StreamHelper readPChar:reader];
    
    NSNumber *key = @(languageId.languageId);
    StrItemList *itemList = lines[key];
    if (itemList == nil) {
        itemList = [[StrItemList alloc] init];
        lines[key] = itemList;
    }
    
    StrToken *token = [[StrToken alloc] initWithIndex:itemList.count
                                           languageId:languageId.languageId
                                                title:title
                                          description:desc];
    [itemList addStrToken:token];
}

- (void)serializeToWriter:(BinaryWriter *)writer {
    if (_language != nil) {
        [writer writeByte:_language.languageId];
    } else {
        [writer writeByte:0];
    }
    
    if (_title != nil) {
        [StreamHelper writePChar:writer string:_title];
    } else {
        [StreamHelper writePChar:writer string:@""];
    }
    
    if (_strDescription != nil) {
        [StreamHelper writePChar:writer string:_strDescription];
    } else {
        [StreamHelper writePChar:writer string:@""];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"0x%lX - %@", (long)_index, self.title];
}

@end

// MARK: - StrItemList Implementation

@implementation StrItemList

- (StrToken *)objectAtIndex:(NSUInteger)index {
    return (StrToken *)[super objectAtIndex:index];
}

- (StrToken *)objectAtUnsignedIntIndex:(uint32_t)index {
    return (StrToken *)[super objectAtIndex:(NSUInteger)index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(StrToken *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIntIndex:(uint32_t)index withObject:(StrToken *)object {
    [super replaceObjectAtIndex:(NSUInteger)index withObject:object];
}

- (NSInteger)addStrToken:(StrToken *)strToken {
    [self addObject:strToken];
    return self.count - 1;
}

- (void)insertStrToken:(StrToken *)strToken atIndex:(NSUInteger)index {
    [self insertObject:strToken atIndex:index];
}

- (void)removeStrToken:(StrToken *)strToken {
    [self removeObject:strToken];
}

- (BOOL)containsStrToken:(StrToken *)strToken {
    return [self containsObject:strToken];
}

- (NSInteger)length {
    return self.count;
}

- (instancetype)deepCopy {
    StrItemList *copy = [[StrItemList alloc] init];
    for (StrToken *token in self) {
        [copy addStrToken:token];
    }
    return copy;
}

@end
