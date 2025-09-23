//
//  SimDNA.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/19/25.
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
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop         *
 *   rhiamom@mac.com                                                        *
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

#import <Foundation/Foundation.h>
#import "Serializer.h"
#import "CpfWrapper.h"

@class Gene, CpfItem;

NS_ASSUME_NONNULL_BEGIN

// MARK: - Gene

/**
 * Represents a gene in Sim DNA
 */
@interface Gene : Serializer

// MARK: - Properties

/**
 * Hair property
 */
@property (nonatomic, copy) NSString *hair;

/**
 * Skintone range property
 */
@property (nonatomic, copy) NSString *skintoneRange;

/**
 * Eye property
 */
@property (nonatomic, copy) NSString *eye;

/**
 * Facial feature property
 */
@property (nonatomic, copy) NSString *facialFeature;

/**
 * Skintone property
 */
@property (nonatomic, copy) NSString *skintone;

/**
 * Description property
 */
@property (nonatomic, readonly, copy) NSString *description;

// MARK: - Initialization

/**
 * Internal constructor
 * @param dna The CPF DNA data
 * @param b The base value
 */
- (instancetype)initWithDna:(Cpf *)dna base:(uint32_t)b;

@end

// MARK: - SimDNA

/**
 * Contains the SimDNA Data
 */
@interface SimDNA : Cpf

// MARK: - Properties

/**
 * Dominant gene
 */
@property (nonatomic, readonly, strong) Gene *dominant;

/**
 * Recessive gene
 */
@property (nonatomic, readonly, strong) Gene *recessive;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
