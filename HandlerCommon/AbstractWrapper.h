//
//  AbstractHandler.h
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
#import "IPackedFileWrapper.h"
#import "IPackedFileSaveExtension.h"
#import "IFileWrapper.h"

// Forward declarations
@protocol IWrapperReferencedResources;
@protocol IFileWrapper;
@protocol IPackedFileDescriptor;
@protocol IPackageFile;
@protocol IPackedFileUI;
@protocol IWrapperInfo;
@protocol IWrapperRegistry;
@protocol IPackedFile;
@protocol IScenegraphFileIndexItem;
@class BinaryReader, BinaryWriter, MemoryStream, TypeAlias;

/**
 * The Abstract Wrapper implements some common Methods of the
 * IPackedFileWrapper and IPackedFileSaveExtension protocols.
 * This is the easiest Way to Implement a Plugin.
 */
@interface AbstractWrapper : NSObject <IWrapper, IPackedFileWrapper, IPackedFileSaveExtension, IFileWrapper>

// MARK: - Properties

/**
 * true if processData was called once
 */
@property (nonatomic, readonly, assign) BOOL processed;

/**
 * true if the stored Data was changed but synchronizeUserData wasn't called
 */
@property (nonatomic, assign) BOOL changed;

/**
 * The Priority of a Wrapper in the Registry
 */
@property (nonatomic, assign) NSInteger priority;

/**
 * Returns the FileDescriptor Associated with the File
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * Returns the Package
 */
@property (nonatomic, strong) id<IPackageFile> package;

/**
 * Returns the UI Handler
 */
@property (nonatomic, strong) id<IPackedFileUI> uiHandler;

/**
 * Returns wrapper description info
 */
@property (nonatomic, readonly, strong) id<IWrapperInfo> wrapperDescription;

/**
 * Returns the wrapper filename
 */
@property (nonatomic, readonly, copy) NSString *wrapperFileName;

/**
 * Get a Description for this Resource
 */
@property (nonatomic, readonly, copy) NSString *description;

/**
 * Get the Header for this Description (i.e. Fieldnames)
 */
@property (nonatomic, readonly, copy) NSString *descriptionHeader;

/**
 * Get this Resource name
 */
@property (nonatomic, readonly, copy) NSString *resourceName;

/**
 * Return the content of the Files
 */
@property (nonatomic, readonly, strong) MemoryStream *content;

/**
 * Returns the default Extension for this File
 */
@property (nonatomic, readonly, copy) NSString *fileExtension;

/**
 * Returns the current Stream (the Data that is stored in the Attributes of the wrapper)
 */
@property (nonatomic, readonly, strong) MemoryStream *currentStateData;

/**
 * Returns the stored data as a BinaryReader
 */
@property (nonatomic, readonly, strong) BinaryReader *storedData;

/**
 * Returns whether multiple instances are allowed
 */
@property (nonatomic, readonly, assign) BOOL allowMultipleInstances;

/**
 * Returns whether this wrapper references resources
 */
@property (nonatomic, readonly, assign) BOOL referencesResources;

/**
 * This is used to initialize single Gui Wrappers
 */
@property (nonatomic, strong) id<IFileWrapper> singleGuiWrapper;

// MARK: - Initialization

/**
 * Creates a new Instance
 */
- (instancetype)init;

// MARK: - Abstract Methods (must be implemented by subclasses)

/**
 * Called By processData when the File needs to update its Data Storage (Attributes, not the UserData)
 * @param reader The Data to process
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Creates the default UI Handler Object
 * @return the default UI Handler Object needed when the UIHandler is set to nil
 */
- (id<IPackedFileUI>)createDefaultUIHandler;

// MARK: - Virtual Methods (can be overridden by subclasses)

/**
 * Called when the data Stored in the Wrappers Attributes must be written to a Stream
 * @param writer The Stream the Data should be written to
 * @note This implementation won't save anything, you have to reimplement this in your class
 */
- (void)serialize:(BinaryWriter *)writer;

/**
 * Creates a new Wrapper Info Object
 * @return wrapper info object
 */
- (id<IWrapperInfo>)createWrapperInfo;

/**
 * Override this to add your own Implementation for resourceName
 * @param ta The Current Type
 * @return nil, if the Default Name should be generated
 */
- (NSString *)getResourceName:(TypeAlias *)ta;

// MARK: - Data Processing Methods

- (void)processData:(id<IPackedFileDescriptor>)fileDescriptor
            package:(id<IPackageFile>)package
               sync:(BOOL)sync;
/**
 * Process data with file descriptor, package, and file
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package file:(id<IPackedFile>)file;

/**
 * Process data with file descriptor, package, and file with exception handling
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package file:(id<IPackedFile>)file catchExceptions:(BOOL)catchex;

/**
 * Process data with file descriptor and package
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package;

/**
 * Process data with file descriptor and package with exception handling
 */
- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package catchExceptions:(BOOL)catchex;

/**
 * Process data with scenegraph item
 */
- (void)processData:(id<IScenegraphFileIndexItem>)item;

/**
 * Process data with scenegraph item with exception handling
 */
- (void)processData:(id<IScenegraphFileIndexItem>)item catchExceptions:(BOOL)catchex;

// MARK: - Save Methods

/**
 * Used to update the UserData contained in a Packed File
 */
- (void)synchronizeUserData;

/**
 * Synchronize user data with exception handling
 */
- (void)synchronizeUserData:(BOOL)catchExceptions;

/**
 * Synchronize user data with exception handling and fire event option
 */
- (void)synchronizeUserData:(BOOL)catchExceptions fireEvent:(BOOL)fire;

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

// MARK: - UI Methods

/**
 * Refresh the UI
 */
- (void)refreshUI;

/**
 * Refresh the wrapper data and UI
 */
- (void)refresh;

/**
 * Load the UI
 */
- (void)loadUI;

// MARK: - Multiple Instance Support

/**
 * Create a new Instance of the Wrapper
 * @return the new Instance
 */
- (id<IFileWrapper>)activate;

/**
 * Returns a list of Arguments that should be passed to the Constructor during activate
 * @return array of constructor arguments
 */
- (NSArray *)getConstructorArguments;

// MARK: - Registry Methods

/**
 * Register this wrapper with a registry
 */
- (void)registerWithRegistry:(id<IWrapperRegistry>)registry;

/**
 * Check if this wrapper supports the given version
 */
- (BOOL)checkVersion:(uint32_t)version;

/**
 * Fix wrapper with registry
 */
- (void)fix:(id<IWrapperRegistry>)registry;

@end
