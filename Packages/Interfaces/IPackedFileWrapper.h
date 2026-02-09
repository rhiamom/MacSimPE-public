//
//  IPackedFileLoader.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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
#import "IWrapper.h"
#import "IPackedFileName.h"

@class BinaryReader, MemoryStream;
@protocol IPackageFile, IPackedFileDescriptor, IPackedFile, IScenegraphFileIndexItem, IPackedFileUI, IWrapperRegistry, IFileWrapper;

/**
 * This Interface Implements Methods that must be provided by a PackedFile Wrapper
 * @remarks If you want to Implement a Wrapper you must use the IFileWrapper protocol
 */
@protocol IPackedFileWrapper <IWrapper, IPackedFileName>

/**
 * Returns the Package where this File is assigned to (can be nil)
 */
@property (nonatomic, readonly, strong) id<IPackageFile> package;

/**
 * Returns the FileDescriptor Associated with the File
 * @remarks
 * When the Descriptor is returned, make sure that the userdata is not out of Data;
 */
@property (nonatomic, readonly, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * Will return current Data
 */
@property (nonatomic, readonly, strong) BinaryReader *storedData;

/**
 * Returns / Sets the assigned UI Handler (can be nil!)
 * @remarks If you set this value to nil, it will Return the Default UIHandler or nil if no default exists
 */
@property (nonatomic, strong) id<IPackedFileUI> uiHandler;

/**
 * Return the content of the Files
 */
@property (nonatomic, readonly, strong) MemoryStream *content;

/**
 * Returns the default Extension for this File
 */
@property (nonatomic, readonly, copy) NSString *fileExtension;

/**
 * Process the Data stored in the sent File
 * @param item Contains a Scenegraph Item (which combines a FileDescriptor with a Package)
 */
- (void)processData:(id<IScenegraphFileIndexItem>)item;

/**
 * Process the Data stored in the sent File
 * @param pfd Description of the sent File
 * @param package The Package containing the File
 * @param file The data of the file (if nil, the Method must try to read it from the package!)
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package
               file:(id<IPackedFile>)file;

/**
 * Process the Data stored in the described File
 * @param pfd Description of the sent File
 * @param package The Package containing the File
 * @remarks The Files's data must be read from the package
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package;

/**
 * Process the Data stored in the sent File
 * @param item Contains a Scenegraph Item (which combines a FileDescriptor with a Package)
 * @param catchex true, if the Method should handle all occurring Exceptions
 */
- (void)processData:(id<IScenegraphFileIndexItem>)item
            catchex:(BOOL)catchex;

/**
 * Process the Data stored in the sent File
 * @param pfd Description of the sent File
 * @param package The Package containing the File
 * @param file The data of the file (if nil, the Method must try to read it from the package!)
 * @param catchex true, if the Method should handle all occurring Exceptions
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package
               file:(id<IPackedFile>)file
            catchex:(BOOL)catchex;

/**
 * Process the Data stored in the described File
 * @param pfd Description of the sent File
 * @param package The Package containing the File
 * @param catchex true, if the Method should handle all occurring Exceptions
 * @remarks The Files's data must be read from the package
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package
            catchex:(BOOL)catchex;

/**
 * Processes the stored Data again and Sends an Update Request to the assigned UI Handler (if not nil)
 */
- (void)refresh;

/**
 * Sends an Update Request to the assigned UI Handler (if not nil)
 */
- (void)refreshUI;

/**
 * Initializes the GUI for this Wrapper, and Updates its content
 */
- (void)loadUI;

/**
 * Tries to correct Possible Errors.
 * @param registry The Wrapper Registry
 */
- (void)fix:(id<IWrapperRegistry>)registry;

/**
 * Always returns this Object.
 * @return this Object
 * @remarks
 * This Method is Important, when a Wrapper implements IMultiplePackedFileWrapper, as
 * it will create a new Instance of the Class it was called from.
 */
- (id<IFileWrapper>)activate;

@end
