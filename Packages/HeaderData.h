//
//  HeaderData.h
//  SimPE for Mac
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
#import "IPackageHeader.h"

// Forward declarations
@class BinaryReader;
@class BinaryWriter;
@class HeaderIndex;
@class HeaderHole;
@protocol IPackageHeader;
@protocol IPackageHeaderIndex;
@protocol IPackageHeaderHoleIndex;

NS_ASSUME_NONNULL_BEGIN

/// Structural Data of a .package Header
@interface HeaderData : NSObject <IPackageHeader>

// MARK: - Properties
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) int32_t majorVersion;
@property (nonatomic, readonly) int32_t minorVersion;
@property (nonatomic, readonly) int64_t version;
@property (nonatomic, assign) uint32_t created;
@property (nonatomic, readonly) int32_t modified;
@property (nonatomic, readwrite, strong) id<IPackageHeaderIndex> index;
@property (nonatomic, readonly) id<IPackageHeaderHoleIndex> holeIndex;
@property (nonatomic, assign) IndexTypes indexType;
@property (nonatomic, readonly) BOOL isVersion0101;


// MARK: - Internal Properties (for File.m access)
@property (nonatomic, readonly) HeaderIndex *headerIndex;  // Direct access to HeaderIndex
@property (nonatomic, readonly) id<IPackageHeaderHoleIndex> hole;          // Direct access to HeaderHole

// MARK: - Initialization
- (instancetype)init;

// MARK: - File Processing Methods
- (void)loadFromReader:(BinaryReader *)reader;
- (void)saveToWriter:(BinaryWriter *)writer;

// MARK: - Cloning
- (id)clone;

@end

NS_ASSUME_NONNULL_END
