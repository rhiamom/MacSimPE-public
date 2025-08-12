//
//  FileTablePaths.h
//  MacSimpe
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import <Foundation/Foundation.h>
#import "FileTableEnums.h"   // <- defines Expansions and FileTablePaths

NS_ASSUME_NONNULL_BEGIN

@class ExpansionItem;         // forward declare the class only; don't import here

@interface FileTableItemType : NSObject

@property (nonatomic, readonly) uint32_t val;
@property (nonatomic) Expansions expansion; // <-- use your real enum type name
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> *pathVars;

@property (nonatomic, readonly) BOOL isPathToken;
- (Expansions)asExpansions;     // only valid if !isPathToken
- (FileTableItemTypePaths)asFileTableItemTypePaths; // only valid if  isPathToken

// Pick ONE designated initializer to avoid “designated initializer” warnings.
// We'll use initWithUInt: as designated, mirroring the C# `uint` constructor.
- (instancetype)initWithUInt:(uint32_t)raw NS_DESIGNATED_INITIALIZER;

// Other convenience initializers funnel into the designated one:
- (instancetype)initWithRawValue:(uint32_t)raw NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithExpansion:(Expansions)expansion;
- (instancetype)initWithFileTablePath:(FileTablePaths)path;
- (instancetype)initWithInt:(int32_t)raw;
+ (NSString *)stringForType:(FileTableItemType *)type;
- (instancetype)init NS_UNAVAILABLE;
- (NSString *)fileTablePathLabel;
- (nullable NSString *)fileTablePathToken; // e.g. @"$(TS2_Downloads)"
// C# properties as methods:
- (FileTablePaths)asFileTablePaths;
- (uint32_t)asUint;

// C# methods:
- (nullable NSString *)getRoot;
- (NSInteger)getEpVersion;

// Your convenience method returning strings:
- (NSArray<NSString *> *)allPaths;

@end

NS_ASSUME_NONNULL_END
