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
        BinaryReader *reader = [[BinaryReader alloc] initWithData:_data];
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
        BinaryReader *reader = [[BinaryReader alloc] initWithData:fileData];
        
        // Seek to header information
        [reader seekToPosition:0x0c];
        int32_t height = [reader readInt32];
        int32_t width = [reader readInt32];
        NSSize size = NSMakeSize(width, height);
        int32_t firstSize = [reader readInt32];
        int32_t unknown = [reader readInt32];
        int32_t mapCount = [reader readInt32];
        
        // Read DXT signature
        [reader seekToPosition:0x54];
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
        
        [reader seekToPosition:0x80];
        NSInteger blockSize = (format == TxtrFormatsDXT1Format) ? 0x8 : 0x10;
        NSSize currentSize = size;
        NSInteger currentFirstSize = firstSize;
        
        for (NSInteger i = 0; i < mapCount; i++) {
            NSData *data = [reader readBytes:currentFirstSize];
            DDSData *ddsData = [[DDSData alloc] initWithData:data
                                                        size:size
                                                      format:format
                                                       level:(mapCount - (i + 1))
                                                       count:mapCount];
            [maps addObject:ddsData];
            
            currentSize = NSMakeSize(MAX(1, currentSize.width / 2), MAX(1, currentSize.height / 2));
            currentFirstSize = MAX(1, currentSize.width / 4) * MAX(1, currentSize.height / 4) * blockSize;
        }
        
    } @catch (NSException *exception) {
        [ExceptionForm execute:exception];
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
    
    if (index != -1) {
        NSInteger revLevel = MAX(0, mapCount - (index + 1));
        
        for (NSInteger i = 0; i < revLevel; i++) {
            width /= 2;
            height /= 2;
        }
    }
    
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
        data = [self dxt3WriterWithImage:image format:format];
    } else if ((format == TxtrFormatsExtRaw8Bit) ||
               (format == TxtrFormatsRaw8Bit) ||
               (format == TxtrFormatsRaw24Bit) ||
               (format == TxtrFormatsRaw32Bit) ||
               (format == TxtrFormatsExtRaw24Bit)) {
        data = [self rawWriterWithImage:image format:format];
    }
    
    return data;
}

// MARK: - RAW Format Processing

+ (NSImage *)rawParserWithParentSize:(NSSize)parentSize
                              format:(TxtrFormats)format
                           imageSize:(NSInteger)imageSize
                              reader:(BinaryReader *)reader
                               width:(NSInteger)width
                              height:(NSInteger)height {
    width = MAX(1, width);
    height = MAX(1, height);
    
    // Create bitmap representation
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
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
    
    if (!bitmap) {
        return nil;
    }
    
    unsigned char *pixels = [bitmap bitmapData];
    NSInteger bytesPerRow = [bitmap bytesPerRow];
    
    for (NSInteger y = 0; y < height; y++) {
        for (NSInteger x = 0; x < width; x++) {
            uint8_t alpha = 0xff;
            uint8_t red = 0;
            uint8_t green = 0;
            uint8_t blue = 0;
            
            blue = [reader readByte];
            if ((format != TxtrFormatsRaw8Bit) && (format != TxtrFormatsExtRaw8Bit)) {
                green = [reader readByte];
                red = [reader readByte];
                
                if (format == TxtrFormatsRaw32Bit) {
                    alpha = [reader readByte];
                }
            } else {
                // Grayscale
                red = blue;
                green = blue;
            }
            
            // Set pixel in bitmap data
            NSInteger pixelIndex = y * bytesPerRow + x * 4;
            pixels[pixelIndex + 0] = red;     // R
            pixels[pixelIndex + 1] = green;   // G
            pixels[pixelIndex + 2] = blue;    // B
            pixels[pixelIndex + 3] = alpha;   // A
        }
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

// MARK: - DXT Format Processing

+ (NSImage *)dxt3ParserWithParentSize:(NSSize)parentSize
                               format:(TxtrFormats)format
                            imageSize:(NSInteger)imageSize
                               reader:(BinaryReader *)reader
                                width:(NSInteger)width
                               height:(NSInteger)height {
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
        NSInteger bytesPerRow = [bitmap bytesPerRow];
        NSInteger samplesPerPixel = [bitmap samplesPerPixel];
        
        uint8_t alpha[16]; // Alpha values for 4x4 block
        
        // Process 4x4 blocks
        for (NSInteger y = 0; y < height; y += 4) {
            for (NSInteger x = 0; x < width; x += 4) {
                // Decode alpha data
                if (format == TxtrFormatsDXT3Format) {
                    uint64_t alphaBits = [reader readUInt64];
                    // 16 alpha values, 4 bits each
                    for (NSInteger i = 0; i < 16; i++) {
                        alpha[i] = (uint8_t)((alphaBits & 0xf) * 0x11);
                        alphaBits >>= 4;
                    }
                } else if (format == TxtrFormatsDXT5Format) {
                    uint8_t alpha1 = [reader readByte];
                    uint8_t alpha2 = [reader readByte];
                    uint64_t alphaBits = (uint64_t)[reader readUInt32] | ((uint64_t)[reader readUInt16] << 32);
                    
                    uint8_t alphas[8];
                    alphas[0] = alpha1;
                    alphas[1] = alpha2;
                    
                    if (alpha1 > alpha2) {
                        alphas[2] = (6 * alpha1 + alpha2) / 7;
                        alphas[3] = (5 * alpha1 + 2 * alpha2) / 7;
                        alphas[4] = (4 * alpha1 + 3 * alpha2) / 7;
                        alphas[5] = (3 * alpha1 + 4 * alpha2) / 7;
                        alphas[6] = (2 * alpha1 + 5 * alpha2) / 7;
                        alphas[7] = (alpha1 + 6 * alpha2) / 7;
                    } else {
                        alphas[2] = (4 * alpha1 + alpha2) / 5;
                        alphas[3] = (3 * alpha1 + 2 * alpha2) / 5;
                        alphas[4] = (2 * alpha1 + 3 * alpha2) / 5;
                        alphas[5] = (1 * alpha1 + 4 * alpha2) / 5;
                        alphas[6] = 0;
                        alphas[7] = 0xff;
                    }
                    
                    for (NSInteger i = 0; i < 16; i++) {
                        alpha[i] = alphas[alphaBits & 7];
                        alphaBits >>= 3;
                    }
                }
                
                // Decode DXT1 RGB data
                uint16_t c1Packed = [reader readUInt16];
                uint16_t c2Packed = [reader readUInt16];
                
                // Extract RGB components
                uint8_t color1r = (uint8_t)(((c1Packed >> 11) & 0x1F) * 8.225806451612903);
                uint8_t color1g = (uint8_t)(((c1Packed >> 5) & 0x3F) * 4.047619047619048);
                uint8_t color1b = (uint8_t)((c1Packed & 0x1F) * 8.225806451612903);
                
                uint8_t color2r = (uint8_t)(((c2Packed >> 11) & 0x1F) * 8.225806451612903);
                uint8_t color2g = (uint8_t)(((c2Packed >> 5) & 0x3F) * 4.047619047619048);
                uint8_t color2b = (uint8_t)((c2Packed & 0x1F) * 8.225806451612903);
                
                // Build color table
                uint8_t colors[4][3];
                colors[0][0] = color1r; colors[0][1] = color1g; colors[0][2] = color1b;
                colors[1][0] = color2r; colors[1][1] = color2g; colors[1][2] = color2b;
                
                // Interpolate colors
                colors[2][0] = (((color1r << 1) + color2r) / 3) & 0xff;
                colors[2][1] = (((color1g << 1) + color2g) / 3) & 0xff;
                colors[2][2] = (((color1b << 1) + color2b) / 3) & 0xff;
                
                colors[3][0] = (((color2r << 1) + color1r) / 3) & 0xff;
                colors[3][1] = (((color2g << 1) + color1g) / 3) & 0xff;
                colors[3][2] = (((color2b << 1) + color1b) / 3) & 0xff;
                
                // Read color indices
                uint32_t colorBits = [reader readUInt32];
                
                for (NSInteger by = 0; by < 4; by++) {
                    for (NSInteger bx = 0; bx < 4; bx++) {
                        @try {
                            if (((x + bx) < width) && ((y + by) < height)) {
                                uint32_t code = (colorBits >> (((by << 2) + bx) << 1)) & 3;
                                NSInteger pixelIndex = (y + by) * bytesPerRow + (x + bx) * samplesPerPixel;
                                
                                pixels[pixelIndex + 0] = colors[code][0]; // R
                                pixels[pixelIndex + 1] = colors[code][1]; // G
                                pixels[pixelIndex + 2] = colors[code][2]; // B
                                
                                if (samplesPerPixel == 4) {
                                    if ((format == TxtrFormatsDXT3Format) || (format == TxtrFormatsDXT5Format)) {
                                        pixels[pixelIndex + 3] = alpha[(by << 2) + bx]; // A
                                    } else {
                                        pixels[pixelIndex + 3] = 0xff; // A
                                    }
                                }
                            }
                        } @catch (NSException *exception) {
                            [ExceptionForm executeWithMessage:@"" exception:exception];
                        }
                    }
                }
            }
        }
        
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"" exception:exception];
    }
    
    if (bitmap) {
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
        [image addRepresentation:bitmap];
        return image;
    }
    
    return nil;
}

+ (NSData *)dxt3WriterWithImage:(NSImage *)image format:(TxtrFormats)format {
    if (image
#import "ImageLoader.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
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
        BinaryReader *reader = [[BinaryReader alloc] initWithData:_data];
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
        BinaryReader *reader = [[BinaryReader alloc] initWithData:fileData];
        
        // Seek to header information
        [reader seekToPosition:0x0c];
        int32_t height = [reader readInt32];
        int32_t width = [reader readInt32];
        NSSize size = NSMakeSize(width, height);
        int32_t firstSize = [reader readInt32];
        int32_t unknown = [reader readInt32];
        int32_t mapCount = [reader readInt32];
        
        // Read DXT signature
        [reader seekToPosition:0x54];
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
        
        [reader seekToPosition:0x80];
        NSInteger blockSize = (format == TxtrFormatsDXT1Format) ? 0x8 : 0x10;
        NSSize currentSize = size;
        NSInteger currentFirstSize = firstSize;
        
        for (NSInteger i = 0; i < mapCount; i++) {
            NSData *data = [reader readBytes:currentFirstSize];
            DDSData *ddsData = [[DDSData alloc] initWithData:data
                                                        size:size
                                                      format:format
                                                       level:(mapCount - (i + 1))
                                                       count:mapCount];
            [maps addObject:ddsData];
            
            currentSize = NSMakeSize(MAX(1, currentSize.width / 2), MAX(1, currentSize.height / 2));
            currentFirstSize = MAX(1, currentSize.width / 4) * MAX(1, currentSize.height / 4) * blockSize;
        }
        
    } @catch (NSException *exception) {
        [ExceptionForm execute:exception];
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
    
    if (index != -1) {
        NSInteger revLevel = MAX(0, mapCount - (index + 1));
        
        for (NSInteger i = 0; i < revLevel; i++) {
            width /= 2;
            height /= 2;
        }
    }
    
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
        data = [self dxt3WriterWithImage:image format:format];
    } else if ((format == TxtrFormatsExtRaw8Bit) ||
               (format == TxtrFormatsRaw8Bit) ||
               (format == TxtrFormatsRaw24Bit) ||
               (format == TxtrFormatsRaw32Bit) ||
               (format == TxtrFormatsExtRaw24Bit)) {
        data = [self rawWriterWithImage:image format:format];
    }
    
    return data;
}

// MARK: - RAW Format Processing

+ (NSImage *)rawParserWithParentSize:(NSSize)parentSize
                              format:(TxtrFormats)format
                           imageSize:(NSInteger)imageSize
                              reader:(BinaryReader *)reader
                               width:(NSInteger)width
                              height:(NSInteger)height {
    width = MAX(1, width);
    height = MAX(1, height);
    
    // Create bitmap representation
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
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
    
    if (!bitmap) {
        return nil;
    }
    
    unsigned char *pixels = [bitmap bitmapData];
    NSInteger bytesPerRow = [bitmap bytesPerRow];
    
    for (NSInteger y = 0; y < height; y++) {
        for (NSInteger x = 0; x < width; x++) {
            uint8_t alpha = 0xff;
            uint8_t red = 0;
            uint8_t green = 0;
            uint8_t blue = 0;
            
            blue = [reader readByte];
            if ((format != TxtrFormatsRaw8Bit) && (format != TxtrFormatsExtRaw8Bit)) {
                green = [reader readByte];
                red = [reader readByte];
                
                if (format == TxtrFormatsRaw32Bit) {
                    alpha = [reader readByte];
                }
            } else {
                // Grayscale
                red = blue;
                green = blue;
            }
            
            // Set pixel in bitmap data
            NSInteger pixelIndex = y * bytesPerRow + x * 4;
            pixels[pixelIndex + 0] = red;     // R
            pixels[pixelIndex + 1] = green;   // G
            pixels[pixelIndex + 2] = blue;    // B
            pixels[pixelIndex + 3] = alpha;   // A
        }
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

// MARK: - DXT Format Processing

+ (NSImage *)dxt3ParserWithParentSize:(NSSize)parentSize
                               format:(TxtrFormats)format
                            imageSize:(NSInteger)imageSize
                               reader:(BinaryReader *)reader
                                width:(NSInteger)width
                               height:(NSInteger)height {
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
        NSInteger bytesPerRow = [bitmap bytesPerRow];
        NSInteger samplesPerPixel = [bitmap samplesPerPixel];
        
        uint8_t alpha[16]; // Alpha values for 4x4 block
        
        // Process 4x4 blocks
        for (NSInteger y = 0; y < height; y += 4) {
            for (NSInteger x = 0; x < width; x += 4) {
                // Decode alpha data
                if (format == TxtrFormatsDXT3Format) {
                    uint64_t alphaBits = [reader readUInt64];
                    // 16 alpha values, 4 bits each
                    for (NSInteger i = 0; i < 16; i++) {
                        alpha[i] = (uint8_t)((alphaBits & 0xf) * 0x11);
                        alphaBits >>= 4;
                    }
                } else if (format == TxtrFormatsDXT5Format) {
                    uint8_t alpha1 = [reader readByte];
                    uint8_t alpha2 = [reader readByte];
                    uint64_t alphaBits = (uint64_t)[reader readUInt32] | ((uint64_t)[reader readUInt16] << 32);
                    
                    uint8_t alphas[8];
                    alphas[0] = alpha1;
                    alphas[1] = alpha2;
                    
                    if (alpha1 > alpha2) {
                        alphas[2] = (6 * alpha1 + alpha2) / 7;
                        alphas[3] = (5 * alpha1 + 2 * alpha2) / 7;
                        alphas[4] = (4 * alpha1 + 3 * alpha2) / 7;
                        alphas[5] = (3 * alpha1 + 4 * alpha2) / 7;
                        alphas[6] = (2 * alpha1 + 5 * alpha2) / 7;
                        alphas[7] = (alpha1 + 6 * alpha2) / 7;
                    } else {
                        alphas[2] = (4 * alpha1 + alpha2) / 5;
                        alphas[3] = (3 * alpha1 + 2 * alpha2) / 5;
                        alphas[4] = (2 * alpha1 + 3 * alpha2) / 5;
                        alphas[5] = (1 * alpha1 + 4 * alpha2) / 5;
                        alphas[6] = 0;
                        alphas[7] = 0xff;
                    }
                    
                    for (NSInteger i = 0; i < 16; i++) {
                        alpha[i] = alphas[alphaBits & 7];
                        alphaBits >>= 3;
                    }
                }
                
                // Decode DXT1 RGB data
                uint16_t c1Packed = [reader readUInt16];
                uint16_t c2Packed = [reader readUInt16];
                
                // Extract RGB components
                uint8_t color1r = (uint8_t)(((c1Packed >> 11) & 0x1F) * 8.225806451612903);
                uint8_t color1g = (uint8_t)(((c1Packed >> 5) & 0x3F) * 4.047619047619048);
                uint8_t color1b = (uint8_t)((c1Packed & 0x1F) * 8.225806451612903);
                
                uint8_t color2r = (uint8_t)(((c2Packed >> 11) & 0x1F) * 8.225806451612903);
                uint8_t color2g = (uint8_t)(((c2Packed >> 5) & 0x3F) * 4.047619047619048);
                uint8_t color2b = (uint8_t)((c2Packed & 0x1F) * 8.225806451612903);
                
                // Build color table
                uint8_t colors[4][3];
                colors[0][0] = color1r; colors[0][1] = color1g; colors[0][2] = color1b;
                colors[1][0] = color2r; colors[1][1] = color2g; colors[1][2] = color2b;
                
                // Interpolate colors
                colors[2][0] = (((color1r << 1) + color2r) / 3) & 0xff;
                colors[2][1] = (((color1g << 1) + color2g) / 3) & 0xff;
                colors[2][2] = (((color1b << 1) + color2b) / 3) & 0xff;
                
                colors[3][0] = (((color2r << 1) + color1r) / 3) & 0xff;
                colors[3][1] = (((color2g << 1) + color1g) / 3) & 0xff;
                colors[3][2] = (((color2b << 1) + color1b) / 3) & 0xff;
                
                // Read color indices
                uint32_t colorBits = [reader readUInt32];
                
                for (NSInteger by = 0; by < 4; by++) {
                    for (NSInteger bx = 0; bx < 4; bx++) {
                        @try {
                            if (((x + bx) < width) && ((y + by) < height)) {
                                uint32_t code = (colorBits >> (((by << 2) + bx) << 1)) & 3;
                                NSInteger pixelIndex = (y + by) * bytesPerRow + (x + bx) * samplesPerPixel;
                                
                                pixels[pixelIndex + 0] = colors[code][0]; // R
                                pixels[pixelIndex + 1] = colors[code][1]; // G
                                pixels[pixelIndex + 2] = colors[code][2]; // B
                                
                                if (samplesPerPixel == 4) {
                                    if ((format == TxtrFormatsDXT3Format) || (format == TxtrFormatsDXT5Format)) {
                                        pixels[pixelIndex + 3] = alpha[(by << 2) + bx]; // A
                                    } else {
                                        pixels[pixelIndex + 3] = 0xff; // A
                                    }
                                }
                            }
                        } @catch (NSException *exception) {
                            [ExceptionForm executeWithMessage:@"" exception:exception];
                        }
                    }
                }
            }
        }
        
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"" exception:exception];
    }
    
    if (bitmap) {
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
        [image addRepresentation:bitmap];
        return image;
    }
    
    return nil;
}

+ (NSData *)dxt3WriterWithImage:(NSImage *)image format:(TxtrFormats)format {
    if (image
