//
//  ExtSRel.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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
#import "SRelWrapper.h"
#import "IFileWrapper.h"

@class ExtSDesc;
@class ExtSrelUI;
@class TypeAlias;
@protocol IWrapperInfo;
@protocol IPackedFileUI;

NS_ASSUME_NONNULL_BEGIN

/**
 * Extended Sim Relation Wrapper
 * Provides enhanced relationship editing with sim name lookup and composite images
 */
@interface ExtSRel : SRel <IMultiplePackedFileWrapper>

// MARK: - Instance Properties

/**
 * Target sim instance ID (lower 16 bits of file descriptor instance)
 */
@property (nonatomic, readonly, assign) uint32_t targetSimInstance;

/**
 * Source sim instance ID (upper 16 bits of file descriptor instance)
 */
@property (nonatomic, readonly, assign) uint32_t sourceSimInstance;

// MARK: - Sim Description Access

/**
 * Source sim description object
 */
@property (nonatomic, readonly, strong, nullable) ExtSDesc *sourceSim;

/**
 * Target sim description object
 */
@property (nonatomic, readonly, strong, nullable) ExtSDesc *targetSim;

// MARK: - Sim Names

/**
 * Full name of source sim (first + last name)
 */
@property (nonatomic, readonly, copy) NSString *sourceSimName;

/**
 * Full name of target sim (first + last name)
 */
@property (nonatomic, readonly, copy) NSString *targetSimName;

// MARK: - Image Composition

/**
 * Composite image showing both source and target sims
 */
@property (nonatomic, readonly, strong, nullable) NSImage *image;

// MARK: - Initialization

/**
 * Default initializer
 */
- (instancetype)init;

// MARK: - Sim Lookup

/**
 * Get sim description by instance ID
 * @param instance The sim instance ID to look up
 * @returns ExtSDesc object or nil if not found
 */
- (nullable ExtSDesc *)getDescriptionByInstance:(uint32_t)instance;

@end

NS_ASSUME_NONNULL_END
