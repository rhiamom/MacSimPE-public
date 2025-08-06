//
//  WaitControl.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/29/25.
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
// ***************************************************************************

#import <Cocoa/Cocoa.h>
#import "IWaitingBarControl.h"

@interface WaitControl : NSView <IWaitingBarControl>

// MARK: - UI Components
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) NSTextField *messageLabel;
@property (nonatomic, strong) NSTextField *percentLabel;
@property (nonatomic, strong) NSProgressIndicator *spinningIndicator;

// MARK: - Properties
@property (nonatomic, assign) BOOL waiting;
@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, assign) BOOL showAnimation;
@property (nonatomic, assign) BOOL showText;

// MARK: - IWaitingBarControl Protocol
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, assign) NSInteger progress;
@property (nonatomic, assign) NSInteger maxProgress;
@property (nonatomic, readonly) BOOL running;

- (void)wait;
- (void)waitWithMax:(NSInteger)max;
- (void)stop;

@end
