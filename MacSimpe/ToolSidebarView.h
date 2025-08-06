//
//  ToolSidebarView.h
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

@class ToolSidebarView;

typedef NS_ENUM(NSInteger, Tool) {
    ToolCatalog,
    ToolObjectWorkshop,
    ToolNeighborhoodBrowser,
    ToolSimSurgery,
    ToolBidouCareerEditor
};

typedef NS_ENUM(NSInteger, BottomTool) {
    BottomToolPluginView,
    BottomToolWrapper,
    BottomToolDetails,
    BottomToolHex,
    BottomToolConverter,
    BottomToolFinder
};

@protocol ToolSidebarDelegate <NSObject>
- (void)toolSidebar:(ToolSidebarView *)sidebar didSelectTool:(Tool)tool;
- (void)toolSidebar:(ToolSidebarView *)sidebar didSelectBottomTool:(BottomTool)bottomTool;
@end

@interface ToolSidebarView : NSView

// MARK: - Properties
@property (nonatomic, weak) id<ToolSidebarDelegate> delegate;
@property (nonatomic, strong) AppState *appState;
@property (nonatomic, assign) Tool selectedTool;
@property (nonatomic, assign) BottomTool selectedBottomTool;
@property (nonatomic, assign) BOOL justOpenedPackage;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSStackView *mainStackView;
@property (nonatomic, strong) IBOutlet NSStackView *topToolStackView;
@property (nonatomic, strong) IBOutlet NSStackView *bottomToolStackView;
@property (nonatomic, strong) NSMutableArray<NSButton *> *topToolButtons;
@property (nonatomic, strong) NSMutableArray<NSButton *> *bottomToolButtons;

// MARK: - Tool Management
- (void)setupTopToolButtons;
- (void)setupBottomToolButtons;
- (void)updateTopToolSelection;
- (void)updateBottomToolSelection;
- (void)updateBottomToolsVisibility;

- (NSString *)titleForTool:(Tool)tool;
- (NSString *)iconNameForTool:(Tool)tool;
- (NSString *)titleForBottomTool:(BottomTool)bottomTool;
- (NSString *)iconNameForBottomTool:(BottomTool)bottomTool;

// MARK: - Actions
- (IBAction)topToolButtonPressed:(NSButton *)sender;
- (IBAction)bottomToolButtonPressed:(NSButton *)sender;

@end
