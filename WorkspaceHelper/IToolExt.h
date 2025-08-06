//
//  IToolExt.h
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
#import "ITool.h"

// MARK: - IToolExt Protocol

/// Defines extended properties for the ITool Interface
@protocol IToolExt <IToolPlugin>

/// Returns nil or the Icon that should be displayed for this Menu Item (can be nil)
@property (nonatomic, strong, readonly, nullable) NSImage *icon;

/// Returns the wanted keyboard shortcut for this tool
@property (nonatomic, strong, readonly, nullable) NSString *keyEquivalent;

/// Returns the modifier flags for the keyboard shortcut
@property (nonatomic, assign, readonly) NSEventModifierFlags keyEquivalentModifierMask;

/// Returns true if the Tool is currently visible on the GUI
@property (nonatomic, assign, readonly) BOOL visible;

@end
