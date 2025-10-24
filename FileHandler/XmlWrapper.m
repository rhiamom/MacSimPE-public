//
//  XmlWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/7/25.
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

#import "XmlWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "AbstractWrapperInfo.h"
#import "IPackedFileUI.h"
#import "MemoryStream.h"

@implementation Xml

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.text = @"";
    }
    return self;
}

// MARK: - AbstractWrapper Implementation

- (void)unserialize:(BinaryReader *)reader {
    // Calculate remaining bytes in the stream
    Stream *stream = [reader baseStream];
    NSInteger remainingLength = [stream length] - [stream position];
    
    if (remainingLength > 0) {
        // Read all remaining bytes
        NSData *data = [reader readBytes:remainingLength];
        
        // Convert to string with UTF-8 encoding
        self.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // If UTF-8 fails, try ASCII as fallback
        if (self.text == nil) {
            self.text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        }
    }
    
    // If still nil, provide empty string
    if (self.text == nil) {
        self.text = @"";
    }
}

- (void)serialize:(BinaryWriter *)writer {
    NSData *data = [self.text dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        data = [self.text dataUsingEncoding:NSASCIIStringEncoding];
    }
    if (data != nil) {
        [writer writeData:data];
    }
}

// Optional helper — matches C# logic using BinaryWriter.position
- (NSInteger)serializeReturningLength:(BinaryWriter *)writer {
    NSInteger start = writer.position;
    [self serialize:writer]; // reuse the conforming method
    return writer.position - start;
}

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Default XML Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:1];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Implement XML UI handler when needed
    // return [[XmlUI alloc] init];
    return nil;
}

// MARK: - IFileWrapper Implementation

- (NSArray<NSNumber *> *)assignableTypes {
    static NSArray<NSNumber *> *types = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = @[
            @(0x00000000), // UI Data
            @(0xCD7FE87A), // Material Shaders
            @(0x7181C501)  // Pet Unknown
        ];
    });
    return types;
}

- (NSData *)fileSignature {
    static NSData *signature = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // XML signature: "<?xml"
        uint8_t bytes[] = {'<', '?', 'x', 'm', 'l'};
        signature = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    });
    return signature;
}

- (BOOL)canHandleType:(uint32_t)type {
    NSArray<NSNumber *> *types = [self assignableTypes];
    return [types containsObject:@(type)];
}

@end
