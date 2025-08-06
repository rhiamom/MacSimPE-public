//
//  WaitingScreen.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *   Copyright (C) 2008 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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

@class WaitingForm;

@interface WaitingScreen : NSObject

// MARK: - Public Class Methods

/// Display a new WaitingScreen image
/// @param image the Image to show
+ (void)updateImage:(NSImage *)image;

/// Display a new WaitingScreen message
/// @param message The Message to show
+ (void)updateMessage:(NSString *)message;

/// Display a new WaitingScreen image and message
/// @param image the Image to show
/// @param message The Message to show
+ (void)updateImage:(NSImage *)image message:(NSString *)message;

/// Show the WaitingScreen for a specific window
/// @param window The window to show the waiting screen over
+ (void)waitForWindow:(NSWindow *)window;

/// Show the WaitingScreen
+ (void)wait;

/// Stop the WaitingScreen and focus the given window
/// @param window The window to focus
+ (void)stopAndFocusWindow:(NSWindow *)window;

/// Stop the WaitingScreen
+ (void)stop;

// MARK: - Properties

/// The WaitingScreen image
@property (class, strong) NSImage *image;

/// The WaitingScreen message
@property (class, strong) NSString *message;

/// True if the WaitingScreen is displayed
@property (class, readonly) BOOL running;

/// Returns the Size of the Displayed Image
@property (class, readonly) NSSize imageSize;

@end
