//
//  ThreadConsumer.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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

@class ProducerThread, Wait;

/**
 * Legacy thread buffer implementation (internal use only)
 */
@interface OldThreadBuffer : NSObject

@property (class, nonatomic, assign) BOOL finishedCreate;
@property (class, nonatomic, assign) BOOL finishedConsume;

+ (void)produce:(id)object;
+ (void)initialize;
+ (void)finish;
+ (id)consume;

@end

/**
 * Abstract base class for producer threads with internal buffering
 */
@interface ProducerThread : NSObject

// MARK: - Properties
@property (nonatomic, readonly, assign) BOOL finishedCreate;
@property (nonatomic, readonly, assign) BOOL finishedConsume;
@property (nonatomic, assign) BOOL canceled;

// MARK: - Events
@property (nonatomic, copy) void (^finishedHandler)(ProducerThread *sender);
@property (nonatomic, copy) void (^cancelingHandler)(ProducerThread *sender);

// MARK: - Public Methods

/**
 * Start the producer thread
 */
- (void)start;

/**
 * Cancel the producer thread
 */
- (void)cancel;

// MARK: - Protected Methods (for subclasses)

/**
 * Add an object to the internal buffer
 * @param object The object to add to the buffer
 */
- (void)addToBuffer:(id)object;

/**
 * Abstract method - subclasses must implement this to produce objects
 * Use addToBuffer: to add objects to the buffer
 */
- (void)produce NS_REQUIRES_SUPER;

/**
 * Called when production is finished - subclasses can override
 */
- (void)onFinish;

// MARK: - Internal Methods
- (void)initializeBuffer;
- (void)finishProduction;
- (id)consume;
- (void)setFinishedConsumeState:(BOOL)finished;

@end

/**
 * Abstract base class for consumer threads
 */
@interface ConsumerThread : NSObject

// MARK: - Properties
@property (nonatomic, strong, readonly) ProducerThread *producerThread;

// MARK: - Initialization

/**
 * Initialize with a producer thread
 * @param producer The producer thread to consume from
 */
- (instancetype)initWithProducer:(ProducerThread *)producer;

// MARK: - Public Methods

/**
 * Start the consumer thread
 */
- (void)start;

// MARK: - Abstract Methods (for subclasses)

/**
 * Implements the consume action for this thread
 * @param object The object that should be consumed (never nil)
 * @return NO if all active consumers should stop consuming
 * @remarks You should only return NO if you know what you are doing,
 *          as this could block the producer thread!
 */
- (BOOL)consume:(id)object NS_SWIFT_NAME(consume(_:));

@end
