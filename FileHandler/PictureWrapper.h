//
//  PictureWrapper.h
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
#import "AbstractWrapper.h"
#import "IFileWrapper.h"

@class BinaryReader;
@protocol IPackedFileUI;

/**
 * Represents a PackedFile in JPEG Format
 */
@interface PictureWrapper : AbstractWrapper <IFileWrapper>

// MARK: - Properties

/**
 * Returns the Stored Image
 */
@property (nonatomic, readonly, strong) NSImage *image;

// MARK: - Class Methods

/**
 * Creates an alpha channel based on RGB brightness
 * @param img The source image
 * @return A new image with alpha channel applied
 */
+ (NSImage *)setAlpha:(NSImage *)img;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Loading Methods

/**
 * Load image data from a BinaryReader
 * @param reader The data to process
 * @param errmsg Whether to show error messages
 * @return YES if loading was successful
 */
- (BOOL)doLoad:(BinaryReader *)reader errmsg:(BOOL)errmsg;

// MARK: - IFileWrapper Protocol

/**
 * Returns a list of File Types this Plugin can process
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

/**
 * Returns the Signature that can be used to identify Files processable with this Plugin
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

@end
