//
//  IScenegraphFileIndexItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/31/25.
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

@protocol IPackedFileDescriptor;
@protocol IPackageFile;

/**
 * An Item in the FileIndex
 */
@protocol IScenegraphFileIndexItem <NSObject>

/**
 * The Descriptor of that File
 * @remarks Contains the original Group
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * The package the File is stored in
 */
@property (nonatomic, readonly) id<IPackageFile> package;

/**
 * Get the Local Group value used for this Package
 */
@property (nonatomic, readonly) uint32_t localGroup;

/**
 * The Descriptor of that File, with a real Group value
 * @returns A Clone FileDescriptor, that contains the correct Group
 * @remarks Contains the local Group (can never be 0xffffffff)
 */
- (id<IPackedFileDescriptor>)getLocalFileDescriptor;

@end
