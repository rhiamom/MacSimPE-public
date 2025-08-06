//
//  IHelpRegistry.h
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

@protocol IHelp;
@protocol IHelpFactory;

// MARK: - IHelpRegistry Protocol

/// Registry interface for managing help topics in SimPE
@protocol IHelpRegistry <NSObject>

// MARK: - Registration Methods

/// Registers a Help Topic to the Registry
/// @param topic The Topic to register
/// @discussion The topic must only be added if the Registry doesn't already contain it
- (void)registerHelpTopic:(id<IHelp>)topic;

/// Registers all listed Help Topics with this Registry
/// @param topics The Topics to register
/// @discussion The topics must only be added if the Registry doesn't already contain them
- (void)registerHelpTopics:(NSArray<id<IHelp>> *)topics;

/// Registers all Help Topics provided by a factory with this Registry
/// @param factory The providing Factory to register
/// @discussion The topics must only be added if the Registry doesn't already contain them
- (void)registerHelpFactory:(id<IHelpFactory>)factory;

// MARK: - Properties

/// Returns the List of Known Help Topics
@property (nonatomic, strong, readonly) NSArray<id<IHelp>> *helpTopics;

@end
