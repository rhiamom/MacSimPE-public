//
//  GroupCacheUI.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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
#import <AppKit/AppKit.h>
#import "IPackedFileUI.h"

// Forward declarations
@protocol IPackedFileUI, IFileWrapper;
@class GroupCache, GroupCacheForm;

/**
 * UI Handler for a GroupCache Wrapper
 * Implements the IPackedFileUI protocol for integration with ResourceViewManager
 */
@interface GroupCacheUI : NSObject <IPackedFileUI>

// MARK: - Properties

/**
 * The form that contains the UI components
 */
@property (nonatomic, strong, readonly) GroupCacheForm *form;

// MARK: - Initialization

/**
 * Constructor for the Class
 */
- (instancetype)init;

// MARK: - IPackedFileUI Protocol Implementation

/**
 * Returns the View that will be displayed within SimPE
 * @return The NSView containing the UI components
 */
- (NSView *)guiHandle;

/**
 * Is called by SimPE (through the Wrapper) when the Panel is going to be displayed, so
 * you should update the Data displayed by the Panel with the Attributes stored in the
 * passed Wrapper.
 * @param wrapper The Attributes of this Wrapper have to be displayed
 */
- (void)updateGUI:(id<IFileWrapper>)wrapper;

/**
 * Clean up resources
 */
- (void)dispose;

@end
