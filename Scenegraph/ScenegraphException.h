//
//  ScenegraphException.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/18/25.
//
//
//  ScenegraphException.h
//  MacSimpe
//
//  Created by Translation Tool on 9/18/25.
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

// Forward declarations
@protocol IScenegraphFileIndexItem, IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

// MARK: - CorruptedFileException

/**
 * SimPE was unable to load a File
 */
@interface CorruptedFileException : NSException

// MARK: - Initialization

/**
 * Create a corrupted file exception for a specific file item
 * @param item The corrupted file index item
 * @param inner The underlying exception that caused the corruption
 */
- (instancetype)initWithFileIndexItem:(id<IScenegraphFileIndexItem>)item
                       innerException:(nullable NSException *)inner;

// MARK: - Utility Methods

/**
 * Get the filename from a file index item
 * @param item The file index item
 * @returns The filename or empty string if unavailable
 */
+ (NSString *)getFileName:(nullable id<IScenegraphFileIndexItem>)item;

@end

// MARK: - ScenegraphException

/**
 * An Error occurred during the attempt of walking the Scenegraph
 */
@interface ScenegraphException : NSException

// MARK: - Properties

/**
 * The packed file descriptor associated with this exception
 */
@property (nonatomic, strong, readonly, nullable) id<IPackedFileDescriptor> packedFileDescriptor;

// MARK: - Initialization

/**
 * Create a scenegraph exception with message and file descriptor
 * @param message The error message
 * @param pfd The packed file descriptor where the error occurred
 */
- (instancetype)initWithMessage:(NSString *)message
           packedFileDescriptor:(nullable id<IPackedFileDescriptor>)pfd;

/**
 * Create a scenegraph exception with message, inner exception and file descriptor
 * @param message The error message
 * @param inner The underlying exception
 * @param pfd The packed file descriptor where the error occurred
 */
- (instancetype)initWithMessage:(NSString *)message
                 innerException:(NSException *)inner
           packedFileDescriptor:(nullable id<IPackedFileDescriptor>)pfd;

// MARK: - Message Override

/**
 * Returns the formatted error message including file descriptor information
 */
@property (nonatomic, readonly, copy) NSString *enhancedReason;

@end

NS_ASSUME_NONNULL_END
