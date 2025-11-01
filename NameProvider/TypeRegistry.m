//
//  TypeRegistry.m
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

#import "TypeRegistry.h"
#import "Helper.h"
#import "Registry.h"
#import "IListener.h"
#import "IWrapper.h"
#import "IPackedFileWrapper.h"
#import "IWrapperFactory.h"
#import "ITool.h"
#import "IToolFactory.h"
#import "IHelpFactory.h"
#import "ISettingsFactory.h"
#import "ICommandLineRegistry.h"
#import "ITool.h"
#import "IDockableTool.h"
#import "IToolAction.h"
#import "IHelp.h"
#import "ISettings.h"
#import "ICommandLine.h"
#import "InternalListeners.h"
#import "IUpdatablePlugin.h"
#import "AbstractWrapper.h"
#import "AbstractWrapperInfo.h"
#import "OpcodeProvider.h"
#import "SimFamilyNames.h"
#import "SimNames.h"
#import "SimDescriptions.h"
#import "SkinProvider.h"
#import "LotProvider.h"
#import "Localization.h"
#import "ExceptionForm.h"

@implementation TypeRegistry {
    // Instance variable declarations go here
    NSMutableArray<id<IToolAction>> *_actionTools;
    NSMutableArray<id<IDockableTool>> *_dockableTools;
    NSMutableArray<id<IToolPlus>> *_toolsPlus;
}

@synthesize knownCommandLines = _knownCommandLines;
@synthesize commandLines = _commandLines;

- (NSArray<id<IDockableTool>> *)docks {
    return [self.dockableTools copy];
}

- (NSArray<id<IToolAction>> *)actions {
    return [self.actionTools copy];
}
// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _updatablePlugins = [[NSMutableArray alloc] init];
        _registry = [Registry windowsRegistry];
        _handlers = [[NSMutableArray alloc] init];
        
        // Initialize providers
        _opcodeProvider = [[OpcodeProvider alloc] init];
        _simFamilynameProvider = [[SimFamilyNames alloc] init];
        _simNameProvider = [[SimNames alloc] initWithOpcodes:nil];
        _simDescriptionProvider = [[SimDescriptions alloc] initWithNames:_simNameProvider
                                                                famNames:_simFamilynameProvider];
        _skinProvider = [[Skins alloc] init];
        _lotProvider = [[LotProvider alloc] init];
        
        // Set up provider connections
        [[NSNotificationCenter defaultCenter] addObserver:_lotProvider
                                                 selector:@selector(simDescriptionProviderChangedPackage:)
                                                     name:@"SimDescriptionProviderChangedPackage"
                                                   object:_simDescriptionProvider];
        
        _tools = [[NSMutableArray alloc] init];
        _toolsPlus = [[NSMutableArray alloc] init];
        _dockableTools = [[NSMutableArray alloc] init];
        _actionTools = [[NSMutableArray alloc] init];
        _commandLines = [[NSMutableArray alloc] init];
        _knownCommandLines = [[NSMutableArray alloc] init];
        _helpTopics = [[NSMutableArray alloc] init];
        _settings = [[NSMutableArray alloc] init];
        _listeners = [[InternalListeners alloc] init];
        
        _wrapperImages = [[NSMutableArray alloc] init];
        
        // Add default images
        // Add default images (placeholders for now)
        NSImage *emptyImage  = [NSImage imageNamed:@"empty"];
        NSImage *binaryImage = [NSImage imageNamed:@"binary"];
        
        if (emptyImage) {
            [_wrapperImages addObject:emptyImage];
        } else {
            [_wrapperImages addObject:[NSImage imageNamed:@"NSDocument"]];
        }
        
        if (binaryImage) {
            [_wrapperImages addObject:binaryImage];
        } else {
            [_wrapperImages addObject:[NSImage imageNamed:@"NSDocument"]];
        }
    }
    return self;
}

// MARK: - IWrapperRegistry Implementation

- (void)registerWrapper:(id<IWrapper>)wrapper {
    if (wrapper != nil) {
        if (![self.handlers containsObject:wrapper]) {
            [wrapper setPriority:[self.registry getWrapperPriority:[wrapper.wrapperDescription uid]]];
            [self.handlers addObject:wrapper];
            
            if ([wrapper.wrapperDescription isKindOfClass:[AbstractWrapperInfo class]]) {
                NSImage *icon = [wrapper.wrapperDescription icon];
                if (icon != nil) {
                    [(AbstractWrapperInfo *)wrapper.wrapperDescription setIconIndex:(NSInteger)[self.wrapperImages count]];
                    [self.wrapperImages addObject:icon];
                } else {
                    [(AbstractWrapperInfo *)wrapper.wrapperDescription setIconIndex:1];
                }
            }
        }
    }
}

- (void)registerWrappers:(NSArray<id<IWrapper>> *)wrappers guiWrappers:(NSArray<id<IWrapper>> *)guiWrappers {
    if (wrappers != nil && guiWrappers == nil) {
        for (id<IWrapper> wrapper in wrappers) {
            [self registerWrapper:wrapper];
        }
    } else if (wrappers != nil && guiWrappers != nil) {
        for (NSUInteger i = 0; i < [wrappers count]; i++) {
            id<IWrapper> wrapper = wrappers[i];
            
            // Make sure we have two instances of each Wrapper otherwise,
            // AbstractWrapper.ResourceName could corrupt a open Resource
            if (![wrapper allowMultipleInstances] && [wrapper isKindOfClass:[AbstractWrapper class]]) {
                [(AbstractWrapper *)wrapper setSingleGuiWrapper:(id<IFileWrapper>)guiWrappers[i]];
            }
            [self registerWrapper:wrapper];
        }
    }
}

- (void)registerWrapperFactory:(id<IWrapperFactory>)factory {
    [factory setLinkedRegistry:self];
    [factory setLinkedProvider:self];
    [self registerWrappers:[factory knownWrappers] guiWrappers:[factory knownWrappers]];
    
    if ([factory conformsToProtocol:@protocol(IHelpFactory)]) {
        [self registerHelpFactory:(id<IHelpFactory>)factory];
    }
    
    if ([factory conformsToProtocol:@protocol(ISettingsFactory)]) {
        [self registerSettingsFactory:(id<ISettingsFactory>)factory];
    }
    
    if ([factory conformsToProtocol:@protocol(ICommandLineFactory)]) {
        [self registerCommandLineFactory:(id<ICommandLineFactory>)factory];
    }
    
    [self addUpdatablePlugin:factory];
}

- (NSArray<id<IWrapper>> *)wrappers {
    NSArray<id<IWrapper>> *allWrappers = [self allWrappers];
    NSMutableArray *validWrappers = [[NSMutableArray alloc] init];
    
    for (id<IWrapper> wrapper in allWrappers) {
        if ([wrapper priority] >= 0) {
            [validWrappers addObject:wrapper];
        }
    }
    
    return [validWrappers copy];
}

- (NSArray<id<IWrapper>> *)allWrappers {
    NSMutableArray<id<IWrapper>> *wrappers = [self.handlers mutableCopy];
    
    // Sort the wrappers by priority using bubble sort (matching original C# logic)
    for (NSUInteger i = 0; i < [wrappers count] - 1; i++) {
        for (NSUInteger k = i + 1; k < [wrappers count]; k++) {
            NSInteger priority1 = ABS([wrappers[i] priority]);
            NSInteger priority2 = ABS([wrappers[k] priority]);
            
            if (priority1 > priority2) {
                [wrappers exchangeObjectAtIndex:i withObjectAtIndex:k];
            }
        }
    }
    
    return [wrappers copy];
}

- (NSArray *)wrapperImageList {
    return [self.wrapperImages copy];
}

// MARK: - Handler Finding

- (id<IPackedFileWrapper>)findHandler:(uint32_t)type {
    NSArray<id<IWrapper>> *wrappers = [self wrappers];
    
    for (id<IPackedFileWrapper> handler in wrappers) {
        if ([handler conformsToProtocol:@protocol(IPackedFileWrapper)]) {
            // Check if this handler also implements IFileWrapper (which has assignableTypes)
            if ([handler conformsToProtocol:@protocol(IFileWrapper)]) {
                id<IFileWrapper> fileHandler = (id<IFileWrapper>)handler;
                NSArray<NSNumber *> *assignableTypes = [fileHandler assignableTypes];
                for (NSNumber *typeNumber in assignableTypes) {
                    if ([typeNumber unsignedIntValue] == type) {
                        return handler;
                    }
                }
            }
        }
    }
    
    return nil;
}

- (id<IPackedFileWrapper>)findHandlerForData:(NSData *)data {
    NSArray<id<IWrapper>> *wrappers = [self wrappers];
    
    for (id<IPackedFileWrapper> handler in wrappers) {
        if ([handler conformsToProtocol:@protocol(IPackedFileWrapper)]) {
            // Check if this handler also implements IFileWrapper (which has fileSignature)
            if ([handler conformsToProtocol:@protocol(IFileWrapper)]) {
                id<IFileWrapper> fileHandler = (id<IFileWrapper>)handler;
                NSData *signature = [fileHandler fileSignature];
                if (signature == nil || [signature length] == 0) {
                    continue;
                }
                
                BOOL check = YES;
                const uint8_t *signatureBytes = [signature bytes];
                const uint8_t *dataBytes = [data bytes];
                
                for (NSUInteger i = 0; i < [signature length]; i++) {
                    if (i >= [data length]) {
                        break;
                    }
                    if (dataBytes[i] != signatureBytes[i]) {
                        check = NO;
                        break;
                    }
                }
                
                if (check) {
                    return handler;
                }
            }
        }
    }
    
    return nil;
}

// MARK: - IProviderRegistry Implementation

- (id<ILotProvider>)getLotProvider {
    return self.lotProvider;
}

- (id<ISimNames>)getSimNameProvider {
    return self.simNameProvider;
}

- (id<ISimFamilyNames>)getSimFamilynameProvider {
    return self.simFamilynameProvider;
}

- (id<ISimDescriptions>)getSimDescriptionProvider {
    return self.simDescriptionProvider;
}

- (id<IOpcodeProvider>)getOpcodeProvider {
    return self.opcodeProvider;
}

- (id<ISkinProvider>)getSkinProvider {
    return self.skinProvider;
}

// MARK: - IToolRegistry Implementation

- (void)registerTool:(id<IToolPlugin>)tool {
    if (tool != nil) {
        if ([tool conformsToProtocol:@protocol(IDockableTool)]) {
            if (![self.dockableTools containsObject:tool]) {
                [self.dockableTools addObject:tool];  // Remove cast
            }
        } else if ([tool conformsToProtocol:@protocol(IToolAction)]) {
            if (![self.actionTools containsObject:tool]) {
                [self.actionTools addObject:tool];  // Remove cast
            }
        } else if ([tool conformsToProtocol:@protocol(IToolPlus)]) {
            if (![self.toolsPlus containsObject:tool]) {
                [self.toolsPlus addObject:tool];  // Remove cast
            }
        } else if ([tool conformsToProtocol:@protocol(IListener)]) {
            // Check what methods Listeners actually has - probably 'addListener:' not 'containsListener:'
            [self.listeners addListener:(id<IListener>)tool];
        } else {
            // Default case - add to regular tools array
            if (![self.tools containsObject:tool]) {
                [self.tools addObject:tool];
            }
        }
    }
}

- (void)registerTools:(NSArray<id<IToolPlugin>> *)tools {
    if (tools != nil) {
        for (id<IToolPlugin> tool in tools) {
            [self registerTool:tool];
        }
    }
}

- (void)registerToolFactory:(id<IToolFactory>)factory {
    [factory setLinkedRegistry:self];
    [factory setLinkedProvider:self];
    
    NSString *fileName = [Localization getString:@"Unknown"];
    @try {
        fileName = [factory fileName];
        [self registerTools:[factory knownTools]];
    } @catch (NSException *exception) {
        NSString *message = [NSString stringWithFormat:@"Unable to load Tool \"%@\". You Probably have a Plugin/Tool installed, that is not compatible with the current SimPE Release.", fileName];
        [ExceptionForm executeWithMessage:message exception:exception];
    }
    
    [self addUpdatablePlugin:factory];
}

- (Listeners *)getListeners {
    return self.listeners;
}

- (NSArray<id<ITool>> *)getTools {
    return [self.tools copy];
}

- (NSArray<id<IToolPlus>> *)getToolsPlus {
    return [self.toolsPlus copy];
}

- (NSArray<id<IDockableTool>> *)getDocks {
    return [self.dockableTools copy];
}

- (NSArray<id<IToolAction>> *)getActions {
    return [self.actionTools copy];
}

// MARK: - IHelpRegistry Implementation

- (void)registerHelpFactory:(id<IHelpFactory>)factory {
    if (factory == nil) return;
    [self registerHelpTopics:[factory knownHelpTopics]];
}

- (void)registerHelpTopics:(NSArray<id<IHelp>> *)topics {
    if (topics == nil) return;
    for (id<IHelp> topic in topics) {
        [self registerHelpTopic:topic];
    }
}

- (void)registerHelpTopic:(id<IHelp>)topic {
    if (topic != nil && ![self.helpTopics containsObject:topic]) {
        [self.helpTopics addObject:topic];
    }
}

- (NSArray<id<IHelp>> *)getHelpTopics {
    return [self.helpTopics copy];
}

// MARK: - ISettingsRegistry Implementation

- (void)registerSettingsFactory:(id<ISettingsFactory>)factory {
    if (factory == nil) return;
    [self registerSettingsArray:[factory knownSettings]];
    [self addUpdatablePlugin:factory];
}

- (NSArray<id<ISettings>> *)getSettings {
    return [self.settings copy];
}

- (void)registerSettingsArray:(NSArray<id<ISettings>> *)settings {
    if (settings == nil) return;
    for (id<ISettings> setting in settings) {
        [self registerSettings:setting];
    }
}

- (void)registerSettings:(id<ISettings>)setting {
    if (self.settings == nil) return;
    if (![self.settings containsObject:setting]) {
        [self.settings addObject:setting];
    }
}

// MARK: - ICommandLineRegistry Implementation

- (void)registerCommandLineFactory:(id<ICommandLineFactory>)factory {
    if (factory == nil) return;
    [self registerCommandLinesArray:[factory knownCommandLines]];
    [self addUpdatablePlugin:factory];
}

- (void)registerCommandLinesArray:(NSArray<id<ICommandLine>> *)commandLines {
    if (self.commandLines == nil) return;
    for (id<ICommandLine> commandLine in commandLines) {
        [self registerCommandLine:commandLine];
    }
}

- (void)registerCommandLine:(id<ICommandLine>)commandLine {
    if (commandLine == nil) return;
    if (![self.commandLines containsObject:commandLine]) {
        [self.commandLines addObject:commandLine];
    }
}

- (NSArray<id<ICommandLine>> *)getCommandLines {
    return [self.commandLines copy];
}

// MARK: - Private Methods

- (void)addUpdatablePlugin:(id)factory {
    if (factory == nil) return;
    
    if ([factory conformsToProtocol:@protocol(IUpdatablePlugin)]) {
        id<IUpdatablePlugin> updatablePlugin = (id<IUpdatablePlugin>)factory;
        if (![self.updatablePlugins containsObject:updatablePlugin]) {
            [self.updatablePlugins addObject:updatablePlugin];
        }
    }
}

@end


