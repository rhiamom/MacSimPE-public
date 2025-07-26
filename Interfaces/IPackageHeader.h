//
//  IPackageHeader.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>
#import "MetaData.h"
#import "IPackageHeaderHole.h"

@protocol IPackageHeaderIndex;
@protocol IPackageHeaderHoleIndex;

/**
 * Structural Data of a .package Header
 */
@protocol IPackageHeader <NSObject>

/**
 * Create a Clone of the Header
 */
- (id)clone;

/**
 * Returns the Identifier of the File
 * @remarks This value should be DBPF
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 * Returns the Major Version of The Packages FileFormat
 * @remarks This value should be 1
 */
@property (nonatomic, readonly) int32_t majorVersion;

/**
 * Returns the Minor Version of The Packages FileFormat
 * @remarks This value should be 0 or 1
 */
@property (nonatomic, readonly) int32_t minorVersion;

/**
 * Returns the Overall Version of this Package
 */
@property (nonatomic, readonly) int64_t version;

/**
 * Returns or Sets the Type of the Package
 */
@property (nonatomic, assign) IndexTypes indexType;

/**
 * true if the version is greater or equal than 1.1
 */
@property (nonatomic, readonly) BOOL isVersion0101;

/**
 * Returns Index Informations stored in the Header
 */
@property (nonatomic, readonly) id<IPackageHeaderIndex> index;

/**
 * Returns Hole Index Informations stored in the Header
 */
@property (nonatomic, readonly) id<IPackageHeaderHoleIndex> holeIndex;

/**
 * This is misused in SimPE as a Unique Creator ID
 */
@property (nonatomic, assign) uint32_t created;

 //Returns Hole Index Informations stored in the Header (C# compatibility)
 
@property (nonatomic, readonly) id<IPackageHeaderHoleIndex> hole;

@end

