//
//  LoadFileWrappers.h
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@protocol IWrapperRegistry;
@protocol IToolRegistry;
@protocol IWrapperFactory;
@protocol IToolFactory;
@protocol ITool;
@protocol IToolPlugin;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IToolResult;
@class ErrorWrapper;

// MARK: - PackageArg

@interface PackageArg : NSObject

@property (nonatomic, strong) id<IPackageFile> package;
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;
@property (nonatomic, strong) id<IToolResult> result;

@end

// MARK: - ToolMenuItem

@interface ToolMenuItem : NSMenuItem

@property (nonatomic, strong) id<ITool> tool;
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;
@property (nonatomic, strong) id<IPackageFile> package;
@property (nonatomic, copy) void (^changeHandler)(PackageArg *args);

- (instancetype)initWithTool:(id<ITool>)tool changeHandler:(void (^)(PackageArg *args))changeHandler;
- (void)updateEnabledState;

@end

// MARK: - LoadFileWrappersExt

@interface LoadFileWrappersExt : NSObject

@property (nonatomic, strong) id<IWrapperRegistry> reg;
@property (nonatomic, strong) id<IToolRegistry> treg;
@property (nonatomic, strong) NSMutableArray *ignore;

- (instancetype)initWithWrapperRegistry:(id<IWrapperRegistry>)registry toolRegistry:(id<IToolRegistry>)toolRegistry;

@end

// MARK: - LoadFileWrappers

@interface LoadFileWrappers : NSObject

// MARK: - Properties
@property (nonatomic, strong) id<IWrapperRegistry> reg;
@property (nonatomic, strong) id<IToolRegistry> treg;
@property (nonatomic, strong) NSMutableArray *ignore;

// MARK: - Initialization
- (instancetype)initWithWrapperRegistry:(id<IWrapperRegistry>)registry toolRegistry:(id<IToolRegistry>)toolRegistry;

// MARK: - Static Plugin Loading Methods

/**
 * Loads plugins from a bundle that implement a specific protocol
 * @param bundle The NSBundle to search in
 * @param protocol The protocol the classes must implement
 * @param arguments Array of arguments to pass to constructors
 * @returns Array of instantiated objects implementing the protocol
 */
+ (NSArray *)loadPluginsFromBundle:(NSBundle *)bundle
                       forProtocol:(Protocol *)protocol
                     withArguments:(NSArray *)arguments;

/**
 * Loads plugins from a file that implement a specific protocol
 * @param filePath The file path to load from
 * @param protocol The protocol the classes must implement
 * @param arguments Array of arguments to pass to constructors
 * @returns Array of instantiated objects implementing the protocol
 */
+ (NSArray *)loadPluginsFromFile:(NSString *)filePath
                     forProtocol:(Protocol *)protocol
                   withArguments:(NSArray *)arguments;

/**
 * Loads a single plugin from a file that implements a specific protocol
 * @param filePath The file path to load from
 * @param protocol The protocol the class must implement
 * @param lfw The LoadFileWrappersExt instance for context
 * @returns The instantiated object or nil
 */
+ (id)loadPluginFromFile:(NSString *)filePath
             forProtocol:(Protocol *)protocol
                     lfw:(LoadFileWrappersExt *)lfw;

/**
 * Loads wrapper factory from file
 * @param filePath The file path to load from
 * @param lfw The LoadFileWrappersExt instance
 */
+ (void)loadWrapperFactory:(NSString *)filePath lfw:(LoadFileWrappersExt *)lfw;

/**
 * Loads tool factory from file
 * @param filePath The file path to load from
 * @param lfw The LoadFileWrappersExt instance
 */
+ (void)loadToolFactory:(NSString *)filePath lfw:(LoadFileWrappersExt *)lfw;

/**
 * Loads error wrapper
 * @param wrapper The error wrapper to load
 * @param lfw The LoadFileWrappersExt instance
 */
+ (void)loadErrorWrapper:(ErrorWrapper *)wrapper lfw:(LoadFileWrappersExt *)lfw;

// MARK: - Menu Management (Legacy GUI Support)

/**
 * Adds tool plugins to the passed menu
 * @param menu The menu to add items to
 * @param changeHandler Handler for when package is changed by a tool
 */
- (void)addMenuItems:(NSMenu *)menu changeHandler:(void (^)(PackageArg *args))changeHandler;

/**
 * Set the enabled state of tool menu items
 * @param menu The menu containing tool items
 * @param fileDescriptor The current file descriptor
 * @param package The current package
 */
- (void)enableMenuItems:(NSMenu *)menu
         fileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor
                package:(id<IPackageFile>)package;

// MARK: - Private Methods
- (void)createIgnoreList;

@end
