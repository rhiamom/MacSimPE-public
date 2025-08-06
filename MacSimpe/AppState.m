//
//  AppState.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *  Copyright (C) 2025 by GramzeSweatShop                                  *
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "AppState.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "TGILoader.h"
#import "TypeRegistry.h"
#import "GenericRcol.h"
#import "Txtr.h"
#import "FileTableBase.h"
#import "PackageMaintainer.h"
#import "RemoteControl.h"

// Notification names
NSString * const AppStatePackageChangedNotification = @"AppStatePackageChanged";
NSString * const AppStateLoadingChangedNotification = @"AppStateLoadingChanged";
NSString * const AppStateErrorChangedNotification = @"AppStateErrorChanged";
NSString * const AppStateUnsavedChangesNotification = @"AppStateUnsavedChanges";

@implementation AppState

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentPackage = nil;
        _isLoading = NO;
        _errorMessage = nil;
        _hasUnsavedChanges = NO;
    }
    return self;
}

- (void)initialize {
    // Initialize TGI Loader if needed
    if ([TGILoader shared] == nil) {
        [TGILoader setShared:[[TGILoader alloc] init]];
        [self setupRemoteControlHandlers];
    }
    
    // Set default for filename decoding
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"DecodeFilenames"] == nil) {
        [defaults setBool:YES forKey:@"DecodeFilenames"];
    }
    
    // Set up the TypeRegistry
    TypeRegistry *registry = [[TypeRegistry alloc] init];
    
    // Create and register the GenericRcol wrapper
    GenericRcol *rcolWrapper = [[GenericRcol alloc] init];
    [registry registerWrapper:rcolWrapper];
    
    // Register the Txtr wrapper
    Txtr *txtrWrapper = [[Txtr alloc] init];
    [registry registerWrapper:txtrWrapper];
    
    // Set it globally so other parts can use it
    [FileTableBase setWrapperRegistry:registry];
    
    NSLog(@"TypeRegistry setup complete with %ld handlers", (long)[[registry wrappers] count]);
    
    [FileTableBase loadPackageFiles];
}

// MARK: - Property Setters with Notifications

- (void)setCurrentPackage:(id<IPackageFile>)currentPackage {
    if (_currentPackage != currentPackage) {
        NSLog(@"🔍 Package changing from: %@ to: %@",
              _currentPackage ? @"not nil" : @"nil",
              currentPackage ? @"not nil" : @"nil");
        
        _currentPackage = currentPackage;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppStatePackageChangedNotification
                                                            object:self];
    }
}

- (void)setIsLoading:(BOOL)isLoading {
    if (_isLoading != isLoading) {
        _isLoading = isLoading;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppStateLoadingChangedNotification
                                                            object:self];
    }
}

- (void)setErrorMessage:(NSString *)errorMessage {
    if (![_errorMessage isEqualToString:errorMessage]) {
        _errorMessage = errorMessage;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppStateErrorChangedNotification
                                                            object:self];
    }
}

- (void)setHasUnsavedChanges:(BOOL)hasUnsavedChanges {
    if (_hasUnsavedChanges != hasUnsavedChanges) {
        _hasUnsavedChanges = hasUnsavedChanges;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppStateUnsavedChangesNotification
                                                            object:self];
    }
}

// MARK: - Package Management

- (void)openPackage {
    NSLog(@"🔍 openPackage called, currentPackage is: %@",
          self.currentPackage == nil ? @"nil" : @"not nil");
    
    // Check if a package is already open (like original SimPE)
    if (self.currentPackage != nil) {
        NSLog(@"🔍 Preventing second package open");
        self.errorMessage = @"A package is already open. Please close the current package first.";
        return;
    }
    
    NSLog(@"🔍 Opening file dialog");
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:@[@"package"]];
    [panel setAllowsMultipleSelection:NO];
    
    NSModalResponse result = [panel runModal];
    if (result == NSModalResponseOK) {
        NSURL *url = [[panel URLs] firstObject];
        NSLog(@"🔍 File selected: %@", [url path]);
        [self loadPackageFromPath:[url path]];
    } else {
        NSLog(@"🔍 File dialog cancelled");
    }
}

- (void)loadPackageFromPath:(NSString *)path {
    self.isLoading = YES;
    self.errorMessage = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            id<IPackageFile> package = [[PackageMaintainer maintainer] loadPackageFromFile:path
                                                                                      sync:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentPackage = package;
                self.isLoading = NO;
            });
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.errorMessage = [NSString stringWithFormat:@"Failed to load package: %@",
                                   [exception reason]];
                self.isLoading = NO;
            });
        }
    });
}

- (void)savePackage {
    if (self.currentPackage == nil) {
        return;
    }
    
    @try {
        [self.currentPackage save];
        self.hasUnsavedChanges = NO;
    } @catch (NSException *exception) {
        self.errorMessage = [NSString stringWithFormat:@"Failed to save: %@", [exception reason]];
    }
}

- (void)closePackage {
    if (self.hasUnsavedChanges) {
        self.errorMessage = @"Package has unsaved changes. Save first.";
        return;
    }
    
    self.currentPackage = nil;
    self.hasUnsavedChanges = NO;
    self.errorMessage = nil;
}

- (void)markChanged {
    self.hasUnsavedChanges = YES;
}

// MARK: - Remote Control Handlers

- (void)setupRemoteControlHandlers {
    __weak typeof(self) weakSelf = self;
    
    [RemoteControl setOpenPackedFileHandler:^BOOL(id<IPackedFileDescriptor> pfd, id<IPackageFile> pkg) {
        return [weakSelf openPackedFile:pfd package:pkg];
    }];
    
    [RemoteControl setOpenPackageHandler:^BOOL(NSString *filename) {
        return [weakSelf openPackageWithFilename:filename];
    }];
}

- (BOOL)openPackedFile:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)pkg {
    NSLog(@"Remote control: Navigate to packed file: %@ in package: %@", pfd, pkg);
    return YES;
}

- (BOOL)openPackageWithFilename:(NSString *)filename {
    NSLog(@"Remote control: Load package: %@", filename);
    [self loadPackageFromPath:filename];
    return YES;
}

@end
