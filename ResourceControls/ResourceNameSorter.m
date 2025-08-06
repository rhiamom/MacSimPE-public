//
//  ResourceNameSorter.m
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
// ***************************************************************************/

#import "ResourceNameSorter.h"
#import "ResourceListViewExt.h"
#import "NamedPackedFileDescriptor.h"
#import "ResourceViewManagerHelpers.h"
#import "Registry.h"
#import "Helper.h"
#import "Wait.h"

@implementation ResourceNameSorter

- (instancetype)initWithParent:(ResourceListViewExt *)parent
                         names:(ResourceNameList *)names
                        ticket:(NSInteger)ticket {
    self = [super init];
    if (self) {
        NSInteger numberOfThreads = [[Registry windowsRegistry] sortProcessCount];
        _parent = parent;
        _ticket = ticket;
        _cancelled = NO;
        
        // Convert to mutable array (acts as stack)
        _names = [[NSMutableArray alloc] init];
        for (NamedPackedFileDescriptor *pfd in names) {
            [_names addObject:pfd];
        }
        
        _counter = 0;
        
        if ([[Registry windowsRegistry] asynchronSort]) {
            _started = numberOfThreads;
            for (NSInteger i = 0; i < numberOfThreads; i++) {
                NSString *threadName = [NSString stringWithFormat:@"Resource Sorting Thread %ld.%@",
                                      (long)i, [Helper hexStringUInt32:(uint32_t)ticket]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self readNames];
                });
            }
        } else {
            _started = 1;
            [self readNames];
        }
    }
    return self;
}

- (void)cancel {
    @synchronized (self.names) {
        [self.names removeAllObjects];
        self.started = 0;
        self.cancelled = YES;
    }
}

- (void)readNames {
    while (self.names.count > 0 && !self.cancelled) {
        NamedPackedFileDescriptor *pfd = nil;
        
        @synchronized (self.names) {
            if (self.names.count == 0 || self.cancelled) break;
            
            // Pop from end of array (stack behavior)
            pfd = [self.names lastObject];
            [self.names removeLastObject];
            
            if ([[Registry windowsRegistry] asynchronSort]) {
                [Wait setProgress:self.counter++];
            }
        }
        
        if (pfd && !self.cancelled) {
            [pfd getRealName];
        }
    }
    
    @synchronized (self.names) {
        self.started--;
        if (self.started == 0 && !self.cancelled) {
            [self.parent signalFinishedSort:self.ticket];
        }
    }
}

@end
