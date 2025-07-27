//
//  IPackedFileSaveExtension.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/27/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop         *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>

// Forward declarations
@protocol IPackedFileDescriptor;
@class MemoryStream, BinaryWriter;

/**
 * Protocol for File handlers that are able to save their content to a BinaryStream
 *
 * @note If you want to implement a Wrapper you must use the IFileWrapperSaveExtension protocol
 */
@protocol IPackedFileSaveExtension <NSObject>

/**
 * Returns the FileDescriptor Associated with the File
 *
 * @note When the Descriptor is returned, make sure that the userdata is not out of data
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * Returns the current Stream (the Data that is stored in the Attributes of the wrapper)
 *
 * @note This Property is used to process the synchronizeUserData command, and returns
 * the BinaryStream representation of the current State of this Wrapper.
 */
@property (nonatomic, readonly, strong) MemoryStream *currentStateData;

/**
 * true if the stored Data was changed but synchronizeUserData wasn't called
 */
@property (nonatomic, assign) BOOL changed;

/**
 * Used to update the UserData contained in a Packed File
 */
- (void)synchronizeUserData;

/**
 * Saves the data represented by this Object to the writer
 * @param writer The BinaryWriter
 * @return The Size of the Data written
 */
- (NSInteger)save:(BinaryWriter *)writer;

/**
 * Saves the data in the UserData Attribute of a PackedFileDescriptor
 * @param pfd The Descriptor where you want to store the Data in
 */
- (void)saveToDescriptor:(id<IPackedFileDescriptor>)pfd;

@end
