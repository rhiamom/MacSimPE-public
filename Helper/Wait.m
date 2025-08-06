//
//  Wait.m
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

#import "Wait.h"
#import "IWaitingBarControl.h"
#import "Helper.h"

@implementation SessionData
@end

@implementation Wait

static id<IWaitingBarControl> _bar = nil;
static NSMutableArray<SessionData *> *_sessionStack = nil;

+ (void)initialize {
    if (self == [Wait class]) {
        _sessionStack = [[NSMutableArray alloc] init];
    }
}

// MARK: - Class Properties

+ (id<IWaitingBarControl>)bar {
    return _bar;
}

+ (void)setBar:(id<IWaitingBarControl>)bar {
    _bar = bar;
}

+ (BOOL)running {
    if (_bar != nil) {
        return [_bar running];
    }
    return NO;
}

+ (NSString *)message {
    if (_bar != nil) {
        return [_bar message];
    }
    return @"";
}

+ (void)setMessage:(NSString *)message {
    if (_bar != nil) {
        [_bar setMessage:message];
        // Note: Application.DoEvents() equivalent not needed in Cocoa
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
}

+ (NSImage *)image {
    if (_bar != nil) {
        return [_bar image];
    }
    return nil;
}

+ (void)setImage:(NSImage *)image {
    if (_bar != nil) {
        [_bar setImage:image];
    }
}

+ (NSInteger)progress {
    if (_bar != nil) {
        return [_bar progress];
    }
    return 0;
}

+ (void)setProgress:(NSInteger)progress {
    if (_bar != nil) {
        [_bar setProgress:progress];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
}

+ (NSInteger)maxProgress {
    if (_bar != nil) {
        return [_bar maxProgress];
    }
    return 1;
}

+ (void)setMaxProgress:(NSInteger)maxProgress {
    if (_bar != nil) {
        [_bar setMaxProgress:maxProgress];
    }
}

// MARK: - Static Methods

+ (void)subStart {
    if (_bar != nil) {
        [self commonStart];
        if (![_bar running]) {
            [_bar wait];
        }
    }
}

+ (void)subStartWithCount:(NSInteger)max {
    [self startWithCount:max];
}

+ (void)subStop {
    [self stop];
}

+ (void)start {
    if (_bar != nil) {
        [self commonStart];
        [_bar setShowProgress:NO];
        if (![_bar running]) {
            [_bar wait];
        }
    }
}

+ (void)startWithCount:(NSInteger)max {
    if (_bar != nil) {
        [self commonStart];
        if (![_bar running]) {
            [_bar waitWithMax:max];
        } else {
            [_bar setMaxProgress:max];
        }
    }
}

+ (void)stop {
    [self stopForced:NO];
}

+ (void)stopForced:(BOOL)force {
    SessionData *sessionData = nil;
    
    @synchronized (_sessionStack) {
        if ([_sessionStack count] == 0) {
            if (_bar != nil) {
                [_bar stop];
            }
            return;
        }
        
        sessionData = [_sessionStack lastObject];
        [_sessionStack removeLastObject];
        
        if ([_sessionStack count] == 0) {
            if (_bar != nil) {
                [_bar stop];
            }
        }
    }
    
    if (force) {
        if (_bar != nil) {
            [_bar stop];
        }
    }
    
    [self reloadSession:sessionData];
    
    if (_bar != nil) {
        if (![_bar running]) {
            [_bar setShowProgress:NO];
        }
    }
}

// MARK: - Private Methods

+ (void)commonStart {
    @synchronized (_sessionStack) {
        [_sessionStack addObject:[self buildSessionData]];
    }
    [self setMessage:@""];
    [self setMaxProgress:0];
    [self setProgress:0];
}

+ (SessionData *)buildSessionData {
    SessionData *sessionData = [[SessionData alloc] init];
    sessionData.message = [self message];
    sessionData.progress = [self progress];
    sessionData.maxProgress = (_bar == nil || ![_bar showProgress]) ? 0 : [self maxProgress];
    return sessionData;
}

+ (void)reloadSession:(SessionData *)sessionData {
    @try {
        if (sessionData != nil) {
            [self setMessage:sessionData.message];
            [self setMaxProgress:sessionData.maxProgress];
            [self setProgress:sessionData.progress];
        }
    } @catch (NSException *exception) {
        if ([Helper debugMode]) {
            NSLog(@"Wait reloadSession exception: %@", exception);
        }
    }
}

@end
