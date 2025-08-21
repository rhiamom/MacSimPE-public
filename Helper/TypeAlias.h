//
//  TypeAlias.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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


#import "Alias.h"

/**
 * Connects a Type Id Value with a name
 */
@interface TypeAlias : Alias

/**
 * True if the first 64 Byte of this Type are interpreted as Filename
 */
@property (nonatomic, assign) BOOL containsFilename;

/**
 * The associated short name
 */
@property (nonatomic, copy) NSString *shortName;

/**
 * Returns the default Extension
 */
@property (nonatomic, readonly, copy) NSString *fileExtension;

/**
 * Returns true if the Type is known
 */
@property (nonatomic, readonly, assign) BOOL known;

/**
 * Returns true, if this resource should be ignored during the cache build phase
 */
@property (nonatomic, readonly, assign) BOOL ignoreDuringCacheBuild;

/**
 * Constructor of the class
 * @param containsFilename True if first 64 bytes are filename
 * @param shortName The short name
 * @param val The id
 * @param name The name
 */
- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name;

/**
 * Constructor of the class
 * @param containsFilename True if first 64 bytes are filename
 * @param shortName The short name
 * @param val The id
 * @param name The name
 * @param extension Proposed File Extension
 */
- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name
                               extension:(NSString *)extension;

/**
 * Constructor of the class
 * @param containsFilename True if first 64 bytes are filename
 * @param shortName The short name
 * @param val The id
 * @param name The name
 * @param extension Proposed File Extension
 * @param known True if the filetype is known
 * @param noDecompForCache True if resource should not get decompressed during cache build/update
 */
- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name
                               extension:(NSString *)extension
                                   known:(BOOL)known
                           noDecompForCache:(BOOL)noDecompForCache;

/**
 * Constructor of the class
 * @param containsFilename True if first 64 bytes are filename
 * @param shortName The short name
 * @param val The id
 * @param name The name
 * @param known True if the filetype is known
 * @param noDecompForCache True if resource should not get decompressed during cache build/update
 */
- (instancetype)initWithContainsFilename:(BOOL)containsFilename
                               shortName:(NSString *)shortName
                                      typeID:(uint32_t)val
                                    name:(NSString *)name
                                   known:(BOOL)known
                           noDecompForCache:(BOOL)noDecompForCache;

@end
