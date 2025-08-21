//
//  SidebarView.h
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

#import <Cocoa/Cocoa.h>
#import "ToolTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class AppState;
@protocol SidebarViewDelegate;

@interface SidebarView : NSView

@property (nonatomic, weak, nullable) id<SidebarViewDelegate> delegate;
@property (nonatomic, assign) Tool selectedTool;
@property (nonatomic, strong) AppState *appState;

- (instancetype)initWithFrame:(NSRect)frameRect appState:(AppState *)appState;
- (void)updateToolSelection:(Tool)tool;

@end

@protocol SidebarViewDelegate <NSObject>
@optional
- (void)sidebarView:(SidebarView *)sidebar didSelectTool:(Tool)tool;
- (void)sidebarViewDidRequestOpenPackage:(SidebarView *)sidebar;
@end

NS_ASSUME_NONNULL_END
