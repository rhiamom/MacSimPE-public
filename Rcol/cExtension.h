//
//  cExtension.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/18/25.
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
#import <Cocoa/Cocoa.h>
#import "AbstractRcolBlock.h"

// Forward declarations
@class Vector3f, Quaternion, BinaryReader, BinaryWriter, Rcol;

// MARK: - ExtensionItem

/**
 * Known Types for Extension Items
 */
typedef NS_ENUM(uint8_t, ItemTypes) {
    ItemTypesValue = 0x02,
    ItemTypesFloat = 0x03,
    ItemTypesTranslation = 0x05,
    ItemTypesString = 0x06,
    ItemTypesArray = 0x07,
    ItemTypesRotation = 0x08,
    ItemTypesBinary = 0x09
};

/**
 * Individual Extension Item
 */
@interface ExtensionItem : NSObject

// MARK: - Properties

/**
 * The type code for this item
 */
@property (nonatomic, assign) ItemTypes typecode;

/**
 * The variable name
 */
@property (nonatomic, copy) NSString *name;

/**
 * Integer value (for Value type)
 */
@property (nonatomic, assign) int32_t value;

/**
 * Float value (for Float type)
 */
@property (nonatomic, assign) float single;

/**
 * Translation vector (for Translation type)
 */
@property (nonatomic, strong) Vector3f *translation;

/**
 * String value (for String type)
 */
@property (nonatomic, copy) NSString *string;

/**
 * Array of sub-items (for Array type)
 */
@property (nonatomic, strong) NSMutableArray<ExtensionItem *> *items;

/**
 * Rotation quaternion (for Rotation type)
 */
@property (nonatomic, strong) Quaternion *rotation;

/**
 * Binary data (for Binary type)
 */
@property (nonatomic, strong) NSData *data;

// MARK: - Initialization

/**
 * Initialize a new ExtensionItem
 */
- (instancetype)init;

// MARK: - Serialization

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @remarks Be sure that the Position of the stream is Proper on
 *          return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - String Representation

/**
 * String representation of the item
 */
- (NSString *)description;

@end

// MARK: - Extension

/**
 * This is the actual FileWrapper
 * @remarks The wrapper is used to (un)serialize the Data of a file into it's Attributes.
 *          So Basically it reads a BinaryStream and translates the data into some userdefine Attributes.
 */
@interface Extension : AbstractRcolBlock

// MARK: - Properties

/**
 * The type code
 */
@property (nonatomic, assign) uint8_t typeCode;

/**
 * The variable name
 */
@property (nonatomic, copy) NSString *varName;

/**
 * Array of extension items
 */
@property (nonatomic, strong) NSMutableArray<ExtensionItem *> *items;

// MARK: - Initialization

/**
 * Constructor
 * @param parent The parent Rcol object
 */
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - IRcolBlock Protocol Methods

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 * @param ver Version parameter
 */
- (void)unserialize:(BinaryReader *)reader version:(uint32_t)ver;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @remarks Be sure that the Position of the stream is Proper on
 *          return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @param ver Version parameter
 * @remarks Be sure that the Position of the stream is Proper on
 *          return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer version:(uint32_t)ver;

/**
 * You can use this to setup the Controls on a TabPage before it is displayed
 */
- (void)initTabPage;

/**
 * Register the extension in a listing
 * @param listing The listing dictionary (can be nil)
 * @returns The extension name
 */
- (NSString *)registerInListing:(NSMutableDictionary *)listing;

/**
 * Add extension to tab control
 * @param tabView The tab view to add to
 */
- (void)addToTabControl:(NSTabView *)tabView;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end
