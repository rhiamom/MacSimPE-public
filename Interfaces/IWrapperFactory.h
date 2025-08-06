//
//  IWrapperFactory.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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

// Forward declarations
@protocol IWrapper;
@protocol IWrapperRegistry;
@protocol IProviderRegistry;

/**
 * If you create a Plugin for SimPE your .dll must implement this interface give the calling main Application a reference to your Plugin Objects
 * @remarks When SimPE tries to load the Wrappers stored here, it will create a new Instance of the Factory. After that it will set linkedRegistry/linkedProvider to the registry the Objects going to be linked with. Last it will load the list of knownWrappers.
 */
@protocol IWrapperFactory <NSObject>

// MARK: - Properties

/**
 * Returns all Wrappers the Factory knows
 */
@property (nonatomic, readonly) NSArray<id<IWrapper>> *knownWrappers;

/**
 * Returns or sets the Registry this Plugin was last registered with
 */
@property (nonatomic, strong) id<IWrapperRegistry> linkedRegistry;

/**
 * Returns or sets the Provider this Plugin can use
 */
@property (nonatomic, strong) id<IProviderRegistry> linkedProvider;

@end
