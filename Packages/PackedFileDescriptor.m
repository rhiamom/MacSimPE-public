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
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop                                                              *
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
#import "BinaryReader.h"
#import "IPackageHeader.h"
#import "IPackedFileWrapper.h"
#import "WindowsRegistry.h"

@interface PackedFileDescriptor () {
    uint32_t _subType;
    int32_t _size;
    BOOL _markForDelete;
    BOOL _markForReCompress;
    BOOL _changed;
    BOOL _wasCompressed;
    uint32_t _offset;
    NSString *_filename;
    NSString *_path;
}
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, assign) BOOL pause;
@property (nonatomic, assign) BOOL changedDataEvent;
@property (nonatomic, assign) BOOL changedDescriptionEvent;
@end

@implementation PackedFileDescriptor

@synthesize subType = _subType;

- (uint32_t)subType {
    return _subType;
}

- (void)setSubType:(uint32_t)subType {
    if (_subType != subType) {
        _subType = subType;
        [self descriptionChangedFkt];
    }
}

- (void)setSize:(int32_t)size {
    _size = size;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _subType = 0;
        _markForDelete = NO;
        _markForReCompress = NO;
        _changed = NO;
        self.valid = YES;
        _wasCompressed = NO;
        _offset = 0;
        _size = 0;
        self.pause = NO;
        self.changedDataEvent = NO;
        self.changedDescriptionEvent = NO;
    }
    return self;
}

/**
 * Creates a clone of this Object
 * @returns The Cloned Object
 */
- (id<IPackedFileDescriptor>)clone {
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    pfd.filename = self.filename;
    pfd.group = self.group;
    pfd.instance = self.instance;
    pfd.offset = self.offset;
    pfd.size = self.size;
    pfd.subType = self.subType;
    pfd.type = self.type;
    pfd.changed = self.changed;
    pfd.wasCompressed = self.wasCompressed;
    pfd.markForReCompress = self.markForReCompress;
    pfd.markForDelete = self.markForDelete;
    
    return pfd;
}

/**
 * Returns the Size of the File
 */
- (int32_t)size {
    if (self.userData == nil) {
        return _size;
    } else {
        return (int32_t)self.userData.length;
    }
}

/**
 * Returns the size stored in the index
 */
- (int32_t)indexedSize {
    return _size;
}

/**
 * Returns the Long Instance
 * @remarks Combination of SubType and Instance
 */
- (uint64_t)longInstance {
    uint64_t ret = self.instance;
    ret = (((uint64_t)self.subType << 32) & 0xffffffff00000000ULL) | (uint64_t)ret;
    return ret;
}

- (void)setLongInstance:(uint64_t)longInstance {
    uint32_t nInstance = (uint32_t)(longInstance & 0xffffffff);
    uint32_t nSubType = (uint32_t)((longInstance >> 32) & 0xffffffff);
    
    if (nInstance != self.instance || nSubType != self.subType) {
        self.instance = nInstance;
        self.subType = nSubType;
        [self descriptionChangedFkt];
    }
}

/**
 * Returns or Sets the Filename
 * @remarks This is mostly of interest when you extract packedFiles
 */
- (NSString *)filename {
    if (_filename == nil) {
        _filename = [NSString stringWithFormat:@"%@-%@-%@.%@",
                    [Helper hexString:self.subType],
                    [Helper hexString:self.group],
                    [Helper hexString:self.instance],
                    self.typeName.extension];
    }
    return _filename;
}

- (NSString *)exportFileName {
    return [NSString stringWithFormat:@"%@-%@", [Helper hexString:self.type], self.filename];
}

/**
 * Returns or Sets the File Path
 * @remarks This is mostly of interest when you extract packedFiles
 */
- (NSString *)path {
    if (_path == nil) {
        _path = [Helper hexString:self.type];
        _path = [_path stringByAppendingFormat:@" - %@",
                [Helper removeUnlistedCharacters:self.typeName.name
                                       allowed:[Helper pathCharacters]]];
    }
    return _path;
}

/**
 * Generates MetInformations about a Packed File
 * @returns A String representing the Description as XML output
 */
- (NSString *)generateXmlMetaInfo {
    NSMutableString *xml = [NSMutableString string];
    [xml appendFormat:@"%@<packedfile path=\"%@\" name=\"%@\">%@",
     [Helper tab], [self.path stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"],
     self.filename, [Helper lbr]];
    [xml appendFormat:@"%@%@<type>%@", [Helper tab], [Helper tab], [Helper lbr]];
    [xml appendFormat:@"%@%@%@<number>%u</number>%@",
     [Helper tab], [Helper tab], [Helper tab], self.type, [Helper lbr]];
    [xml appendFormat:@"%@%@</type>%@", [Helper tab], [Helper tab], [Helper lbr]];
    [xml appendFormat:@"%@%@<classid>%u</classid>%@",
     [Helper tab], [Helper tab], self.subType, [Helper lbr]];
    [xml appendFormat:@"%@%@<group>%u</group>%@",
     [Helper tab], [Helper tab], self.group, [Helper lbr]];
    [xml appendFormat:@"%@%@<instance>%u</instance>%@",
     [Helper tab], [Helper tab], self.instance, [Helper lbr]];
    [xml appendFormat:@"%@</packedfile>%@", [Helper tab], [Helper lbr]];
    
    return xml;
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"%@: %@ - %@ - %@ - %@",
            self.typeName,
            [Helper hexString:self.type],
            [Helper hexString:self.subType],
            [Helper hexString:self.group],
            [Helper hexString:self.instance]];
}

- (NSString *)getResDescString {
    if ([Helper.windowsRegistry resourceListUnknownDescriptionFormat] == ResourceListUnnamedFormatsFullTGI) {
        return [NSString stringWithFormat:@"%@ - %@ - %@ - %@",
                [Helper hexString:self.type],
                [Helper hexString:self.subType],
                [Helper hexString:self.group],
                [Helper hexString:self.instance]];
    }
    
    if ([Helper.windowsRegistry resourceListUnknownDescriptionFormat] == ResourceListUnnamedFormatsInstance) {
        return [NSString stringWithFormat:@"%@ - %@",
                [Helper hexString:self.subType],
                [Helper hexString:self.instance]];
    }
    
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            [Helper hexString:self.subType],
            [Helper hexString:self.group],
            [Helper hexString:self.instance]];
}

- (NSString *)toResListString {
    if ([Helper.windowsRegistry resourceListFormat] == ResourceListFormatsShortTypeNames) {
        return [NSString stringWithFormat:@"%@: %@", self.typeName.shortName, [self getResDescString]];
    }
    
    if ([Helper.windowsRegistry resourceListFormat] == ResourceListFormatsJustNames ||
        [Helper.windowsRegistry resourceListFormat] == ResourceListFormatsJustLongType) {
        return [self.typeName toString];
    }
    
    return [NSString stringWithFormat:@"%@: %@", self.typeName, [self getResDescString]];
}

#pragma mark - Compare Methods

/**
 * Same Equals, except this Version is also checking the Offset
 * @param obj The Object to compare to
 * @returns true if the TGI Values are the same
 */
- (BOOL)sameAs:(id)obj {
    if (obj == nil) return NO;
    
    // passed a FileWrapper, so extract the FileDescriptor
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
    return (self.type == pfd.type && self.longInstance == pfd.longInstance &&
            self.group == pfd.group && self.offset == pfd.offset);
}

/**
 * Allow compare with IPackedFileWrapper and IPackedFileDescriptor Objects
 * @param obj The Object to compare to
 * @returns true if the TGI Values are the same
 */
- (BOOL)isEqual:(id)obj {
    if (obj == nil) return NO;
    
    // passed a FileWrapper, so extract the FileDescriptor
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
    return (self.type == pfd.type && self.longInstance == pfd.longInstance && self.group == pfd.group);
}

#pragma mark - UserData Extensions

/**
 * Returns/sets if this file should be kept in the Index for the next Save
 */
- (void)setMarkForDelete:(BOOL)markForDelete {
    if (markForDelete != _markForDelete) {
        _markForDelete = markForDelete;
        [self descriptionChangedFkt];
        if (self.deleted && markForDelete) {
            self.deleted();
        }
    }
}

/**
 * Returns/sets if this File should be Recompressed during the next Save Operation
 */
- (void)setMarkForReCompress:(BOOL)markForReCompress {
    if (_markForReCompress != markForReCompress) {
        _markForReCompress = markForReCompress;
        [self descriptionChangedFkt];
    }
}

/**
 * Returns true if the Resource was Compressed
 */
- (void)setWasCompressed:(BOOL)wasCompressed {
    if (_wasCompressed != wasCompressed) {
        _wasCompressed = wasCompressed;
        [self descriptionChangedFkt];
    }
}

/**
 * Returns true, if Userdata is available
 * @remarks This happens when a user assigns new Data
 */
- (BOOL)hasUserdata {
    return (self.userData != nil);
}

/**
 * Puts Userdefined Data into the File
 */
- (void)setUserData:(NSData *)userData {
    [self setUserData:userData fire:YES];
}

- (void)setUserData:(NSData *)data fire:(BOOL)fire {
    self.changed = YES;
    _userData = data;
    if (self.packageInternalUserDataChange) {
        self.packageInternalUserDataChange(self);
    }
    if (self.changedUserData && fire) {
        self.changedUserData(self);
    }
    [self changedDataFkt];
}

/**
 * Returns true if this File was changed since the last Save
 * @remarks Fires the ChangedData Event
 */
- (void)setChanged:(BOOL)changed {
    if (changed != _changed) {
        _changed = changed;
        [self changedDataFkt];
    }
}

/**
 * Close this Descriptor (make it invalid)
 */
- (void)markInvalid {
    if (self.closed) {
        self.closed(self);
    }
    self.valid = NO;
}

/**
 * true, if this Descriptor is Invalid
 */
- (BOOL)invalid {
    return !self.valid;
}

#pragma mark - Events

- (void)beginUpdate {
    self.changedDataEvent = NO;
    self.changedDescriptionEvent = NO;
    self.pause = YES;
}

- (void)endUpdate {
    self.pause = NO;
    if (self.changedDataEvent) [self changedDataFkt];
    if (self.changedDescriptionEvent) [self descriptionChangedFkt];
}

- (void)changedDataFkt {
    if (self.pause) {
        self.changedDataEvent = YES;
        return;
    }
    
    if (self.changedData) {
        self.changedData(self);
    }
}

- (void)descriptionChangedFkt {
    if (self.pause) {
        self.changedDescriptionEvent = YES;
        return;
    }
    
    if (self.descriptionChanged) {
        self.descriptionChanged();
    }
}

- (NSString *)exceptionString {
    return [NSString stringWithFormat:@"%@ (%@) - %@ - %@ - %@",
            self.typeName.name,
            [Helper hexString:self.type],
            [Helper hexString:self.subType],
            [Helper hexString:self.group],
            [Helper hexString:self.instance]];
}

- (void)loadFromStream:(id<IPackageHeader>)header reader:(BinaryReader *)reader {
    self.type = [reader readUInt32];
    self.group = [reader readUInt32];
    self.instance = [reader readUInt32];
    
    if ([header isVersion0101] && [header.index itemSize] >= 24) {
        self.subType = [reader readUInt32];
    }
    
    self.offset = [reader readUInt32];
    self.size = [reader readInt32];
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

@end
