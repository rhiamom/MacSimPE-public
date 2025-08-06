//
//  Warning.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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
 * An Exception that is interpreted as Warning
 */
@interface Warning : NSObject

// MARK: - Properties
@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, strong, readonly) NSString *details;
@property (nonatomic, strong, readonly) NSException *innerException;

// MARK: - Initialization
/**
 * Create a new Warning with message and details
 * @param message The warning message
 * @param details Additional details about the warning
 */
- (instancetype)initWithMessage:(NSString *)message details:(NSString *)details;

/**
 * Create a new Warning with message, details and inner exception
 * @param message The warning message
 * @param details Additional details about the warning
 * @param innerException The underlying exception that caused this warning
 */
- (instancetype)initWithMessage:(NSString *)message
                        details:(NSString *)details
                      exception:(NSException *)innerException;

/**
 * Convenience initializer with title and description (matching XmlRegistry usage)
 * @param title The warning title
 * @param description The warning description
 * @param exception The underlying exception
 */
- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                    exception:(NSException *)exception;

@end
