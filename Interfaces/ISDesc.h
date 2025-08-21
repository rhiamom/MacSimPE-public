//
//  IDesc.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
//
/// ***************************************************************************
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

//
//  ISDesc.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
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

#import <AppKit/AppKit.h>

@protocol IPackedFileDescriptor;

/**
 * Protocol for Sim Description Files
 */
@protocol ISDesc <NSObject>

// MARK: - Sim Identity Properties

/**
 * Returns/Sets the Sim Id
 */
@property (nonatomic, assign) uint32_t simId;

/**
 * Returns or Sets the Instance Number
 */
@property (nonatomic, assign) uint16_t instance;

/**
 * Returns/Sets the Family Instance
 */
@property (nonatomic, assign) uint16_t familyInstance;

// MARK: - Display Properties

/**
 * Returns the FirstName of a Sim
 * @remarks If no SimName Provider is available, '---' will be delivered
 */
@property (nonatomic, readonly, copy) NSString *simName;

/**
 * Returns the FamilyName of a Sim
 * @remarks If no SimFamilyName Provider is available, '---' will be delivered
 */
@property (nonatomic, readonly, copy) NSString *simFamilyName;

/**
 * Returns the FamilyName of a Sim that is stored in the current Package
 * @remarks If no SimFamilyName Provider is available, '---' will be delivered
 */
@property (nonatomic, readonly, copy) NSString *householdName;

/**
 * Returns the Image stored for a specific Sim
 */
@property (nonatomic, readonly, strong) NSImage *image;

/**
 * Returns the Name of the File the Character is stored in
 * @remarks nil, if no File was found
 */
@property (nonatomic, readonly, copy) NSString *characterFileName;

// MARK: - File System Properties

/**
 * Returns the FileDescriptor used to obtain the current Data
 */
@property (nonatomic, readonly, strong) id<IPackedFileDescriptor> fileDescriptor;

@end
