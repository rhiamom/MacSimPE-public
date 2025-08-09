//
//  PackedFileDescriptor.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
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

#import "PackedFileDescriptor.h"
#import "IPackageHeader.h"
#import "IPackedFileWrapper.h"
#import "BinaryReader.h"
#import "Helper.h"
#import "Registry.h"
#import "MetaData.h"
#import "TypeAlias.h"

@interface PackedFileDescriptor () {
    // Instance variables for properties that need manual synthesis
    uint32_t _offset;
    int _size;
    BOOL _markForDelete;
    BOOL _markForReCompress;
    BOOL _wasCompressed;
    BOOL _changed;
    BOOL _valid;
    BOOL _pause;
    BOOL _changedataEvent;
    BOOL _changeddescriptionEvent;
    NSData *_userData;
    NSString *_filename;
    NSString *_path;
    id _tag;
    PackedFile *_fldata;
}

@property (nonatomic, strong) NSString *cachedFilename;
@property (nonatomic, strong) NSString *cachedPath;

@end

@implementation PackedFileDescriptor

// Manual property synthesis for properties that conflict with protocols/parent class
@synthesize offset = _offset;
@synthesize size = _size;
@synthesize markForDelete = _markForDelete;
@synthesize markForReCompress = _markForReCompress;
@synthesize wasCompressed = _wasCompressed;
@synthesize changed = _changed;
@synthesize userData = _userData;
@synthesize filename = _filename;
@synthesize path = _path;
@synthesize tag = _tag;
@synthesize fldata = _fldata;

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subtype = 0;
        _markForDelete = NO;
        _markForReCompress = NO;
        _changed = NO;
        _valid = YES;
        _wasCompressed = NO;
        _offset = 0;
        _size = 0;
        _pause = NO;
        _changedataEvent = NO;
        _changeddescriptionEvent = NO;
    }
    return self;
}

// MARK: - IPackedFileDescriptor Protocol Methods

- (id<IPackedFileDescriptor>)clone {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.cachedFilename = self.cachedFilename;
    pfd.group = self.group;
    pfd.instance = self.instance;
    pfd.offset = self.offset;
    pfd.size = self.size;
    pfd.subtype = self.subtype;
    pfd.type = self.type;
    pfd.changed = self.changed;
    pfd.wasCompressed = self.wasCompressed;
    pfd.markForReCompress = self.markForReCompress;
    pfd.markForDelete = self.markForDelete;
    
    return pfd;
}

// MARK: - Properties

- (int)fileSize {
    if (_userData == nil) {
        return _size;
    } else {
        return (int)_userData.length;
    }
}

- (int)indexedSize {
    return _size;
}

- (uint64_t)longInstance {
    uint64_t ret = self.instance;
    ret = (((uint64_t)self.subtype << 32) & 0xffffffff00000000ULL) | (uint64_t)ret;
    return ret;
}

- (void)setLongInstance:(uint64_t)longInstance {
    uint32_t ninstance = (uint32_t)(longInstance & 0xffffffff);
    uint32_t nsubtype = (uint32_t)((longInstance >> 32) & 0xffffffff);
    
    if (ninstance != self.instance || nsubtype != self.subtype) {
        self.instance = ninstance;
        self.subtype = nsubtype;
        [self descriptionChangedFkt];
    }
}

- (NSString *)filename {
    if (_filename == nil) {
        NSString *subtypeHex = [Helper hexString:self.subtype];
        NSString *groupHex = [Helper hexString:self.group];
        NSString *instanceHex = [Helper hexString:self.instance];
        
        _filename = [NSString stringWithFormat:@"%@-%@-%@.%@",
                              subtypeHex, groupHex, instanceHex, self.pfdTypeName.fileExtension ?: @""];
    }
    
    return _filename;
}

- (void)setFilename:(NSString *)filename {
    _filename = filename;
}

- (NSString *)exportFileName {
    NSString *typeHex = [Helper hexString:self.type];
    return [NSString stringWithFormat:@"%@-%@", typeHex, self.filename];
}

- (NSString *)path {
    if (_path == nil) {
        NSString *typeHex = [Helper hexString:self.type];
        NSString *typeName = self.pfdTypeName.name ?: @"";
        NSCharacterSet *invalidChars = [NSCharacterSet characterSetWithCharactersInString:@"<>:\"/\\|?*"];
        NSString *cleanName = [[typeName componentsSeparatedByCharactersInSet:invalidChars] componentsJoinedByString:@"_"];
        _path = [NSString stringWithFormat:@"%@ - %@", typeHex, cleanName];
    }
    
    return _path;
}

- (void)setPath:(NSString *)path {
    _path = path;
}

- (BOOL)hasUserdata {
    return (_userData != nil);
}

- (void)setUserData:(NSData *)userData {
    [self setUserData:userData fire:YES];
}

- (BOOL)invalid {
    return !_valid;
}

// Add getter for valid property
- (BOOL)valid {
    return _valid;
}

- (void)setValid:(BOOL)valid {
    _valid = valid;
}

// MARK: - Setters with Change Notifications

- (void)setMarkForDelete:(BOOL)markForDelete {
    if (_markForDelete != markForDelete) {
        _markForDelete = markForDelete;
        [self descriptionChangedFkt];
        if (self.deleted && markForDelete) {
            self.deleted();
        }
    }
}

- (void)setMarkForReCompress:(BOOL)markForReCompress {
    if (_markForReCompress != markForReCompress) {
        _markForReCompress = markForReCompress;
        [self descriptionChangedFkt];
    }
}

- (void)setWasCompressed:(BOOL)wasCompressed {
    if (_wasCompressed != wasCompressed) {
        _wasCompressed = wasCompressed;
        [self descriptionChangedFkt];
    }
}

- (void)setChanged:(BOOL)changed {
    if (_changed != changed) {
        _changed = changed;
        [self changedDataFkt];
    }
}

// MARK: - Methods

- (NSString *)generateXmlMetaInfo {
    NSString *xml = @"";
    NSString *escapedPath = [self.path stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    NSString *tab = @"\t";
    NSString *lbr = @"\n";
    
    xml = [xml stringByAppendingFormat:@"%@<packedfile path=\"%@\" name=\"%@\">%@",
           tab, escapedPath, self.filename, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@%@<type>%@",
           tab, tab, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@%@%@<number>%u</number>%@",
           tab, tab, tab, self.type, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@%@</type>%@",
           tab, tab, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@%@<classid>%u</classid>%@",
           tab, tab, self.subtype, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@%@<group>%u</group>%@",
           tab, tab, self.group, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@%@<instance>%u</instance>%@",
           tab, tab, self.instance, lbr];
    
    xml = [xml stringByAppendingFormat:@"%@</packedfile>%@",
           tab, lbr];
    
    return xml;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ - %@ - %@ - %@",
            self.pfdTypeName ?: @"Unknown",
            [Helper hexString:self.type],
            [Helper hexString:self.subtype],
            [Helper hexString:self.group],
            [Helper hexString:self.instance]];
}

- (NSString *)getResDescString {
    Registry *registry = [Registry windowsRegistry];
    
    if (registry.resourceListUnknownDescriptionFormat == ResourceListUnnamedFormatsFullTGI) {
        return [NSString stringWithFormat:@"%@ - %@ - %@ - %@",
                [Helper hexString:self.type],
                [Helper hexString:self.subtype],
                [Helper hexString:self.group],
                [Helper hexString:self.instance]];
    }
    
    if (registry.resourceListUnknownDescriptionFormat == ResourceListUnnamedFormatsInstance) {
        return [NSString stringWithFormat:@"%@ - %@",
                [Helper hexString:self.subtype],
                [Helper hexString:self.instance]];
    }
    
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            [Helper hexString:self.subtype],
            [Helper hexString:self.group],
            [Helper hexString:self.instance]];
}

- (NSString *)toResListString {
    Registry *registry = [Registry windowsRegistry];
    
    if (registry.resourceListFormat == ResourceListFormatsShortTypeNames) {
        return [NSString stringWithFormat:@"%@: %@", self.pfdTypeName.shortName ?: @"", [self getResDescString]];
    }
    
    if (registry.resourceListFormat == ResourceListFormatsJustNames ||
        registry.resourceListFormat == ResourceListFormatsJustLongType) {
        return [self.pfdTypeName description] ?: @"Unknown";
    }
    
    return [NSString stringWithFormat:@"%@: %@", self.pfdTypeName ?: @"Unknown", [self getResDescString]];
}

- (NSString *)exceptionString {
    return [NSString stringWithFormat:@"%@ (%@) - %@ - %@ - %@",
            self.pfdTypeName.name ?: @"Unknown",
            [Helper hexString:self.type],
            [Helper hexString:self.subtype],
            [Helper hexString:self.group],
            [Helper hexString:self.instance]];
}

// MARK: - Compare Methods

- (BOOL)sameAs:(id)obj {
    if (obj == nil) return NO;
    
    // Handle IPackedFileWrapper
    if ([obj conformsToProtocol:@protocol(IPackedFileWrapper)]) {
        id<IPackedFileWrapper> pfw = (id<IPackedFileWrapper>)obj;
        obj = pfw.fileDescriptor;
    } else if (![obj conformsToProtocol:@protocol(IPackedFileDescriptor)] &&
               ![obj isKindOfClass:[self class]]) {
        return NO;
    }
    
    id<IPackedFileDescriptor> pfd = (id<IPackedFileDescriptor>)obj;
    return (self.type == pfd.type &&
            self.longInstance == pfd.longInstance &&
            self.group == pfd.group &&
            self.offset == pfd.offset);
}

- (BOOL)isEqual:(id)object {
    if (object == nil) return NO;
    
    // Handle IPackedFileWrapper
    if ([object conformsToProtocol:@protocol(IPackedFileWrapper)]) {
        id<IPackedFileWrapper> pfw = (id<IPackedFileWrapper>)object;
        object = pfw.fileDescriptor;
    } else if (![object conformsToProtocol:@protocol(IPackedFileDescriptor)] &&
               ![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    id<IPackedFileDescriptor> pfd = (id<IPackedFileDescriptor>)object;
    return (self.type == pfd.type &&
            self.longInstance == pfd.longInstance &&
            self.group == pfd.group);
}

- (NSUInteger)hash {
    return [super hash];
}

// MARK: - User Data Management

- (void)setUserData:(NSData *)data fire:(BOOL)fire {
    _changed = YES;
    _userData = data;
    
    if (self.packageInternalUserDataChange) {
        self.packageInternalUserDataChange(self);
    }
    
    if (self.changedUserData && fire) {
        self.changedUserData(self);
    }
    
    [self changedDataFkt];
}

// MARK: - Validation

- (void)markInvalid {
    if (self.closed) {
        self.closed(self);
    }
    _valid = NO;
}

// MARK: - Update Management

- (void)beginUpdate {
    _changedataEvent = NO;
    _changeddescriptionEvent = NO;
    _pause = YES;
}

- (void)endUpdate {
    _pause = NO;
    if (_changedataEvent) {
        [self changedDataFkt];
    }
    if (_changeddescriptionEvent) {
        [self descriptionChangedFkt];
    }
}

// MARK: - Loading

- (void)loadFromStream:(id<IPackageHeader>)header reader:(BinaryReader *)reader {
    self.type = [reader readUInt32];
    self.group = [reader readUInt32];
    self.instance = [reader readUInt32];
    
    if (header.isVersion0101 && header.hole.itemSize >= 24)
        self.subtype = [reader readUInt32];
        
    _offset = [reader readUInt32];
    _size = [reader readInt32];
}

// MARK: - Event Handling

- (void)changedDataFkt {
    if (_pause) {
        _changedataEvent = YES;
        return;
    }
    
    if (self.changedData) {
        self.changedData(self);
    }
}

- (void)descriptionChangedFkt {
    if (_pause) {
        _changeddescriptionEvent = YES;
        return;
    }
    
    if (self.descriptionChanged) {
        self.descriptionChanged();
    }
}

// MARK: - Cleanup

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

@synthesize type;

@synthesize subtype;

@end
