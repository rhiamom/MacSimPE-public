//
//  ErrorWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/17/25.
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
#import "IWrapper.h"
#import "IFileWrapper.h"
#import "IPackedFileWrapper.h"

@protocol IWrapperRegistry;
@protocol IWrapperInfo;
@protocol IPackedFileDescriptor;
@protocol IPackageFile;
@protocol IPackedFile;
@protocol IScenegraphFileIndexItem;
@protocol IPackedFileUI;
@class BinaryReader;
@class MemoryStream;

/**
 * This is A ResourceWrapper, which is added when an external Wrapper could not be loaded
 */
@interface ErrorWrapper : NSObject <IWrapper, IFileWrapper, IPackedFileWrapper>

// MARK: - Properties
@property (nonatomic, strong, readonly) NSString *filename;
@property (nonatomic, strong, readonly) NSException *exception;
@property (nonatomic, assign) NSInteger priority;

// MARK: - Initialization
- (instancetype)initWithFilename:(NSString *)filename exception:(NSException *)exception;

@end
