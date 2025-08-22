//
//  ThreadConsumer.m
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

#import "ThreadConsumer.h"
#import "Wait.h"

#pragma mark - OldThreadBuffer

@implementation OldThreadBuffer

static BOOL _finishedCreate = NO;
static BOOL _finishedConsume = NO;
static NSMutableArray *_buffer;
static NSCondition *_bufferCondition;
static NSCondition *_consumeCondition;
static const NSUInteger kMaxBufferSize = 50;

+ (void)initialize {
    if (self == [OldThreadBuffer class]) {
        _buffer = [[NSMutableArray alloc] init];
        _bufferCondition = [[NSCondition alloc] init];
        _consumeCondition = [[NSCondition alloc] init];
    }
}

+ (BOOL)finishedCreate {
    return _finishedCreate;
}

+ (void)setFinishedCreate:(BOOL)finishedCreate {
    _finishedCreate = finishedCreate;
}

+ (BOOL)finishedConsume {
    return _finishedConsume;
}

+ (void)setFinishedConsume:(BOOL)finishedConsume {
    _finishedConsume = finishedConsume;
}

+ (void)produce:(id)object {
    [_bufferCondition lock];
    
    while (_buffer.count >= kMaxBufferSize) {
        [_bufferCondition wait];
    }
    
    [_buffer addObject:object];
    [_bufferCondition broadcast];
    
    [_bufferCondition unlock];
}

+ (void)initializeBuffer {
    _finishedCreate = NO;
    _finishedConsume = NO;
}

+ (void)finish {
    [_bufferCondition lock];
    _finishedCreate = YES;
    [_bufferCondition broadcast];
    [_bufferCondition unlock];
}

+ (id)consume {
    [_consumeCondition lock];
    
    while (_buffer.count == 0) {
        if (!_finishedCreate) {
            [_bufferCondition wait];
        } else {
            _finishedConsume = YES;
            [_consumeCondition unlock];
            return nil;
        }
    }
    
    id object = [_buffer lastObject];
    [_buffer removeLastObject];
    [_bufferCondition broadcast];
    
    [_consumeCondition unlock];
    return object;
}

@end

#pragma mark - ProducerThread

@implementation ProducerThread {
    NSMutableArray *_buffer;
    NSCondition *_bufferCondition;
    NSCondition *_consumeCondition;
    NSUInteger _counter;
    BOOL _finishedCreate;
    BOOL _finishedConsume;
    BOOL _canceled;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _buffer = [[NSMutableArray alloc] init];
        _bufferCondition = [[NSCondition alloc] init];
        _consumeCondition = [[NSCondition alloc] init];
    }
    return self;
}

- (BOOL)finishedCreate {
    return _finishedCreate;
}

- (BOOL)finishedConsume {
    return _finishedConsume;
}

- (BOOL)canceled {
    return _canceled;
}

- (void)setCanceled:(BOOL)canceled {
    _canceled = canceled;
    
    if (canceled) {
        if (self.cancelingHandler) {
            self.cancelingHandler(self);
        }
        
        [_bufferCondition lock];
        _counter = 0;
        [_buffer removeAllObjects];
        [_bufferCondition broadcast];
        [_bufferCondition unlock];
        
        [_consumeCondition lock];
        [_consumeCondition broadcast];
        [_consumeCondition unlock];
    }
}

- (void)cancel {
    self.canceled = YES;
}

- (void)addToBuffer:(id)object {
    [_bufferCondition lock];
    
    while (_counter >= kMaxBufferSize) {
        [_bufferCondition wait];
    }
    
    [_buffer addObject:object];
    _counter++;
    [_bufferCondition broadcast];
    
    [_bufferCondition unlock];
}

- (void)initializeBuffer {
    _finishedCreate = NO;
    _finishedConsume = NO;
    _canceled = NO;
    
    [_buffer removeAllObjects];
    _counter = 0;
}

- (void)finishProduction {
    [_bufferCondition lock];
    _finishedCreate = YES;
    [_bufferCondition broadcast];
    [_bufferCondition unlock];
}

- (id)consume {
    [_consumeCondition lock];
    
    while (_counter == 0) {
        if (!_finishedCreate) {
            [_bufferCondition wait];
        } else {
            _finishedConsume = YES;
            [_consumeCondition unlock];
            return nil;
        }
        
        if (_canceled) {
            [_consumeCondition unlock];
            return nil;
        }
    }
    
    id object = [_buffer lastObject];
    [_buffer removeLastObject];
    _counter--;
    
    [_bufferCondition broadcast];
    [_consumeCondition unlock];
    
    return object;
}

- (void)produce {
    // Abstract method - must be implemented by subclasses
    [NSException raise:NSInternalInconsistencyException
                format:@"Subclasses must implement %@", NSStringFromSelector(_cmd)];
}

- (void)onFinish {
    // Virtual method - can be overridden by subclasses
}

- (void)start {
    [self initializeBuffer];
    [Wait subStart];
    
    [self produce];
    
    [self finishProduction];
    
    while (!_finishedConsume) {
        [NSThread sleepForTimeInterval:0.5];
    }
    
    [Wait subStop];
    [self onFinish];
    
    if (self.finishedHandler) {
        self.finishedHandler(self);
    }
}

- (void)setFinishedConsumeState:(BOOL)finished {
    _finishedConsume = finished;
}

@end

#pragma mark - ConsumerThread

@implementation ConsumerThread

- (instancetype)initWithProducer:(ProducerThread *)producer {
    self = [super init];
    if (self) {
        _producerThread = producer;
    }
    return self;
}

- (BOOL)consume:(id)object {
    // Abstract method - must be implemented by subclasses
    [NSException raise:NSInternalInconsistencyException
                format:@"Subclasses must implement %@", NSStringFromSelector(_cmd)];
    return NO;
}

- (void)start {
    while (!_producerThread.finishedConsume && !_producerThread.canceled) {
        // Consume data
        id object = [_producerThread consume];
        if (!object) {
            break;
        }
        
        BOOL shouldContinue = [self consume:object];
        if (!shouldContinue) {
            // Set the producer thread's finished state through a method call
            [_producerThread setFinishedConsumeState:YES];
            break;
        }
    }
    
    [_producerThread setFinishedConsumeState:YES];
}

@end
