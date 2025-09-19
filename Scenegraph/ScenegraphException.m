//
//  ScenegraphException.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/18/25.
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

#import "ScenegraphException.h"
#import "IScenegraphFileIndexItem.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "FileTableBase.h"
#import "ExceptionForm.h"

// MARK: - CorruptedFileException Implementation

@implementation CorruptedFileException

// MARK: - Initialization

- (instancetype)initWithFileIndexItem:(id<IScenegraphFileIndexItem>)item
                       innerException:(NSException *)inner {
    NSString *filename = [CorruptedFileException getFileName:item];
    NSString *fileDescriptor = item ? [item.fileDescriptor description] : @"Unknown";
    
    NSString *detailMessage = [NSString stringWithFormat:
                               @"The File '%@' contains a Corrupted File (%@).\n\nSimPE will Ignore this File, but the resulting Package might be broken!",
                               filename, fileDescriptor];
    
    NSException *wrappedException = [NSException exceptionWithName:@"CorruptedFileException"
                                                            reason:detailMessage
                                                          userInfo:inner ? @{@"innerException": inner} : nil];
    
    self = [super initWithName:@"CorruptedFileException"
                        reason:@"A corrupted PackedFile was found."
                      userInfo:@{@"wrappedException": wrappedException}];
    
    if (self) {
        // Remove the corrupted item from the file index (equivalent to FileTable.FileIndex.RemoveItem)
        if (item && [FileTableBase fileIndex]) {
            [[FileTableBase fileIndex] removeItem:item];
        }
        
        // Display error using macOS native error handling
        [ExceptionForm showError:@"Corrupted File Found"
                     withDetails:detailMessage
                       exception:inner];
    }
    
    return self;
}

// MARK: - Utility Methods

+ (NSString *)getFileName:(id<IScenegraphFileIndexItem>)item {
    if (item == nil) return @"";
    if (item.package == nil) return @"";
    if (item.package.fileName == nil) return @"";
    
    return item.package.fileName;
}

@end

// MARK: - ScenegraphException Implementation

@implementation ScenegraphException

@synthesize packedFileDescriptor = _pfd;

// MARK: - Initialization

- (instancetype)initWithMessage:(NSString *)message
           packedFileDescriptor:(id<IPackedFileDescriptor>)pfd {
    self = [super initWithName:@"ScenegraphException" reason:message userInfo:nil];
    if (self) {
        _pfd = pfd;
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
                 innerException:(NSException *)inner
           packedFileDescriptor:(id<IPackedFileDescriptor>)pfd {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if (inner) {
        userInfo[@"innerException"] = inner;
    }
    
    self = [super initWithName:@"ScenegraphException"
                        reason:message
                      userInfo:userInfo];
    if (self) {
        _pfd = pfd;
    }
    return self;
}

// MARK: - Message Override

- (NSString *)enhancedReason {
    if (_pfd != nil) {
        return [NSString stringWithFormat:@"%@ (in %@)", self.reason, _pfd];
    } else {
        return self.reason;
    }
}

// MARK: - NSException Overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", self.name, self.enhancedReason];
}

@end
