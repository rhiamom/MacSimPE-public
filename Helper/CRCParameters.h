//
//  CRCParameters.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop        *
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
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Classless.Hasher - C#/.NET Hash and Checksum Algorithm Library.
 *
 * The Initial Developer of the Original Code is Classless.net.
 * Portions created by the Initial Developer are Copyright (C) 2004 the Initial
 * Developer. All Rights Reserved.
 *
 * Contributor(s):
 *        Jason Simeone (jay@classless.net)
 *
 * ***** END LICENSE BLOCK ***** */

#import <Foundation/Foundation.h>
#import "CRCStandard.h"

/// A class that contains the parameters necessary to initialize a CRC algorithm.
@interface CRCParameters : NSObject <NSCopying>

/// Gets or sets the order of the CRC (e.g., how many bits).
@property (nonatomic, assign) NSInteger order;

/// Gets or sets the polynomial to use in the CRC calculations.
@property (nonatomic, assign) int64_t polynomial;

/// Gets or sets the initial value of the CRC.
@property (nonatomic, assign) int64_t initialValue;

/// Gets or sets the final value to XOR with the CRC.
@property (nonatomic, assign) int64_t finalXORValue;

/// Gets or sets the value dictating whether or not to reflect the incoming data before calculating. (UART)
@property (nonatomic, assign) BOOL reflectInput;

/// Initializes a new instance of the CRCParameters class.
/// @param order The order of the CRC (e.g., how many bits).
/// @param polynomial The polynomial to use in the calculations.
/// @param initialValue The initial value of the CRC.
/// @param finalXORValue The final value to XOR with the CRC.
/// @param reflectInput Whether or not to reflect the incoming data before calculating.
- (instancetype)initWithOrder:(NSInteger)order
                   polynomial:(int64_t)polynomial
                 initialValue:(int64_t)initialValue
                finalXORValue:(int64_t)finalXORValue
                 reflectInput:(BOOL)reflectInput;

/// Retrieves a standard set of CRC parameters.
/// @param standard The name of the standard parameter set to retrieve.
/// @return The CRC Parameters for the given standard.
+ (CRCParameters *)getParameters:(CRCStandard)standard;

@end
