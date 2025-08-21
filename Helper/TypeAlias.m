//
//  TypeAlias.m
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


#import "TypeAlias.h"

@implementation TypeAlias {
    NSString *_extension;
    BOOL _knownType;
    BOOL _noDecompForCache;
}

- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name {
    self = [super initWithId:val name:name];
    if (self) {
        _shortName = [shortName copy];
        _extension = nil;
        _knownType = YES;
        _containsFilename = containsFilename;
        _noDecompForCache = NO;
    }
    return self;
}

- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name
                               extension:(NSString *)extension {
    return [self initWithContainsFilename:containsFilename
                                shortName:shortName
                                       typeID:val
                                     name:name
                                extension:extension
                                    known:YES
                            noDecompForCache:NO];
}

- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name
                               extension:(NSString *)extension
                                   known:(BOOL)known
                           noDecompForCache:(BOOL)noDecompForCache {
    self = [super initWithId:val name:name];
    if (self) {
        _shortName = [shortName copy];
        _extension = [extension copy];
        _knownType = known;
        _containsFilename = containsFilename;
        _noDecompForCache = noDecompForCache;
    }
    return self;
}

- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name
                                   known:(BOOL)known
                           noDecompForCache:(BOOL)noDecompForCache {
    self = [super initWithId:val name:name];
    if (self) {
        _shortName = [shortName copy];
        _extension = @"";
        _knownType = known;
        _containsFilename = containsFilename;
        _noDecompForCache = noDecompForCache;
    }
    return self;
}

- (NSString *)fileExtension {
    if (_extension == nil || [_extension isEqualToString:@""]) {
        return @"simpe";
    }
    return _extension;
}

- (BOOL)known {
    return _knownType;
}

- (BOOL)ignoreDuringCacheBuild {
    return _noDecompForCache;
}

- (NSString *)description {
    return self.name;
}

@end
