///
//  IToolFactory.h
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
// ***************************************************************************

#import <Foundation/Foundation.h>

@protocol IToolPlugin;
@protocol IWrapperRegistry;
@protocol IProviderRegistry;

NS_ASSUME_NONNULL_BEGIN
// MARK: - IToolFactory Protocol

/// If you create a Plugin for SimPE your bundle must implement this interface
/// to give the calling main Application a reference to your Plugin Objects
/// @discussion When SimPE tries to load the Tools stored here, it will create a new Instance of
/// the Factory. After that it will set linkedRegistry/linkedProvider to the registry the Objects are going
/// to be linked with. Last it will load the list of knownTools.
@protocol IToolFactory <NSObject>

// MARK: - Properties

/// Returns all Plugin (dockable) Tools the Factory knows
@property (nonatomic, strong, readonly) NSArray<id<IToolPlugin>> *knownTools;

/// Returns or sets the Registry this Plugin was last registered with
@property (nonatomic, strong, nullable) id<IWrapperRegistry> linkedRegistry;

/// Returns or sets the Provider this Plugin can use
@property (nonatomic, strong, nullable) id<IProviderRegistry> linkedProvider;

/// Returns the Name of the File where this factory is located in
@property (nonatomic, strong, readonly) NSString *fileName;

@end
NS_ASSUME_NONNULL_END

