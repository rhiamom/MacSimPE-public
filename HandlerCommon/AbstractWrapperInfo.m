//
//  AbstractWrapperInfo..m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/**************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
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
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 **************************************************************************/

#import "AbstractWrapperInfo.h"

@implementation AbstractWrapperInfo {
    NSString *_name;
    NSString *_author;
    NSString *_wrapperDescription;
    NSInteger _version;
    NSInteger _iconIndex;
}

- (instancetype)initWithName:(NSString *)name
                      author:(NSString *)author
                 description:(NSString *)description
                     version:(NSInteger)version
                        icon:(PlatformImage *)icon {
    self = [super init];
    if (self) {
        _name = [name copy];
        _author = [author copy];
        _wrapperDescription = [description copy];
        _version = version;
        _icon = icon;
        _iconIndex = -1;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                      author:(NSString *)author
                 description:(NSString *)description
                     version:(NSInteger)version {
    return [self initWithName:name
                       author:author
                  description:description
                      version:version
                         icon:nil];
}

// MARK: - Properties

- (NSString *)name {
    return _name;
}

- (NSString *)author {
    return _author;
}

- (NSString *)wrapperDescription {
    return _wrapperDescription;
}

- (NSInteger)version {
    return _version;
}

- (NSInteger)iconIndex {
    return _iconIndex;
}

- (void)setIconIndex:(NSInteger)iconIndex {
    _iconIndex = iconIndex;
}

- (uint64_t)uid {
    uint32_t guid0 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid0 += (uint8_t)c * ((guid0 % 27) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid0 += (uint8_t)c * ((guid0 % 17) + 1);
    }
    
    uint32_t guid1 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid1 += (uint8_t)c * ((guid1 % 33) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid1 += (uint8_t)c * ((guid1 % 45) + 1);
    }
    
    uint32_t guid2 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid2 += (uint8_t)c * ((guid2 % 13) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid2 += (uint8_t)c * ((guid2 % 9) + 1);
    }
    
    uint32_t guid3 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid3 += (uint8_t)c * ((guid3 % 19) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid3 += (uint8_t)c * ((guid3 % 41) + 1);
    }
    
    return guid0 + ((uint64_t)guid1 << 16) + ((uint64_t)guid2 << 32) + ((uint64_t)guid3 << 48);
}

// MARK: - Cleanup

- (void)dispose {
    _icon = nil;
    _name = nil;
    _author = nil;
    _wrapperDescription = nil;
}

- (void)dealloc {
    [self dispose];
}

@end

#import "AbstractWrapperInfo.h"

@implementation AbstractWrapperInfo {
    NSString *_name;
    NSString *_author;
    NSString *_wrapperDescription;
    NSInteger _version;
    NSInteger _iconIndex;
}

- (instancetype)initWithName:(NSString *)name
                      author:(NSString *)author
                 description:(NSString *)description
                     version:(NSInteger)version
                        icon:(PlatformImage *)icon {
    self = [super init];
    if (self) {
        _name = [name copy];
        _author = [author copy];
        _wrapperDescription = [description copy];
        _version = version;
        _icon = icon;
        _iconIndex = -1;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                      author:(NSString *)author
                 description:(NSString *)description
                     version:(NSInteger)version {
    return [self initWithName:name
                       author:author
                  description:description
                      version:version
                         icon:nil];
}

// MARK: - Properties

- (NSString *)name {
    return _name;
}

- (NSString *)author {
    return _author;
}

- (NSString *)wrapperDescription {
    return _wrapperDescription;
}

- (NSInteger)version {
    return _version;
}

- (NSInteger)iconIndex {
    return _iconIndex;
}

- (void)setIconIndex:(NSInteger)iconIndex {
    _iconIndex = iconIndex;
}

- (uint64_t)uid {
    uint32_t guid0 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid0 += (uint8_t)c * ((guid0 % 27) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid0 += (uint8_t)c * ((guid0 % 17) + 1);
    }
    
    uint32_t guid1 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid1 += (uint8_t)c * ((guid1 % 33) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid1 += (uint8_t)c * ((guid1 % 45) + 1);
    }
    
    uint32_t guid2 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid2 += (uint8_t)c * ((guid2 % 13) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid2 += (uint8_t)c * ((guid2 % 9) + 1);
    }
    
    uint32_t guid3 = 0;
    for (NSUInteger i = 0; i < self.name.length; i++) {
        unichar c = [self.name characterAtIndex:i];
        guid3 += (uint8_t)c * ((guid3 % 19) + 1);
    }
    for (NSUInteger i = 0; i < self.author.length; i++) {
        unichar c = [self.author characterAtIndex:i];
        guid3 += (uint8_t)c * ((guid3 % 41) + 1);
    }
    
    return guid0 + ((uint64_t)guid1 << 16) + ((uint64_t)guid2 << 32) + ((uint64_t)guid3 << 48);
}

// MARK: - Cleanup

- (void)dispose {
    _icon = nil;
    _name = nil;
    _author = nil;
    _wrapperDescription = nil;
}

- (void)dealloc {
    [self dispose];
}

@end
