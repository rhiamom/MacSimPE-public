//
//  FixGUID.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

@protocol IPackageFile;

NS_ASSUME_NONNULL_BEGIN

/**
 * Set of old and new Guid
 */
@interface GuidSet : NSObject

@property (nonatomic, assign) uint32_t oldGuid;
@property (nonatomic, assign) uint32_t guid;

@end

/**
 * This class can Fix the Integrity of cloned Objects
 */
@interface FixGuid : NSObject

/**
 * The Base Package
 */
@property (nonatomic, strong, readonly) id<IPackageFile> package;

/**
 * Creates a new Instance of this class
 * @param package The package you want to fix the Integrity in
 */
- (instancetype)initWithPackage:(id<IPackageFile>)package;

/**
 * Changes all guids (Depends on the passed Replacement Map)
 * @param guids List of GuidSet Objects
 */
- (void)fixGuids:(NSArray<GuidSet *> *)guids;

/**
 * Changes all guids (ignore the current GUID)
 * @param newGuid The new GUID
 */
- (void)fixGuid:(uint32_t)newGuid;

@end

NS_ASSUME_NONNULL_END
