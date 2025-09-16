//
//  NrefWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/15/25.
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

#import "NrefWrapper.h"
#import "Helper.h"
#import "Hashes.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "AbstractWrapperInfo.h"

@interface NrefWrapper ()

@property (nonatomic, strong) NSData *data;

@end

@implementation NrefWrapper

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.data = [NSData data];
    }
    return self;
}

// MARK: - Properties

- (NSString *)fileName {
    return [Helper dataToString:self.data];
}

- (void)setFileName:(NSString *)fileName {
    self.data = [Helper stringToBytes:fileName];
}

- (uint32_t)group {
    return [Hashes groupHash:self.fileName];
}

// MARK: - AbstractWrapper Methods

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Name Reference Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:3];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Implement NrefUI
    // return [[NrefUI alloc] init];
    return nil;
}

- (void)unserialize:(BinaryReader *)reader {
    NSInteger length = (NSInteger)reader.baseStream.length;
    self.data = [reader readBytes:length];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeData:self.data];
}

// MARK: - IWrapper Properties

- (NSString *)description {
    return [NSString stringWithFormat:@"Name=%@, Group=0x%@",
            self.fileName,
            [Helper hexString:self.group]];
}

// MARK: - IFileWrapper Protocol

- (NSData *)fileSignature {
    return [NSData data]; // Empty signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@(0x4E524546)]; // NREF type
}

// MARK: - IMultiplePackedFileWrapper Protocol

- (NSArray *)getConstructorArguments {
    return @[]; // No constructor arguments needed
}

@end
