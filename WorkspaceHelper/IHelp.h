//
//  IHelp.h
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
#import <Cocoa/Cocoa.h>

@class ShowHelpEventArgs;

// MARK: - IHelp Protocol

/// The Interface for a Help Topic
@protocol IHelp <NSObject>

// MARK: - Properties

/// Returns a short describing String that identifies the Topic. This will resemble the Menu name
/// @discussion This is explicitly listed in the Interface description, as you should return a String (best would be Name) that identifies the Topic
@property (nonatomic, strong, readonly, nonnull) NSString *title;

/// A 16x16 Image, that is displayed as an Icon for the Help Topic (by default this is a question mark)
/// @returns nil for the default, or a custom Image
@property (nonatomic, strong, readonly, nullable) NSImage *icon;

// MARK: - Methods

/// Executed when the User decided to show the Help
/// @param eventArgs Currently, this does not provide any data
- (void)showHelpWithEventArgs:(nonnull ShowHelpEventArgs *)eventArgs;

@end
