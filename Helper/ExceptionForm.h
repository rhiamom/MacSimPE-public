//
//  ExceptionForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
// ***************************************************************************
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
#import "WarningException.h"

/**
 * Native macOS error handling system that replaces the Windows Forms ExceptionForm
 * Uses NSAlert and native macOS UI patterns for better user experience
 */
@interface ExceptionForm : NSObject

// MARK: - Main Error Display Methods (matching original API)

/**
 * Show an Exception Message
 * @param exception The exception that was thrown
 */
+ (void)execute:(NSException *)exception;

/**
 * Show an Exception Message with custom message
 * @param message The message you want to display
 * @param exception The exception that was thrown
 */
+ (void)executeWithMessage:(NSString *)message exception:(NSException *)exception;

// MARK: - Enhanced Native Methods

/**
 * Show a warning dialog with details
 * @param warning The Warning object containing message and details
 */
+ (void)showWarning:(Warning *)warning;

/**
 * Show a simple error alert
 * @param message The error message to display
 */
+ (void)showError:(NSString *)message;

/**
 * Show an error alert with detailed information
 * @param message The main error message
 * @param details Additional details about the error
 */
+ (void)showError:(NSString *)message withDetails:(NSString *)details;

/**
 * Show an error alert with detailed information and allow copying to clipboard
 * @param message The main error message
 * @param details Additional details about the error
 * @param exception The original exception for logging
 */
+ (void)showError:(NSString *)message
      withDetails:(NSString *)details
        exception:(NSException *)exception;

// MARK: - Configuration

/**
 * Enable or disable error reporting (matches Helper.NoErrors)
 */
@property (class, nonatomic, assign) BOOL errorsEnabled;

/**
 * Enable or disable detailed error information in alerts
 */
@property (class, nonatomic, assign) BOOL showDetailedErrors;

// MARK: - Logging Support

/**
 * Log exception details to console without showing UI
 * @param exception The exception to log
 */
+ (void)logException:(NSException *)exception;

/**
 * Get formatted exception details for logging or display
 * @param exception The exception to format
 * @returns Formatted string with exception details
 */
+ (NSString *)formatExceptionDetails:(NSException *)exception;

@end
