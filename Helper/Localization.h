//
//  Localization.h
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

/**
 * Supports localization for SimPE
 * Uses NSBundle's localization system for string lookups
 */
@interface Localization : NSObject

// MARK: - Singleton Access
+ (instancetype)shared;

// MARK: - String Localization
/**
 * Returns a localized string for the given key
 * @param key The localization key
 * @return The localized string, or the key itself if no translation is found
 */
+ (NSString *)getString:(NSString *)key;

/**
 * Returns a localized string for the given key from the shared instance
 * @param key The localization key
 * @return The localized string, or the key itself if no translation is found
 */
- (NSString *)getString:(NSString *)key;

// MARK: - Bundle Access
/**
 * Returns the current localization bundle
 */
+ (NSBundle *)bundle;

/**
 * Returns the current locale
 */
+ (NSLocale *)locale;

@end
