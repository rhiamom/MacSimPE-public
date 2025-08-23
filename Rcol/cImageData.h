//
//  cImageData.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AbstractRcolBlock.h"
#import "IScenegraphBlock.h"

// Forward declarations
@class ImageData, MipMapBlock, Rcol, SGResource, DDSData;
@class BinaryReader, BinaryWriter;
@protocol IPackageFile, IPackedFileDescriptor, IScenegraphFileIndexItem;

/**
 * Describes the Type of a MipMap
 */
typedef NS_ENUM(uint8_t, MipMapType) {
    MipMapTypeTexture = 0x0,
    MipMapTypeLifoReference = 0x1,
    MipMapTypeSimPEPlainData = 0xff
};

/**
 * Texture formats supported by ImageLoader
 */
typedef NS_ENUM(uint32_t, TxtrFormats) {
    TxtrFormatsExtRaw24Bit,
    TxtrFormatsExtRaw32Bit,
    TxtrFormatsDXT1,
    TxtrFormatsDXT3,
    TxtrFormatsDXT5
    // Add other formats as needed
};

/**
 * A MipMap contains one Texture in a specific Size
 */
@interface MipMap : NSObject

// MARK: - Properties
@property (nonatomic, assign, readonly) MipMapType dataType;
@property (nonatomic, strong) NSImage *texture;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *lifoFile;
@property (nonatomic, weak, readonly) ImageData *parent;

// MARK: - Initialization
- (instancetype)initWithParent:(ImageData *)parent;

// MARK: - Texture Management
- (void)reloadTexture;

// MARK: - Serialization
- (void)unserialize:(BinaryReader *)reader index:(NSInteger)index mapCount:(NSInteger)mapCount;
- (void)serialize:(BinaryWriter *)writer;

// MARK: - LIFO Reference Handling
- (void)getReferencedLifo;
- (BOOL)getReferencedLifoNoLoad;

// MARK: - Resource Management
- (void)dispose;

@end

/**
 * MipMap Blocks contain all MipMaps in given sizes
 */
@interface MipMapBlock : NSObject

// MARK: - Properties
@property (nonatomic, strong) NSArray<MipMap *> *mipMaps;
@property (nonatomic, weak, readonly) ImageData *parent;
@property (nonatomic, assign) uint32_t creator;
@property (nonatomic, assign) uint32_t unknown1;

// MARK: - Initialization
- (instancetype)initWithParent:(ImageData *)parent;

// MARK: - DDS Data Handling
- (void)addDDSData:(NSArray<DDSData *> *)data;

// MARK: - Serialization
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Texture Access
- (MipMap *)largestTexture;
- (MipMap *)getLargestTexture:(NSSize)size;

// MARK: - LIFO Reference Handling
- (void)getReferencedLifos;

// MARK: - Resource Management
- (void)dispose;

@end

/**
 * This is the actual FileWrapper for Image Data
 * The wrapper is used to (un)serialize the Data of a file into it's Attributes.
 * So Basically it reads a BinaryStream and translates the data into some user-defined Attributes.
 */
@interface ImageData : AbstractRcolBlock <IScenegraphBlock>

// MARK: - Properties
@property (nonatomic, assign) NSSize textureSize;
@property (nonatomic, assign) TxtrFormats format;
@property (nonatomic, assign) uint32_t mipMapLevels;
@property (nonatomic, assign) float unknown0;
@property (nonatomic, assign) uint32_t unknown1;
@property (nonatomic, copy) NSString *fileNameRepeat;
@property (nonatomic, strong) NSArray<MipMapBlock *> *mipMapBlocks;

// MARK: - Initialization
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - Texture Access
- (MipMap *)largestTexture;
- (MipMap *)getLargestTexture:(NSSize)size;

// MARK: - LIFO Reference Handling
- (void)getReferencedLifos;

// MARK: - Resource Management
- (void)dispose;

@end
