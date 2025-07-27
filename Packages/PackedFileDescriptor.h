//
//  PackedFileDescriptor.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop               *
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
 ***************************************************************************/

#import <Foundation/Foundation.h>
#import "IPackedFileDescriptor.h"
#import "IPackedFileDescriptorSimple.h"
#import "TypeAlias.h"

NS_ASSUME_NONNULL_BEGIN

@class MetaData;
@class TypeAlias;
@class BinaryReader;
@protocol IPackageHeader;
@class PackedFile;

@interface PackedFileDescriptorSimple : NSObject <IPackedFileDescriptorSimple>

@property (nonatomic, assign) uint32_t pfdType;
@property (nonatomic, assign) uint32_t group;
@property (nonatomic, assign) uint32_t instance;
@property (nonatomic, assign) uint32_t subType;
@property (nonatomic, readonly) TypeAlias *pfdTypeName;

- (instancetype)init;
- (instancetype)initWithType:(uint32_t)pfdType group:(uint32_t)grp instanceHi:(uint32_t)ihi instanceLo:(uint32_t)ilo;

@end

@interface PackedFileDescriptor : PackedFileDescriptorSimple <IPackedFileDescriptor>

@property (nonatomic, assign) uint32_t offset;
@property (nonatomic, readonly) int32_t size;
@property (nonatomic, readonly) int32_t indexedSize;
@property (nonatomic, assign) uint64_t longInstance;
@property (nonatomic, strong, nullable) NSString *filename;
@property (nonatomic, readonly) NSString *exportFileName;
@property (nonatomic, strong, nullable) NSString *path;
@property (nonatomic, assign) BOOL markForDelete;
@property (nonatomic, assign) BOOL markForReCompress;
@property (nonatomic, assign) BOOL wasCompressed;
@property (nonatomic, readonly) BOOL hasUserdata;
@property (nonatomic, strong, nullable) NSData *userData;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, readonly) BOOL invalid;
@property (nonatomic, strong, nullable) id tag;
@property (nonatomic, readonly) NSString *exceptionString;

// Internal properties
@property (nonatomic, strong, nullable) PackedFile *fldata;

// Event handlers (from IPackedFileDescriptor protocol)
@property (nonatomic, copy, nullable) PackedFileChanged changedUserData;
@property (nonatomic, copy, nullable) PackedFileChanged changedData;
@property (nonatomic, copy, nullable) PackedFileChanged closed;
@property (nonatomic, copy, nullable) void (^descriptionChanged)(void);
@property (nonatomic, copy, nullable) void (^deleted)(void);

// Internal event handler
@property (nonatomic, copy, nullable) PackedFileChanged packageInternalUserDataChange;

- (instancetype)init;
- (id<IPackedFileDescriptor>)clone;

// Data manipulation
- (void)setUserData:(NSData * _Nullable)data fire:(BOOL)fire;

// State management
- (void)markInvalid;
- (void)beginUpdate;
- (void)endUpdate;

// Comparison methods
- (BOOL)sameAs:(id)obj;
- (BOOL)isEqual:(id)obj;

// String generation
- (NSString *)generateXmlMetaInfo;
- (NSString *)description;
- (NSString *)getResDescString;
- (NSString *)toResListString;

// Loading
- (void)loadFromStream:(id<IPackageHeader>)header reader:(BinaryReader *)reader;

@end

NS_ASSUME_NONNULL_END
