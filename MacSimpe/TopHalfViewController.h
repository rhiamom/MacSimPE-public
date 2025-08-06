//
//  TopHalfViewController.h
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

#import <Cocoa/Cocoa.h>
#import "AppState.h"
#import "ResourceViewManager.h"
#import "ToolSidebarView.h"

@protocol IPackedFileDescriptor;
@class ResourceTreeViewExt;
@class ResourceListViewExt;

@interface TopHalfViewController : NSViewController

// MARK: - Properties (matching Swift TopHalfView)
@property (nonatomic, strong) AppState *appState;
@property (nonatomic, assign) Tool selectedTool;
@property (nonatomic, assign) uint32_t selectedResourceType;
@property (nonatomic, strong) id<IPackedFileDescriptor> selectedResource;
@property (nonatomic, strong) ResourceViewManager *resourceManager;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSTextField *headerLabel;
@property (nonatomic, strong) IBOutlet NSTextField *resourceCountLabel;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *loadingIndicator;
@property (nonatomic, strong) IBOutlet NSSplitView *contentSplitView;

// Object Workshop Components
@property (nonatomic, strong) IBOutlet ResourceTreeViewExt *resourceTreeView;
@property (nonatomic, strong) IBOutlet ResourceListViewExt *resourceListView;

// MARK: - Tool Management
- (void)updateContentForSelectedTool;
- (void)updateHeader;

@end
