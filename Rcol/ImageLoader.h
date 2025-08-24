//
//  ImageLoader.h
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

// Import CSoil2 headers
#import "SOIL2.h"

@class BinaryReader, BinaryWriter;

/**
 * Texture formats supported by ImageLoader
 */
typedef NS_ENUM(uint32_t, TxtrFormats) {
    TxtrFormatsUnknown = 0x0,
    TxtrFormatsRaw32Bit = 0x1,
    TxtrFormatsRaw24Bit = 0x2,
    TxtrFormatsExtRaw8Bit = 0x3,
    TxtrFormatsDXT1Format = 0x4,
    TxtrFormatsDXT3Format = 0x5,
    TxtrFormatsRaw8Bit = 0x6,
    TxtrFormatsDXT5Format = 0x8,
    TxtrFormatsExtRaw24Bit = 0x9
};

/**
 * Class used to return DDS Data
 */
@interface DDSData : NSObject

// MARK: - Properties
@property (nonatomic, assign) TxtrFormats format;
@property (nonatomic, assign) NSSize parentSize;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, readonly, strong) NSImage *texture;

// MARK: - Initialization
- (instancetype)initWithData:(NSData *)data
                        size:(NSSize)size
                      format:(TxtrFormats)format
                       level:(NSInteger)level
                       count:(NSInteger)count;

@end

/**
 * Provides static Methods to process several Image Data formats
 * Now using CSoil2 library for improved DDS/DXT handling
 */
@interface ImageLoader : NSObject

// MARK: - DDS File Processing
/**
 * Loads the MipMap Data from a DDS File using CSoil2
 * @param filename The filename of the DDS file
 * @returns Array of DDSData objects (Biggest Map first)
 * @throws NSException if the signature is unknown
 */
+ (NSArray<DDSData *> *)parseDDS:(NSString *)filename;

// MARK: - Image Loading
/**
 * Tries to load an Image from the datasource using CSoil2 when appropriate
 * @param imageSize Maximum Dimensions of the Image (used to determine the aspect ratio)
 * @param dataSize Number of bytes used for the image in the Stream
 * @param format Format of the Image
 * @param reader A Binary Reader. Position must be the start of the Image Data
 * @param level The index of the Texture in the current MipMap use -1 if you don't want to specify a Level
 * @param levelCount Number of Levels stored in the MipMap
 * @returns nil or a valid NSImage
 */
+ (NSImage *)loadWithImageSize:(NSSize)imageSize
                      dataSize:(NSInteger)dataSize
                        format:(TxtrFormats)format
                        reader:(BinaryReader *)reader
                         level:(NSInteger)level
                    levelCount:(NSInteger)levelCount;

/**
 * Convenience method with NSSize parameter name matching original
 */
+ (NSImage *)loadWithTextureSize:(NSSize)textureSize
                          length:(NSInteger)length
                          format:(TxtrFormats)format
                          reader:(BinaryReader *)reader
                           index:(NSInteger)index
                        mapCount:(NSInteger)mapCount;

// MARK: - Image Saving
/**
 * Creates a NSData array for the passed Image using CSoil2 for DDS formats
 * @param format The Format you want to store the Image in
 * @param image The Image
 * @returns NSData containing the Image Data
 */
+ (NSData *)saveWithFormat:(TxtrFormats)format image:(NSImage *)image;

// MARK: - RAW Format Processing
/**
 * Parse RAW format image data (uses native implementation for raw formats)
 */
+ (NSImage *)rawParserWithParentSize:(NSSize)parentSize
                              format:(TxtrFormats)format
                            imageSize:(NSInteger)imageSize
                              reader:(BinaryReader *)reader
                               width:(NSInteger)width
                              height:(NSInteger)height;

/**
 * Write RAW format image data (uses native implementation for raw formats)
 */
+ (NSData *)rawWriterWithImage:(NSImage *)image format:(TxtrFormats)format;

// MARK: - DXT Format Processing (now using CSoil2)
/**
 * Parse DXT1/DXT3/DXT5 format image data using CSoil2 library
 */
+ (NSImage *)dxt3ParserWithParentSize:(NSSize)parentSize
                               format:(TxtrFormats)format
                            imageSize:(NSInteger)imageSize
                               reader:(BinaryReader *)reader
                                width:(NSInteger)width
                               height:(NSInteger)height;

/**
 * Write DXT format image data using CSoil2 library
 */
+ (NSData *)dxt3WriterWithImage:(NSImage *)image format:(TxtrFormats)format;

// MARK: - Image Utilities
/**
 * Creates a Preview with the correct Aspect Ratio
 * @param image The Image you want to preview
 * @param size Size of the Preview Image
 * @returns The Preview image
 */
+ (NSImage *)previewImage:(NSImage *)image size:(NSSize)size;

/**
 * Get appropriate image format from file extension
 * @param name The filename
 * @returns NSBitmapImageFileType for the file extension
 */
+ (NSBitmapImageFileType)getImageFormatFromName:(NSString *)name;

// MARK: - Private CSoil2 Utility Methods
/**
 * Converts TxtrFormats enum to SOIL format constants
 */
+ (int)txtrFormatToSoilFormat:(TxtrFormats)format;

/**
 * Converts SOIL format constants to TxtrFormats enum
 */
+ (TxtrFormats)soilFormatToTxtrFormat:(int)soilFormat;

/**
 * Converts NSImage to raw pixel data for CSoil2
 */
+ (unsigned char *)nsImageToPixelData:(NSImage *)image
                                width:(int *)width
                               height:(int *)height
                             channels:(int *)channels;

/**
 * Creates NSImage from raw pixel data returned by CSoil2
 */
+ (NSImage *)pixelDataToNSImage:(unsigned char *)pixelData
                          width:(int)width
                         height:(int)height
                       channels:(int)channels;

@end
