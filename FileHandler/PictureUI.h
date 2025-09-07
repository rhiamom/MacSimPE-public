//
//  PictureUI.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/5/25.
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
#import <AppKit/AppKit.h>
#import "UIBase.h"
#import "IPackedFileUI.h"

@protocol IFileWrapper;
@class PictureForm;

/**
 * Handles Packed Jpeg Files
 */
@interface PictureUI : UIBase <IPackedFileUI>

// MARK: - Initialization

/**
 * Initialize the Picture UI handler
 */
- (instancetype)init;

// MARK: - IPackedFileUI Implementation

/**
 * Returns the main GUI view for this packed file UI
 */
@property (nonatomic, readonly) NSView *guiHandle;

/**
 * Update the GUI with data from the wrapper
 * @param wrapper The file wrapper containing image data
 */
- (void)updateGUI:(id<IFileWrapper>)wrapper;

@end
