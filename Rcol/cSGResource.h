//
//  SGResource.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/15/25.
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
#import "AbstractRcolBlock.h"

@class Rcol;
@class BinaryReader;
@class BinaryWriter;

/**
 * This is the actual FileWrapper
 * @remarks The wrapper is used to (un)serialize the Data of a file into its Attributes.
 * So Basically it reads a BinaryStream and translates the data into some user-defined Attributes.
 */
@interface SGResource : AbstractRcolBlock

// MARK: - Properties
@property (nonatomic, strong) NSString *fileName;

// MARK: - Initialization
- (instancetype)initWithParent:(Rcol *)parent;
/**
 * Registers this resource and returns its identifier
 * @param parent The parent object (can be nil)
 * @returns The filename or identifier string
 */
- (NSString *)register:(id)parent;
// MARK: - IRcolBlock Protocol Methods
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (void)dispose;

@end
