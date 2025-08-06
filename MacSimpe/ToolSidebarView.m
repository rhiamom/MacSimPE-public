//
//  ToolSidebarView.m
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

#import "ToolSidebarView.h"

@implementation ToolSidebarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedTool = -1; // No tool selected initially
    self.selectedBottomTool = BottomToolPluginView; // Default bottom tool
    self.topToolButtons = [[NSMutableArray alloc] init];
    self.bottomToolButtons = [[NSMutableArray alloc] init];
    
    [self setupUI];
    [self setupTopToolButtons];
    [self setupBottomToolButtons];
    [self updateTopToolSelection];
    [self updateBottomToolSelection];
    [self updateBottomToolsVisibility];
}

- (void)setupUI {
    // Create main vertical stack view
    self.mainStackView = [[NSStackView alloc] init];
    [self.mainStackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
    [self.mainStackView setSpacing:0];
    [self.mainStackView setAlignment:NSLayoutAttributeLeading];
    [self.mainStackView setDistribution:NSStackViewDistributionFill];
    
    // Create top tools section
    self.topToolStackView = [[NSStackView alloc] init];
    [self.topToolStackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
    [self.topToolStackView setSpacing:2];
    [self.topToolStackView setAlignment:NSLayoutAttributeLeading];
    
    // Create bottom tools section
    self.bottomToolStackView = [[NSStackView alloc] init];
    [self.bottomToolStackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
    [self.bottomToolStackView setSpacing:2];
    [self.bottomToolStackView setAlignment:NSLayoutAttributeLeading];
    
    // Add sections to main stack
    [self.mainStackView addArrangedSubview:self.topToolStackView];
    [self.mainStackView addArrangedSubview:self.bottomToolStackView];
    
    // Add separator between sections
    NSBox *separator = [[NSBox alloc] init];
    [separator setBoxType:NSBoxSeparator];
    [self.mainStackView insertArrangedSubview:separator atIndex:1];
    
    // Add main stack to view
    [self addSubview:self.mainStackView];
    
    // Setup constraints
    [self.mainStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8]
    ]];
}

- (void)setupTopToolButtons {
    // Clear existing buttons
    NSArray *arrangedSubviews = [self.topToolStackView.arrangedSubviews copy];
    for (NSView *view in arrangedSubviews) {
        [self.topToolStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    [self.topToolButtons removeAllObjects];
    
    // Create top tool buttons
    NSArray *tools = @[@(ToolCatalog), @(ToolObjectWorkshop), @(ToolNeighborhoodBrowser),
                      @(ToolSimSurgery), @(ToolBidouCareerEditor)];
    
    for (NSNumber *toolNumber in tools) {
        Tool tool = [toolNumber integerValue];
        NSButton *button = [self createTopToolButton:tool];
        [self.topToolButtons addObject:button];
        [self.topToolStackView addArrangedSubview:button];
    }
}

- (void)setupBottomToolButtons {
    // Clear existing buttons
    NSArray *arrangedSubviews = [self.bottomToolStackView.arrangedSubviews copy];
    for (NSView *view in arrangedSubviews) {
        [self.bottomToolStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    [self.bottomToolButtons removeAllObjects];
    
    // Create bottom tool buttons
    NSArray *bottomTools = @[@(BottomToolPluginView), @(BottomToolWrapper), @(BottomToolDetails),
                            @(BottomToolHex), @(BottomToolConverter), @(BottomToolFinder)];
    
    for (NSNumber *toolNumber in bottomTools) {
        BottomTool bottomTool = [toolNumber integerValue];
        NSButton *button = [self createBottomToolButton:bottomTool];
        [self.bottomToolButtons addObject:button];
        [self.bottomToolStackView addArrangedSubview:button];
    }
}

- (NSButton *)createTopToolButton:(Tool)tool {
    NSButton *button = [[NSButton alloc] init];
    [button setButtonType:NSButtonTypePushOnPushOff];
    [button setBezelStyle:NSBezelStyleRegularSquare];
    [button setTitle:[self titleForTool:tool]];
    [button setTag:tool];
    [button setTarget:self];
    [button setAction:@selector(topToolButtonPressed:)];
    
    // Set image if available
    NSString *iconName = [self iconNameForTool:tool];
    if (iconName) {
        NSImage *icon = [NSImage imageNamed:iconName];
        if (icon) {
            [button setImage:icon];
            [button setImagePosition:NSImageLeft];
        }
    }
    
    // Configure appearance
    [button setAlignment:NSTextAlignmentLeft];
    [button setFont:[NSFont systemFontOfSize:13]];
    
    return button;
}

- (NSButton *)createBottomToolButton:(BottomTool)bottomTool {
    NSButton *button = [[NSButton alloc] init];
    [button setButtonType:NSButtonTypePushOnPushOff];
    [button setBezelStyle:NSBezelStyleRegularSquare];
    [button setTitle:[self titleForBottomTool:bottomTool]];
    [button setTag:bottomTool];
    [button setTarget:self];
    [button setAction:@selector(bottomToolButtonPressed:)];
    
    // Set image if available
    NSString *iconName = [self iconNameForBottomTool:bottomTool];
    if (iconName) {
        NSImage *icon = [NSImage imageNamed:iconName];
        if (icon) {
            [button setImage:icon];
            [button setImagePosition:NSImageLeft];
        }
    }
    
    // Configure appearance
    [button setAlignment:NSTextAlignmentLeft];
    [button setFont:[NSFont systemFontOfSize:12]];
    
    return button;
}

- (NSString *)titleForTool:(Tool)tool {
    switch (tool) {
        case ToolCatalog:
            return @"Catalog";
        case ToolObjectWorkshop:
            return @"Object Workshop";
        case ToolNeighborhoodBrowser:
            return @"Neighborhood Browser";
        case ToolSimSurgery:
            return @"SimSurgery";
        case ToolBidouCareerEditor:
            return @"Bidou Career Editor";
        default:
            return @"Unknown Tool";
    }
}

- (NSString *)iconNameForTool:(Tool)tool {
    switch (tool) {
        case ToolCatalog:
            return @"NSFolder";
        case ToolObjectWorkshop:
            return @"NSApplicationIcon";
        case ToolNeighborhoodBrowser:
            return @"NSNetwork";
        case ToolSimSurgery:
            return @"NSPreferencesGeneral";
        case ToolBidouCareerEditor:
            return @"NSUser";
        default:
            return nil;
    }
}

- (NSString *)titleForBottomTool:(BottomTool)bottomTool {
    switch (bottomTool) {
        case BottomToolPluginView:
            return @"Plugin View";
        case BottomToolWrapper:
            return @"Wrapper";
        case BottomToolDetails:
            return @"Details";
        case BottomToolHex:
            return @"Hex";
        case BottomToolConverter:
            return @"Converter";
        case BottomToolFinder:
            return @"Finder";
        default:
            return @"Unknown Tool";
    }
}

- (NSString *)iconNameForBottomTool:(BottomTool)bottomTool {
    switch (bottomTool) {
        case BottomToolPluginView:
            return @"NSAdvanced";
        case BottomToolWrapper:
            return @"NSInfo";
        case BottomToolDetails:
            return @"NSListViewTemplate";
        case BottomToolHex:
            return @"NSFontPanel";
        case BottomToolConverter:
            return @"NSRefreshTemplate";
        case BottomToolFinder:
            return @"NSFindTemplate";
        default:
            return nil;
    }
}

- (void)setSelectedTool:(Tool)selectedTool {
    if (_selectedTool != selectedTool) {
        _selectedTool = selectedTool;
        [self updateTopToolSelection];
        [self updateBottomToolsVisibility];
    }
}

- (void)setSelectedBottomTool:(BottomTool)selectedBottomTool {
    if (_selectedBottomTool != selectedBottomTool) {
        _selectedBottomTool = selectedBottomTool;
        [self updateBottomToolSelection];
    }
}

- (void)updateTopToolSelection {
    for (NSButton *button in self.topToolButtons) {
        [button setState:(button.tag == self.selectedTool) ? NSControlStateValueOn : NSControlStateValueOff];
    }
}

- (void)updateBottomToolSelection {
    for (NSButton *button in self.bottomToolButtons) {
        [button setState:(button.tag == self.selectedBottomTool) ? NSControlStateValueOn : NSControlStateValueOff];
    }
}

- (void)updateBottomToolsVisibility {
    // Bottom tools are only visible when Object Workshop (Resource Tree) is selected
    BOOL showBottomTools = (self.selectedTool == ToolObjectWorkshop);
    [self.bottomToolStackView setHidden:!showBottomTools];
}

- (IBAction)topToolButtonPressed:(NSButton *)sender {
    Tool tool = (Tool)sender.tag;
    
    if (self.selectedTool == tool) {
        // Deselect if clicking the same tool
        self.selectedTool = -1;
    } else {
        self.selectedTool = tool;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolSidebar:didSelectTool:)]) {
        [self.delegate toolSidebar:self didSelectTool:self.selectedTool];
    }
}

- (IBAction)bottomToolButtonPressed:(NSButton *)sender {
    BottomTool bottomTool = (BottomTool)sender.tag;
    self.selectedBottomTool = bottomTool;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolSidebar:didSelectBottomTool:)]) {
        [self.delegate toolSidebar:self didSelectBottomTool:self.selectedBottomTool];
    }
}

@end
