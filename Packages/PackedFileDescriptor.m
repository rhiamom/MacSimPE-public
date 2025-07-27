//
//  PackedFileDescriptor.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                                                                                    *
 *   quaxi@ambertation.de                                                                                                                *
 *                                                                         *
 *   Objective C  translation Copyright (C) 2025 by GramzeSweatShop                                                              *
 *   rhiamom@mac.com                                                                                                                           *
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
 ***************************************************************************/

#import "PackedFileDescriptor.h"
#import "Helper.h"
#import "Registry.h"
#import "BinaryReader.h"
#import "IPackageHeader.h"
#import "MetaData.h"
#import "IPackedFileWrapper.h"
#import "TGILoader.h"


@implementation PackedFileDescriptorSimple

- (instancetype)init {
    return [self initWithType:0 group:0 instanceHi:0 instanceLo:0];
}

- (instancetype)initWithType:(uint32_t)pfdType group:(uint32_t)grp instanceHi:(uint32_t)ihi instanceLo:(uint32_t)ilo {
    self = [super init];
    if (self) {
        _pfdType = self.pfdType;
        _group = grp;
        _subType = ihi;
        _instance = ilo;
    }
    return self;
}

- (void)setType:(uint32_t)pfdType {
    if (_pfdType != pfdType) {
        _pfdType = pfdType;
        [self descriptionChangedFkt];
    }
}

- (void)setGroup:(uint32_t)group {
    if (_group != group) {
        _group = group;
        [self descriptionChangedFkt];
    }
}

- (void)setInstance:(uint32_t)instance {
    if (_instance != instance) {
        _instance = instance;
        [self descriptionChangedFkt];
    }
}

- (void)setSubType:(uint32_t)subType {
    if (_subType != subType) {
        _subType = subType;
        [self descriptionChangedFkt];
    }
}

- (TypeAlias *)typeName {
    return [MetaData findTypeAlias:self.pfdType];
}

- (void)descriptionChangedFkt {
    // Override in subclass
}

@end

@implementation PackedFileDescriptor {
    uint32_t _offset;
    int32_t _size;
    BOOL _valid;
    BOOL _pause;
    BOOL _changedDataEvent;
    BOOL _changedDescriptionEvent;
    BOOL _markForDelete;
    BOOL _markForReCompress;
    BOOL _wasCompressed;
    BOOL _changed;
    NSString *_filename;
    NSString *_path;
    NSData *_userData;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subType = 0;
        _markForDelete = NO;
        _markForReCompress = NO;
        _changed = NO;
        _valid = YES;
        _wasCompressed = NO;
        _offset = 0;
        _size = 0;
        _pause = NO;
        _changedDataEvent = NO;
        _changedDescriptionEvent = NO;
    }
    return self;
}

- (void)dealloc {
    _userData = nil;
    _filename = nil;
    _path = nil;
    
    _changedData = nil;
    _changedUserData = nil;
    _closed = nil;
    _deleted = nil;
    _descriptionChanged = nil;
}

- (id<IPackedFileDescriptor>)clone {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.filename = self.filename;
    pfd.group = self.group;
    pfd.instance = self.instance;
    pfd.offset = self.offset;
    pfd.size = self.size;
    pfd.subType = self.subType;
    pfd.type = self.pfdType;
    pfd.changed = self.changed;
    pfd.wasCompressed = self.wasCompressed;
    pfd.markForReCompress = self.markForReCompress;
    pfd.markForDelete = self.markForDelete;
    
    return pfd;
}

- (int32_t)size {
    if (self.userData == nil) {
        return _size;
    } else {
        return (int32_t)self.userData.length;
    }
}

- (void)setSize:(int32_t)size {
    _size = size;
}

- (int32_t)indexedSize {
    return _size;
}

- (uint32_t)offset {
    return _offset;
}

- (void)setOffset:(uint32_t)offset {
    _offset = offset;
}

- (uint64_t)longInstance {
    uint64_t ret = self.instance;
    ret = (((uint64_t)self.subType << 32) & 0xffffffff00000000ULL) | (uint64_t)ret;
    return ret;
}

- (void)setLongInstance:(uint64_t)longInstance {
    uint32_t ninstance = (uint32_t)(longInstance & 0xffffffff);
    uint32_t nsubtype = (uint32_t)((longInstance >> 32) & 0xffffffff);
    if ((ninstance != self.instance || nsubtype != self.subType)) {
        self.instance = ninstance;
        self.subType = nsubtype;
        [self descriptionChangedFkt];
    }
}

- (NSString *)filename {
    if (_filename == nil) {
        _filename = [NSString stringWithFormat:@"%@-%@-%@.%@",
                    [Helper hexStringUInt:self.subType],
                    [Helper hexStringUInt:self.group],
                    [Helper hexStringUInt:self.instance],
                    self.typeName.fileExtension];
    }
    return _filename;
}

- (void)setFilename:(NSString *)filename {
    _filename = [filename copy];
}

- (NSString *)exportFileName {
    return [NSString stringWithFormat:@"%@-%@", [Helper hexStringUInt:self.pfdType], self.filename];
}

- (NSString *)path {
    if (_path == nil) {
        _path = [NSString stringWithFormat:@"%@ - %@",
                [Helper hexStringUInt:self.pfdType],
                [Helper removeUnlistedCharacters:self.pfdTypeName.name allowed:HelperPathCharacters]];
    }
    return _path;
}

- (void)setPath:(NSString *)path {
    _path = [path copy];
}

- (NSString *)generateXmlMetaInfo {
    NSMutableString *xml = [NSMutableString string];
    [xml appendFormat:@"%@<packedfile path=\"%@\" name=\"%@\">%@",
     HelperTab,
     [self.path stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"],
     self.filename,
     HelperLbr];
    
    [xml appendFormat:@"%@%@<type>%@", HelperTab, HelperTab, HelperLbr];
    [xml appendFormat:@"%@%@%@<number>%u</number>%@", HelperTab, HelperTab, HelperTab, self.pfdType, HelperLbr];
    [xml appendFormat:@"%@%@</type>%@", HelperTab, HelperTab, HelperLbr];
    [xml appendFormat:@"%@%@<classid>%u</classid>%@", HelperTab, HelperTab, self.subType, HelperLbr];
    [xml appendFormat:@"%@%@<group>%u</group>%@", HelperTab, HelperTab, self.group, HelperLbr];
    [xml appendFormat:@"%@%@<instance>%u</instance>%@", HelperTab, HelperTab, self.instance, HelperLbr];
    [xml appendFormat:@"%@</packedfile>%@", HelperTab, HelperLbr];
    
    return [xml copy];
}

- (NSString *)description {
    NSString *name = [NSString stringWithFormat:@"%@: %@ - %@ - %@ - %@",
                     self.typeName.description,
                     [Helper hexStringUInt:self.pfdType],
                     [Helper hexStringUInt:self.subType],
                     [Helper hexStringUInt:self.group],
                     [Helper hexStringUInt:self.instance]];
    
    return name;
}

- (NSString *)getResDescString {
    ResourceListUnnamedFormats format = (ResourceListUnnamedFormats)[Registry resourceListUnknownDescriptionFormat];
    
    if (format == ResourceListUnnamedFormatsFullTGI) {
        return [NSString stringWithFormat:@"%@ - %@ - %@ - %@",
                [Helper hexStringUInt:self.pfdType],
                [Helper hexStringUInt:self.subType],
                [Helper hexStringUInt:self.group],
                [Helper hexStringUInt:self.instance]];
    }
    
    if (format == ResourceListUnnamedFormatsInstance) {
        return [NSString stringWithFormat:@"%@ - %@",
                [Helper hexStringUInt:self.subType],
                [Helper hexStringUInt:self.instance]];
    }
    
    // Default: GroupInstance
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            [Helper hexStringUInt:self.subType],
            [Helper hexStringUInt:self.group],
            [Helper hexStringUInt:self.instance]];
}

- (NSString *)toResListString {
    ResourceListFormats format = [Registry resourceListFormat];
    
    if (format == ResourceListFormatsShortTypeNames) {
        return [NSString stringWithFormat:@"%@: %@", self.pfdTypeName.shortName, [self getResDescString]];
    }
    
    if (format == ResourceListFormatsJustNames) {
        return self.pfdTypeName.description;
    }
    
    if (format == ResourceListFormatsJustLongType) {
        return self.pfdTypeName.description;
    }
    
    // Default: LongTypeNames
    return [NSString stringWithFormat:@"%@: %@", self.pfdTypeName.description, [self getResDescString]];
}

#pragma mark - Compare Methods

- (BOOL)sameAs:(id)obj {
    if (obj == nil) return NO;
    
    // Check if passed a FileWrapper, so extract the FileDescriptor
    if ([obj conformsToProtocol:@protocol(IPackedFileWrapper)]) {
        id<IPackedFileWrapper> pfw = (id<IPackedFileWrapper>)obj;
        obj = pfw.fileDescriptor;
    } else {
        // Check for null values and compare run-time types
        if (![obj conformsToProtocol:@protocol(IPackedFileDescriptor)] && ![obj isKindOfClass:[self class]]) {
            return NO;
        }
    }
    
    id<IPackedFileDescriptor> pfd = (id<IPackedFileDescriptor>)obj;
    return ((self.pfdType == pfd.pfdType) && (self.longInstance == pfd.longInstance) &&
            (self.group == pfd.group) && (self.offset == pfd.offset));
}

- (BOOL)isEqual:(id)obj {
    if (obj == nil) return NO;
    
    // Check if passed a FileWrapper, so extract the FileDescriptor
    if ([obj conformsToProtocol:@protocol(IPackedFileWrapper)]) {
        id<IPackedFileWrapper> pfw = (id<IPackedFileWrapper>)obj;
        obj = pfw.fileDescriptor;
    } else {
        // Check for null values and compare run-time types
        if (![obj conformsToProtocol:@protocol(IPackedFileDescriptor)] && ![obj isKindOfClass:[self class]]) {
            return NO;
        }
    }
    
    id<IPackedFileDescriptor> pfd = (id<IPackedFileDescriptor>)obj;
    return ((self.pfdType == pfd.pfdType) && (self.longInstance == pfd.longInstance) && (self.group == pfd.group));
}

- (NSUInteger)hash {
    return [super hash];
}

#pragma mark - UserData Extensions

- (BOOL)markForDelete {
    return _markForDelete;
}

- (void)setMarkForDelete:(BOOL)markForDelete {
    if (markForDelete != _markForDelete) {
        _markForDelete = markForDelete;
        [self descriptionChangedFkt];
        if (self.deleted && markForDelete) {
            self.deleted();
        }
    }
}

- (BOOL)markForReCompress {
    return _markForReCompress;
}

- (void)setMarkForReCompress:(BOOL)markForReCompress {
    if (_markForReCompress != markForReCompress) {
        _markForReCompress = markForReCompress;
        [self descriptionChangedFkt];
    }
}

- (BOOL)wasCompressed {
    return _wasCompressed;
}

- (void)setWasCompressed:(BOOL)wasCompressed {
    if (_wasCompressed != wasCompressed) {
        _wasCompressed = wasCompressed;
        [self descriptionChangedFkt];
    }
}

- (BOOL)hasUserdata {
    return (_userData != nil);
}

- (NSData *)userData {
    return _userData;
}

- (void)setUserData:(NSData *)userData {
    [self setUserData:userData fire:YES];
}

- (void)setUserData:(NSData *)userData fire:(BOOL)fire {
    _changed = YES;
    _userData = [userData copy];
    if (self.packageInternalUserDataChange) {
        self.packageInternalUserDataChange(self);
    }
    if (self.changedUserData && fire) {
        self.changedUserData(self);
    }
    [self changedDataFkt];
}

- (BOOL)changed {
    return _changed;
}

- (void)setChanged:(BOOL)changed {
    if (changed != _changed) {
        _changed = changed;
        [self changedDataFkt];
    }
}

- (void)markInvalid {
    if (self.closed) {
        self.closed(self);
    }
    _valid = NO;
}

- (BOOL)invalid {
    return !_valid;
}

#pragma mark - Events

- (void)beginUpdate {
    _changedDataEvent = NO;
    _changedDescriptionEvent = NO;
    _pause = YES;
}

- (void)endUpdate {
    _pause = NO;
    if (_changedDataEvent) [self changedDataFkt];
    if (_changedDescriptionEvent) [self descriptionChangedFkt];
}

- (void)changedDataFkt {
    if (_pause) {
        _changedDataEvent = YES;
        return;
    }
    
    if (self.changedData) {
        self.changedData(self);
    }
}

- (void)descriptionChangedFkt {
    if (_pause) {
        _changedDescriptionEvent = YES;
        return;
    }
    
    if (self.descriptionChanged) {
        self.descriptionChanged();
    }
}

- (NSString *)exceptionString {
    return [NSString stringWithFormat:@"%@ (%@) - %@ - %@ - %@",
            self.typeName.name,
            [Helper hexStringUInt:self.pfdType],
            [Helper hexStringUInt:self.subType],
            [Helper hexStringUInt:self.group],
            [Helper hexStringUInt:self.instance]];
}

- (void)loadFromStream:(id<IPackageHeader>)header reader:(BinaryReader *)reader {
    self.type = [reader readUInt32];
    self.group = [reader readUInt32];
    self.instance = [reader readUInt32];
    if ([header isVersion0101] && ((id<IPackageHeaderHoleIndex>)header.index).itemSize >= 24) {
        self.subType = [reader readUInt32];
    }
    self.offset = [reader readUInt32];
    self.size = [reader readInt32];
}

@end
