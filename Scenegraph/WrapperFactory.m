//
//  WrapperFactory.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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
#import "WrapperFactory.h"
#import "FileTable.h"
#import "FileIndex.h"
#import "PackageMaintainer.h"
#import "PathProvider.h"
#import "Registry.h"
#import "ExceptionForm.h"
#import "WarningException.h"
#import "File.h"
#import "GroupCacheWrapper.h"
// Import specific wrappers
#import "PackedFile.h"
#import "TxtrWrapper.h"
#import "LifoWrapper.h"
#import "GenericRcolWrapper.h"
#import "MmatWrapper.h"
#import "SlotWrapper.h"
// Import command line implementations (uploaded by user)
#import "BuildTxtr.h"
#import "FixPackage.h"

// Forward declaration for Rcol class
@class Rcol;

@implementation ScenegraphWrapperFactory {
    static BOOL inited;
}

// MARK: - Static Initialization

+ (void)initialize {
    if (self == [ScenegraphWrapperFactory class]) {
        inited = NO;
    }
}

// MARK: - RCol Blocks Initialization

+ (void)initRcolBlocks {
    if (!inited) {
        // Add the assembly reference for GeometryDataContainer types
        // In Objective-C, we would register the classes with the Rcol system
        // This is equivalent to: Rcol.TokenAssemblies.Add(typeof(SimPe.Plugin.GeometryDataContainer).Assembly);
        // Implementation depends on how the Rcol token system is implemented in Objective-C
        [Rcol addTokenAssemblyForClass:[GeometryDataContainer class]];
        inited = YES;
    }
}

// MARK: - GroupCache Loading

+ (void)loadGroupCache {
    [self loadGroupCache:NO];
}

+ (void)loadGroupCache:(BOOL)force {
    if ([FileTable groupCache] != nil) {
        return;
    }

    GroupCache *gc = [[GroupCache alloc] init];

    if (![[Registry windowsRegistry] useMaxisGroupsCache] && !force) {
        [FileTable setGroupCache:gc];
        return;
    }

    @try {
        NSString *name = [NSString pathWithComponents:@[[PathProvider simSavegameFolder], @"Groups.cache"]];

        if ([[NSFileManager defaultManager] fileExistsAtPath:name]) {
            File *pkg = [File loadFromFile:name];
            id<IPackedFileDescriptor> pfd = [pkg findFileWithType:0x54535053 subtype:0 group:1 instance:1];
            if (pfd != nil) {
                [gc processData:pfd package:pkg sync:NO];
            }
        }
    }
    @catch (NSException *ex) {
        Warning *warning = [[Warning alloc] initWithMessage:@"Unable to load groups.cache"
                                                     details:ex.reason
                                                   exception:ex];
        [Helper exceptionMessage:warning];
    }

    [FileTable setGroupCache:gc];
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Prepare the FileIndex
        [FileTable setFileIndex:[[FileIndex alloc] init]];
        [[PackageMaintainer sharedMaintainer] setFileIndex:[[FileTable fileIndex] addNewChild]];
    }
    return self;
}

// MARK: - AbstractWrapperFactory Implementation

- (NSArray<id<IWrapper>> *)knownWrappers {
    [ScenegraphWrapperFactory initRcolBlocks];
    
    NSMutableArray<id<IWrapper>> *wrappers = [[NSMutableArray alloc] init];
    
    // Add all the wrappers equivalent to the C# version
    [wrappers addObject:[[RefFile alloc] init]];
    [wrappers addObject:[[Txtr alloc] initWithProvider:self.linkedProvider fast:NO]];
    // [wrappers addObject:[[Matd alloc] initWithProvider:self.linkedProvider fast:NO]]; // Commented in original
    [wrappers addObject:[[Lifo alloc] initWithProvider:self.linkedProvider fast:NO]];
    // [wrappers addObject:[[Shpe alloc] initWithProvider:self.linkedProvider]]; // Commented in original
    [wrappers addObject:[[GenericRcol alloc] initWithProvider:self.linkedProvider fast:NO]];
    [wrappers addObject:[[MmatWrapper alloc] init]];
    [wrappers addObject:[[GroupCache alloc] init]];
    [wrappers addObject:[[Slot alloc] init]];
    
    return [wrappers copy];
}

// MARK: - ICommandLineFactory Implementation

- (NSArray<id<ICommandLine>> *)knownCommandLines {
    NSMutableArray<id<ICommandLine>> *commandLines = [[NSMutableArray alloc] init];
    
    [commandLines addObject:[[BuildTxtr alloc] init]];
    [commandLines addObject:[[FixPackage alloc] init]];
    
    return [commandLines copy];
}

@end
