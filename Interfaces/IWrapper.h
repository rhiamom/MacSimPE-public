//
//  IWrapper.h
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


#import <Foundation/Foundation.h>

@protocol IWrapperRegistry, IWrapperInfo;

/**
 * Defines an Object that can be put into a Registry
 */
@protocol IWrapper <NSObject>

/**
 * true, if the UIHandler for this Wrapper is able to display more than one Instance at once
 */
@property (nonatomic, readonly, assign) BOOL allowMultipleInstances;

/**
 * The Priority of a Wrapper in the Registry
 * @remarks Wrappers with low Numbers are more likely chosen to handle a specific File
 */
@property (nonatomic, assign) NSInteger priority;

/**
 * Returns a Human Readable Description of the Wrapper
 */
@property (nonatomic, readonly, strong) id<IWrapperInfo> wrapperDescription;

/**
 * Returns/sets the Name of the File where this wrapper is located in
 */
@property (nonatomic, readonly, copy) NSString *wrapperFileName;

/**
 * Registers the Wrapper with the passed Registry
 * @param registry The Registry you want to register this Wrapper with
 */
- (void)registerWithRegistry:(id<IWrapperRegistry>)registry;

/**
 * Returns true, if the Plugin can be used with the passed SimPe Version
 * @param version The Version of SimPe Application that requested this Wrapper (0.05 would be 5, while 2.0 would be 2000)
 * @return true, if the Wrapper can be used with this Version
 * @remarks
 * SimPe will check if the Function does always return true, in order to prevent
 * possible conflicts, so you should perform a real Version Check.
 */
- (BOOL)checkVersion:(uint32_t)version;

@end
