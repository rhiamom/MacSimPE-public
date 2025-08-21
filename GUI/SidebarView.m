//
//  SidebarView.m
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/10/25.
//
//***************************************************************************
//*  Copyright (C) 2025 by GramzeSweatShop                                  *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*  along with this program; if not, write to the                          *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/

#import "SidebarView.h"

@interface SidebarView ()
@property (nonatomic, strong) NSMutableArray<NSButton *> *toolButtons;
@property (nonatomic, strong) NSTextField *titleLabel;
@end

@implementation SidebarView

- (instancetype)initWithFrame:(NSRect)frameRect appState:(AppState *)appState {
    self = [super initWithFrame:frameRect];
    if (self) {
        _appState = appState;
        _toolButtons = [[NSMutableArray alloc] init];
        _selectedTool = -1;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.titleLabel = [[NSTextField alloc] init];
    self.titleLabel.stringValue = @"Tools";
    self.titleLabel.font = [NSFont boldSystemFontOfSize:16];
    self.titleLabel.bordered = NO;
    self.titleLabel.editable = NO;
    self.titleLabel.backgroundColor = [NSColor clearColor];
    [self addSubview:self.titleLabel];
    
    NSArray *topTools = [ToolHelper topHalfTools];
    NSArray *bottomTools = [ToolHelper bottomHalfTools];
    
    for (NSNumber *toolNum in topTools) {
        Tool tool = [toolNum integerValue];
        [self addToolButton:tool];
    }
    
    for (NSNumber *toolNum in bottomTools) {
        Tool tool = [toolNum integerValue];
        [self addToolButton:tool];
    }
    
    [self layoutButtons];
}

- (void)addToolButton:(Tool)tool {
    NSButton *button = [[NSButton alloc] init];
    button.title = [ToolHelper displayNameForTool:tool];
    button.bezelStyle = NSBezelStyleTexturedRounded;
    button.buttonType = NSButtonTypeMomentaryPushIn;
    button.alignment = NSTextAlignmentLeft;
    button.tag = tool;
    button.target = self;
    button.action = @selector(toolButtonClicked:);
    
    [self.toolButtons addObject:button];
    [self addSubview:button];
}

- (void)layoutButtons {
    CGFloat y = self.bounds.size.height - 30;
    
    [self.titleLabel setFrame:NSMakeRect(16, y, self.bounds.size.width - 32, 20)];
    y -= 40;
    
    for (NSButton *button in self.toolButtons) {
        [button setFrame:NSMakeRect(8, y, self.bounds.size.width - 16, 32)];
        y -= 36;
    }
}

- (void)toolButtonClicked:(NSButton *)sender {
    Tool selectedTool = (Tool)sender.tag;
    
    if (selectedTool == ToolOpenPackage) {
        if ([self.delegate respondsToSelector:@selector(sidebarViewDidRequestOpenPackage:)]) {
            [self.delegate sidebarViewDidRequestOpenPackage:self];
        }
    } else {
        [self updateToolSelection:selectedTool];
        if ([self.delegate respondsToSelector:@selector(sidebarView:didSelectTool:)]) {
            [self.delegate sidebarView:self didSelectTool:selectedTool];
        }
    }
}

- (void)updateToolSelection:(Tool)tool {
    self.selectedTool = tool;
    
    for (NSButton *button in self.toolButtons) {
        if (button.tag == tool) {
            button.state = NSControlStateValueOn;
        } else {
            button.state = NSControlStateValueOff;
        }
    }
}

@end
