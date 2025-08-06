//
//  FlagBase.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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
#import "Serializer.h"
#import "IPropertyClass.h"

/// <summary>
/// Basic Class you can use if you have to implement Flags
/// </summary>
@interface FlagBase : Serializer <IPropertyClass>

// MARK: - Properties

@property (nonatomic, assign) uint16_t value;

// MARK: - Initialization

- (instancetype)initWithValue:(uint16_t)flags;
- (instancetype)initWithObject:(id)flags;

// MARK: - Flag Operations

- (BOOL)getBit:(uint8_t)bitNumber;
- (void)setBit:(uint8_t)bitNumber value:(BOOL)value;

// MARK: - Conversion

- (uint16_t)unsignedShortValue;
- (int16_t)shortValue;

@end
