//
//  MmatWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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
#import "CpfWrapper.h"
#import "IScenegraphBlock.h"
#import "IScenegraphItem.h"

@class GenericRcol, CpfUI;
@protocol IPackedFileUI;

NS_ASSUME_NONNULL_BEGIN

/**
 * Preview execution callback type for MMAT
 */
typedef void (^ExecutePreviewBlock)(Cpf *cpf, id<IPackageFile> package);

/**
 * MMAT Wrapper - Material wrapper for mesh groups/subsets
 * Provides color options and material data for objects
 */
@interface MmatWrapper : Cpf <IScenegraphBlock, IScenegraphItem>

// MARK: - Class Properties

/**
 * Global CPF preview execution block
 */
@property (class, nonatomic, copy, nullable) ExecutePreviewBlock globalCpfPreview;

// MARK: - Material References

/**
 * Load and return the referenced CRES File (nil if none was available)
 * @remarks You should store this value in a temp var if you need it multiple times,
 * as the File is reloaded with each call
 */
@property (nonatomic, readonly, nullable) GenericRcol *cres;

/**
 * Load and return the referenced TXMT File (nil if none was available)
 * @remarks You should store this value in a temp var if you need it multiple times,
 * as the File is reloaded with each call
 */
@property (nonatomic, readonly, nullable) GenericRcol *txmt;

/**
 * Load and return the referenced TXTR File (through the TXMT, nil if none was available)
 * @remarks You should store this value in a temp var if you need it multiple times,
 * as the File is reloaded with each call
 */
@property (nonatomic, readonly, nullable) GenericRcol *txtr;

/**
 * Load and return the used GMDC File (through the CRES, nil if none was available)
 * @remarks You should store this value in a temp var if you need it multiple times,
 * as the File is reloaded with each call
 */
@property (nonatomic, readonly, nullable) GenericRcol *gmdc;

// MARK: - MMAT Properties

/**
 * Creator of the material
 */
@property (nonatomic, copy) NSString *creator;

/**
 * Whether this is the default material
 */
@property (nonatomic, assign) BOOL defaultMaterial;

/**
 * Material family
 */
@property (nonatomic, copy) NSString *family;

/**
 * Material flags
 */
@property (nonatomic, assign) uint32_t flags;

/**
 * Material state flags
 */
@property (nonatomic, assign) uint32_t materialStateFlags;

/**
 * Model name reference
 */
@property (nonatomic, copy) NSString *modelName;

/**
 * Material name
 */
@property (nonatomic, copy) NSString *name;

/**
 * Object GUID
 */
@property (nonatomic, assign) uint32_t objectGUID;

/**
 * Object state index
 */
@property (nonatomic, assign) int32_t objectStateIndex;

/**
 * Subset name
 */
@property (nonatomic, copy) NSString *subsetName;

// MARK: - Texture Loading

/**
 * Load a Texture belonging to a TXMT
 * @param txmt A valid TXMT wrapper
 * @returns The texture or nil
 */
- (nullable GenericRcol *)getTxtr:(GenericRcol *)txmt;

@end

NS_ASSUME_NONNULL_END
