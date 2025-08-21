//
//  ISimNames.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/20/25.
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

@protocol IAlias;

/**
 * Interface to obtain the SimNames Alias List from the Type Registry
 */
@protocol ISimNames <NSObject>

/**
 * Returns or sets the Folder where the Character Files are stored
 * @remarks Automatically Updates the stored Names
 */
@property (nonatomic, strong) NSString *baseFolder;

/**
 * Returns the stored Alias Data (key is the simid, value an IAlias Object)
 */
@property (nonatomic, strong) NSMutableDictionary *storedData;

/**
 * Returns the the Alias with the specified Type
 * @param simId The id of a Sim
 * @returns The Alias of the Sim
 */
- (id<IAlias>)findName:(uint32_t)simId;

@end
