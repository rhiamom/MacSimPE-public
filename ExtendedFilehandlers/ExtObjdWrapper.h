//
//  ExtObjdWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/9/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "IMultiplePackedFileWrapper.h"
#import "ObjectTypes.h"
#import "ObjFunctionSubSort.h"

@class BinaryReader, BinaryWriter, ObjdPropertyParser;
@class ObjRoomSort, ObjFunctionSort;

NS_ASSUME_NONNULL_BEGIN

// MARK: - Enums

/**
 * Shelve dimension enumeration
 */
typedef NS_ENUM(uint32_t, ShelveDimension) {
    ShelveDimensionBig = 0x0,
    ShelveDimensionMedium = 0x1,
    ShelveDimensionSmall = 0x2,
    ShelveDimensionUnknown2 = 0x64,
    ShelveDimensionUnknown1 = 0x96,
    ShelveDimensionMultitile = 0xffff00fe,
    ShelveDimensionIndetermined = 0xffff00ff
};

/**
 * OBJD file health status
 */
typedef NS_ENUM(uint8_t, ObjdHealth) {
    ObjdHealthOk = 0,
    ObjdHealthUnreadable = 1,
    ObjdHealthUnmatchingFilenames = 2,
    ObjdHealthOverLength = 3
};

// MARK: - ExtObjd Class

/**
 * Represents a PackedFile in Extended OBJD Format
 */
@interface ExtObjd : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension, IMultiplePackedFileWrapper>

// MARK: - Properties

/**
 * Returns/Sets the Name of a File
 */
@property (nonatomic, copy) NSString *fileName;

/**
 * Returns/Sets the stored Data
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *data;

/**
 * Returns the GUID of the Object
 */
@property (nonatomic, assign) uint32_t guid;

/**
 * Returns the GUID of the Proxy Object
 */
@property (nonatomic, assign) uint32_t proxyGuid;

/**
 * Returns the GUID of the Original Object
 */
@property (nonatomic, assign) uint32_t originalGuid;

/**
 * Returns the GUID of the Diagonal Object
 */
@property (nonatomic, assign) uint32_t diagonalGuid;

/**
 * Returns the GUID of the Grid Aligned Object
 */
@property (nonatomic, assign) uint32_t gridAlignedGuid;

/**
 * Returns the dimension of an Object on the Shelve
 */
@property (nonatomic, assign) ShelveDimension shelveDimension;

/**
 * Returns the Instance of the assigned Catalog Description
 */
@property (nonatomic, assign) uint16_t ctssInstance;

/**
 * Returns/Sets the Type of an Object
 */
@property (nonatomic, assign) ObjectTypes type;

/**
 * Returns the Room Sort Flags
 */
@property (nonatomic, strong) ObjRoomSort *roomSort;

/**
 * Returns the Function Sort Flags
 */
@property (nonatomic, strong) ObjFunctionSort *functionSort;

/**
 * Returns/Sets the Function Sub Sort
 */
@property (nonatomic, assign) ObjFunctionSubSort functionSubSort;

/**
 * Returns/Sets the Price
 */
@property (nonatomic, assign) int16_t price;

/**
 * Returns the Health Status of the OBJD
 */
@property (nonatomic, readonly, assign) ObjdHealth ok;

// MARK: - Class Properties

/**
 * Return a PropertyParser, that enumerates all known Properties
 */
@property (class, nonatomic, readonly, strong) ObjdPropertyParser *propertyParser;

// MARK: - Initialization

/**
 * Standard constructor
 */
- (instancetype)init;

// MARK: - Methods

/**
 * Update the room and function sort flags from data array
 */
- (void)updateFlags;

@end

// MARK: - ObjRoomSort Class

/**
 * Room sorting flags for OBJD
 */
@interface ObjRoomSort : NSObject

// MARK: - Properties

/**
 * The raw flag value
 */
@property (nonatomic, assign) uint16_t value;

/**
 * Room type flags
 */
@property (nonatomic, assign) BOOL inBathroom;
@property (nonatomic, assign) BOOL inBedroom;
@property (nonatomic, assign) BOOL inDiningRoom;
@property (nonatomic, assign) BOOL inKitchen;
@property (nonatomic, assign) BOOL inLivingRoom;
@property (nonatomic, assign) BOOL inMisc;
@property (nonatomic, assign) BOOL inOutside;
@property (nonatomic, assign) BOOL inStudy;
@property (nonatomic, assign) BOOL inKids;

// MARK: - Initialization

/**
 * Initialize with flags value
 * @param flags The room sort flags
 */
- (instancetype)initWithFlags:(int16_t)flags;

/**
 * Initialize with object
 * @param object The object containing flags
 */
- (instancetype)initWithObject:(id)object;

@end

// MARK: - ObjFunctionSort Class

/**
 * Function sorting flags for OBJD
 */
@interface ObjFunctionSort : NSObject

// MARK: - Properties

/**
 * The raw flag value
 */
@property (nonatomic, assign) uint16_t value;

/**
 * Function type flags
 */
@property (nonatomic, assign) BOOL inAppliances;
@property (nonatomic, assign) BOOL inDecorative;
@property (nonatomic, assign) BOOL inElectronics;
@property (nonatomic, assign) BOOL inGeneral;
@property (nonatomic, assign) BOOL inLighting;
@property (nonatomic, assign) BOOL inPlumbing;
@property (nonatomic, assign) BOOL inSeating;
@property (nonatomic, assign) BOOL inSurfaces;
@property (nonatomic, assign) BOOL inHobbies;
@property (nonatomic, assign) BOOL inAspirationRewards;
@property (nonatomic, assign) BOOL inCareerRewards;

// MARK: - Initialization

/**
 * Initialize with flags value
 * @param flags The function sort flags
 */
- (instancetype)initWithFlags:(int16_t)flags;

/**
 * Initialize with object
 * @param object The object containing flags
 */
- (instancetype)initWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
