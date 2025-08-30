//
//  ContentViewController.h
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/10/25.
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

#import <Cocoa/Cocoa.h>
#import "AppState.h"
#import "ToolSidebarView.h"

@protocol IPackedFileDescriptor;

@interface BottomHalfViewController : NSViewController

// MARK: - Properties
@property (nonatomic, strong) AppState *appState;
@property (nonatomic, assign) BottomTool selectedBottomTool;
@property (nonatomic, strong) id<IPackedFileDescriptor> selectedResource;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSView *containerView;
@property (nonatomic, strong) NSViewController *currentViewController;

// MARK: - View Management
- (void)updateContentView;
- (void)showEmptyState;

// MARK: - Plugin Integration Points
- (NSView *)createPluginViewForResource:(id<IPackedFileDescriptor>)resource;
- (NSViewController *)createWrapperViewForResource:(id<IPackedFileDescriptor>)resource;
- (NSViewController *)createDetailsViewForResource:(id<IPackedFileDescriptor>)resource;
- (NSViewController *)createHexViewForResource:(id<IPackedFileDescriptor>)resource;
- (NSViewController *)createConverterView;
- (NSViewController *)createFinderView;

// MARK: - Private View Management
- (void)cleanupCurrentView;
- (void)installPluginView:(NSView *)pluginView;
- (void)installViewController:(NSViewController *)viewController;

@end
