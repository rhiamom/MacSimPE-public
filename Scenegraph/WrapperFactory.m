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
#import "PackedFileWrapper.h"
#import "TxtrWrapper.h"
#import "LifoWrapper.h"
#import "GenericRcolWrapper.h"
#import "MmatWrapper.h"
#import "SlotWrapper.h"
// Import command line implementations (uploaded by user)
#import "BuildTxtr.h"
#import "FixPackage.h"
#import "GeneratableFile.h"

// Tell the compiler these selectors exist somewhere at runtime.
// They don't create methods, they just silence undeclared-selector warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@interface NSObject (RcolSelectors)
+ (void)addTokenAssemblyForClass:(Class)cls;
+ (id)sharedRegistry;
+ (id)defaultRegistry;
+ (id)currentRegistry;
@end
#pragma clang diagnostic pop

// Forward declaration for Rcol class
@class Rcol;

static BOOL inited;

@implementation ScenegraphWrapperFactory

// MARK: - Static Initialization

+ (void)initialize {
    if (self == [ScenegraphWrapperFactory class]) {
        inited = NO;
    }
}

// MARK: - RCol Blocks Initialization

+ (void)initRcolBlocks {
    if (inited) return;
    
    Class gmdc = NSClassFromString(@"GeometryDataContainer");
    if (gmdc) {
        Class rcolClass = NSClassFromString(@"Rcol");
        if (rcolClass) {
            // Prefer a class API if it exists
            if ([rcolClass respondsToSelector:@selector(addTokenAssemblyForClass:)]) {
                [rcolClass performSelector:@selector(addTokenAssemblyForClass:) withObject:gmdc];
            }
            // Otherwise try a singleton-style instance
            else {
                id rcol = nil;
                if ([rcolClass respondsToSelector:@selector(sharedRegistry)]) {
                    rcol = [rcolClass performSelector:@selector(sharedRegistry)];
                } else if ([rcolClass respondsToSelector:@selector(defaultRegistry)]) {
                    rcol = [rcolClass performSelector:@selector(defaultRegistry)];
                } else if ([rcolClass respondsToSelector:@selector(currentRegistry)]) {
                    rcol = [rcolClass performSelector:@selector(currentRegistry)];
                }
                if (rcol && [rcol respondsToSelector:@selector(addTokenAssemblyForClass:)]) {
                    [rcol performSelector:@selector(addTokenAssemblyForClass:) withObject:gmdc];
                }
            }
        }
    }
    inited = YES;
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
            GeneratableFile *pkg = [File loadFromFile:name];  // Change File * to GeneratableFile *
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
        [ExceptionForm showWarning:warning];
    }

    [FileTable setGroupCache:gc];
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Prepare the FileIndex
        [FileTable setFileIndex:[[FileIndex alloc] init]];
        [[PackageMaintainer maintainer] setFileIndex:[[FileTable fileIndex] addNewChild]];
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
