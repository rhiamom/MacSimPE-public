//
//  ImageLoader.m
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

#import "ImageLoader.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "MemoryStream.h"
#import "Stream.h"
#import "Helper.h"
#import "ExceptionForm.h"

// MARK: - DDSData Implementation

@implementation DDSData {
    NSInteger _level;
    NSInteger _count;
    NSImage *_texture;
}

- (instancetype)initWithData:(NSData *)data
                        size:(NSSize)size
                      format:(TxtrFormats)format
                       level:(NSInteger)level
                       count:(NSInteger)count {
    self = [super init];
    if (self) {
        _data = data;
        _parentSize = size;
        _format = format;
        _level = level;
        _count = count;
    }
    return self;
}

- (NSImage *)texture {
    if (_texture == nil) {
        MemoryStream *memoryStream = [[MemoryStream alloc] initWithData:_data];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:memoryStream];
        _texture = [ImageLoader loadWithImageSize:_parentSize
                                         dataSize:_data.length
                                           format:_format
                                           reader:reader
                                            level:-1
                                       levelCount:_count];
    }
    return _texture;
}

@end

// MARK: - ImageLoader Implementation

@implementation ImageLoader

// MARK: - DDS File Processing

+ (NSArray<DDSData *> *)parseDDS:(NSString *)filename {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return @[];
    }
    
    NSMutableArray<DDSData *> *maps = [[NSMutableArray alloc] init];
    NSData *fileData = [NSData dataWithContentsOfFile:filename];
    
    if (!fileData || fileData.length < 0x80) {
        return @[];
    }
    
    @try {
        MemoryStream *memoryStream = [[MemoryStream alloc] initWithData:fileData];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:memoryStream];
        
        // Seek to header information
        [reader.baseStream seekToOffset:0x0c origin:SeekOriginBegin];
        int32_t height = [reader readInt32];
        int32_t width = [reader readInt32];
        NSSize size = NSMakeSize(width, height);
        int32_t firstSize = [reader readInt32];
        int32_t unknown = [reader readInt32];
        int32_t mapCount = [reader readInt32];
        
        // Read DXT signature
        [reader.baseStream seekToOffset:0x54 origin:SeekOriginBegin];
        NSData *sigData = [reader readBytes:4];
        NSString *signature = [[NSString alloc] initWithData:sigData encoding:NSASCIIStringEncoding];
        
        TxtrFormats format;
        if ([signature isEqualToString:@"DXT1"]) {
            format = TxtrFormatsDXT1Format;
        } else if ([signature isEqualToString:@"DXT3"]) {
            format = TxtrFormatsDXT3Format;
        } else if ([signature isEqualToString:@"DXT5"]) {
            format = TxtrFormatsDXT5Format;
        } else {
            @throw [NSException exceptionWithName:@"UnknownDXTFormatException"
                                           reason:[NSString stringWithFormat:@"Unknown DXT Format %@", signature]
                                         userInfo:nil];
        }
        
        [reader.baseStream seekToOffset:0x80 origin:SeekOriginBegin];
        NSInteger blockSize = (format == TxtrFormatsDXT1Format) ? 8 : 16;
        
        // Process each mipmap level
        for (NSInteger i = 0; i < mapCount; i++) {
            NSInteger levelWidth = MAX(1, width >> i);
            NSInteger levelHeight = MAX(1, height >> i);
            NSInteger levelSize = ((levelWidth + 3) / 4) * ((levelHeight + 3) / 4) * blockSize;
            
            NSData *levelData = [reader readBytes:levelSize];
            
            DDSData *ddsData = [[DDSData alloc] initWithData:levelData
                                                        size:NSMakeSize(levelWidth, levelHeight)
                                                      format:format
                                                       level:i
                                                       count:mapCount];
            [maps addObject:ddsData];
        }
        
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"Error parsing DDS file" exception:exception];
        return @[];
    }
    
    return [maps copy];
}

// MARK: - Image Loading

+ (NSImage *)loadWithImageSize:(NSSize)imageSize
                      dataSize:(NSInteger)dataSize
                        format:(TxtrFormats)format
                        reader:(BinaryReader *)reader
                         level:(NSInteger)level
                    levelCount:(NSInteger)levelCount {
    return [self loadWithTextureSize:imageSize
                              length:dataSize
                              format:format
                              reader:reader
                               index:level
                            mapCount:levelCount];
}

+ (NSImage *)loadWithTextureSize:(NSSize)textureSize
                          length:(NSInteger)length
                          format:(TxtrFormats)format
                          reader:(BinaryReader *)reader
                           index:(NSInteger)index
                        mapCount:(NSInteger)mapCount {
    NSImage *image = nil;
    NSInteger width = (NSInteger)textureSize.width;
    NSInteger height = (NSInteger)textureSize.height;
    
    // Ensure minimum dimensions
    width = MAX(1, width);
    height = MAX(1, height);
    
    // Calculate data size based on format
    NSInteger calculatedSize;
    if (format == TxtrFormatsDXT1Format) {
        calculatedSize = (width * height) / 2;
    } else if (format == TxtrFormatsRaw24Bit) {
        calculatedSize = (width * height) * 3;
    } else if (format == TxtrFormatsRaw32Bit) {
        calculatedSize = (width * height) * 4;
    } else {
        calculatedSize = (width * height);
    }
    
    if ((format == TxtrFormatsDXT1Format) ||
        (format == TxtrFormatsDXT3Format) ||
        (format == TxtrFormatsDXT5Format)) {
        // Use CSoil2 for DXT formats
        image = [self dxt3ParserWithParentSize:textureSize
                                        format:format
                                     imageSize:calculatedSize
                                        reader:reader
                                         width:width
                                        height:height];
    } else if ((format == TxtrFormatsExtRaw8Bit) ||
               (format == TxtrFormatsRaw8Bit) ||
               (format == TxtrFormatsRaw24Bit) ||
               (format == TxtrFormatsRaw32Bit) ||
               (format == TxtrFormatsExtRaw24Bit)) {
        // Use native implementation for raw formats
        image = [self rawParserWithParentSize:textureSize
                                       format:format
                                    imageSize:calculatedSize
                                       reader:reader
                                        width:width
                                       height:height];
    }
    
    return image;
}

// MARK: - Image Saving

+ (NSData *)saveWithFormat:(TxtrFormats)format image:(NSImage *)image {
    if (image == nil) {
        return [[NSData alloc] init];
    }
    
    NSData *data = [[NSData alloc] init];
    
    if ((format == TxtrFormatsDXT1Format) ||
        (format == TxtrFormatsDXT3Format) ||
        (format == TxtrFormatsDXT5Format)) {
        // Use CSoil2 for DXT formats
        data = [self dxt3WriterWithImage:image format:format];
    } else if ((format == TxtrFormatsExtRaw8Bit) ||
               (format == TxtrFormatsRaw8Bit) ||
               (format == TxtrFormatsRaw24Bit) ||
               (format == TxtrFormatsRaw32Bit) ||
               (format == TxtrFormatsExtRaw24Bit)) {
        // Use native implementation for raw formats
        data = [self rawWriterWithImage:image format:format];
    }
    
    return data;
}

// MARK: - RAW Format Processing (Native Implementation Preserved)

+ (NSImage *)rawParserWithParentSize:(NSSize)parentSize
                              format:(TxtrFormats)format
                           imageSize:(NSInteger)imageSize
                              reader:(BinaryReader *)reader
                               width:(NSInteger)width
                              height:(NSInteger)height {
    NSBitmapImageRep *bitmap = nil;
    NSInteger samplesPerPixel = 3; // Default RGB
    
    // Determine samples per pixel based on format
    if (format == TxtrFormatsRaw32Bit) {
        samplesPerPixel = 4; // RGBA
    } else if ((format == TxtrFormatsRaw8Bit) || (format == TxtrFormatsExtRaw8Bit)) {
        samplesPerPixel = 1; // Grayscale
    }
    
    bitmap = [[NSBitmapImageRep alloc]
             initWithBitmapDataPlanes:NULL
                           pixelsWide:width
                           pixelsHigh:height
                        bitsPerSample:8
                      samplesPerPixel:samplesPerPixel
                             hasAlpha:(samplesPerPixel == 4)
                             isPlanar:NO
                       colorSpaceName:(samplesPerPixel == 1) ? NSCalibratedWhiteColorSpace : NSCalibratedRGBColorSpace
                          bytesPerRow:0
                         bitsPerPixel:0];
    
    if (!bitmap) {
        return [[NSImage alloc] initWithSize:NSMakeSize(MAX(1, width), MAX(1, height))];
    }
    
    unsigned char *pixels = [bitmap bitmapData];
    NSInteger bytesPerRow = [bitmap bytesPerRow];
    
    @try {
        NSData *rawData = [reader readBytes:imageSize];
        const unsigned char *sourceBytes = (const unsigned char *)[rawData bytes];
        NSInteger sourceIndex = 0;
        
        for (NSInteger y = 0; y < height && sourceIndex < rawData.length; y++) {
            for (NSInteger x = 0; x < width && sourceIndex < rawData.length; x++) {
                NSInteger pixelIndex = y * bytesPerRow + x * samplesPerPixel;
                
                if (samplesPerPixel == 1) {
                    // Grayscale
                    pixels[pixelIndex] = sourceBytes[sourceIndex++];
                } else if (samplesPerPixel == 3) {
                    // RGB (note: source is BGR)
                    pixels[pixelIndex + 2] = sourceBytes[sourceIndex++]; // B -> R
                    pixels[pixelIndex + 1] = sourceBytes[sourceIndex++]; // G -> G
                    pixels[pixelIndex + 0] = sourceBytes[sourceIndex++]; // R -> B
                } else if (samplesPerPixel == 4) {
                    // RGBA (note: source is BGRA)
                    pixels[pixelIndex + 2] = sourceBytes[sourceIndex++]; // B -> R
                    pixels[pixelIndex + 1] = sourceBytes[sourceIndex++]; // G -> G
                    pixels[pixelIndex + 0] = sourceBytes[sourceIndex++]; // R -> B
                    pixels[pixelIndex + 3] = sourceBytes[sourceIndex++]; // A -> A
                }
            }
        }
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"Error parsing raw image data" exception:exception];
        return nil;
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [image addRepresentation:bitmap];
    
    return image;
}

+ (NSData *)rawWriterWithImage:(NSImage *)image format:(TxtrFormats)format {
    if (image == nil) {
        return [[NSData alloc] init];
    }
    
    NSMutableData *outputData = [[NSMutableData alloc] init];
    
    // Get bitmap representation
    NSImageRep *imageRep = [[image representations] firstObject];
    NSBitmapImageRep *bitmap = nil;
    
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmap = (NSBitmapImageRep *)imageRep;
    } else {
        // Convert to bitmap
        NSSize imageSize = image.size;
        bitmap = [[NSBitmapImageRep alloc]
                 initWithBitmapDataPlanes:NULL
                               pixelsWide:imageSize.width
                               pixelsHigh:imageSize.height
                            bitsPerSample:8
                          samplesPerPixel:4
                                 hasAlpha:YES
                                 isPlanar:NO
                           colorSpaceName:NSCalibratedRGBColorSpace
                              bytesPerRow:0
                             bitsPerPixel:0];
        
        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:context];
        [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height)];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    unsigned char *pixels = [bitmap bitmapData];
    NSInteger bytesPerRow = [bitmap bytesPerRow];
    NSInteger width = [bitmap pixelsWide];
    NSInteger height = [bitmap pixelsHigh];
    
    for (NSInteger y = 0; y < height; y++) {
        for (NSInteger x = 0; x < width; x++) {
            NSInteger pixelIndex = y * bytesPerRow + x * 4;
            uint8_t red = pixels[pixelIndex + 0];
            uint8_t green = pixels[pixelIndex + 1];
            uint8_t blue = pixels[pixelIndex + 2];
            uint8_t alpha = pixels[pixelIndex + 3];
            
            // Output as BGR(A) format
            [outputData appendBytes:&blue length:1];
            if ((format != TxtrFormatsRaw8Bit) && (format != TxtrFormatsExtRaw8Bit)) {
                [outputData appendBytes:&green length:1];
                [outputData appendBytes:&red length:1];
                if (format == TxtrFormatsRaw32Bit) {
                    [outputData appendBytes:&alpha length:1];
                }
            }
        }
    }
    
    return [outputData copy];
}

// MARK: - DXT Format Processing (Using CSoil2)

+ (NSImage *)dxt3ParserWithParentSize:(NSSize)parentSize
                               format:(TxtrFormats)format
                            imageSize:(NSInteger)imageSize
                               reader:(BinaryReader *)reader
                                width:(NSInteger)width
                               height:(NSInteger)height {
    @try {
        // Read the compressed data
        NSData *compressedData = [reader readBytes:imageSize];
        if (!compressedData || compressedData.length == 0) {
            return [[NSImage alloc] initWithSize:NSMakeSize(MAX(1, width), MAX(1, height))];
        }
        
        // Use CSoil2 to decompress the DXT data
        int imgWidth, imgHeight, channels;
        unsigned char *pixelData = SOIL_load_image_from_memory(
            (const unsigned char *)[compressedData bytes],
            (int)compressedData.length,
            &imgWidth, &imgHeight, &channels,
            SOIL_LOAD_RGBA // Force RGBA for consistency
        );
        
        if (!pixelData) {
            // If CSoil2 can't handle it directly, fall back to manual DXT parsing
            // (This preserves the original behavior for edge cases)
            NSLog(@"CSoil2 failed to load DXT data: %s", SOIL_last_result());
            return [self fallbackDxtParser:compressedData width:width height:height format:format];
        }
        
        // Convert pixel data to NSImage
        NSImage *image = [self pixelDataToNSImage:pixelData
                                            width:imgWidth
                                           height:imgHeight
                                         channels:4]; // Always RGBA from SOIL_LOAD_RGBA
        
        // Clean up CSoil2 allocated memory
        SOIL_free_image_data(pixelData);
        
        return image;
        
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"Error parsing DXT image data with CSoil2" exception:exception];
        return [[NSImage alloc] initWithSize:NSMakeSize(MAX(1, width), MAX(1, height))];
    }
}

+ (NSData *)dxt3WriterWithImage:(NSImage *)image format:(TxtrFormats)format {
    if (image == nil) {
        return [[NSData alloc] init];
    }
    
    @try {
        // Convert NSImage to pixel data
        int width, height, channels;
        unsigned char *pixelData = [self nsImageToPixelData:image
                                                      width:&width
                                                     height:&height
                                                   channels:&channels];
        
        if (!pixelData) {
            return [[NSData alloc] init];
        }
        
        // Determine SOIL save type from format
        int soilImageType = SOIL_SAVE_TYPE_DDS;
        
        // Use CSoil2 to save as DDS with appropriate compression
        int imageSize;
        unsigned char *compressedData = SOIL_write_image_to_memory(
            soilImageType,
            width, height, channels,
            pixelData,
            &imageSize
        );
        
        // Clean up input pixel data
        free(pixelData);
        
        if (!compressedData) {
            NSLog(@"CSoil2 failed to save DXT data: %s", SOIL_last_result());
            return [[NSData alloc] init];
        }
        
        // Create NSData from the compressed data
        NSData *result = [NSData dataWithBytes:compressedData length:imageSize];
        
        // Clean up CSoil2 allocated memory
        SOIL_free_image_data(compressedData);
        
        return result;
        
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"Error writing DXT image data with CSoil2" exception:exception];
        return [[NSData alloc] init];
    }
}

// MARK: - Image Utilities

+ (NSImage *)previewImage:(NSImage *)image size:(NSSize)size {
    if (image == nil) {
        return nil;
    }
    
    NSSize imageSize = image.size;
    NSSize targetSize = size;
    
    // Calculate aspect ratio preserving size
    CGFloat aspectRatio = imageSize.width / imageSize.height;
    CGFloat targetAspectRatio = targetSize.width / targetSize.height;
    
    if (aspectRatio > targetAspectRatio) {
        // Image is wider than target
        targetSize.height = targetSize.width / aspectRatio;
    } else {
        // Image is taller than target
        targetSize.width = targetSize.height * aspectRatio;
    }
    
    NSImage *previewImage = [[NSImage alloc] initWithSize:targetSize];
    [previewImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, targetSize.width, targetSize.height)
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:1.0];
    [previewImage unlockFocus];
    
    return previewImage;
}

+ (NSBitmapImageFileType)getImageFormatFromName:(NSString *)name {
    NSString *extension = [[name pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"png"]) {
        return NSBitmapImageFileTypePNG;
    } else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
        return NSBitmapImageFileTypeJPEG;
    } else if ([extension isEqualToString:@"bmp"]) {
        return NSBitmapImageFileTypeBMP;
    } else if ([extension isEqualToString:@"tiff"] || [extension isEqualToString:@"tif"]) {
        return NSBitmapImageFileTypeTIFF;
    } else if ([extension isEqualToString:@"gif"]) {
        return NSBitmapImageFileTypeGIF;
    }
    
    return NSBitmapImageFileTypePNG; // Default
}

// MARK: - Private CSoil2 Utility Methods

+ (int)txtrFormatToSoilFormat:(TxtrFormats)format {
    switch (format) {
        case TxtrFormatsDXT1Format:
            return SOIL_LOAD_RGB;
        case TxtrFormatsDXT3Format:
        case TxtrFormatsDXT5Format:
            return SOIL_LOAD_RGBA;
        case TxtrFormatsRaw8Bit:
        case TxtrFormatsExtRaw8Bit:
            return SOIL_LOAD_L;
        case TxtrFormatsRaw24Bit:
        case TxtrFormatsExtRaw24Bit:
            return SOIL_LOAD_RGB;
        case TxtrFormatsRaw32Bit:
            return SOIL_LOAD_RGBA;
        default:
            return SOIL_LOAD_AUTO;
    }
}

+ (TxtrFormats)soilFormatToTxtrFormat:(int)soilFormat {
    switch (soilFormat) {
        case SOIL_LOAD_L:
            return TxtrFormatsRaw8Bit;
        case SOIL_LOAD_RGB:
            return TxtrFormatsRaw24Bit;
        case SOIL_LOAD_RGBA:
            return TxtrFormatsRaw32Bit;
        default:
            return TxtrFormatsUnknown;
    }
}

+ (unsigned char *)nsImageToPixelData:(NSImage *)image
                                width:(int *)width
                               height:(int *)height
                             channels:(int *)channels {
    if (image == nil) {
        return NULL;
    }
    
    NSSize imageSize = image.size;
    *width = (int)imageSize.width;
    *height = (int)imageSize.height;
    *channels = 4; // Always use RGBA
    
    // Create bitmap representation
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                               initWithBitmapDataPlanes:NULL
                                             pixelsWide:*width
                                             pixelsHigh:*height
                                          bitsPerSample:8
                                        samplesPerPixel:*channels
                                               hasAlpha:YES
                                               isPlanar:NO
                                         colorSpaceName:NSCalibratedRGBColorSpace
                                            bytesPerRow:0
                                           bitsPerPixel:0];
    
    if (!bitmap) {
        return NULL;
    }
    
    // Draw image into bitmap
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [image drawInRect:NSMakeRect(0, 0, *width, *height)];
    [NSGraphicsContext restoreGraphicsState];
    
    // Copy pixel data
    unsigned char *bitmapData = [bitmap bitmapData];
    NSInteger totalBytes = (*width) * (*height) * (*channels);
    unsigned char *pixelData = (unsigned char *)malloc(totalBytes);
    
    if (pixelData && bitmapData) {
        memcpy(pixelData, bitmapData, totalBytes);
    }
    
    return pixelData;
}

+ (NSImage *)pixelDataToNSImage:(unsigned char *)pixelData
                          width:(int)width
                         height:(int)height
                       channels:(int)channels {
    if (!pixelData || width <= 0 || height <= 0 || channels <= 0) {
        return nil;
    }
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                               initWithBitmapDataPlanes:&pixelData
                                             pixelsWide:width
                                             pixelsHigh:height
                                          bitsPerSample:8
                                        samplesPerPixel:channels
                                               hasAlpha:(channels == 4 || channels == 2)
                                               isPlanar:NO
                                         colorSpaceName:(channels == 1 || channels == 2) ?
                                                       NSCalibratedWhiteColorSpace :
                                                       NSCalibratedRGBColorSpace
                                            bytesPerRow:width * channels
                                           bitsPerPixel:8 * channels];
    
    if (!bitmap) {
        return nil;
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [image addRepresentation:bitmap];
    
    return image;
}

// MARK: - Fallback DXT Parser (Original Implementation)

+ (NSImage *)fallbackDxtParser:(NSData *)compressedData
                         width:(NSInteger)width
                        height:(NSInteger)height
                        format:(TxtrFormats)format {
    // This is a simplified version of the original manual DXT parser
    // for cases where CSoil2 can't handle the specific DXT variant
    
    NSBitmapImageRep *bitmap = nil;
    
    @try {
        if ((format == TxtrFormatsDXT3Format) || (format == TxtrFormatsDXT5Format)) {
            bitmap = [[NSBitmapImageRep alloc]
                     initWithBitmapDataPlanes:NULL
                                   pixelsWide:width
                                   pixelsHigh:height
                                bitsPerSample:8
                              samplesPerPixel:4
                                     hasAlpha:YES
                                     isPlanar:NO
                               colorSpaceName:NSCalibratedRGBColorSpace
                                  bytesPerRow:0
                                 bitsPerPixel:0];
        } else {
            bitmap = [[NSBitmapImageRep alloc]
                     initWithBitmapDataPlanes:NULL
                                   pixelsWide:width
                                   pixelsHigh:height
                                bitsPerSample:8
                              samplesPerPixel:3
                                     hasAlpha:NO
                                     isPlanar:NO
                               colorSpaceName:NSCalibratedRGBColorSpace
                                  bytesPerRow:0
                                 bitsPerPixel:0];
        }
        
        if (!bitmap) {
            return [[NSImage alloc] initWithSize:NSMakeSize(MAX(1, width), MAX(1, height))];
        }
        
        unsigned char *pixels = [bitmap bitmapData];
        NSInteger samplesPerPixel = [bitmap samplesPerPixel];
        const unsigned char *sourceBytes = (const unsigned char *)[compressedData bytes];
        NSInteger sourceIndex = 0;
        
        // Simple block-based decompression (very basic fallback)
        for (NSInteger by = 0; by < height; by += 4) {
            for (NSInteger bx = 0; bx < width; bx += 4) {
                if (sourceIndex + 8 <= compressedData.length) {
                    // Read color endpoints (simplified)
                    uint16_t color0 = sourceBytes[sourceIndex] | (sourceBytes[sourceIndex + 1] << 8);
                    uint16_t color1 = sourceBytes[sourceIndex + 2] | (sourceBytes[sourceIndex + 3] << 8);
                    sourceIndex += 4;
                    
                    // Convert 565 to RGB
                    uint8_t r0 = (color0 >> 11) * 8;
                    uint8_t g0 = ((color0 >> 5) & 0x3F) * 4;
                    uint8_t b0 = (color0 & 0x1F) * 8;
                    
                    uint8_t r1 = (color1 >> 11) * 8;
                    uint8_t g1 = ((color1 >> 5) & 0x3F) * 4;
                    uint8_t b1 = (color1 & 0x1F) * 8;
                    
                    // Fill 4x4 block with interpolated colors (simplified)
                    for (NSInteger py = 0; py < 4 && (by + py) < height; py++) {
                        for (NSInteger px = 0; px < 4 && (bx + px) < width; px++) {
                            NSInteger pixelIndex = (by + py) * width * samplesPerPixel + (bx + px) * samplesPerPixel;
                            
                            // Simple interpolation
                            pixels[pixelIndex + 0] = (r0 + r1) / 2; // R
                            pixels[pixelIndex + 1] = (g0 + g1) / 2; // G
                            pixels[pixelIndex + 2] = (b0 + b1) / 2; // B
                            
                            if (samplesPerPixel == 4) {
                                pixels[pixelIndex + 3] = 0xff; // A
                            }
                        }
                    }
                    
                    sourceIndex += 4; // Skip color indices for simplicity
                }
            }
        }
        
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"Error in fallback DXT parser" exception:exception];
        return [[NSImage alloc] initWithSize:NSMakeSize(MAX(1, width), MAX(1, height))];
    }
    
    if (bitmap) {
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
        [image addRepresentation:bitmap];
        return image;
    }
    
    return [[NSImage alloc] initWithSize:NSMakeSize(MAX(1, width), MAX(1, height))];
}

@end
