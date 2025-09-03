//
//  SimsComboBox.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/31/25.
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

#import <Cocoa/Cocoa.h>

@protocol IAlias;
@class ExtSDesc;

NS_ASSUME_NONNULL_BEGIN

/**
 * Custom combo box for selecting Sims
 * Translated from SimPe.PackedFiles.Wrapper.SimComboBox
 */
@interface SimComboBox : NSView

// MARK: - UI Components
@property (nonatomic, strong) NSComboBox *comboBox;

// MARK: - Properties

/**
 * The currently selected Sim instance number
 */
@property (nonatomic, assign) uint16_t selectedSimInstance;

/**
 * The currently selected Sim ID
 */
@property (nonatomic, assign) uint32_t selectedSimId;

/**
 * The currently selected Sim description object
 */
@property (nonatomic, strong, nullable) ExtSDesc *selectedSim;

// MARK: - Events

/**
 * Event fired when the selected Sim changes
 */
@property (nonatomic, copy, nullable) void (^selectedSimChanged)(SimComboBox *sender);

// MARK: - Initialization

/**
 * Initialize the SimComboBox
 */
- (instancetype)initWithFrame:(NSRect)frameRect;

// MARK: - Data Management

/**
 * Reload the combo box content from the SimDescriptionProvider
 */
- (void)reload;

@end

NS_ASSUME_NONNULL_END
