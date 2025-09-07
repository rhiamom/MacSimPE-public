//
//  TGALoader.m
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
//
//  LoadTGAClass.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "TGALoader.h"
#import "BinaryReader.h"
#import "Stream.h"
#import "MemoryStream.h"
#import "FileStream.h"

@implementation LoadTGAClass

// MARK: - Private Methods

+ (uint32_t)unpackColor:(uint32_t)sourceColor withCD:(TGACD)cd {
    uint32_t rpermute = (sourceColor << cd.rShift) | (sourceColor >> (32 - cd.rShift));
    uint32_t gpermute = (sourceColor << cd.gShift) | (sourceColor >> (32 - cd.gShift));
    uint32_t bpermute = (sourceColor << cd.bShift) | (sourceColor >> (32 - cd.bShift));
    uint32_t apermute = (sourceColor << cd.aShift) | (sourceColor >> (32 - cd.aShift));
    
    uint32_t result = (rpermute & cd.rMask) | (gpermute & cd.gMask) |
                      (bpermute & cd.bMask) | (apermute & cd.aMask) | cd.finalOr;
    
    return result;
}

+ (void)decodeLine:(NSBitmapImageRep *)bitmap
              line:(NSInteger)line
        bytesPerPixel:(NSInteger)byp
              data:(NSData *)data
                cd:(TGACD)cd {
    
    NSInteger width = bitmap.size.width;
    const uint8_t *bytes = (const uint8_t *)data.bytes;
    
    if (cd.needNoConvert && byp == 4) {
        // Fast copy for 32-bit ARGB
        const uint32_t *sourcePixels = (const uint32_t *)bytes;
        for (NSInteger i = 0; i < width; i++) {
            uint32_t pixel = sourcePixels[i];
            NSColor *color = [NSColor colorWithSRGBRed:((pixel >> 16) & 0xFF) / 255.0
                                                 green:((pixel >> 8) & 0xFF) / 255.0
                                                  blue:(pixel & 0xFF) / 255.0
                                                 alpha:((pixel >> 24) & 0xFF) / 255.0];
            [bitmap setColor:color atX:i y:line];
        }
    } else {
        // Color conversion needed
        NSInteger rdi = 0;
        for (NSInteger i = 0; i < width; i++) {
            uint32_t x = 0;
            for (NSInteger j = 0; j < byp; j++) {
                x |= ((uint32_t)bytes[rdi]) << (j << 3);
                rdi++;
            }
            uint32_t pixel = [self unpackColor:x withCD:cd];
            NSColor *color = [NSColor colorWithSRGBRed:((pixel >> 16) & 0xFF) / 255.0
                                                 green:((pixel >> 8) & 0xFF) / 255.0
                                                  blue:(pixel & 0xFF) / 255.0
                                                 alpha:((pixel >> 24) & 0xFF) / 255.0];
            [bitmap setColor:color atX:i y:line];
        }
    }
}

+ (void)decodeRLE:(NSBitmapImageRep *)bitmap
   bytesPerPixel:(NSInteger)byp
              cd:(TGACD)cd
          reader:(BinaryReader *)br
        bottomUp:(BOOL)bottomUp {
    
    @try {
        NSInteger width = bitmap.size.width;
        NSInteger height = bitmap.size.height;
        
        // Make buffer larger for safety
        NSMutableData *lineBuffer = [NSMutableData dataWithLength:(width + 128) * byp];
        uint8_t *buffer = (uint8_t *)lineBuffer.mutableBytes;
        NSInteger maxIndex = width * byp;
        NSInteger index = 0;
        
        for (NSInteger j = 0; j < height; j++) {
            while (index < maxIndex) {
                uint8_t blockType = [br readByte];
                
                NSInteger bytesToRead;
                NSInteger bytesToCopy;
                
                if (blockType >= 0x80) {
                    bytesToRead = byp;
                    bytesToCopy = byp * (blockType - 0x80);
                } else {
                    bytesToRead = byp * (blockType + 1);
                    bytesToCopy = 0;
                }
                
                NSData *readData = [br readBytes:bytesToRead];
                memcpy(buffer + index, readData.bytes, bytesToRead);
                index += bytesToRead;
                
                for (NSInteger i = 0; i < bytesToCopy; i++) {
                    buffer[index + i] = buffer[index + i - bytesToRead];
                }
                index += bytesToCopy;
            }
            
            NSInteger targetLine = bottomUp ? j : (height - j - 1);
            NSData *lineData = [NSData dataWithBytes:buffer length:maxIndex];
            [self decodeLine:bitmap line:targetLine bytesPerPixel:byp data:lineData cd:cd];
            
            if (index > maxIndex) {
                memmove(buffer, buffer + maxIndex, index - maxIndex);
                index -= maxIndex;
            } else {
                index = 0;
            }
        }
    } @catch (NSException *exception) {
        // Handle end of stream
    }
}

+ (void)decodePlain:(NSBitmapImageRep *)bitmap
     bytesPerPixel:(NSInteger)byp
                cd:(TGACD)cd
            reader:(BinaryReader *)br
          bottomUp:(BOOL)bottomUp {
    
    NSInteger width = bitmap.size.width;
    NSInteger height = bitmap.size.height;
    
    for (NSInteger j = 0; j < height; j++) {
        NSData *lineData = [br readBytes:width * byp];
        NSInteger targetLine = bottomUp ? j : (height - j - 1);
        [self decodeLine:bitmap line:targetLine bytesPerPixel:byp data:lineData cd:cd];
    }
}

+ (void)decodeStandard8:(NSBitmapImageRep *)bitmap
                 header:(TGAHeader)hdr
                 reader:(BinaryReader *)br {
    TGACD cd;
    cd.rMask = 0x000000ff;
    cd.gMask = 0x0000ff00;
    cd.bMask = 0x00ff0000;
    cd.aMask = 0x00000000;
    cd.rShift = 0;
    cd.gShift = 8;
    cd.bShift = 16;
    cd.aShift = 0;
    cd.finalOr = 0xff000000;
    cd.needNoConvert = NO;
    
    if ([self isRLEEncoded:hdr.imageType]) {
        [self decodeRLE:bitmap bytesPerPixel:1 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    } else {
        [self decodePlain:bitmap bytesPerPixel:1 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    }
}

+ (void)decodeSpecial16:(NSBitmapImageRep *)bitmap
                 header:(TGAHeader)hdr
                 reader:(BinaryReader *)br {
    TGACD cd;
    cd.rMask = 0x00f00000;
    cd.gMask = 0x0000f000;
    cd.bMask = 0x000000f0;
    cd.aMask = 0xf0000000;
    cd.rShift = 12;
    cd.gShift = 8;
    cd.bShift = 4;
    cd.aShift = 16;
    cd.finalOr = 0;
    cd.needNoConvert = NO;
    
    if ([self isRLEEncoded:hdr.imageType]) {
        [self decodeRLE:bitmap bytesPerPixel:2 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    } else {
        [self decodePlain:bitmap bytesPerPixel:2 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    }
}

+ (void)decodeStandard16:(NSBitmapImageRep *)bitmap
                  header:(TGAHeader)hdr
                  reader:(BinaryReader *)br {
    TGACD cd;
    cd.rMask = 0x00f80000;
    cd.gMask = 0x0000fc00;
    cd.bMask = 0x000000f8;
    cd.aMask = 0x00000000;
    cd.rShift = 8;
    cd.gShift = 5;
    cd.bShift = 3;
    cd.aShift = 0;
    cd.finalOr = 0xff000000;
    cd.needNoConvert = NO;
    
    if ([self isRLEEncoded:hdr.imageType]) {
        [self decodeRLE:bitmap bytesPerPixel:2 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    } else {
        [self decodePlain:bitmap bytesPerPixel:2 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    }
}

+ (void)decodeSpecial24:(NSBitmapImageRep *)bitmap
                 header:(TGAHeader)hdr
                 reader:(BinaryReader *)br {
    TGACD cd;
    cd.rMask = 0x00f80000;
    cd.gMask = 0x0000fc00;
    cd.bMask = 0x000000f8;
    cd.aMask = 0xff000000;
    cd.rShift = 8;
    cd.gShift = 5;
    cd.bShift = 3;
    cd.aShift = 8;
    cd.finalOr = 0;
    cd.needNoConvert = NO;
    
    if ([self isRLEEncoded:hdr.imageType]) {
        [self decodeRLE:bitmap bytesPerPixel:3 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    } else {
        [self decodePlain:bitmap bytesPerPixel:3 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    }
}

+ (void)decodeStandard24:(NSBitmapImageRep *)bitmap
                  header:(TGAHeader)hdr
                  reader:(BinaryReader *)br {
    TGACD cd;
    cd.rMask = 0x00ff0000;
    cd.gMask = 0x0000ff00;
    cd.bMask = 0x000000ff;
    cd.aMask = 0x00000000;
    cd.rShift = 0;
    cd.gShift = 0;
    cd.bShift = 0;
    cd.aShift = 0;
    cd.finalOr = 0xff000000;
    cd.needNoConvert = NO;
    
    if ([self isRLEEncoded:hdr.imageType]) {
        [self decodeRLE:bitmap bytesPerPixel:3 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    } else {
        [self decodePlain:bitmap bytesPerPixel:3 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    }
}

+ (void)decodeStandard32:(NSBitmapImageRep *)bitmap
                  header:(TGAHeader)hdr
                  reader:(BinaryReader *)br {
    TGACD cd;
    cd.rMask = 0x00ff0000;
    cd.gMask = 0x0000ff00;
    cd.bMask = 0x000000ff;
    cd.aMask = 0xff000000;
    cd.rShift = 0;
    cd.gShift = 0;
    cd.bShift = 0;
    cd.aShift = 0;
    cd.finalOr = 0x00000000;
    cd.needNoConvert = YES;
    
    if ([self isRLEEncoded:hdr.imageType]) {
        [self decodeRLE:bitmap bytesPerPixel:4 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    } else {
        [self decodePlain:bitmap bytesPerPixel:4 cd:cd reader:br bottomUp:[self isBottomUpFromDescriptor:hdr.imageSpec.descriptor]];
    }
}

// MARK: - Public Methods

+ (NSSize)getTGASize:(NSString *)filename {
    FileStream *fileStream = [[FileStream alloc] initWithPath:filename access:FileAccessRead];
    if (!fileStream) return NSZeroSize;
    
    BinaryReader *br = [[BinaryReader alloc] initWithStream:fileStream];
    TGAHeader header = [self readTGAHeader:br];
    [fileStream close];
    
    return NSMakeSize(header.imageSpec.width, header.imageSpec.height);
}

+ (NSImage *)loadTGA:(Stream *)source {
    // Read all data from the stream
    NSMutableData *buffer = [NSMutableData dataWithLength:(NSUInteger)source.length];
    [source seekToOffset:0 origin:SeekOriginBegin];
    [source readBytes:(uint8_t *)buffer.mutableBytes maxLength:(NSInteger)source.length];
    
    MemoryStream *ms = [[MemoryStream alloc] initWithData:buffer];
    BinaryReader *br = [[BinaryReader alloc] initWithStream:ms];
    
    TGAHeader header = [self readTGAHeader:br];
    
    // Validate pixel depth
    if (header.imageSpec.pixelDepth != 8 && header.imageSpec.pixelDepth != 16 &&
        header.imageSpec.pixelDepth != 24 && header.imageSpec.pixelDepth != 32) {
        @throw [NSException exceptionWithName:@"TGALoaderException"
                                       reason:[NSString stringWithFormat:@"Not a supported tga file. (Pixeldepth=%d)", header.imageSpec.pixelDepth]
                                     userInfo:nil];
    }
    
    if ([self alphaBitsFromDescriptor:header.imageSpec.descriptor] > 8) {
        @throw [NSException exceptionWithName:@"TGALoaderException"
                                       reason:@"Not a supported tga file."
                                     userInfo:nil];
    }
    
    if (header.imageSpec.width > 4096 || header.imageSpec.height > 4096) {
        @throw [NSException exceptionWithName:@"TGALoaderException"
                                       reason:@"Image too large."
                                     userInfo:nil];
    }
    
    NSSize imageSize = NSMakeSize(header.imageSpec.width, header.imageSpec.height);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                       pixelsWide:(NSInteger)imageSize.width
                                                                       pixelsHigh:(NSInteger)imageSize.height
                                                                    bitsPerSample:8
                                                                  samplesPerPixel:4
                                                                         hasAlpha:YES
                                                                         isPlanar:NO
                                                                   colorSpaceName:NSCalibratedRGBColorSpace
                                                                      bytesPerRow:0
                                                                     bitsPerPixel:32];
    
    uint8_t alphaBits = [self alphaBitsFromDescriptor:header.imageSpec.descriptor];
    
    switch (header.imageSpec.pixelDepth) {
        case 8:
            [self decodeStandard8:bitmap header:header reader:br];
            break;
        case 16:
            if (alphaBits > 0) {
                [self decodeSpecial16:bitmap header:header reader:br];
            } else {
                [self decodeStandard16:bitmap header:header reader:br];
            }
            break;
        case 24:
            if (alphaBits > 0) {
                [self decodeSpecial24:bitmap header:header reader:br];
            } else {
                [self decodeStandard24:bitmap header:header reader:br];
            }
            break;
        case 32:
            [self decodeStandard32:bitmap header:header reader:br];
            break;
        default:
            return nil;
    }
    
    NSImage *result = [[NSImage alloc] initWithSize:imageSize];
    [result addRepresentation:bitmap];
    
    return result;
}

+ (NSImage *)loadTGAFromFile:(NSString *)filename {
    @try {
        FileStream *fileStream = [[FileStream alloc] initWithPath:filename access:FileAccessRead];
        if (!fileStream) return nil;
        
        NSImage *result = [self loadTGA:fileStream];
        [fileStream close];
        return result;
    } @catch (NSException *exception) {
        return nil; // File not found or other error
    }
}

// MARK: - Helper Methods

+ (TGAHeader)readTGAHeader:(BinaryReader *)reader {
    TGAHeader header;
    header.idLength = [reader readByte];
    header.colorMapType = [reader readByte];
    header.imageType = [reader readByte];
    
    header.colorMap.firstEntryIndex = [reader readUInt16];
    header.colorMap.length = [reader readUInt16];
    header.colorMap.entrySize = [reader readByte];
    
    header.imageSpec.xOrigin = [reader readUInt16];
    header.imageSpec.yOrigin = [reader readUInt16];
    header.imageSpec.width = [reader readUInt16];
    header.imageSpec.height = [reader readUInt16];
    header.imageSpec.pixelDepth = [reader readByte];
    header.imageSpec.descriptor = [reader readByte];
    
    return header;
}

+ (uint8_t)alphaBitsFromDescriptor:(uint8_t)descriptor {
    return descriptor & 0xF;
}

+ (BOOL)isBottomUpFromDescriptor:(uint8_t)descriptor {
    return (descriptor & 0x20) == 0x20;
}

+ (BOOL)isRLEEncoded:(uint8_t)imageType {
    return imageType >= 9;
}

@end
