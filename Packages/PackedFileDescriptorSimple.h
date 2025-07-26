//
//  PackedFileDescriptorSimple.h
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
#import "IPackedFileDescriptorSimple.h"

@interface PackedFileDescriptorSimple : NSObject <IPackedFileDescriptorSimple>

@property (nonatomic, assign) uint32_t type;
@property (nonatomic, assign) uint32_t group;
@property (nonatomic, assign) uint32_t instance;
@property (nonatomic, assign) uint32_t subType;
@property (nonatomic, readonly) TypeAlias *typeName;
@property (nonatomic, readonly) uint32_t offset;
@property (nonatomic, readonly) int32_t size;
@property (nonatomic, readonly) int32_t indexedSize;
@property (nonatomic, assign) uint64_t longInstance;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, readonly) NSString *exportFileName;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, readonly) BOOL hasUserdata;
@property (nonatomic, strong) NSData *userData;
@property (nonatomic, assign) BOOL markForDelete;
@property (nonatomic, assign) BOOL markForReCompress;
@property (nonatomic, readonly) BOOL wasCompressed;
@property (nonatomic, strong) id tag;
@property (nonatomic, readonly) BOOL invalid;
@property (nonatomic, readonly) NSString *exceptionString;

- (instancetype)init;
- (instancetype)initWithType:(uint32_t)type group:(uint32_t)grp instanceHi:(uint32_t)ihi instanceLo:(uint32_t)ilo;
- (NSString *)generateXmlMetaInfo;
- (BOOL)sameAs:(id)obj;
- (void)markInvalid;
- (void)beginUpdate;
- (void)endUpdate;

@end
