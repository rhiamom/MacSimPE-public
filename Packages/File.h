//
//  File.h
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/25/25.
//
/***************************************************************************
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
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>

// Forward declarations
@class BinaryReader;
@class HeaderData;
@class PackedFileDescriptor;
@class CompressedFileList;
@class HoleIndexItem;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IPackedFile;
@protocol IPackageHeader;

NS_ASSUME_NONNULL_BEGIN

/// The Type ID for CompressedFile Lists
extern const uint32_t FILELIST_TYPE;

/// Was the package opened by using a Filename?
typedef NS_ENUM(uint8_t, PackageBaseType) {
    PackageBaseTypeStream = 0x00,
    PackageBaseTypeFilename = 0x01
};

/// Header of a .package File
@interface File : NSObject <IPackageFile>

// MARK: - Properties
@property (nonatomic, readonly, nullable) BinaryReader *reader;
@property (nonatomic, assign) BOOL persistent;
@property (nonatomic, readonly) PackageBaseType type;
@property (nonatomic, readonly) id<IPackageHeader> header;
@property (nonatomic, readonly) NSArray<id<IPackedFileDescriptor>> *index;
@property (nonatomic, readonly) BOOL hasUserChanges;
@property (nonatomic, strong, nullable) NSString *fileName;
@property (nonatomic, readonly) NSString *saveFileName;
@property (nonatomic, readonly) uint32_t fileGroupHash;
@property (nonatomic, readonly) BOOL loadedCompressedState;
@property (nonatomic, readonly, nullable) PackedFileDescriptor *fileList;
@property (nonatomic, readonly, nullable) CompressedFileList *fileListFile;

// MARK: - Initialization
- (instancetype)initWithBinaryReader:(nullable BinaryReader *)br;
- (instancetype)initWithFileName:(NSString *)filename;
+ (instancetype)loadFromFile:(NSString *)filename;
+ (instancetype)loadFromFile:(NSString *)filename sync:(BOOL)sync;
+ (instancetype)loadFromStream:(BinaryReader *)br;
+ (instancetype)createNew;

// MARK: - Basic Methods (we'll add more incrementally)
- (void)reloadReader;
- (void)close;
- (void)closeWithTotal:(BOOL)total;

@end

NS_ASSUME_NONNULL_END//
//  File.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//

