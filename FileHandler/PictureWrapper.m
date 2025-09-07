//
//  PictureWrapper.m
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

#import "PictureWrapper.h"
#import "PictureUI.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "MemoryStream.h"
#import "AbstractWrapperInfo.h"
#import "Helper.h"
#import "Localization.h"
#import "TGALoader.h"

@interface PictureWrapper ()

/**
 * Stores the Image
 */
@property (nonatomic, strong) NSImage *image;

@end

@implementation PictureWrapper

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _image = nil;
    }
    return self;
}

// MARK: - AbstractWrapper Overrides

- (id<IWrapperInfo>)createWrapperInfo {
    NSImage *icon = [NSImage imageNamed:@"pic"];
    return [[AbstractWrapperInfo alloc] initWithName:@"Picture Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:2
                                                icon:icon];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[PictureUI alloc] init];
}

- (void)unserialize:(BinaryReader *)reader {
    if (![self doLoad:reader errmsg:NO]) {
        BinaryReader *br = [[BinaryReader alloc] initWithStream:[[MemoryStream alloc] init]];
        BinaryWriter *bw = [[BinaryWriter alloc] initWithStream:br.baseStream];
        
        [reader.baseStream seekToOffset:0x40 origin:SeekOriginBegin];
        NSData *remainingData = [reader readBytes:(NSInteger)(reader.baseStream.length - 0x40)];
        [bw writeBytes:[remainingData bytes] length:[remainingData length]];
        
        [self doLoad:br errmsg:YES];
    }
}

// MARK: - Loading Methods

- (BOOL)doLoad:(BinaryReader *)reader errmsg:(BOOL)errmsg {
    @try {
        // Get the stream length to know how much data to read
        int64_t streamLength = reader.baseStream.length;
        
        // Create a buffer to hold all the data
        NSMutableData *imageData = [NSMutableData dataWithLength:streamLength];
        
        // Read all bytes from the stream
        NSInteger bytesRead = [reader.baseStream readBytes:(uint8_t *)[imageData mutableBytes]
                                                 maxLength:streamLength];
        
        if (bytesRead > 0) {
            // Adjust data length if we read less than expected
            if (bytesRead < streamLength) {
                [imageData setLength:bytesRead];
            }
            
            self.image = [[NSImage alloc] initWithData:imageData];
            if (self.image != nil) {
                return YES;
            }
        }
    } @catch (NSException *exception) {
        // Fall through to TGA loading
    }
    
    @try {
        // Try loading as TGA
        self.image = [LoadTGAClass loadTGA:reader.baseStream];
        if (self.image != nil) {
            return YES;
        }
    } @catch (NSException *exception) {
        if (errmsg) {
            NSString *message = [Localization getString:@"errunsupportedimage"];
            [Helper exceptionMessage:message error:[NSError errorWithDomain:@"PictureWrapper"
                                                                        code:1
                                                                    userInfo:@{NSLocalizedDescriptionKey: exception.reason}]];
        }
    }
    
    return NO;
}

// MARK: - Class Methods

+ (NSImage *)setAlpha:(NSImage *)img {
    if (img == nil) return nil;
    
    NSSize size = img.size;
    NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                    pixelsWide:(NSInteger)size.width
                                                                    pixelsHigh:(NSInteger)size.height
                                                                 bitsPerSample:8
                                                               samplesPerPixel:4
                                                                      hasAlpha:YES
                                                                      isPlanar:NO
                                                                colorSpaceName:NSCalibratedRGBColorSpace
                                                                   bytesPerRow:0
                                                                  bitsPerPixel:32];
    
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bmp];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    
    [img drawInRect:NSMakeRect(0, 0, size.width, size.height)];
    
    [NSGraphicsContext restoreGraphicsState];
    
    // Apply alpha based on RGB brightness
    NSInteger width = (NSInteger)size.width;
    NSInteger height = (NSInteger)size.height;
    
    for (NSInteger y = 0; y < height; y++) {
        for (NSInteger x = 0; x < width; x++) {
            NSColor *pixel = [bmp colorAtX:x y:y];
            NSColor *rgbPixel = [pixel colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
            
            CGFloat r = rgbPixel.redComponent;
            CGFloat g = rgbPixel.greenComponent;
            CGFloat b = rgbPixel.blueComponent;
            
            NSInteger brightness = (NSInteger)((r + g + b) * 255.0 / 3.0);
            NSInteger alpha = 0xFF - brightness;
            if (alpha > 0x10) alpha = 0xFF;
            
            NSColor *newColor = [NSColor colorWithSRGBRed:r
                                                    green:g
                                                     blue:b
                                                    alpha:(CGFloat)alpha / 255.0];
            [bmp setColor:newColor atX:x y:y];
        }
    }
    
    NSImage *result = [[NSImage alloc] initWithSize:size];
    [result addRepresentation:bmp];
    
    return result;
}

// MARK: - IFileWrapper Protocol

- (NSArray<NSNumber *> *)assignableTypes {
    return @[
        @0x0C7E9A76, // jpeg
        @0x856DDBAC, // jpeg
        @0x424D505F, // bitmap
        @0x856DDBAC, // png
        @0x856DDBAC, // tga
        @0xAC2950C1, // thumbnail
        @0x4D533EDD,
        @0xAC2950C1,
        @0x2C30E040,
        @0x2C43CBD4,
        @0x2C488BCA,
        @0x8C31125E,
        @0x8C311262,
        @0xCC30CDF8,
        @0xCC44B5EC,
        @0xCC489E46,
        @0xCC48C51F,
        @0x8C3CE95A,
        @0xEC3126C4
    ];
}

- (NSData *)fileSignature {
    return [NSData data]; // Empty signature
}

@end
