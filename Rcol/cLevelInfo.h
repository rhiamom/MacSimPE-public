//
//  cLevelInfo.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/23/25.
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
#import "ImageLoader.h"

@class Rcol;
@class SGResource;
@class BinaryReader;
@class BinaryWriter;

/**
 * MipMap data type enumeration
 */
typedef NS_ENUM(NSUInteger, MipMapType) {
    MipMapTypeSimPEPlainData,
    MipMapTypeTexture,
    MipMapTypeLifoReference
};


 // This is the actual FileWrapper for Level Info
 // @remarks
 // The wrapper is used to (un)serialize the Data of a file into its Attributes. So Basically it reads
 // a BinaryStream and translates the data into some user-defined Attributes.

@interface LevelInfo : AbstractRcolBlock

// MARK: - Properties

/**
 * The texture size
 */
@property (nonatomic, readonly) NSSize textureSize;

/**
 * The Z level
 */
@property (nonatomic, assign) NSInteger zLevel;

/**
 * The image format
 */
@property (nonatomic, assign) TxtrFormats format;

/**
 * The texture image (lazy loaded)
 */
@property (nonatomic, readonly, strong) NSImage *texture;

/**
 * The raw data bytes
 */
@property (nonatomic, strong) NSData *data;

// MARK: - Initialization

/**
 * Constructor
 * @param parent The parent Rcol object
 */
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - Texture Management

/**
 * Sets the texture image
 * @param texture The NSImage to set
 */
- (void)setTexture:(NSImage *)texture;

@end
