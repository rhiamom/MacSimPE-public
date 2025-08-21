//
//  IDockableTool.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/19/25.
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
#import <Cocoa/Cocoa.h>
#import "ITool.h"
#import "IToolExt.h"

@class ResourceEventArgs;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;

/**
 * Defines an Object that can be put into Dock of the Main Form
 */
@protocol IDockableTool <IToolPlugin, IToolExt>

/**
 * Fired, when a new Resource should be displayed
 */
@property (nonatomic, copy) void (^showNewResource)(id sender, ResourceEventArgs *args);

/**
 * Starts the Tool Window
 * @param package The currently opened Package
 * @param pfd The currently selected File
 * @returns The dockable control (NSView subclass for macOS)
 */
- (NSView *)getDockableControl;

/**
 * This EventHandler will be connected to the ChangeResource Event of the Caller, you can set
 * the Enabled State here
 * @param sender The sender
 * @param e The resource event arguments
 */
- (void)refreshDock:(id)sender resourceEventArgs:(ResourceEventArgs *)e;

@end
