//
//  IWrapperRegistry.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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

// Forward declarations
@protocol IWrapper;
@protocol IWrapperFactory;
@protocol IPackedFileWrapper;
@protocol IFileWrapper;
@protocol IUpdatablePlugin;
@class NSImageView; // Objective-C equivalent to ImageList

/**
 * Wrapper Registry Interface
 */
@protocol IWrapperRegistry <NSObject>

// MARK: - Registration Methods

/**
 * Registers a Wrapper to the Registry
 * @param wrapper The wrapper to register
 * @remarks The wrapper must only be added if the Registry doesn't already contain it
 */
- (void)registerWrapper:(id<IWrapper>)wrapper;

/**
 * Registers all listed Wrappers with this Registry
 * @param wrappers The Wrappers to register
 * @param guiWrappers nil, or a List of the same Length as wrappers, with a second Instance of each wrapper
 * @remarks The wrapper must only be added if the Registry doesn't already contain it
 */
- (void)registerWrappers:(NSArray<id<IWrapper>> *)wrappers
             guiWrappers:(NSArray<id<IWrapper>> *)guiWrappers;

/**
 * Registers all Wrappers supported by the Factory
 * @param factory The Factory Elements you want to register
 * @remarks The wrapper must only be added if the Registry doesn't already contain it
 */
- (void)registerWrapperFactory:(id<IWrapperFactory>)factory;

// MARK: - Properties

/**
 * Returns the List of Known Wrappers (without Wrappers having a Priority < 0!)
 * @remarks The Wrappers should be Returned in Order of Priority starting with the lowest!
 */
@property (nonatomic, readonly) NSArray<id<IWrapper>> *wrappers;

/**
 * Returns the List of all Known Wrappers including Wrappers with Priority < 0
 * @remarks The Wrappers should be Returned in Order of Priority starting with the lowest!
 */
@property (nonatomic, readonly) NSArray<id<IWrapper>> *allWrappers;

/**
 * Contains a Listing of all available Wrapper Icons
 */
@property (nonatomic, readonly) NSImageView *wrapperImageList;

/**
 * Returns a list of all known plugins, that have an update location
 */
@property (nonatomic, readonly) NSArray<id<IUpdatablePlugin>> *updatablePlugins;

// MARK: - Handler Finding Methods

/**
 * Returns the first Handler capable of processing a File of the given Type
 * @param type The Type of the PackedFile
 * @returns The assigned Handler or nil if none was found
 */
- (id<IPackedFileWrapper>)findHandler:(uint32_t)type;

/**
 * Returns the first Handler capable of processing a File
 * @param data The Data of the PackedFile
 * @returns The assigned Handler or nil if none was found
 * @remarks A handler is assigned if the first bytes of the Data are equal to the signature provided by the Handler
 */
- (id<IFileWrapper>)findHandlerForData:(NSData *)data;

@end
