//
//  LoadFileWrappers.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/15/25.
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

#import "LoadFileWrappers.h"
#import "IWrapperRegistry.h"
#import "IToolRegistry.h"
#import "IWrapperFactory.h"
#import "IToolFactory.h"
#import "ITool.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IToolResult.h"
#import "ErrorWrapper.h"
#import "Helper.h"
#import "Localization.h"
#import "WaitingScreen.h"
#import "ExceptionForm.h"
#import <objc/runtime.h>

// MARK: - PackageArg Implementation

@implementation PackageArg
@end

// MARK: - ToolMenuItem Implementation

@implementation ToolMenuItem

- (instancetype)initWithTool:(id<ITool>)tool changeHandler:(void (^)(PackageArg *args))changeHandler {
    self = [super init];
    if (self) {
        _tool = tool;
        _changeHandler = changeHandler;
        
        NSString *name = [tool description];
        NSArray *parts = [name componentsSeparatedByString:@"\\"];
        name = [Localization getString:[parts lastObject]];
        [self setTitle:name];
        
        [self setTarget:self];
        [self setAction:@selector(clickItem:)];
    }
    return self;
}

- (void)clickItem:(id)sender {
    @try {
        if ([self.tool isEnabledForFileDescriptor:self.fileDescriptor package:self.package]) {
            id<IPackedFileDescriptor> pfd = self.fileDescriptor;
            id<IPackageFile> package = self.package;
            
            id<IToolResult> tr = [self.tool showDialogWithFileDescriptor:&pfd package:&package];
            [WaitingScreen stop];
            
            if ([tr changedAny]) {
                PackageArg *p = [[PackageArg alloc] init];
                p.package = package;
                p.fileDescriptor = pfd;
                p.result = tr;
                
                if (self.changeHandler) {
                    self.changeHandler(p);
                }
            }
        }
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:@"Unable to Start ToolPlugin." exception:ex];
    }
}

- (NSString *)description {
    @try {
        return [self.tool description];
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:@"Unable to Load ToolPlugin." exception:ex];
    }
    return @"Plugin Error";
}

- (void)updateEnabledState {
    @try {
        [self setEnabled:[self.tool isEnabledForFileDescriptor:self.fileDescriptor package:self.package]];
    } @catch (NSException *ex) {
        [self setEnabled:NO];
    }
}

@end

// MARK: - LoadFileWrappersExt Implementation

@implementation LoadFileWrappersExt

- (instancetype)initWithWrapperRegistry:(id<IWrapperRegistry>)registry toolRegistry:(id<IToolRegistry>)toolRegistry {
    self = [super init];
    if (self) {
        _reg = registry;
        _treg = toolRegistry;
        _ignore = [[NSMutableArray alloc] init];
        [_ignore addObject:@"simpe.3d.plugin.dll"];
    }
    return self;
}

@end

// MARK: - LoadFileWrappers Implementation

@implementation LoadFileWrappers

// MARK: - Initialization

- (instancetype)initWithWrapperRegistry:(id<IWrapperRegistry>)registry toolRegistry:(id<IToolRegistry>)toolRegistry {
    self = [super init];
    if (self) {
        _reg = registry;
        _treg = toolRegistry;
        [self createIgnoreList];
    }
    return self;
}

- (void)createIgnoreList {
    self.ignore = [[NSMutableArray alloc] init];
    [self.ignore addObject:@"simpe.3d.plugin.dll"];
}

// MARK: - Static Plugin Loading Methods

+ (NSArray *)loadPluginsFromBundle:(NSBundle *)bundle
                       forProtocol:(Protocol *)protocol
                     withArguments:(NSArray *)arguments {
    if (bundle == nil) {
        return @[];
    }
    
    NSMutableArray *plugins = [[NSMutableArray alloc] init];
    
    @try {
        // Get all classes in the bundle
        NSArray *classes = [self getClassesFromBundle:bundle];
        
        for (Class class in classes) {
            // Skip interfaces and abstract classes
            if (class_isMetaClass(class)) continue;
            
            @try {
                // Check if class conforms to protocol
                if ([class conformsToProtocol:protocol]) {
                    @try {
                        id obj = nil;
                        
                        // Try to create with arguments
                        if (arguments && [arguments count] > 0) {
                            @try {
                                obj = [self createInstanceOfClass:class withArguments:arguments];
                            } @catch (NSException *ex) {
                                // Fall back to default constructor
                                obj = [[class alloc] init];
                            }
                        } else {
                            obj = [[class alloc] init];
                        }
                        
                        if (obj != nil) {
                            [plugins addObject:obj];
                        }
                    } @catch (NSException *ex) {
                        [ExceptionForm executeWithMessage:[NSString stringWithFormat:@"Unable to load %@", NSStringFromClass(class)]
                                        exception:[[NSException alloc] initWithName:@"LoadError"
                                                                             reason:[NSString stringWithFormat:@"Unable to load %@ from '%@'", NSStringFromClass(class), [bundle bundlePath]]
                                                                           userInfo:@{NSUnderlyingErrorKey: ex}]];
                    }
                }
            } @catch (NSException *ex) {
                [ExceptionForm executeWithMessage:[NSString stringWithFormat:@"Unable to get protocol conformance for %@", NSStringFromClass(class)]
                                exception:ex];
            }
        }
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[NSString stringWithFormat:@"Unable to load plugin \"%@\"", [bundle bundlePath]]
                        exception:ex];
    }
    
    return [plugins copy];
}

+ (NSArray *)loadPluginsFromFile:(NSString *)filePath
                     forProtocol:(Protocol *)protocol
                   withArguments:(NSArray *)arguments {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return @[];
    }
    
    if (![Helper canLoadPlugin:filePath]) {
        return @[];
    }
    
    // For Objective-C, we'll load bundles instead of .NET assemblies
    NSBundle *bundle = [NSBundle bundleWithPath:filePath];
    if (bundle == nil) {
        return @[];
    }
    
    return [self loadPluginsFromBundle:bundle forProtocol:protocol withArguments:arguments];
}

+ (id)loadPluginFromFile:(NSString *)filePath
             forProtocol:(Protocol *)protocol
                     lfw:(LoadFileWrappersExt *)lfw {
    NSString *fileName = [[filePath lastPathComponent] lowercaseString];
    if ([lfw.ignore containsObject:fileName]) {
        return nil;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    if (![Helper canLoadPlugin:filePath]) {
        return nil;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:filePath];
    if (bundle == nil) {
        return nil;
    }
    
    @try {
        NSArray *classes = [self getClassesFromBundle:bundle];
        
        for (Class class in classes) {
            if ([class conformsToProtocol:protocol]) {
                id obj = [[class alloc] init];
                return obj;
            }
        }
    } @catch (NSException *ex) {
        NSLog(@"Exception loading plugin: %@", ex);
    }
    
    return nil;
}

+ (void)loadWrapperFactory:(NSString *)filePath lfw:(LoadFileWrappersExt *)lfw {
    id obj = [self loadPluginFromFile:filePath forProtocol:@protocol(IWrapperFactory) lfw:lfw];
    if (obj != nil) {
        [lfw.reg registerWrapperFactory:(id<IWrapperFactory>)obj];
    }
}

+ (void)loadToolFactory:(NSString *)filePath lfw:(LoadFileWrappersExt *)lfw {
    id obj = [self loadPluginFromFile:filePath forProtocol:@protocol(IToolFactory) lfw:lfw];
    if (obj != nil) {
        [lfw.treg registerToolFactory:(id<IToolFactory>)obj];
    }
}

+ (void)loadErrorWrapper:(ErrorWrapper *)wrapper lfw:(LoadFileWrappersExt *)lfw {
    [lfw.reg registerWrapper:wrapper];
}

// MARK: - Menu Management

- (void)addMenuItems:(NSMenu *)menu changeHandler:(void (^)(PackageArg *args))changeHandler {
    NSArray *tools = [self.treg tools];
    for (id<ITool> tool in tools) {
        ToolMenuItem *item = [[ToolMenuItem alloc] initWithTool:tool changeHandler:changeHandler];
        [menu addItem:item];
    }
    
    NSArray *docks = [self.treg docks];
    for (id<IToolPlugin> toolPlugin in docks) {
        if ([toolPlugin conformsToProtocol:@protocol(ITool)]) {
            ToolMenuItem *item = [[ToolMenuItem alloc] initWithTool:(id<ITool>)toolPlugin changeHandler:changeHandler];
            [menu addItem:item];
        }
    }
    
    [self enableMenuItems:menu fileDescriptor:nil package:nil];
}

- (void)enableMenuItems:(NSMenu *)menu
         fileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor
                package:(id<IPackageFile>)package {
    for (NSMenuItem *item in [menu itemArray]) {
        @try {
            if ([item isKindOfClass:[ToolMenuItem class]]) {
                ToolMenuItem *tmi = (ToolMenuItem *)item;
                tmi.package = package;
                tmi.fileDescriptor = fileDescriptor;
                [tmi updateEnabledState];
            }
        } @catch (NSException *ex) {
            // Ignore exceptions in menu item setup
        }
    }
}

// MARK: - Helper Methods

+ (NSArray *)getClassesFromBundle:(NSBundle *)bundle {
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    
    // Load the bundle
    if (![bundle isLoaded]) {
        [bundle load];
    }
    
    // Get classes from bundle - this is a simplified approach
    // In a real implementation, you might need to parse the bundle's executable
    // or use runtime introspection to find all classes
    
    // For now, we'll return an empty array as this requires more complex
    // Objective-C runtime introspection that would need the specific bundle format
    NSLog(@"Class enumeration from bundle not yet implemented: %@", [bundle bundlePath]);
    
    return [classes copy];
}

+ (id)createInstanceOfClass:(Class)class withArguments:(NSArray *)arguments {
    // Simplified instance creation - in a real implementation,
    // you would need to match constructor signatures with arguments
    
    if ([arguments count] == 0) {
        return [[class alloc] init];
    }
    
    // For now, just try the default constructor
    return [[class alloc] init];
}

@end
