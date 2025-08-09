//
//  IScenegraphItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

/**
 * Specialization of an IRcol Interface, providing additional Methods to find referenced Scenegraph Resources
 */
@protocol IScenegraphItem <NSObject>

/**
 * Returns all Referenced Scenegraph Resources sorted by type of Reference
 * @remarks The Key is the name of the Reference Type, the value is an NSArray containing all ReferencedFiles
 * @returns Dictionary where keys are NSString reference type names and values are NSArray objects containing referenced files
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray *> *referenceChains;

/**
 * Returns the first Referenced RCOL Resource for the passed Type
 * @param type Type of the Resource you are looking for
 * @returns Descriptor for the first found RCOL Resource or nil
 */
// - (id)findReferencedType:(uint32_t)type;

@end
