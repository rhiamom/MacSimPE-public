//
//  BottomHalfViewController.m
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

#import "BottomHalfViewController.h"
#import "IPackedFileDescriptor.h"

@interface BottomHalfViewController ()
@property (nonatomic, strong) NSTextField *emptyStateLabel;
@end

@implementation BottomHalfViewController

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Don't set any default bottom tool
    self.selectedResource = nil;
    self.currentViewController = nil;
    
    [self setupUI];
    [self showEmptyState];
}

// MARK: - Setup

- (void)setupUI {
    // Create container view if not connected via IB
    if (self.containerView == nil) {
        self.containerView = [[NSView alloc] init];
        [self.view addSubview:self.containerView];
        
        // Setup constraints for container view
        [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[
            [self.containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [self.containerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [self.containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
        ]];
    }
    
    // Create empty state label
    self.emptyStateLabel = [[NSTextField alloc] init];
    [self.emptyStateLabel setStringValue:@"No Resource Selected"];
    [self.emptyStateLabel setBezeled:NO];
    [self.emptyStateLabel setDrawsBackground:NO];
    [self.emptyStateLabel setEditable:NO];
    [self.emptyStateLabel setSelectable:NO];
    [self.emptyStateLabel setAlignment:NSTextAlignmentCenter];
    [self.emptyStateLabel setTextColor:[NSColor secondaryLabelColor]];
    [self.emptyStateLabel setFont:[NSFont systemFontOfSize:16]];
}

// MARK: - Property Setters

- (void)setSelectedBottomTool:(BottomTool)selectedBottomTool {
    if (_selectedBottomTool != selectedBottomTool) {
        _selectedBottomTool = selectedBottomTool;
        [self updateContentView];
    }
}

- (void)setSelectedResource:(id<IPackedFileDescriptor>)selectedResource {
    if (_selectedResource != selectedResource) {
        _selectedResource = selectedResource;
        [self updateContentView];
    }
}

// MARK: - View Management

- (void)updateContentView {
    // Remove current view controller
    if (self.currentViewController != nil) {
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = nil;
    }
    
    // If no resource is selected, show empty state
    if (self.selectedResource == nil) {
        [self showEmptyState];
        return;
    }
    
    // Create appropriate view controller based on selected bottom tool
    NSViewController *newViewController = nil;
    
    switch (self.selectedBottomTool) {
        case BottomToolPluginView:
            newViewController = [self createPluginViewForResource:self.selectedResource];
            break;
            
        case BottomToolWrapper:
            newViewController = [self createWrapperViewForResource:self.selectedResource];
            break;
            
        case BottomToolDetails:
            newViewController = [self createDetailsViewForResource:self.selectedResource];
            break;
            
        case BottomToolHex:
            newViewController = [self createHexViewForResource:self.selectedResource];
            break;
            
        case BottomToolConverter:
            newViewController = [self createConverterView];
            break;
            
        case BottomToolFinder:
            newViewController = [self createFinderView];
            break;
    }
    
    // Install the new view controller
    if (newViewController != nil) {
        [self addChildViewController:newViewController];
        [self.containerView addSubview:newViewController.view];
        
        // Setup constraints for new view
        [newViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[
            [newViewController.view.topAnchor constraintEqualToAnchor:self.containerView.topAnchor],
            [newViewController.view.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor],
            [newViewController.view.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor],
            [newViewController.view.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor]
        ]];
        
        self.currentViewController = newViewController;
    } else {
        [self showEmptyState];
    }
}

- (void)showEmptyState {
    // Remove empty state label if it's already added
    [self.emptyStateLabel removeFromSuperview];
    
    // Add empty state label to container
    [self.containerView addSubview:self.emptyStateLabel];
    
    // Setup constraints for empty state
    [self.emptyStateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyStateLabel.centerXAnchor constraintEqualToAnchor:self.containerView.centerXAnchor],
        [self.emptyStateLabel.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor]
    ]];
}

// MARK: - Future Plugin Integration Points
// These methods will be implemented when PluginManager and ResourceLoader are translated

- (NSViewController *)createPluginViewForResource:(id<IPackedFileDescriptor>)resource {
    // TODO: This will be implemented when PluginManager is translated
    // The PluginManager will determine the appropriate plugin view based on file type
    NSLog(@"TODO: Create plugin view for resource type: 0x%08X", [resource type]);
    return nil;
}

- (NSViewController *)createWrapperViewForResource:(id<IPackedFileDescriptor>)resource {
    // TODO: This will be implemented when wrapper system is translated
    // Shows simple metadata: Name, Author, Description, Version
    NSLog(@"TODO: Create wrapper view for resource");
    return nil;
}

- (NSViewController *)createDetailsViewForResource:(id<IPackedFileDescriptor>)resource {
    // TODO: This will show basic file properties (the current BottomHalfViewController content)
    // Type, Group, Instance, Size, Offset, etc.
    NSLog(@"TODO: Create details view for resource");
    return nil;
}

- (NSViewController *)createHexViewForResource:(id<IPackedFileDescriptor>)resource {
    // TODO: This will be implemented when hex editor is translated
    NSLog(@"TODO: Create hex view for resource");
    return nil;
}

- (NSViewController *)createConverterView {
    // TODO: This will be implemented when converter tools are translated
    NSLog(@"TODO: Create converter view");
    return nil;
}

- (NSViewController *)createFinderView {
    // TODO: This will be implemented when finder/search tools are translated
    NSLog(@"TODO: Create finder view");
    return nil;
}

@end
