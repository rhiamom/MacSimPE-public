//
//  XmlWrapper.h
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

#import <Foundation/Foundation.h>
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"

@class BinaryReader, BinaryWriter;
@protocol IPackedFileUI;

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a PackedFile in XML Format
 */
@interface Xml : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * The XML text content
 */
@property (nonatomic, copy) NSString *text;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - File Type Support

/**
 * Returns a list of File Types this Plugin can process
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

/**
 * Returns the File Signature
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

- (NSInteger)serializeReturningLength:(BinaryWriter *)writer;

@end

NS_ASSUME_NONNULL_END
