//
//  BuildTxtr.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
//
//****************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2008 by Peter L Jones                                    *
// *   pljones@users.sf.net                                                  *
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
//****************************************************************************

#import "BuildTxtr.h"
#import "cImageData.h"
#import "cLevelInfo.h"
#import "GenericRcolWrapper.h"
#import "PackedFileDescriptor.h"
#import "PathProvider.h"
#import "Soil2.h"
#import "ArgParser.h"
#import "ExceptionForm.h"
#import "FileStream.h"
#import "BinaryWriter.h"

@implementation BuildTxtr

// MARK: - ICommandLine Protocol Implementation

- (NSString *)commandName {
    return @"BuildTxtr";
}

- (void)execute {
    // This method could be implemented if needed for direct execution
    NSLog(@"BuildTxtr command executed - use parse: method with arguments");
}

// MARK: - Static TXTR Building Methods

+ (void)loadTxtr:(ImageData *)imageData
        filename:(NSString *)filename
            size:(NSSize)size
          levels:(NSInteger)levels
          format:(TxtrFormats)format {
    @try {
        NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:filename];
        if (sourceImage) {
            [self loadTxtr:imageData image:sourceImage size:size levels:levels format:format];
        }
    }
    @catch (NSException *ex) {
        // Equivalent to Helper.ExceptionMessage("", ex);
        NSLog(@"Exception in loadTxtr:filename: %@", ex.reason);
    }
}

+ (void)loadTxtr:(ImageData *)imageData
           image:(NSImage *)sourceImage
            size:(NSSize)size
          levels:(NSInteger)levels
          format:(TxtrFormats)format {
    @try {
        imageData.textureSize = size;
        imageData.format = format;
        imageData.mipMapLevels = (uint32_t)levels;

        // Create target image with specified size
        NSImage *targetImage = [[NSImage alloc] initWithSize:size];
        [targetImage lockFocus];
        
        // Set high quality rendering
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [[NSGraphicsContext currentContext] setShouldAntialias:YES];
        
        // Draw source image scaled to target size
        [sourceImage drawInRect:NSMakeRect(0, 0, size.width, size.height)
                       fromRect:NSMakeRect(0, 0, sourceImage.size.width, sourceImage.size.height)
                      operation:NSCompositingOperationSourceOver
                       fraction:1.0];
        
        [targetImage unlockFocus];

        NSMutableArray<MipMap *> *maps = [[NSMutableArray alloc] initWithCapacity:levels];
        NSInteger width = 1;
        NSInteger height = 1;

        // Build default sizes
        for (NSInteger i = 0; i < levels; i++) {
            MipMap *mipMap = [[MipMap alloc] initWithParent:imageData];
            mipMap.texture = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];

            if ((width == height) && (width == 1)) {
                if (imageData.textureSize.width > imageData.textureSize.height) {
                    width = (NSInteger)(imageData.textureSize.width / imageData.textureSize.height);
                    height = 1;
                } else {
                    height = (NSInteger)(imageData.textureSize.height / imageData.textureSize.width);
                    width = 1;
                }

                if ((width == height) && (width == 1)) {
                    width *= 2;
                    height *= 2;
                }
            } else {
                width *= 2;
                height *= 2;
            }

            [maps addObject:mipMap];
        }

        // Create a scaled version for each texture
        for (NSInteger i = 0; i < maps.count; i++) {
            MipMap *mipMap = maps[i];
            if (targetImage != nil) {
                NSImage *mipTexture = mipMap.texture;
                [mipTexture lockFocus];
                
                [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
                [[NSGraphicsContext currentContext] setShouldAntialias:YES];
                
                [targetImage drawInRect:NSMakeRect(0, 0, mipTexture.size.width, mipTexture.size.height)
                               fromRect:NSMakeRect(0, 0, targetImage.size.width, targetImage.size.height)
                              operation:NSCompositingOperationSourceOver
                               fraction:1.0];
                
                [mipTexture unlockFocus];
                
                imageData.textureSize = mipTexture.size;
            }
        }

        NSMutableArray<MipMapBlock *> *mipMapBlocks = [[NSMutableArray alloc] initWithCapacity:1];
        MipMapBlock *block = [[MipMapBlock alloc] initWithParent:imageData];
        block.mipMaps = [maps copy];
        [mipMapBlocks addObject:block];

        imageData.mipMapBlocks = [mipMapBlocks copy];
    }
    @catch (NSException *ex) {
        NSLog(@"Exception in loadTxtr:image: %@", ex.reason);
    }
}

+ (void)loadDds:(ImageData *)imageData data:(NSArray<DDSData *> *)data {
    if (data == nil || data.count == 0) {
        return;
    }
    
    @try {
        DDSData *firstData = data.firstObject;
        imageData.textureSize = firstData.parentSize;
        imageData.format = firstData.format;
        imageData.mipMapLevels = (uint32_t)data.count;

        NSMutableArray<MipMap *> *maps = [[NSMutableArray alloc] initWithCapacity:data.count];
        NSInteger count = 0;
        
        // Process in reverse order (like the C# version)
        for (NSInteger i = data.count - 1; i >= 0; i--) {
            DDSData *item = data[i];
            MipMap *mipMap = [[MipMap alloc] initWithParent:imageData];
            mipMap.texture = item.texture;
            mipMap.data = item.data;
            
            [maps addObject:mipMap];
            count++;
        }

        NSMutableArray<MipMapBlock *> *mipMapBlocks = [[NSMutableArray alloc] initWithCapacity:1];
        MipMapBlock *block = [[MipMapBlock alloc] initWithParent:imageData];
        block.mipMaps = [maps copy];
        [mipMapBlocks addObject:block];

        imageData.mipMapBlocks = [mipMapBlocks copy];
    }
    @catch (NSException *ex) {
        NSLog(@"Exception in loadDds: %@", ex.reason);
    }
}

// MARK: - Command Line Parsing

- (BOOL)parse:(NSArray<NSString *> *)argv {
    NSMutableArray<NSString *> *mutableArgv = [argv mutableCopy];
    NSInteger index = [ArgParser parseArguments:mutableArgv parameter:@"-txtr"];
    if (index < 0) {
        return NO;
    }

    // Get parameters
    NSString *filename = @"";
    NSString *output = @"";
    NSString *textureName = @"";
    NSString *numberString = @"";
    NSInteger levels = 9;
    NSSize size = NSMakeSize(512, 512);
    TxtrFormats format = TxtrFormatsDXT1Format;
    
    while (mutableArgv.count > index) {
        NSString *result = nil;
        
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-image" result:&result]) {
            filename = result;
            continue;
        }
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-out" result:&result]) {
            output = result;
            continue;
        }
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-name" result:&result]) {
            textureName = result;
            continue;
        }
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-levels" result:&result]) {
            levels = [result integerValue];
            continue;
        }
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-width" result:&result]) {
            size.width = [result doubleValue];
            continue;
        }
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-height" result:&result]) {
            size.height = [result doubleValue];
            continue;
        }
        if ([ArgParser parseArguments:mutableArgv atIndex:index parameter:@"-format" result:&result]) {
            if ([result isEqualToString:@"dxt1"]) {
                format = TxtrFormatsDXT1Format;
            } else if ([result isEqualToString:@"dxt3"]) {
                format = TxtrFormatsDXT3Format;
            } else if ([result isEqualToString:@"dxt5"]) {
                format = TxtrFormatsDXT5Format;
            } else if ([result isEqualToString:@"raw24"]) {
                format = TxtrFormatsRaw24Bit;
            } else if ([result isEqualToString:@"raw32"]) {
                format = TxtrFormatsRaw32Bit;
            } else if ([result isEqualToString:@"raw8"]) {
                format = TxtrFormatsRaw8Bit;
            }
            continue;
        }
        
        // If we get here, show help and return
        [ExceptionForm showError:[self help].firstObject];
        return YES;
    }

    // Check if the file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        [ExceptionForm showError:[NSString stringWithFormat:@"%@ was not found.", filename]];
        return YES;
    }
    if ([output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [ExceptionForm showError:@"Please specify an output file using -out"];
        return YES;
    }

    // Build TXTR File
    ImageData *imageData = [[ImageData alloc] initWithParent:nil];

    // For DXT formats, try advanced processing first, then fallback to basic method
    if (format == TxtrFormatsDXT1Format || format == TxtrFormatsDXT3Format || format == TxtrFormatsDXT5Format) {
        // Try to parse existing DDS file using CSOIL 2
        NSArray<DDSData *> *ddsData = [ImageLoader parseDDS:filename];
        if (ddsData && ddsData.count > 0) {
            // Successfully parsed as DDS file
            [self.class loadDds:imageData data:ddsData];
        } else {
            // Fallback: Input file is not DDS format, process as regular image
            [self.class loadTxtr:imageData filename:filename size:size levels:levels format:format];
        }
    } else {
        // For non-DXT formats, always use the regular texture processing
        [self.class loadTxtr:imageData filename:filename size:size levels:levels format:format];
    }

    GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
    rcol.fileName = textureName;
    rcol.fileDescriptor = [[PackedFileDescriptor alloc] init];
    NSMutableArray *blocks = [[NSMutableArray alloc] initWithCapacity:1];
    [blocks addObject:imageData];
    rcol.blocks = [blocks copy];

    [rcol synchronizeUserData];
    
    FileStream *fileStream = [[FileStream alloc] initWithPath:output access:FileAccessWrite];
    BinaryWriter *binaryWriter = [[BinaryWriter alloc] initWithFileStream:fileStream];
    [binaryWriter writeData:rcol.fileDescriptor.userData];
    [binaryWriter close];
    [fileStream close];

    return YES;

}
- (NSArray<NSString *> *)help {
    NSString *helpText = @"-txtr -image [imgfile] -out [output].package -name [textureName] -format [dxt1|dxt3|dxt5|raw8|raw24|raw32] -levels [nr] -width [max. Width] -height [max. Height]";
    return @[helpText];
}

@end
