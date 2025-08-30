//
//  CacheException.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/29/25.
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

NS_ASSUME_NONNULL_BEGIN

/**
 * A Cache Exception
 */
@interface CacheException : NSException

// MARK: - Properties

/**
 * The name of the cache file (can be nil)
 */
@property (nonatomic, readonly, copy, nullable) NSString *filename;

/**
 * The version of the cache file
 */
@property (nonatomic, readonly, assign) uint8_t version;

// MARK: - Initialization

/**
 * Create a new Instance of the Exception
 * @param message The Message
 * @param filename the Name of the Cache File (can be nil)
 * @param version the Version of the Cache File
 */
- (instancetype)initWithMessage:(NSString *)message
                       filename:(nullable NSString *)filename
                        version:(uint8_t)version;

/**
 * Convenience method to create and raise a CacheException
 * @param message The Message
 * @param filename the Name of the Cache File (can be nil)
 * @param version the Version of the Cache File
 */
+ (void)raiseWithMessage:(NSString *)message
                filename:(nullable NSString *)filename
                 version:(uint8_t)version;

@end

NS_ASSUME_NONNULL_END
