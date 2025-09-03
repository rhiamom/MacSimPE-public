//
//  SimsComboBox.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/31/25.
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

#import "SimsComboBox.h"
#import "IAlias.h"
#import "ExtSDesc.h"
#import "Alias.h"
#import "FileTableBase.h"
#import "TypeRegistry.h"
#import "ISimDescriptionProvider.h"

@interface SimComboBox ()
@property (nonatomic, assign) BOOL needReload;
@end

@implementation SimComboBox

// MARK: - Initialization

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupUI];
        [self setupNotifications];
        self.needReload = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - UI Setup

- (void)setupUI {
    // Create the combo box
    self.comboBox = [[NSComboBox alloc] initWithFrame:self.bounds];
    [self.comboBox setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.comboBox setTarget:self];
    [self.comboBox setAction:@selector(comboBoxSelectionChanged:)];
    [self.comboBox setFont:[NSFont systemFontOfSize:13]];
    
    // Set up combo box properties
    [self.comboBox setEditable:NO];
    [self.comboBox setHasVerticalScroller:YES];
    [self.comboBox setIntercellSpacing:NSMakeSize(3.0, 2.0)];
    
    [self addSubview:self.comboBox];
}

- (void)setupNotifications {
    // Listen for SimDescriptionProvider changes
    // In the original C# code, this would be:
    // SimPe.FileTable.ProviderRegistry.SimDescriptionProvider.ChangedPackage += new EventHandler(SimDescriptionProvider_ChangedPackage);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(simDescriptionProviderChangedPackage:)
                                                 name:@"SimDescriptionProviderChangedPackage"
                                               object:nil];
}

// MARK: - Properties

- (uint16_t)selectedSimInstance {
    ExtSDesc *selectedSim = self.selectedSim;
    if (selectedSim != nil) {
        return selectedSim.instance;
    }
    return 0xFFFF;
}

- (void)setSelectedSimInstance:(uint16_t)selectedSimInstance {
    NSInteger selectedIndex = -1;
    
    for (NSInteger i = 0; i < [self.comboBox numberOfItems]; i++) {
        id item = [self.comboBox itemObjectValueAtIndex:i];
        if ([item conformsToProtocol:@protocol(IAlias)]) {
            id<IAlias> alias = (id<IAlias>)item;
            NSArray *tag = [alias tag];
            if ([tag count] > 0 && [tag[0] isKindOfClass:[ExtSDesc class]]) {
                ExtSDesc *sDesc = (ExtSDesc *)tag[0];
                if (sDesc.instance == selectedSimInstance) {
                    selectedIndex = i;
                    break;
                }
            }
        }
    }
    
    [self.comboBox selectItemAtIndex:selectedIndex];
}

- (uint32_t)selectedSimId {
    ExtSDesc *selectedSim = self.selectedSim;
    if (selectedSim != nil) {
        return selectedSim.simId;
    }
    return 0xFFFFFFFF;
}

- (void)setSelectedSimId:(uint32_t)selectedSimId {
    NSInteger selectedIndex = -1;
    
    for (NSInteger i = 0; i < [self.comboBox numberOfItems]; i++) {
        id item = [self.comboBox itemObjectValueAtIndex:i];
        if ([item conformsToProtocol:@protocol(IAlias)]) {
            id<IAlias> alias = (id<IAlias>)item;
            NSArray *tag = [alias tag];
            if ([tag count] > 0 && [tag[0] isKindOfClass:[ExtSDesc class]]) {
                ExtSDesc *sDesc = (ExtSDesc *)tag[0];
                if (sDesc.simId == selectedSimId) {
                    selectedIndex = i;
                    break;
                }
            }
        }
    }
    
    [self.comboBox selectItemAtIndex:selectedIndex];
}

- (ExtSDesc *)selectedSim {
    NSInteger selectedIndex = [self.comboBox indexOfSelectedItem];
    if (selectedIndex == -1) return nil;
    
    id item = [self.comboBox itemObjectValueAtIndex:selectedIndex];
    if ([item conformsToProtocol:@protocol(IAlias)]) {
        id<IAlias> alias = (id<IAlias>)item;
        NSArray *tag = [alias tag];
        if ([tag count] > 0 && [tag[0] isKindOfClass:[ExtSDesc class]]) {
            return (ExtSDesc *)tag[0];
        }
    }
    
    return nil;
}

- (void)setSelectedSim:(ExtSDesc *)selectedSim {
    NSInteger selectedIndex = -1;
    
    if (selectedSim != nil) {
        for (NSInteger i = 0; i < [self.comboBox numberOfItems]; i++) {
            id item = [self.comboBox itemObjectValueAtIndex:i];
            if ([item conformsToProtocol:@protocol(IAlias)]) {
                id<IAlias> alias = (id<IAlias>)item;
                NSArray *tag = [alias tag];
                if ([tag count] > 0 && [tag[0] isKindOfClass:[ExtSDesc class]]) {
                    ExtSDesc *sDesc = (ExtSDesc *)tag[0];
                    if (sDesc.instance == selectedSim.instance) {
                        selectedIndex = i;
                        break;
                    }
                }
            }
        }
    }
    
    [self.comboBox selectItemAtIndex:selectedIndex];
}

// MARK: - Data Management

- (void)reload {
    self.needReload = NO;
    [self setContent];
}

- (void)setContent {
    [self.comboBox removeAllItems];
    
    // Get the TypeRegistry which should have the SimDescriptionProvider
    // This matches: FileTable.ProviderRegistry.SimDescriptionProvider.SimInstance.Values
    id<IWrapperRegistry> registry = [FileTableBase wrapperRegistry];
    if ([registry respondsToSelector:@selector(simDescriptionProvider)]) {
        TypeRegistry *typeRegistry = (TypeRegistry *)registry;
        id<ISimDescriptions> simDescriptionProvider = typeRegistry.simDescriptionProvider;
        
        if (simDescriptionProvider != nil) {
            // Get the Sim instances from the provider
            // In C# this was: FileTable.ProviderRegistry.SimDescriptionProvider.SimInstance.Values
            NSDictionary *simInstanceDict = [simDescriptionProvider simInstance]; // Dictionary like C# .SimInstance
            NSArray *simInstances = [simInstanceDict allValues]; // .Values in C#
            
            // Disable sorting temporarily (matches C# cb.Sorted = false)
            // NSComboBox doesn't have a sorted property, so we'll handle sorting manually
            
            // Create aliases for each sim description
            NSMutableArray *aliases = [[NSMutableArray alloc] init];
            
            for (ExtSDesc *sDesc in simInstances) {
                NSString *displayName = [NSString stringWithFormat:@"%@ %@", sDesc.simName, sDesc.simFamilyName];
                StaticAlias *alias = [[StaticAlias alloc] initWithId:sDesc.simId
                                                                name:displayName
                                                                 tag:@[sDesc]];
                [aliases addObject:alias];
            }
            
            // Sort the aliases by name (matches C# cb.Sorted = true)
            [aliases sortUsingComparator:^NSComparisonResult(id<IAlias> obj1, id<IAlias> obj2) {
                return [[obj1 name] compare:[obj2 name]];
            }];
            
            // Add sorted items to combo box
            for (id<IAlias> alias in aliases) {
                [self.comboBox addItemWithObjectValue:alias];
            }
        }
    }
}

// MARK: - Actions

- (void)comboBoxSelectionChanged:(id)sender {
    if (self.selectedSimChanged) {
        self.selectedSimChanged(self);
    }
}

// MARK: - Notifications

- (void)simDescriptionProviderChangedPackage:(NSNotification *)notification {
    self.needReload = YES;
    if (!self.isHidden) {
        [self reload];
    }
}

// MARK: - View Lifecycle

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    if (self.needReload && !self.isHidden) {
        [self reload];
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (self.needReload && !hidden) {
        [self reload];
    }
}

@end
