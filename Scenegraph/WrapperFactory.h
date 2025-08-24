//
//  WrapperFactory.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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
#import "AbstractFactory.h"

// Forward declarations
@protocol ICommandLine;
@class BuildTxtr, FixPackage;

// MARK: - Command Line Factory Protocol

/**
 * Protocol for factories that provide command line interfaces
 */
@protocol ICommandLineFactory <NSObject>

/**
 * Returns all command line interfaces the factory knows
 */
@property (nonatomic, readonly) NSArray<id<ICommandLine>> *knownCommandLines;

@end

// MARK: - Command Line Protocol

/**
 * Protocol for command line interface implementations
 */
@protocol ICommandLine <NSObject>

/**
 * Execute the command line interface
 */
- (void)execute;

/**
 * Get command name/identifier
 */
@property (nonatomic, readonly, copy) NSString *commandName;

@end

// MARK: - ScenegraphWrapperFactory Interface

/**
 * Lists all Plugins (=FileType Wrappers) available in this Package
 *
 * @remarks
 * knownWrappers has to return a list of all Plugins provided by this Library.
 * If a Plugin isn't returned, SimPe won't recognize it!
 */
@interface ScenegraphWrapperFactory : AbstractWrapperFactory <ICommandLineFactory>

// MARK: - Static Methods

/**
 * Add all other default RCol Extensions
 */
+ (void)initRcolBlocks;

/**
 * Loads the GroupCache
 */
+ (void)loadGroupCache;

/**
 * Loads the GroupCache
 * @param force Will force the load of the GroupsCache even
 * if Helper.WindowsRegistry.UseMaxisGroupsCache is set to NO
 */
+ (void)loadGroupCache:(BOOL)force;

@end
