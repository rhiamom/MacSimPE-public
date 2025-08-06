//
//  ExtractableFile.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop        *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "ExtractableFile.h"
#import "PackedFileDescriptor.h"
#import "BinaryReader.h"
#import "IPackedFile.h"
#import "IPackageHeader.h"
#import "StreamMaintainer.h"
#import "Helper.h"

@implementation ExtractableFile

- (instancetype)initWithBinaryReader:(BinaryReader *)br {
    return [super initWithBinaryReader:br];
}

- (instancetype)initWithFilename:(NSString *)filename {
    return [super initWithFilename:filename];
}

- (id<IPackageFile>)newCloneBase {
    ExtractableFile *fl = [[ExtractableFile alloc] initWithBinaryReader:nil];
    fl.header = self.header;
    return fl;
}

- (NSData *)extract:(PackedFileDescriptor *)pfd {
    id<IPackedFile> pf = [super readDescriptor:pfd];
    return [pf uncompressedData];
}

- (void)savePackedFile:(NSString *)filename data:(NSData *)data descriptor:(PackedFileDescriptor *)pfd withMeta:(BOOL)meta {
    if (pfd != nil) {
        if (data == nil) {
            data = [self extract:pfd];
        }
        if (meta) {
            NSString *metaFilename = [filename stringByAppendingString:@".xml"];
            [self saveMetaInfo:metaFilename descriptor:pfd];
        }
    }
    
    if (data != nil) {
        [self savePackedFileData:filename data:data];
    }
}

- (void)savePackedFileData:(NSString *)filename data:(NSData *)data {
    StreamItem *si = [StreamFactory getStreamItem:filename create:NO];
    
    NSFileHandle *fileHandle = nil;
    NSString *filePath = filename;
    
    if (si == nil) {
        // Create new file
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } else {
        [si setFileAccess:NSFileHandleWriteAccess];
        fileHandle = [si fileHandle];
    }
    
    @try {
        [fileHandle writeData:data];
    } @finally {
        if (si != nil) {
            [si close];
        } else {
            [fileHandle closeFile];
        }
    }
}

- (void)saveMetaInfo:(NSString *)filename descriptor:(PackedFileDescriptor *)pfd {
    NSMutableString *xmlContent = [NSMutableString string];
    
    [xmlContent appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
    [xmlContent appendFormat:@"<package type=\"%u\">\n", (uint32_t)[[self header] indexType]];
    [xmlContent appendString:[pfd generateXmlMetaInfo]];
    [xmlContent appendString:@"</package>\n"];
    
    NSError *error = nil;
    BOOL success = [xmlContent writeToFile:filename
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error];
    
    if (!success) {
        NSLog(@"Failed to write meta info to file %@: %@", filename, error.localizedDescription);
    }
}

- (NSString *)generatePackageXML {
    return [self generatePackageXMLWithHeader:YES];
}

- (NSString *)generatePackageXMLWithHeader:(BOOL)includeHeader {
    NSMutableString *xml = [NSMutableString string];
    
    if (includeHeader) {
        [xml appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>%@", [Helper lineBreak]];
    }
    
    [xml appendFormat:@"<package type=\"%u\">%@", (uint32_t)[[self header] indexType], [Helper lineBreak]];
    
    NSArray<id<IPackedFileDescriptor>> *fileIndex = [self index];
    for (id<IPackedFileDescriptor> pfd in fileIndex) {
        if ([pfd respondsToSelector:@selector(generateXmlMetaInfo)]) {
            PackedFileDescriptor *descriptor = (PackedFileDescriptor *)pfd;
            [xml appendFormat:@"%@%@", [descriptor generateXmlMetaInfo], [Helper lineBreak]];
        }
    }
    
    [xml appendFormat:@"</package>%@", [Helper lineBreak]];
    
    return [xml copy];
}

- (void)generatePackageXMLToFile:(NSString *)filename {
    NSMutableString *xmlContent = [NSMutableString string];
    
    [xmlContent appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
    [xmlContent appendString:[self generatePackageXMLWithHeader:NO]];
    
    NSError *error = nil;
    BOOL success = [xmlContent writeToFile:filename
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error];
    
    if (!success) {
        NSLog(@"Failed to write package XML to file %@: %@", filename, error.localizedDescription);
    }
}

@end
#import <Foundation/Foundation.h>
