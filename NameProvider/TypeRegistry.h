//
//  TypeRegistry.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *   Copyright (C) 2008 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "IWrapperRegistry.h"
#import "IProviderRegistry.h"
#import "IToolRegistry.h"
#import "IHelpRegistry.h"
#import "ISettingsRegistry.h"
#import "ICommandLineRegistry.h"

@protocol IWrapper;
@protocol IPackedFileWrapper;
@protocol IWrapperFactory;
@protocol IToolPlugin;
@protocol IToolFactory;
@protocol IHelpFactory;
@protocol ISettingsFactory;
@protocol ICommandLineFactory;
@protocol ITool;
@protocol IToolPlus;
@protocol IDockableTool;
@protocol IToolAction;
@protocol IHelp;
@protocol ISettings;
@protocol ICommandLine;
@protocol IListener;
@protocol IUpdatablePlugin;
@protocol ILotProvider;
@protocol ISimNames;
@protocol ISimFamilyNames;
@protocol ISimDescriptions;
@protocol IOpcodeProvider;
@protocol ISkinProvider;
@class Registry;
@class Listeners;
@class InternalListeners;
@class OpcodeProvider;
@class SimFamilyNamesProvider;
@class SimNamesProvider;
@class SimDescriptionsProvider;
@class SkinsProvider;
@class LotProvider;

/// <summary>
/// Holds the index of available Handlers
/// </summary>
/// <remarks>
/// The TypeRegistry is the main Communication Point for all Plugins, so if you want to
/// provide Infoformations from the Main Application to the Plugins, you have to use the
/// TypeRegistry!
/// </remarks>
@interface TypeRegistry : NSObject <IWrapperRegistry, IProviderRegistry, IToolRegistry, IHelpRegistry, ISettingsRegistry, ICommandLineFactory>

// MARK: - Properties

/// <summary>
/// Contains all available handler Objects
/// </summary>
/// <remarks>All handlers are stored as IPackedFileHandler Objects</remarks>
@property (nonatomic, strong) NSMutableArray *handlers;

/// <summary>
/// Contains all available Tool Plugins
/// </summary>
@property (nonatomic, strong) NSMutableArray *tools;
@property (nonatomic, strong) NSMutableArray *toolsPlus;

/// <summary>
/// Contains all available dockable Tool Plugins
/// </summary>
@property (nonatomic, strong) NSMutableArray *dockableTools;

/// <summary>
/// Contains all available action Tool Plugins
/// </summary>
@property (nonatomic, strong) NSMutableArray *actionTools;

/// <summary>
/// Contains all known CommandLine tools
/// </summary>
@property (nonatomic, strong) NSMutableArray *commandLines;

/// <summary>
/// Contains all known Helptopics
/// </summary>
@property (nonatomic, strong) NSMutableArray *helpTopics;

/// <summary>
/// Contains all known Custom Settings
/// </summary>
@property (nonatomic, strong) NSMutableArray *settings;

/// <summary>
/// Contains all available Listeners
/// </summary>
@property (nonatomic, strong, readonly) Listeners *listeners;

/// <summary>
/// Used to access the Windows Registry
/// </summary>
@property (nonatomic, strong) Registry *registry;

/// <summary>
/// Wrapper ImageList
/// </summary>
@property (nonatomic, strong) NSMutableArray *wrapperImages;

/// <summary>
/// Updateable plugins
/// </summary>
@property (nonatomic, strong) NSMutableArray<id<IUpdatablePlugin>> *updatablePlugins;

// MARK: - Providers

@property (nonatomic, strong) id<ILotProvider> lotProvider;
@property (nonatomic, strong) id<ISimNames> simNameProvider;
@property (nonatomic, strong) id<ISimFamilyNames> simFamilynameProvider;
@property (nonatomic, strong) id<ISimDescriptions> simDescriptionProvider;
@property (nonatomic, strong) id<IOpcodeProvider> opcodeProvider;
@property (nonatomic, strong) id<ISkinProvider> skinProvider;

// MARK: - Initialization

- (instancetype)init;

// MARK: - IWrapperRegistry Methods

- (void)registerWrapper:(id<IWrapper>)wrapper;
- (void)registerWrappers:(NSArray<id<IWrapper>> *)wrappers guiWrappers:(NSArray<id<IWrapper>> *)guiWrappers;
- (void)registerWrapperFactory:(id<IWrapperFactory>)factory;
- (NSArray<id<IWrapper>> *)wrappers;
- (NSArray<id<IWrapper>> *)allWrappers;
- (NSArray *)wrapperImageList;

// MARK: - Handler Finding

- (id<IPackedFileWrapper>)findHandler:(uint32_t)type;
- (id<IPackedFileWrapper>)findHandlerForData:(NSData *)data;

// MARK: - IToolRegistry Methods

- (void)registerTool:(id<IToolPlugin>)tool;
- (void)registerTools:(NSArray<id<IToolPlugin>> *)tools;
- (void)registerToolFactory:(id<IToolFactory>)factory;
- (Listeners *)getListeners;
- (NSArray<id<ITool>> *)getTools;
- (NSArray<id<IToolPlus>> *)getToolsPlus;
- (NSArray<id<IDockableTool>> *)getDocks;
- (NSArray<id<IToolAction>> *)getActions;

// MARK: - IHelpRegistry Methods

- (void)registerHelpFactory:(id<IHelpFactory>)factory;
- (void)registerHelpTopics:(NSArray<id<IHelp>> *)topics;
- (void)registerHelpTopic:(id<IHelp>)topic;
- (NSArray<id<IHelp>> *)getHelpTopics;

// MARK: - ISettingsRegistry Methods

- (void)registerSettingsFactory:(id<ISettingsFactory>)factory;
- (void)registerSettingsArray:(NSArray<id<ISettings>> *)settings;
- (void)registerSettings:(id<ISettings>)setting;
- (NSArray<id<ISettings>> *)getSettings;

// MARK: - ICommandLineRegistry Methods

- (void)registerCommandLineFactory:(id<ICommandLineFactory>)factory;
- (void)registerCommandLinesArray:(NSArray<id<ICommandLine>> *)commandLines;
- (void)registerCommandLine:(id<ICommandLine>)commandLine;
- (NSArray<id<ICommandLine>> *)getCommandLines;

// MARK: - Private Methods

- (void)addUpdatablePlugin:(id)factory;

@end
