//
//  StoppableThread.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "Thread.h"
#import "Registry.h"
#import "Wait.h"

@interface StoppableThread ()
@property (nonatomic, assign, readwrite) BOOL isAsync;
@property (nonatomic, strong) NSCondition *stopCondition;
@property (nonatomic, strong) NSCondition *endedCondition;
@property (nonatomic, assign) BOOL shouldStop;
@property (nonatomic, assign) BOOL hasEnded;
@property (nonatomic, strong, readwrite) NSThread *worker;
@end

@implementation StoppableThread

// MARK: - Initialization

- (instancetype)init {
    // TODO: Replace with actual registry call when available
    return [self initWithAsync:YES]; // Default to async for now
}

- (instancetype)initWithAsync:(BOOL)async {
    self = [super init];
    if (self) {
        _isAsync = async;
        _stopCondition = [[NSCondition alloc] init];
        _endedCondition = [[NSCondition alloc] init];
        _shouldStop = NO;
        _hasEnded = YES;
    }
    return self;
}

// MARK: - Properties

- (BOOL)haveToStop {
    if (!self.isAsync) return NO;
    
    [self.stopCondition lock];
    BOOL result = self.shouldStop;
    [self.stopCondition unlock];
    
    return result;
}

// MARK: - Thread Management

- (void)waitForEnd {
    [self waitForEnd:[Wait timeout] / 100];
}

- (BOOL)waitForEnd:(NSInteger)timeout {
    if (!self.isAsync) return YES;
    if (self.worker == nil) return YES;
    
    // Signal stop
    [self.stopCondition lock];
    self.shouldStop = YES;
    [self.stopCondition broadcast];
    [self.stopCondition unlock];
    
    NSInteger ct = 0;
    while (![self.worker isFinished] && (ct <= timeout || timeout < 0)) {
        ct++;
        
        // Signal stop again
        [self.stopCondition lock];
        self.shouldStop = YES;
        [self.stopCondition broadcast];
        [self.stopCondition unlock];
        
        // Process events on main thread (equivalent to DoEvents)
        if ([NSThread isMainThread]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
        
        [NSThread sleepForTimeInterval:0.1]; // 100ms
    }
    
    // Signal ended
    [self.endedCondition lock];
    self.hasEnded = YES;
    [self.endedCondition broadcast];
    [self.endedCondition unlock];
    
    return [self.worker isFinished];
}

- (void)dispose {
    [self waitForEnd];
}

// MARK: - Abstract Methods

- (void)startThread {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses must override startThread"
                                 userInfo:nil];
}

// MARK: - Private Methods

- (void)threadEntry {
    // Reset conditions
    [self.stopCondition lock];
    self.shouldStop = NO;
    [self.stopCondition unlock];
    
    [self.endedCondition lock];
    self.hasEnded = NO;
    [self.endedCondition unlock];
    
    @try {
        [self startThread];
    } @finally {
        [self.endedCondition lock];
        self.hasEnded = YES;
        [self.endedCondition broadcast];
        [self.endedCondition unlock];
    }
}

- (double)threadPriorityFromEnum:(ThreadPriority)priority {
    switch (priority) {
        case ThreadPriorityLow:
            return 0.25;
        case ThreadPriorityNormal:
            return 0.5;
        case ThreadPriorityHigh:
            return 0.75;
        default:
            return 0.5;
    }
}

// MARK: - Thread Execution

- (void)executeThread:(ThreadPriority)priority name:(NSString *)name {
    [self executeThread:priority name:name sync:NO events:YES syncTime:500];
}

- (void)executeThread:(ThreadPriority)priority name:(NSString *)name sync:(BOOL)sync {
    [self executeThread:priority name:name sync:sync events:YES syncTime:500];
}

- (void)executeThread:(ThreadPriority)priority
                 name:(NSString *)name
                 sync:(BOOL)sync
               events:(BOOL)events {
    [self executeThread:priority name:name sync:sync events:events syncTime:500];
}

- (void)executeThread:(ThreadPriority)priority
                 name:(NSString *)name
                 sync:(BOOL)sync
               events:(BOOL)events
             syncTime:(NSInteger)syncTime {
    [self waitForEnd];
    
    if (!self.isAsync) {
        [self threadEntry];
    } else {
        self.worker = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadEntry)
                                                object:nil];
        [self.worker setName:name];
        [self.worker setThreadPriority:[self threadPriorityFromEnum:priority]];
        [self.worker start];
        
        if (sync) {
            while (![self.worker isFinished]) {
                [NSThread sleepForTimeInterval:syncTime / 1000.0]; // Convert ms to seconds
                
                if (events && [NSThread isMainThread]) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                }
            }
        }
    }
}

@end
