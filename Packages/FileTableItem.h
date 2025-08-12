//
//  FileTableItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/6/25.
//
//***************************************************************************
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
#import "FileTable.h"
#import "FileTableItemType.h"

/**
 * The type and location of a Folder/file
 */
@interface FileTableItem : NSObject

// MARK: - Properties

@property (nonatomic, assign) BOOL ignore;
@property (nonatomic, assign) BOOL isRecursive;
@property (nonatomic, assign) BOOL isFile;
@property (nonatomic, assign) NSInteger epVersion;
@property (nonatomic, strong) FileTableItemType *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) NSString *relativePath;


// MARK: - Computed Properties

@property (nonatomic, readonly) BOOL use;
@property (nonatomic, readonly) BOOL isUseable;
@property (nonatomic, readonly) BOOL isAvail;
@property (nonatomic, readonly) BOOL exists;

// MARK: - Initialization

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path recursive:(BOOL)recursive file:(BOOL)file;
- (instancetype)initWithPath:(NSString *)path recursive:(BOOL)recursive file:(BOOL)file version:(NSInteger)version;
- (instancetype)initWithPath:(NSString *)path recursive:(BOOL)recursive file:(BOOL)file version:(NSInteger)version ignore:(BOOL)ignore;
- (instancetype)initWithRelativePath:(NSString *)relativePath
                                type:(FileTableItemType *)type
                           recursive:(BOOL)recursive
                                file:(BOOL)file
                             version:(NSInteger)version
                              ignore:(BOOL)ignore;

// MARK: - Static Methods

+ (NSString *)getRootForType:(FileTableItemType *)type;
+ (NSInteger)getEPVersionForType:(FileTableItemType *)type;

// MARK: - Instance Methods

- (NSArray<NSString *> *)getFiles;
- (void)setRecursive:(BOOL)state;
- (void)setFile:(BOOL)state;

@end
