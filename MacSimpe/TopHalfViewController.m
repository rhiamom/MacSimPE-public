//
//  TopHalfViewController.m
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

#import "TopHalfViewController.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "ResourceTreeViewExt.h"
#import "ResourceListViewExt.h"
#import "PackedFileDescriptors.h"

@interface TopHalfViewController ()
@property (nonatomic, assign) BOOL hasSetupObservers;
@end

@implementation TopHalfViewController

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize properties (matching Swift TopHalfView)
    self.selectedTool = -1;
    self.selectedResourceType = 0;
    self.selectedResource = nil;
    
    [self setupUI];
    [self setupObservers];
    [self updateHeader];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    if (self.hasSetupObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.hasSetupObservers = NO;
    }
}

// MARK: - Setup

- (void)setupUI {
    // Configure loading indicator
    [self.loadingIndicator setStyle:NSProgressIndicatorStyleSpinning];
    [self.loadingIndicator setDisplayedWhenStopped:NO];
    
    // Configure split view
    [self.contentSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
    // Configure header
    [self.headerLabel setFont:[NSFont boldSystemFontOfSize:16]];
    [self.resourceCountLabel setFont:[NSFont systemFontOfSize:12]];
    [self.resourceCountLabel setTextColor:[NSColor secondaryLabelColor]];
    
    // Initially hide content until tool is selected
    [self updateContentForSelectedTool];
}

- (void)setupObservers {
    if (!self.hasSetupObservers) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appStateDidChange:)
                                                     name:AppStatePackageChangedNotification
                                                   object:self.appState];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appStateDidChange:)
                                                     name:AppStateLoadingChangedNotification
                                                   object:self.appState];
        
        self.hasSetupObservers = YES;
    }
}

// MARK: - Property Setters

- (void)setAppState:(AppState *)appState {
    if (_appState != appState) {
        _appState = appState;
        [self setupObservers];
        [self updateHeader];
    }
}

- (void)setResourceManager:(ResourceViewManager *)resourceManager {
    if (_resourceManager != resourceManager) {
        _resourceManager = resourceManager;
        
        // Connect ResourceViewManager to the tree and list views
        [self.resourceManager setTreeView:self.resourceTreeView];
        [self.resourceManager setListView:self.resourceListView];
    }
}

- (void)setSelectedTool:(Tool)selectedTool {
    if (_selectedTool != selectedTool) {
        _selectedTool = selectedTool;
        [self updateContentForSelectedTool];
        [self updateHeader];
    }
}

- (void)setSelectedResourceType:(uint32_t)selectedResourceType {
    if (_selectedResourceType != selectedResourceType) {
        _selectedResourceType = selectedResourceType;
        
        // Clear resource selection when type changes
        self.selectedResource = nil;
    }
}

// MARK: - UI Updates

- (void)updateContentForSelectedTool {
    // Switch statement matching Swift TopHalfView
    switch (self.selectedTool) {
        case ToolCatalog:
            [self setupCatalogLayout];
            break;
            
        case ToolObjectWorkshop:
            [self setupObjectWorkshopLayout];
            break;
            
        default:
            [self setupPlaceholderLayout];
            break;
    }
}

- (void)setupCatalogLayout {
    // Placeholder for catalog - UI file not translated yet
    // Hide resource views
    [self.resourceTreeView setHidden:YES];
    [self.resourceListView setHidden:YES];
}

- (void)setupObjectWorkshopLayout {
    // Show resource tree and list views
    [self.resourceTreeView setHidden:NO];
    [self.resourceListView setHidden:NO];
    
    // Configure split view for object workshop
    [self.contentSplitView setDividerStyle:NSSplitViewDividerStyleThin];
}

- (void)setupPlaceholderLayout {
    // Hide all views for unimplemented tools
    [self.resourceTreeView setHidden:YES];
    [self.resourceListView setHidden:YES];
}

- (void)updateHeader {
    if (self.appState.currentPackage != nil) {
        NSString *filename = [[self.appState.currentPackage fileName] lastPathComponent];
        [self.headerLabel setStringValue:filename];
        
        id<IPackageFile> package = self.appState.currentPackage;
        PackedFileDescriptors *index = [package index];
        NSInteger resourceCount = [index count];
        [self.resourceCountLabel setStringValue:[NSString stringWithFormat:@"%ld resources", (long)resourceCount]];
    } else {
        [self.headerLabel setStringValue:@"No Package Open"];
        [self.resourceCountLabel setStringValue:@""];
    }
    
    // Update loading indicator
    if (self.appState.isLoading) {
        [self.loadingIndicator startAnimation:nil];
        [self.loadingIndicator setHidden:NO];
    } else {
        [self.loadingIndicator stopAnimation:nil];
        [self.loadingIndicator setHidden:YES];
    }
}


// MARK: - Notifications

- (void)appStateDidChange:(NSNotification *)notification {
    [self updateHeader];
}

@end
