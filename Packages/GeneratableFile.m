//
//  GeneratableFile.m
//  MacSimpe
//
//  Translated from GeneratableFile.cs
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

#import "GeneratableFile.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PackedFileDescriptor.h"
#import "PackedFile.h"
#import "CompressedFileList.h"
#import "ClstItem.h"
#import "HoleIndexItem.h"
#import "StreamMaintainer.h"
#import "PackageMaintainer.h"
#import "Helper.h"
#import "MetaData.h"
#import "IPackageHeader.h"
#import "IscenegraphFileIndex.h"


const uint32_t BLOCKSIZE = 0x200;

@implementation GeneratableFile

- (instancetype)initWithBinaryReader:(BinaryReader *)br {
    return [super initWithBinaryReader:br];
}

- (instancetype)initWithFilename:(NSString *)filename {
    return [super initWithFilename:filename];
}

- (id<IPackageFile>)newCloneBase {
    GeneratableFile *fl = [[GeneratableFile alloc] initWithBinaryReader:nil];
    // Note: Need to check if header property has a setter or use internal method
    // fl.header = self.header;  // This might be readonly
    return fl;
}

+ (BOOL)canWriteToFile:(NSString *)filename close:(BOOL)closeAfterCheck {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return YES;
    }
    
    StreamItem *si = [StreamFactory useStream:filename fileAccess:@"ReadWrite"];
    BOOL result = ([si streamState] == StreamStateOpened);
    
    if (closeAfterCheck && result) {
        [si close];
    }
    return result;
}

- (NSString *)getBakFileName:(NSString *)filename {
    NSString *directory = [filename stringByDeletingLastPathComponent];
    NSString *baseName = [filename stringByDeletingPathExtension];
    return [directory stringByAppendingPathComponent:[baseName stringByAppendingString:@".bak"]];
}

- (void)saveWithFilename:(NSString *)filename {
    // Can we write to the output file?
    if (![GeneratableFile canWriteToFile:filename close:NO]) {
        NSString *message = [NSString stringWithFormat:@"\"%@\" is write protected.", filename];
        NSError *error = [NSError errorWithDomain:@"WriteProtected"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"Changes cannot be saved!",
                                                   NSLocalizedFailureReasonErrorKey: message}];
        [Helper exceptionMessage:error];
        return;
    }
    
    // Can we write to the .bak file?
        if ([[Registry windowsRegistry] autoBackup]) {
            NSString *bakFileName = [self getBakFileName:filename];
            if (![GeneratableFile canWriteToFile:bakFileName close:YES]) {
                NSString *message = [NSString stringWithFormat:@"\"%@\" is write protected.", bakFileName];
                NSError *error = [NSError errorWithDomain:@"WriteProtected"
                                                     code:1002
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Changes cannot be saved!",
                                                           NSLocalizedFailureReasonErrorKey: message}];
                [Helper exceptionMessage:error];
                return;
            }
        }
    
    [self beginUpdate];
    BOOL wasInFileIndex = [[[PackageMaintainer maintainer] fileIndex] contains:filename];
    [[PackageMaintainer maintainer] removePackage:self];
    
    
    @try {
        NSData *packageData = [self build];
        if ([self reader] != nil) {
            [[self reader] close];
        }
        [self saveData:packageData toFile:filename];
        
        // Update filename - this might need to be done through a protected setter
        self.fileName = filename;
        // self.pType = PackageBaseTypeFilename;  // This is likely readonly
        
        // These methods might need to be declared as protected or internal
        // [self openReader];
        // [self closeReader];
    } @finally {
        [self forgetUpdate];
        [self endUpdate];
        
        if (wasInFileIndex) {
            [[PackageMaintainer maintainer] syncFileIndex:self];
        }
        
        // This method might need to be declared as protected
        // [self fireSavedIndexEvent];
    }
}

- (void)reloadFromFile:(NSString *)filename {
    // Close existing reader if open
    if ([self reader] != nil) {
        [[self reader] close];
        // self.reader = nil;  // This is likely readonly
    }
    
    // Clear current state - these might need protected setters
    // [self setIndex:nil];
    // [self setHoleindex:nil];
    // [self setFilelist:nil];
    // [self setFilelistfile:nil];
    
    // Update filename
    self.fileName = filename;
    // self.pType = PackageBaseTypeFilename;  // This is likely readonly
    
    // Reload from the new file - these might need to be declared as protected
    // [self openReader];
    // [self closeReader];
    
    // Fire events to notify of the reload
    // [self fireIndexEvent];
}

- (void)saveData:(NSData *)data toFile:(NSString *)filename {
    [StreamFactory closeStream:filename];
    
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    @try {
        // Try to save to a temp file first
        BOOL success = [data writeToFile:tempFile atomically:YES];
        if (!success) {
            @throw [NSException exceptionWithName:@"FileWriteException"
                                           reason:@"Failed to write to temporary file"
                                         userInfo:nil];
        }
        
        // If the destination already exists...
        if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
            // ...back up the current package content...
            if ([[Registry windowsRegistry] autoBackup]) {
                NSString *bakFile = [self getBakFileName:filename];
                NSError *error = nil;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:bakFile]) {
                    [[NSFileManager defaultManager] removeItemAtPath:bakFile error:&error];
                }
                
                [[NSFileManager defaultManager] copyItemAtPath:filename toPath:bakFile error:&error];
                if (error) {
                    NSLog(@"Warning: Failed to create backup file: %@", error.localizedDescription);
                }
            }
            
            // ...and remove the original
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
            if (error) {
                @throw [NSException exceptionWithName:@"FileDeleteException"
                                               reason:error.localizedDescription
                                             userInfo:nil];
            }
        }
    } @catch (NSException *ex) {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
        @throw ex;
    }
    
    // At this point we have successfully written tempFile and deleted filename
    // Move the temp file to the destination
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:filename error:&error];
    if (error) {
        @throw [NSException exceptionWithName:@"FileMoveException"
                                       reason:error.localizedDescription
                                     userInfo:nil];
    }
    
    [StreamFactory useStream:filename fileAccess:@"Read"];
}

- (void)prepareCompression {
    // This method likely needs access to protected properties
    // Implementation would depend on how fileindex, filelist, and filelistfile are exposed
    NSLog(@"TODO: Implement prepareCompression - needs access to protected properties");
}

- (NSData *)build {
    // This is a complex method that needs access to many protected properties and methods
    // For now, providing a skeleton implementation
    NSLog(@"TODO: Implement build method - needs access to protected properties and methods");
    return [NSData data];
}

- (void)writeFileListWithWriter:(BinaryWriter *)writer
                          index:(NSMutableArray<PackedFileDescriptor *> *)tmpIndex
                     compressed:(NSMutableArray<NSNumber *> *)tmpCompressed {
    // Implementation depends on access to protected properties
    NSLog(@"TODO: Implement writeFileListWithWriter - needs access to protected properties");
}

- (void)saveIndexWithWriter:(BinaryWriter *)writer index:(NSArray<id<IPackedFileDescriptor>> *)tmpIndex {
    
    for (id<IPackedFileDescriptor> item in tmpIndex) {
        [writer writeUInt32:[item type]];
        [writer writeUInt32:[item group]];
        [writer writeUInt32:[item instance]];
        
        if ([[self header] isVersion0101] && [[self header] indexType] == ptLongFileIndex) {
            [writer writeUInt32:[item subtype]];
        }
        
        [writer writeUInt32:[item offset]];
        [writer writeUInt32:[item size]];
    }
    
    // This likely needs access to a protected header setter
    //[[self header] setIndexSize:(int32_t)(writer.position - startPos)];    // Index bytes have been written; header has no                                                                           // explicit index-size field to update here.
}

+ (GeneratableFile *)createNew {
    GeneratableFile *gf = [[GeneratableFile alloc] initWithBinaryReader:nil];
    
    // Initialize with default header
    // Implementation would create a new empty package structure
    
    // This would need UserVerification class
    // if ([UserVerification haveValidUserId]) {
    //     [[gf header] setCreated:[UserVerification userId]];
    // }
    
    return gf;
}

@end
