//
//  EnumComboBox.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/4/25.
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

/**
 * Item wrapper for enum values in the combo box
 * Stores both the display name and the actual enum value
 */
@interface EnumComboBoxItem : NSObject

/**
 * The actual enum value content
 */
@property (nonatomic, strong, readonly) id content;

/**
 * The display name for the enum value
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * Initialize with enum information
 * @param enumClass The class/type of the enum (for debug display)
 * @param enumValue The actual enum value (NSNumber for C enums, or custom enum object)
 * @param bundle Resource bundle for localized names (can be nil)
 */
- (instancetype)initWithEnumClass:(Class)enumClass
                        enumValue:(id)enumValue
                           bundle:(nullable NSBundle *)bundle;

@end

/**
 * A specialized NSComboBox that displays enum values with optional localization
 * Automatically populates itself with enum values and provides localized display names
 */
@interface EnumComboBox : NSComboBox

// MARK: - Properties

/**
 * The class/type of enum to display
 * When set, automatically populates the combo box with enum values
 */
@property (nonatomic, strong, nullable) Class enumClass;

/**
 * Resource bundle for localized enum names
 * Looks for strings with format: "ClassName.EnumName.ValueName"
 */
@property (nonatomic, strong, nullable) NSBundle *resourceBundle;

/**
 * The currently selected enum value
 * Returns the actual enum value, not the display wrapper
 */
@property (nonatomic, strong, nullable) id selectedEnumValue;

// MARK: - Methods

/**
 * Update the combo box content with current enum values
 * @param keepSelection Whether to preserve the current selection if possible
 */
- (void)updateContentKeepingSelection:(BOOL)keepSelection;

/**
 * Set up the combo box for a specific enum type
 * @param enumClass The class containing the enum constants
 * @param bundle Optional bundle for localized names
 */
- (void)configureWithEnumClass:(Class)enumClass bundle:(nullable NSBundle *)bundle;

/**
 * Add enum values from a dictionary of name->value pairs
 * Useful for C-style enums or custom enum implementations
 * @param enumValues Dictionary with string keys and enum values
 * @param enumClass Class name for localization key generation
 */
- (void)addEnumValuesFromDictionary:(NSDictionary<NSString *, id> *)enumValues
                          enumClass:(Class)enumClass;

/**
 * Get the localized name for an enum value
 * @param enumValue The enum value
 * @param enumClass The enum class for key generation
 * @param bundle Resource bundle to search
 * @returns Localized name or the enum value's string representation
 */
- (NSString *)localizedNameForEnumValue:(id)enumValue
                              enumClass:(Class)enumClass
                                 bundle:(nullable NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
