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
#import "AbstractWrapper.h"
#import "IPackedFileUI.h"
#import "IFileWrapper.h"
#import <AppKit/AppKit.h>

@interface BottomHalfViewController ()
@property (nonatomic, strong) NSTextField *emptyStateLabel;
@property (nonatomic, strong) NSView *currentPluginView;
@property (nonatomic, strong) id<IPackedFileUI> currentUIHandler;
@end

@implementation BottomHalfViewController

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Don't set any default bottom tool
    self.selectedResource = nil;
    self.currentViewController = nil;
    self.currentPluginView = nil;
    self.currentUIHandler = nil;
    
    [self setupUI];
    [self showEmptyState];
}

- (void)dealloc {
    // ARC will handle cleanup automatically
    [self cleanupCurrentView];
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
    // Clean up current view
    [self cleanupCurrentView];
    
    // If no resource is selected, show empty state
    if (self.selectedResource == nil) {
        [self showEmptyState];
        return;
    }
    
    // Create appropriate view based on selected bottom tool
    NSViewController *newViewController = nil;
    NSView *newPluginView = nil;
    
    switch (self.selectedBottomTool) {
        case BottomToolPluginView:
            newPluginView = [self createPluginViewForResource:self.selectedResource];
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
    
    // Install the new view
    if (newPluginView != nil) {
        [self installPluginView:newPluginView];
    } else if (newViewController != nil) {
        [self installViewController:newViewController];
    } else {
        [self showEmptyState];
    }
}

- (void)cleanupCurrentView {
    // Clean up plugin view and UI handler
    if (self.currentPluginView != nil) {
        [self.currentPluginView removeFromSuperview];
        self.currentPluginView = nil;
    }
    
    // Simply nil the UI handler - ARC will handle cleanup
    self.currentUIHandler = nil;
    
    // Clean up view controller
    if (self.currentViewController != nil) {
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = nil;
    }
    
    // Remove empty state label if present
    [self.emptyStateLabel removeFromSuperview];
}

- (void)installPluginView:(NSView *)pluginView {
    self.currentPluginView = pluginView;
    [self.containerView addSubview:pluginView];
    
    // Setup constraints for plugin view
    [pluginView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [pluginView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor],
        [pluginView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor],
        [pluginView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor],
        [pluginView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor]
    ]];
}

- (void)installViewController:(NSViewController *)viewController {
    [self addChildViewController:viewController];
    [self.containerView addSubview:viewController.view];
    
    // Setup constraints for view controller's view
    [viewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [viewController.view.topAnchor constraintEqualToAnchor:self.containerView.topAnchor],
        [viewController.view.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor],
        [viewController.view.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor],
        [viewController.view.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor]
    ]];
    
    self.currentViewController = viewController;
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

// MARK: - Plugin Integration Methods

- (NSView *)createPluginViewForResource:(id<IPackedFileDescriptor>)resource {
    // Get the wrapper from the resource's tag property
    if (resource.tag != nil && [resource.tag conformsToProtocol:@protocol(IFileWrapper)]) {
        AbstractWrapper *wrapper = (AbstractWrapper *)resource.tag;
        
        // Get or create the UI handler
        id<IPackedFileUI> uiHandler = wrapper.uiHandler;
        if (uiHandler == nil) {
            uiHandler = [wrapper createDefaultUIHandler];
            wrapper.uiHandler = uiHandler;
        }
        
        if (uiHandler != nil) {
            // Store reference for cleanup
            self.currentUIHandler = uiHandler;
            
            // Use string-based selectors to avoid compile-time selector checking
            SEL createViewSelector = NSSelectorFromString(@"createView");
            SEL refreshSelector = NSSelectorFromString(@"refresh");
            
            // Check and call createView
            if ([uiHandler respondsToSelector:createViewSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                NSView *pluginView = [uiHandler performSelector:createViewSelector];
#pragma clang diagnostic pop
                if (pluginView != nil) {
                    // Check and call refresh
                    if ([uiHandler respondsToSelector:refreshSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [uiHandler performSelector:refreshSelector];
#pragma clang diagnostic pop
                    }
                    return pluginView;
                }
            }
        }
    }
    
    // If no plugin view available, log debug info and return nil
    NSLog(@"No plugin view available for resource type: 0x%08X", [resource type]);
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
