//
//  ExceptionForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
// ***************************************************************************
// *   Copyright (C) 2025 by GramzeSweatShop                                  *
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
//
//  ExceptionForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/31/25.
//
// ***************************************************************************
// *   Copyright (C) 2025 by GramzeSweatShop                                  *
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

#import <Cocoa/Cocoa.h>
#import "ExceptionForm.h"
#import "WarningException.h"
#import "Helper.h"

@implementation ExceptionForm

// MARK: - Class Properties

static BOOL _errorsEnabled = YES;
static BOOL _showDetailedErrors = NO;

+ (BOOL)errorsEnabled {
    return _errorsEnabled;
}

+ (void)setErrorsEnabled:(BOOL)errorsEnabled {
    _errorsEnabled = errorsEnabled;
}

+ (BOOL)showDetailedErrors {
    return _showDetailedErrors;
}

+ (void)setShowDetailedErrors:(BOOL)showDetailedErrors {
    _showDetailedErrors = showDetailedErrors;
}

// MARK: - Original API Compatibility

+ (void)execute:(NSException *)exception {
    if (!_errorsEnabled) return;
    
    [self executeWithMessage:nil exception:exception];
}

+ (void)executeWithMessage:(NSString *)message exception:(NSException *)exception {
    if (!_errorsEnabled) return;
    
    // Log the exception first
    [self logException:exception];
    
    // Prepare the display message
    NSString *displayMessage = message;
    if (!displayMessage || displayMessage.length == 0) {
        displayMessage = exception.reason ?: @"An unknown error occurred";
    }
    
    // Check if this is a Warning object passed as userInfo
    Warning *warning = exception.userInfo[@"warning"];
    if (warning) {
        [self showWarningObject:warning];
        return;
    }
    
    // Check if the exception name indicates it's a warning
    if ([exception.name isEqualToString:@"Warning"]) {
        // Create a Warning object from the exception
        Warning *warningObj = [[Warning alloc] initWithMessage:exception.reason
                                                        details:exception.userInfo[@"details"]
                                                      exception:exception.userInfo[NSUnderlyingErrorKey]];
        [self showWarningObject:warningObj];
        return;
    }
    
    // Check for DirectX-related errors (maintain compatibility with original)
    if ([displayMessage containsString:@"Microsoft.DirectX"]) {
        NSString *directXMessage = @"You need to install MANAGED DirectX";
        NSString *directXDetails = @"In order to perform some operations, you need to install Managed DirectX (which is an additional set of libraries for the DirectX you installed with The Sims 2).\n\nThis error indicates missing DirectX components.";
        
        [self showError:directXMessage withDetails:directXDetails exception:exception];
        return;
    }
    
    // Format detailed error information
    NSString *details = [self formatExceptionDetails:exception];
    
    [self showError:displayMessage withDetails:details exception:exception];
}

// MARK: - Native Error Display Methods

/**
 * Show a warning dialog with details using your existing Warning class
 * @param warning The Warning object containing message and details
 */
+ (void)showWarningObject:(Warning *)warning {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Warning";
        alert.informativeText = warning.message ?: @"A warning occurred";
        alert.alertStyle = NSAlertStyleWarning;
        
        [alert addButtonWithTitle:@"OK"];
        
        // Add details button if warning has details
        if (warning.details && warning.details.length > 0) {
            [alert addButtonWithTitle:@"Details"];
        }
        
        NSModalResponse response = [alert runModal];
        
        // If user clicked Details, show detailed information
        if (response == NSAlertSecondButtonReturn) {
            [self showError:warning.message withDetails:warning.details exception:warning.innerException];
        }
    });
}

+ (void)showWarning:(Warning *)warning {
    [self showWarningObject:warning];
}

+ (void)showError:(NSString *)message {
    [self showError:message withDetails:nil];
}

+ (void)showError:(NSString *)message withDetails:(NSString *)details {
    [self showError:message withDetails:details exception:nil];
}

+ (void)showError:(NSString *)message
      withDetails:(NSString *)details
        exception:(NSException *)exception {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Error";
        alert.informativeText = message ?: @"An error occurred";
        alert.alertStyle = NSAlertStyleCritical;
        
        [alert addButtonWithTitle:@"OK"];
        
        // Add Details button if we have detailed information
        if ((details && details.length > 0) || _showDetailedErrors) {
            [alert addButtonWithTitle:@"Details"];
        }
        
        // Add Copy button for detailed errors
        if (details && details.length > 0) {
            [alert addButtonWithTitle:@"Copy"];
        }
        
        NSModalResponse response = [alert runModal];
        
        // Handle button responses
        if (response == NSAlertSecondButtonReturn) {
            // Details button clicked
            [self showDetailedErrorDialog:message details:details exception:exception];
        } else if (response == NSAlertThirdButtonReturn) {
            // Copy button clicked
            [self copyDetailsToClipboard:message details:details exception:exception];
        }
    });
}

// MARK: - Detailed Error Display

+ (void)showDetailedErrorDialog:(NSString *)message
                        details:(NSString *)details
                      exception:(NSException *)exception {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create a detailed error window
        NSAlert *detailAlert = [[NSAlert alloc] init];
        detailAlert.messageText = @"Error Details";
        detailAlert.alertStyle = NSAlertStyleInformational;
        
        // Create the detailed message
        NSMutableString *detailedInfo = [[NSMutableString alloc] init];
        
        if (message) {
            [detailedInfo appendFormat:@"Message:\n%@\n\n", message];
        }
        
        // Add application version info
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *build = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        if (version || build) {
            [detailedInfo appendFormat:@"SimPE Version:\n%@ (%@)\n\n",
             version ?: @"Unknown", build ?: @"Unknown"];
        }
        
        // Add system information
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        [detailedInfo appendFormat:@"macOS Version:\n%@\n\n",
         processInfo.operatingSystemVersionString];
        
        // Add exception details if available
        if (exception) {
            [detailedInfo appendFormat:@"Exception Details:\n%@\n\n",
             [self formatExceptionDetails:exception]];
        }
        
        // Add custom details
        if (details) {
            [detailedInfo appendFormat:@"Additional Information:\n%@", details];
        }
        
        detailAlert.informativeText = [detailedInfo copy];
        
        [detailAlert addButtonWithTitle:@"OK"];
        [detailAlert addButtonWithTitle:@"Copy to Clipboard"];
        
        NSModalResponse response = [detailAlert runModal];
        
        if (response == NSAlertSecondButtonReturn) {
            // Copy to clipboard
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            [pasteboard setString:detailedInfo forType:NSPasteboardTypeString];
        }
    });
}

// MARK: - Clipboard Support

+ (void)copyDetailsToClipboard:(NSString *)message
                       details:(NSString *)details
                     exception:(NSException *)exception {
    
    NSMutableString *clipboardText = [[NSMutableString alloc] init];
    
    if (message) {
        [clipboardText appendFormat:@"Error: %@\n\n", message];
    }
    
    if (details) {
        [clipboardText appendFormat:@"Details:\n%@\n\n", details];
    }
    
    if (exception) {
        [clipboardText appendFormat:@"Exception Information:\n%@\n",
         [self formatExceptionDetails:exception]];
    }
    
    // Add system info
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    [clipboardText appendFormat:@"\nApplication: SimPE for Mac %@ (%@)\n",
     version ?: @"Unknown", build ?: @"Unknown"];
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [clipboardText appendFormat:@"System: %@\n", processInfo.operatingSystemVersionString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard setString:[clipboardText copy] forType:NSPasteboardTypeString];
        
        // Show confirmation
        NSAlert *confirmAlert = [[NSAlert alloc] init];
        confirmAlert.messageText = @"Copied to Clipboard";
        confirmAlert.informativeText = @"Error details have been copied to the clipboard.";
        confirmAlert.alertStyle = NSAlertStyleInformational;
        [confirmAlert addButtonWithTitle:@"OK"];
        [confirmAlert runModal];
    });
}

// MARK: - Logging Support

+ (void)logException:(NSException *)exception {
    if (!exception) return;
    
    NSString *logMessage = [NSString stringWithFormat:@"[ERROR] %@: %@",
                           exception.name, exception.reason];
    NSLog(@"%@", logMessage);
    
    // Log call stack if available
    if (exception.callStackSymbols && exception.callStackSymbols.count > 0) {
        NSLog(@"[ERROR] Call Stack:");
        for (NSString *symbol in exception.callStackSymbols) {
            NSLog(@"[ERROR]   %@", symbol);
        }
    }
    
    // Log user info if available
    if (exception.userInfo && exception.userInfo.count > 0) {
        NSLog(@"[ERROR] User Info: %@", exception.userInfo);
    }
}

+ (NSString *)formatExceptionDetails:(NSException *)exception {
    if (!exception) return @"No exception information available";
    
    NSMutableString *details = [[NSMutableString alloc] init];
    
    [details appendFormat:@"Exception: %@\n", exception.name ?: @"Unknown"];
    [details appendFormat:@"Reason: %@\n", exception.reason ?: @"No reason provided"];
    
    if (exception.userInfo && exception.userInfo.count > 0) {
        [details appendFormat:@"User Info: %@\n", exception.userInfo];
    }
    
    if (exception.callStackSymbols && exception.callStackSymbols.count > 0) {
        [details appendString:@"\nCall Stack:\n"];
        for (NSString *symbol in exception.callStackSymbols) {
            [details appendFormat:@"  %@\n", symbol];
        }
    }
    
    return [details copy];
}

@end
