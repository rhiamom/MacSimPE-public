//
//  StoppableThread.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ThreadPriority) {
    ThreadPriorityLow,
    ThreadPriorityNormal,
    ThreadPriorityHigh
};

/**
 * Implements a Thread that can be stopped
 */
@interface StoppableThread : NSObject

// MARK: - Properties
@property (nonatomic, assign, readonly) BOOL isAsync;
@property (nonatomic, assign, readonly) BOOL haveToStop;
@property (nonatomic, strong, readonly) NSThread *worker;

// MARK: - Initialization
/**
 * Initialize with default async setting from registry
 */
- (instancetype)init;

/**
 * Initialize with specific async setting
 * @param async Whether to run asynchronously
 */
- (instancetype)initWithAsync:(BOOL)async;

// MARK: - Thread Management
/**
 * Block until the loader thread is cancelled (with default timeout)
 */
- (void)waitForEnd;

/**
 * Block until the loader thread is cancelled
 * @param timeout Timeout in deciseconds (1/10 second), negative for no timeout
 * @returns YES if thread ended within timeout, NO if timed out
 */
- (BOOL)waitForEnd:(NSInteger)timeout;

/**
 * Stop and cleanup the thread
 */
- (void)dispose;

// MARK: - Abstract Methods (Must be overridden by subclasses)
/**
 * Subclasses must implement this method to define thread behavior
 */
- (void)startThread;

// MARK: - Thread Execution
/**
 * Execute thread with priority and name (default settings)
 */
- (void)executeThread:(ThreadPriority)priority name:(NSString *)name;

/**
 * Execute thread with priority, name and sync option
 */
- (void)executeThread:(ThreadPriority)priority name:(NSString *)name sync:(BOOL)sync;

/**
 * Execute thread with priority, name, sync and events options
 */
- (void)executeThread:(ThreadPriority)priority
                 name:(NSString *)name
                 sync:(BOOL)sync
               events:(BOOL)events;

/**
 * Execute thread with full configuration
 */
- (void)executeThread:(ThreadPriority)priority
                 name:(NSString *)name
                 sync:(BOOL)sync
               events:(BOOL)events
             syncTime:(NSInteger)syncTime;

@end
