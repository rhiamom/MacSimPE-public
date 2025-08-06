//
//  NamedPackedFileDescriptor.m
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
// ***************************************************************************/

#import "NamedPackedFileDescriptor.h"
#import "FileIndexItem.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "Registry.h"
#import "FileTableBase.h"
#import "IPackedFileWrapper.h"
#import "AbstractWrapper.h"
#import "TypeRegistry.h"

@interface NamedPackedFileDescriptor ()
@property (nonatomic, strong, readwrite) id<IPackedFileDescriptor> descriptor;
@property (nonatomic, strong, readwrite) id<IPackageFile> package;
@property (nonatomic, strong, readwrite) FileIndexItem *resource;
@property (nonatomic, strong) NSString *realName;
@end

@implementation NamedPackedFileDescriptor

// MARK: - Initialization

- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)descriptor
                           package:(id<IPackageFile>)package {
    self = [super init];
    if (self) {
        _descriptor = descriptor;
        _package = package;
        _resource = [[FileIndexItem alloc] initWithDescriptor:descriptor package:package];
        _realName = nil;
    }
    return self;
}

// MARK: - Properties

- (BOOL)realNameLoaded {
    return (self.realName != nil);
}

// MARK: - Name Resolution

- (void)resetRealName {
    self.realName = nil;
}

- (NSString *)getRealName {
    if (self.realName == nil) {
        if ([Registry.windowsRegistry decodeFilenamesState]) {
            id<IPackedFileWrapper> wrapper = [TypeRegistry findHandler:[self.descriptor type]];
            
            if (wrapper != nil) {
                @synchronized (wrapper) {
                    // System.Diagnostics.Debug.WriteLine("Processing " + pfd.Type.ToString("X")+" "+pfd.Offset.ToString("X"));
                    
                    id<IPackedFileDescriptor> backupDescriptor = nil;
                    id<IPackageFile> backupPackage = nil;
                    
                    if ([wrapper isKindOfClass:[AbstractWrapper class]]) {
                        AbstractWrapper *abstractWrapper = (AbstractWrapper *)wrapper;
                        
                        if (![abstractWrapper allowMultipleInstances]) {
                            backupDescriptor = [abstractWrapper fileDescriptor];
                            backupPackage = [abstractWrapper package];
                        }
                        
                        [abstractWrapper setFileDescriptor:self.descriptor];
                        [abstractWrapper setPackage:self.package];
                    }
                    
                    @try {
                        self.realName = [wrapper resourceName];
                    }
                    @catch (NSException *exception) {
#ifdef DEBUG
                        self.realName = [exception reason];
#else
                        self.realName = [self.descriptor toResListString];
#endif
                    }
                    @finally {
                        // Restore original state
                        if (backupDescriptor != nil || backupPackage != nil) {
                            if ([wrapper isKindOfClass:[AbstractWrapper class]]) {
                                AbstractWrapper *abstractWrapper = (AbstractWrapper *)wrapper;
                                
                                if (![abstractWrapper allowMultipleInstances]) {
                                    [abstractWrapper setFileDescriptor:backupDescriptor];
                                    [abstractWrapper setPackage:backupPackage];
                                }
                            }
                        }
                    }
                } // @synchronized
            }
        }
        
        if (self.realName == nil) {
            self.realName = [self.descriptor toResListString];
        }
    }
    
    return self.realName;
}

@end
