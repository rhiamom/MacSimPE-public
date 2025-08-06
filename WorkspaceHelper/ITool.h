//
//  ITool.h
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

@protocol IPackedFileDescriptor;
@protocol IPackageFile;
@protocol IToolResult;
@protocol IToolExt;
@class ResourceEventArgs;

// MARK: - IToolPlugin Protocol

/// The Basic Interface for ToolPlugins (dockable or not)
@protocol IToolPlugin <NSObject>

/// Returns a short describing String
/// @discussion This is explicitly listed in the Interface description, as you should return a String (best would be Name) that identifies the Tool
/// @returns A Describing String for the Tool
- (NSString *)description;

@end

// MARK: - ITool Protocol

/// Defines an Object that can be put into a Registry
@protocol ITool <IToolPlugin>

/// Starts the Tool Window
/// @param pfd The currently selected File (passed by reference)
/// @param package The currently opened Package (passed by reference)
/// @returns The tool result indicating what changes were made
- (id<IToolResult>)showDialogWithFileDescriptor:(id<IPackedFileDescriptor> __autoreleasing *)pfd
                                        package:(id<IPackageFile> __autoreleasing *)package;

/// Returns true if the Menu Item can be enabled
/// @param pfd Descriptor for the currently selected File or nil if none
/// @param package The opened Package or nil if none
/// @returns true if this tool is available
- (BOOL)isEnabledForFileDescriptor:(id<IPackedFileDescriptor>)pfd
                           package:(id<IPackageFile>)package;

@end

// MARK: - IToolPlus Protocol

/// Defines a Action Plugin with the new Interface
@protocol IToolPlus <IToolExt>

/// This method will be called to execute the action. You should perform the Action here.
/// You can notify the caller of changes through the event args.
/// @param sender The object that triggered the action
/// @param eventArgs Event arguments containing resource information
- (void)executeWithSender:(id)sender eventArgs:(ResourceEventArgs *)eventArgs;

/// This method will be called when the resource changes, you can set the Enabled State here
/// @param sender The object that triggered the event
/// @param eventArgs Event arguments containing resource information
/// @returns true if this tool should be enabled for the current resource
- (BOOL)changeEnabledStateWithSender:(id)sender eventArgs:(ResourceEventArgs *)eventArgs;

@end
