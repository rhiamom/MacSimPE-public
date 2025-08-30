//
//  SlotWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/29/25.
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
#import "SlotItem.h"

@class BinaryReader, BinaryWriter, SlotItems;
@protocol IPackedFileUI, IWrapperInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * Used to decode the Slot files
 */
@interface Slot : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * Returns the Items stored in the File
 * @remarks Do not add Items based on this List! use the Add Method!!
 */
@property (nonatomic, readonly, strong) SlotItems *items;

/**
 * The filename stored in the slot file
 */
@property (nonatomic, copy) NSString *filename;

/**
 * The version of the slot file format
 */
@property (nonatomic, assign) uint32_t version;

/**
 * Unknown value stored in the slot file
 */
@property (nonatomic, assign) uint32_t unknown;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - IFileWrapper Protocol Methods

/**
 * Returns the Signature that can be used to identify Files processable with this Plugin
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

/**
 * Returns a list of File Types this Plugin can process
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

@end

NS_ASSUME_NONNULL_END
