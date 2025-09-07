//
//  TGALoader.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/5/25.
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class BinaryReader, Stream;

// MARK: - TGA Structures

/**
 * TGA Color Map structure
 */
typedef struct {
    uint16_t firstEntryIndex;
    uint16_t length;
    uint8_t entrySize;
} TGAColorMap;

/**
 * TGA Image Specification structure
 */
typedef struct {
    uint16_t xOrigin;
    uint16_t yOrigin;
    uint16_t width;
    uint16_t height;
    uint8_t pixelDepth;
    uint8_t descriptor;
} TGAImageSpec;

/**
 * TGA Header structure
 */
typedef struct {
    uint8_t idLength;
    uint8_t colorMapType;
    uint8_t imageType;
    TGAColorMap colorMap;
    TGAImageSpec imageSpec;
} TGAHeader;

/**
 * TGA Color Decoder structure
 */
typedef struct {
    uint32_t rMask, gMask, bMask, aMask;
    uint8_t rShift, gShift, bShift, aShift;
    uint32_t finalOr;
    BOOL needNoConvert;
} TGACD;

/**
 * Capability to load TGAs to NSImage
 */
@interface LoadTGAClass : NSObject

// MARK: - Public Methods

/**
 * Load TGA image from stream
 * @param source The stream containing TGA data
 * @return NSImage or nil if loading failed
 */
+ (NSImage *)loadTGA:(Stream *)source;

/**
 * Load TGA image from file
 * @param filename Path to TGA file
 * @return NSImage or nil if loading failed
 */
+ (NSImage *)loadTGAFromFile:(NSString *)filename;

/**
 * Get TGA image size without loading full image
 * @param filename Path to TGA file
 * @return Size of the image
 */
+ (NSSize)getTGASize:(NSString *)filename;

// MARK: - Helper Methods

/**
 * Read TGA header from binary reader
 * @param reader Binary reader positioned at start of TGA data
 * @return TGA header structure
 */
+ (TGAHeader)readTGAHeader:(BinaryReader *)reader;

/**
 * Get alpha bits from descriptor
 * @param descriptor TGA descriptor byte
 * @return Number of alpha bits
 */
+ (uint8_t)alphaBitsFromDescriptor:(uint8_t)descriptor;

/**
 * Check if image is bottom-up oriented
 * @param descriptor TGA descriptor byte
 * @return YES if bottom-up
 */
+ (BOOL)isBottomUpFromDescriptor:(uint8_t)descriptor;

/**
 * Check if TGA is RLE encoded
 * @param imageType TGA image type
 * @return YES if RLE encoded
 */
+ (BOOL)isRLEEncoded:(uint8_t)imageType;

@end
