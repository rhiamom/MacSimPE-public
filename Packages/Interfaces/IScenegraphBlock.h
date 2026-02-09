//
//  IScenegraphBlock.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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

/// <summary>
/// Specialization of an IRcol Interface, providing additional Methods to find referenced Scenegraph Resources
/// </summary>
@protocol IScenegraphBlock <NSObject>

/// <summary>
/// Adds all Referenced Scenegraph Resources sorted by type of Reference
/// </summary>
/// <param name="refmap">Dictionary to store references, where key is reference type name and value is array of referenced files</param>
/// <param name="parentgroup">The parent group identifier</param>
/// <remarks>The Key is the name of the Reference Type, the value is an NSArray containing all ReferencedFiles</remarks>
- (void)referencedItems:(NSMutableDictionary<NSString *, NSMutableArray *> *)refmap
            parentGroup:(uint32_t)parentgroup;

@end
