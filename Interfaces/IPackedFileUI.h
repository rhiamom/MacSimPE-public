//
//  IPackedFileUI.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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

@protocol IFileWrapper;

/// <summary>
/// Interface for PackedFile handlers
/// </summary>
/// <remarks>
/// Packed File handlers Provide a GUI to present the Data stored in a Packed File.<br />
/// To Export your GUI, you have to put everything into one NSView. The reference to this
/// NSView will be used by the Main Application to Display The Data.<br />
/// Currently the Size of the Client Window is 880x246 Pixel. Your NSView will be resized to
/// those measurements. If your output is bigger, you might want to consider the Use of the
/// scroll view or other layout management!
/// </remarks>
@protocol IPackedFileUI <NSObject>

/// <summary>
/// Passes the NSView that should present the Data
/// </summary>
/// <returns>The NSView Displaying the PackedFile Data</returns>
@property (nonatomic, strong, readonly) NSView *guiHandle;

/// <summary>
/// Processes the Data and displays it within the GUI
/// </summary>
/// <param name="wrapper">The Calling Wrapper</param>
/// <remarks>
/// The passed data is definitely uncompressed and represents
/// the Plain Packed File Data
///
/// A UI class can allow Multiple instances, by Implementing
/// IMultiplePackedFileUI.
///
/// When Multiple Files are allowed, this Method should only Refresh
/// the GUI Contents, and not create an entire new one.
/// </remarks>
- (void)updateGUI:(id<IFileWrapper>)wrapper;

@end

/// <summary>
/// Extended interface for PackedFile handlers
/// </summary>
/// <remarks>
/// Packed File handlers Provide a GUI to present the Data stored in a Packed File.<br />
/// To Export your GUI, you have to put everything into one NSView. The reference to this
/// NSView will be used by the Main Application to Display The Data.<br />
/// Currently the Size of the Client Window is 880x246 Pixel. Your NSView will be resized to
/// those measurements. If your output is bigger, you might want to consider the Use of the
/// scroll view or other layout management!
/// </remarks>
@protocol IPackedFileUIExt <NSObject>

/// <summary>
/// Passes the NSView that should present the Data
/// </summary>
/// <returns>The NSView Displaying the PackedFile Data</returns>
@property (nonatomic, strong, readonly) NSView *guiControl;

@end

/// <summary>
/// Interface for PackedFile handlers that support multiple instances
/// </summary>
@protocol IMultiplePackedFileUI <IPackedFileUI>

// Multiple file support - when this protocol is implemented,
// updateGUI: should refresh existing GUI instead of creating new one

@end
