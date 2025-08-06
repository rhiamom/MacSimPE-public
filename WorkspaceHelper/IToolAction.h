//
//  IToolAction.h
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
#import "ITool.h"

@protocol IToolExt;
@class ResourceEventArgs;

// MARK: - IToolAction Protocol

/// Defines a Action Plugin
@protocol IToolAction <IToolPlugin, IToolExt>

/// This method will be connected to the ExecuteAction Event of the Caller, you should
/// perform the Action here. You can notify the caller of Changes when setting the appropriate
/// Attributes in the event args
/// @param sender The object that triggered the action
/// @param eventArgs Event arguments containing resource information
- (void)executeEventHandlerWithSender:(id)sender eventArgs:(ResourceEventArgs *)eventArgs;

/// This method will be connected to the ChangeResource Event of the Caller, you can set
/// the Enabled State here
/// @param sender The object that triggered the event
/// @param eventArgs Event arguments containing resource information
/// @returns true if this action should be enabled for the current resource
- (BOOL)changeEnabledStateEventHandlerWithSender:(id)sender eventArgs:(ResourceEventArgs *)eventArgs;

@end
