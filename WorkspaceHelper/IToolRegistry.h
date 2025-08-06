///
//  IToolRegistry.h
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
@protocol IToolFactory;
@protocol ITool;
@protocol IToolPlus;
@protocol IDockableTool;
@protocol IToolAction;
@class Listeners;

/// Protocol for tool registry management in SimPE
@protocol IToolRegistry <NSObject>

// MARK: - Registration Methods

/// Registers a Tool to the Registry
/// @param tool The Tool to register
/// @discussion The tool must only be added if the Registry doesn't already contain it
- (void)registerTool:(id<IToolPlugin>)tool;

/// Registers all listed Tools with this Registry
/// @param tools The Tools to register
/// @discussion The tool must only be added if the Registry doesn't already contain it
- (void)registerTools:(NSArray<id<IToolPlugin>> *)tools;

/// Registers all Tools supported by the Factory
/// @param factory The Factory Elements you want to register
/// @discussion The tool must only be added if the Registry doesn't already contain it
- (void)registerFactory:(id<IToolFactory>)factory;

// MARK: - Properties

/// Return a Collection of loaded Listeners
@property (nonatomic, strong, readonly) Listeners *listeners;

/// Returns the List of Known Tools
/// @discussion The Tools should be Returned in Order of Priority starting with the lowest!
@property (nonatomic, strong, readonly) NSArray<id<ITool>> *tools;

/// Returns the List of Known Tools Plus
/// @discussion The Tools should be Returned in Order of Priority starting with the lowest!
@property (nonatomic, strong, readonly) NSArray<id<IToolPlus>> *toolsPlus;

/// Returns a List of Known Dockable Tools
@property (nonatomic, strong, readonly) NSArray<id<IDockableTool>> *docks;

/// Returns a List of Known Action Tools
@property (nonatomic, strong, readonly) NSArray<id<IToolAction>> *actions;

@end
