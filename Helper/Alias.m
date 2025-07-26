//
//  Alias.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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
#import "IAlias.h"

/**
 * Connects a value with a name
 */
@interface StaticAlias : NSObject <IAlias>

/**
 * Stores arbitrary Data
 */
@property (nonatomic, strong) NSArray *tag;

/**
 * The id Value
 */
@property (nonatomic, readonly) uint32_t id;

/**
 * The long Name
 */
@property (nonatomic, copy) NSString *name;

/**
 * Constructor of the class
 * @param val The id
 * @param name The name
 */
- (instancetype)initWithId:(uint32_t)val name:(NSString *)name;

/**
 * Constructor of the class
 * @param val The id
 * @param name The name
 * @param tag Arbitrary data array
 */
- (instancetype)initWithId:(uint32_t)val name:(NSString *)name tag:(NSArray *)tag;

@end

/**
 * Connects a value with a name (with formatting template support)
 */
@interface Alias : StaticAlias

/**
 * Constructor of the class
 * @param val The id
 * @param name The name
 */
- (instancetype)initWithId:(uint32_t)val name:(NSString *)name;

/**
 * Constructor of the class
 * @param val The id
 * @param name The name
 * @param tag Arbitrary data array
 */
- (instancetype)initWithId:(uint32_t)val name:(NSString *)name tag:(NSArray *)tag;

/**
 * Constructor of the class
 * @param val The id
 * @param name The name
 * @param template The toString Template
 */
- (instancetype)initWithId:(uint32_t)val name:(NSString *)name template:(NSString *)template;

/**
 * Constructor of the class
 * @param val The id
 * @param name The name
 * @param tag Arbitrary data array
 * @param template The toString Template
 */
- (instancetype)initWithId:(uint32_t)val name:(NSString *)name tag:(NSArray *)tag template:(NSString *)template;

/**
 * Load a List of Aliases from an XML File
 * @param filename Name of the File
 * @return The IAlias Array
 */
+ (NSArray<id<IAlias>> *)loadFromXml:(NSString *)filename;

@end
