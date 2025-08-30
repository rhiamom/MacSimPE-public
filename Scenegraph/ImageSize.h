//
//  ImageSize.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/27/25.
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageSizeDialog : NSWindowController

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSTextField *widthTextField;
@property (nonatomic, strong) IBOutlet NSTextField *heightTextField;
@property (nonatomic, strong) IBOutlet NSTextField *sizeLabel;
@property (nonatomic, strong) IBOutlet NSTextField *xLabel;
@property (nonatomic, strong) IBOutlet NSButton *okButton;

// MARK: - Properties
@property (nonatomic, assign) NSSize imageSize;
@property (nonatomic, assign) BOOL cancelled;

// MARK: - Class Methods
/**
 * Shows the image size dialog and returns the selected size
 * @param size The initial size to display
 * @returns The new size selected by the user
 */
+ (NSSize)executeWithSize:(NSSize)size;

// MARK: - Instance Methods
- (instancetype)init;
- (void)setupUI;

// MARK: - Actions
- (IBAction)okButtonPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
