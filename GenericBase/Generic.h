//
//  Generic.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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
#import "GenericUIBase.h"
#import "IPackedFileUI.h"

@protocol IFileWrapper, IPackedFileDescriptor;
@class GenericCommon, GenericItem, GenericElements;

NS_ASSUME_NONNULL_BEGIN

/**
 * Generic UI Handler, which is able to Display Properties in a ListView
 */
@interface GenericUI : GenericUIBase <IPackedFileUI>

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Property Conversion Methods

/**
 * Used to Convert Property contents.
 * @param name The Name of the Property
 * @param item The Item the property is in.
 * @param object The value of the Property
 * @returns nil, if the default Converter has to handle this Property, or the converted String
 * @remarks This Method can be used by derived Classes to implement Property dependent
 * Conversions while generating the ListView.
 */
- (nullable NSString *)propertyToString:(NSString *)name
                                   item:(GenericCommon *)item
                                 object:(nullable id)object;

/**
 * Converts an Object to a valid String
 * @param object The Object you want to convert
 * @returns The String represented by the Object
 */
- (NSString *)toString:(nullable id)object;

/**
 * Converts an Object from a Generic.Common Property List into a valid String
 * @param name The Name of the Property that will be converted. nil if no property
 * @param item The Item the property is in.
 * @param object The Object you want to convert
 * @returns The String represented by the Object
 * @remarks
 * The name Parameter was introduced for derived classes who need special Conversion for special
 * Property values. When toString gets a name value not equal to nil, it will call the propertyToString
 * Method. When this Method returns nil, the default Conversion will be executed, otherwise the returned
 * String will be passed to the caller.
 */
- (NSString *)toString:(nullable NSString *)name
                  item:(nullable GenericCommon *)item
                object:(nullable id)object;

// MARK: - IPackedFileUI Protocol

/**
 * Returns the main GUI view
 */
- (NSView *)createView;

/**
 * Updates the GUI with the given wrapper data
 * @param wrapper The file wrapper containing data to display
 */
- (void)updateGUI:(id<IFileWrapper>)wrapper;

/**
 * Refreshes the current display
 */
- (void)refresh;

/**
 * Synchronizes any changes back to the wrapper
 */
- (void)synchronize;

/**
 * Cleanup and dispose of resources
 */
- (void)dispose;

@end

NS_ASSUME_NONNULL_END
