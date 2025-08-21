//
//  AbstractHandler.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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


#import <Foundation/Foundation.h>
#import "IWrapperFactory.h"
#import "TgiLoader.h"

@protocol IWrapperRegistry, IProviderRegistry, IWrapper;

/**
 * Lists all Plugins (=FileType Wrappers) available in this Package
 *
 * @remarks
 * knownWrappers has to return a list of all Plugins provided by this Library.
 * If a Plugin isn't returned, SimPe won't recognize it!
 */
@interface AbstractWrapperFactory : NSObject <IWrapperFactory>

/**
 * Holds a reference to the Registry this Plugin was last registered to (can be nil!)
 */
@property (nonatomic, strong) id<IWrapperRegistry> linkedRegistry;

/**
 * Returns or sets the Provider this Plugin can use
 */
@property (nonatomic, strong) id<IProviderRegistry> linkedProvider;

/**
 * Returns a List of all available Plugins in this Package
 * @return A List of all provided Plugins (=FileType Wrappers)
 */
@property (nonatomic, readonly, strong) NSArray<id<IWrapper>> *knownWrappers;

/**
 * The filename of this factory
 */
@property (nonatomic, readonly, copy) NSString *fileName;

@end

#import "AbstractWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "MemoryStream.h"
#import "Helper.h"
#import "AbstractWrapperInfo.h"
#import "TypeAlias.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "IPackedFileUI.h"
#import "IWrapperRegistry.h"
#import "IWrapperInfo.h"
#import "IPackedFile.h"
#import "IScenegraphFileIndexItem.h"
#import "IFileWrapper.h"
#import "IWrapperReferencedResources.h"
#import "ExceptionForm.h"

@implementation AbstractWrapper {
    BOOL _processed;
    BOOL _changed;
    id<IWrapperInfo> _wrapperInfo;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _processed = NO;
        _changed = NO;
        _uiHandler = nil;
        _priority = 0;
    }
    return self;
}

- (void)dealloc {
    [self dispose];
}

// MARK: - Properties

- (BOOL)processed {
    return _processed;
}

- (BOOL)changed {
    return _changed;
}

- (void)setChanged:(BOOL)changed {
    _changed = changed;
}

- (void)setFileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor {
    _processed = NO;
    _fileDescriptor = fileDescriptor;
}

- (void)setPackage:(id<IPackageFile>)package {
    _processed = NO;
    _package = package;
}

- (id<IPackedFileUI>)uiHandler {
    if (!_uiHandler) {
        _uiHandler = [self createDefaultUIHandler];
    }
    return _uiHandler;
}

- (NSString *)wrapperFileName {
    NSString *bundleName = [[NSBundle mainBundle] bundleIdentifier];
    if (bundleName) {
        return bundleName;
    }
    return @"unknown";
}

- (MemoryStream *)currentStateData {
    MemoryStream *ms = [[MemoryStream alloc] init];
    BinaryWriter *writer = [[BinaryWriter alloc] initWithStream:ms];
    [self serialize:writer];
    return ms;
}

- (BinaryReader *)storedData {
    if (self.fileDescriptor && self.package) {
        id<IPackedFile> file = [self.package readDescriptor:self.fileDescriptor];
        NSData *data = [file uncompressedData];
        MemoryStream *ms = [[MemoryStream alloc] initWithData:data];
        return [[BinaryReader alloc] initWithStream:ms];
    } else {
        MemoryStream *ms = [[MemoryStream alloc] init];
        return [[BinaryReader alloc] initWithStream:ms];
    }
}

// MARK: - Abstract Methods (must be implemented by subclasses)

- (void)unserialize:(BinaryReader *)reader {
    @throw [NSException exceptionWithName:@"AbstractMethodException"
                                   reason:@"unserialize: must be implemented by subclass"
                                 userInfo:nil];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    @throw [NSException exceptionWithName:@"AbstractMethodException"
                                   reason:@"createDefaultUIHandler must be implemented by subclass"
                                 userInfo:nil];
}

// MARK: - Virtual Methods (can be overridden by subclasses)

- (void)serialize:(BinaryWriter *)writer {
    // Default implementation does nothing
}

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"unnamed"
                                              author:@"unknown"
                                         description:[self description]
                                             version:1];
}

- (BOOL)checkVersion:(uint32_t)version {
    return NO;
}

- (NSString *)getResourceName:(TypeAlias *)ta {
    return nil;
}

// MARK: - Exception Handling

- (NSString *)exceptionMessage:(NSString *)msg {
    if (!msg) msg = @"";
    
    NSMutableString *fullMsg = [msg mutableCopy];
    [fullMsg appendString:@"\n\nPackage: "];
    if (self.package) {
        [fullMsg appendString:[self.package fileName]];
    } else {
        [fullMsg appendString:@"null"];
    }
    
    [fullMsg appendString:@"\nFile: "];
    if (self.fileDescriptor) {
        [fullMsg appendString:[self.fileDescriptor exceptionString]];
    } else {
        [fullMsg appendString:@"null"];
    }
    
    return [fullMsg copy];
}

- (void)exceptionMessage:(NSString *)msg error:(NSError *)error {
    NSString *fullMsg = [self exceptionMessage:msg];
    [Helper exceptionMessage:fullMsg error:error];
}

// MARK: - IWrapper Methods

- (void)registerWithRegistry:(id<IWrapperRegistry>)registry {
    [registry registerWrapper:self];
}

- (id<IWrapperInfo>)wrapperDescription {
    if (!_wrapperInfo) {
        _wrapperInfo = [self createWrapperInfo];
    }
    return _wrapperInfo;
}

- (NSString *)description {
    id<IWrapperInfo> info = [self wrapperDescription];
    return [NSString stringWithFormat:@"%@ (Author=%@, Version=%ld, GUID=%@, FileName=%@, Type=%@)",
            info.name, info.author, (long)info.version,
            [Helper hexStringUInt64:info.uid], self.wrapperFileName, NSStringFromClass([self class])];
}

// MARK: - IPackedFileSaveExtension Methods

- (void)synchronizeUserData {
    [self synchronizeUserData:YES];
}

- (void)synchronizeUserData:(BOOL)catchex {
    [self synchronizeUserData:catchex fire:NO];
}

- (void)synchronizeUserData:(BOOL)catchex fire:(BOOL)fire {
    if (!self.fileDescriptor) {
        self.changed = NO;
        return;
    }
    
    if (catchex) {
        @try {
            NSData *data = [[self currentStateData] toData];
            [self.fileDescriptor setUserData:data fire:fire];
            self.changed = NO;
        }
        @catch (NSException *exception) {
            NSError *error = [NSError errorWithDomain:@"SimPE" code:1
                                             userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
            [self exceptionMessage:@"Error writing file" error:error];
        }
    } else {
        NSData *data = [[self currentStateData] toData];
        [self.fileDescriptor setUserData:data fire:NO];
        self.changed = NO;
    }
}

- (void)savePFD:(id<IPackedFileDescriptor>)pfd {
    @try {
        MemoryStream *ms = [[MemoryStream alloc] init];
        BinaryWriter *bw = [[BinaryWriter alloc] initWithStream:ms];
        NSInteger size = [self save:bw];
        
        NSData *data = [ms toData];
        if (size > 0 && size <= data.length) {
            NSData *trimmedData = [data subdataWithRange:NSMakeRange(0, size)];
            [pfd setUserData:trimmedData];
        }
    }
    @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"error writing file" exception:exception];
    }
}

- (void)saveToDescriptor:(id<IPackedFileDescriptor>)pfd {
    @try {
        NSMutableData *data = [[NSMutableData alloc] init];
        BinaryWriter *writer = [[BinaryWriter alloc] initWithData:data];
        
        NSInteger size = [self save:writer];
        
        // Validate that we wrote some data
        if (size != [data length]) {
            NSLog(@"Warning: Expected %ld bytes but data contains %lu bytes",
                  (long)size, (unsigned long)[data length]);
        }
        
        [pfd setUserData:[data copy]];
        [writer close];
    } @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"errwritingfile" exception:exception];
    }
}


- (NSInteger)save:(BinaryWriter *)writer {
    NSInteger pos = [writer.stream position];
    @try {
        [self serialize:writer];
    }
    @catch (NSException *exception) {
        [ExceptionForm executeWithMessage:@"error writing file" exception:exception];
    }
    return [writer.stream position] - pos;
}

// MARK: - IPackedFileLoadExtension Methods

- (void)fix:(id<IWrapperRegistry>)registry {
    // Default implementation does nothing
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package {
    [self processData:pfd package:package catchex:YES];
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package file:(id<IPackedFile>)file {
    [self processData:pfd package:package file:file catchex:YES];
}

- (void)processData:(id<IPackedFileDescriptor>)fileDescriptor
            package:(id<IPackageFile>)package
               sync:(BOOL)sync {
    
    // Store references (use direct ivar access if properties don't exist)
    _fileDescriptor = fileDescriptor;
    _package = package;
    
    if (fileDescriptor == nil || package == nil) {
        return;
    }
    
    @try {
        // Use readDescriptor method from IPackageFile
        id<IPackedFile> packedFile = [package readDescriptor:fileDescriptor];
        
        if (packedFile == nil) {
            NSLog(@"Warning: No packed file found for descriptor");
            return;
        }
        
        // You'll need to get the actual data from IPackedFile
        // For now, just mark as processed
        _processed = YES;
        
    } @catch (NSException *exception) {
        NSLog(@"Error processing data: %@", [exception reason]);
        _processed = NO;
        @throw exception;
    }
}

- (void)processData:(id<IScenegraphFileIndexItem>)item {
    [self processData:item catchex:YES];
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package catchex:(BOOL)catchex {
    if (!pfd || !package) return;
    
    self.changed = NO;
    
#ifndef DEBUG
    if (catchex) {
        @try {
            self.fileDescriptor = pfd;
            self.package = package;
            BinaryReader *reader = [self storedData];
            if ([reader.stream length] > 0) {
                [self unserialize:reader];
                _processed = YES;
            }
        }
        @catch (NSException *exception) {
            NSError *error = [NSError errorWithDomain:@"SimPE" code:1
                                             userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
            [self exceptionMessage:@"Error opening file" error:error];
        }
    } else
#endif
    {
        self.fileDescriptor = pfd;
        self.package = package;
        BinaryReader *reader = [self storedData];
        if ([reader.baseStream length] > 0) {
            [self unserialize:reader];
            _processed = YES;
        }
    }
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package file:(id<IPackedFile>)file catchex:(BOOL)catchex {
    self.changed = NO;
    if (!pfd || !package) return;
    
    if (catchex) {
        @try {
            if (file) {
                self.fileDescriptor = pfd;
                self.package = package;
                file = [package readDescriptor:pfd];
                NSData *data = [file uncompressedData];
                MemoryStream *ms = [[MemoryStream alloc] initWithData:data];
                if ([ms length] > 0) {
                    BinaryReader *reader = [[BinaryReader alloc] initWithStream:ms];
                    [self unserialize:reader];
                    _processed = YES;
                }
            } else {
                [self processData:pfd package:package];
            }
        }
        @catch (NSException *exception) {
            NSError *error = [NSError errorWithDomain:@"SimPE" code:1
                                             userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
            [self exceptionMessage:@"Error opening file" error:error];
        }
    } else {
        if (file) {
            self.fileDescriptor = pfd;
            self.package = package;
            file = [package readDescriptor:pfd];
            NSData *data = [file uncompressedData];
            MemoryStream *ms = [[MemoryStream alloc] initWithData:data];
            if ([ms length] > 0) {
                BinaryReader *reader = [[BinaryReader alloc] initWithStream:ms];
                [self unserialize:reader];
                _processed = YES;
            }
        } else {
            [self processData:pfd package:package];
        }
    }
}

- (void)processData:(id<IScenegraphFileIndexItem>)item catchex:(BOOL)catchex {
    [self processData:[item fileDescriptor] package:[item package] catchex:catchex];
}

- (void)refreshUI {
    if (self.uiHandler) {
        [self.uiHandler updateGUI:self];
    }
}

- (void)refresh {
    [self processData:self.fileDescriptor package:self.package];
    [self refreshUI];
}

- (void)loadUI {
    [self refreshUI];
}

// MARK: - Resource Information

- (NSString *)getEmbeddedFileName:(TypeAlias *)ta {
    if (!self.package || !self.fileDescriptor) return nil;
    
    if (ta.containsFilename) {
        id<IPackedFile> pf = [self.package readDescriptor:self.fileDescriptor];
        NSData *data = [pf getUncompressedDataWithMaxSize:0x40];
        return [Helper dataToString:data];
    } else {
        return nil;
    }
}

- (NSString *)resourceName {
    NSString *res = nil;
    if (self.fileDescriptor) {
        TypeAlias *ta = [[Helper tgiLoader] getByType:[self.fileDescriptor type]];
        
        // This is a simplified version - the full logic would need Registry access
        res = [self getResourceName:ta];
        if (!res) {
            res = [self getEmbeddedFileName:ta];
        }
        if (!res) {
            res = [self.fileDescriptor toResListString];
        } else if (!ta.name) {
            res = [NSString stringWithFormat:@"Unknown: %@", res];
        } else {
            if ([res stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
                res = [NSString stringWithFormat:@"[%@]", ta.name];
            } else {
                res = [NSString stringWithFormat:@"%@: %@", ta.name, res];
            }
        }
    } else {
        res = @"Unknown";
    }
    
    return res;
}

- (NSString *)resourceDescription {
    return @"";
}

- (NSString *)descriptionHeader {
    return @"";
}

- (MemoryStream *)content {
    return nil;
}

- (NSString *)fileExtension {
    if (self.fileDescriptor) {
        TypeAlias *ta = [[Helper tgiLoader] getByType:[self.fileDescriptor type]];
        return ta.fileExtension;
    }
    return @"simpe";
}

// MARK: - Multiple Instance Support

- (BOOL)allowMultipleInstances {
    // Check if this class conforms to IMultiplePackedFileWrapper protocol
    return [self conformsToProtocol:@protocol(IMultiplePackedFileWrapper)];
}

- (BOOL)referencesResources {
    // Check if this class conforms to IWrapperReferencedResources protocol
    return [self conformsToProtocol:@protocol(IWrapperReferencedResources)];
}

- (id<IFileWrapper>)activate {
    if (!self.allowMultipleInstances) {
        if (!self.singleGuiWrapper) {
            self.singleGuiWrapper = [[self.class alloc] init];
        }
        return self.singleGuiWrapper;
    } else {
        // For multiple instances, create new instance with constructor arguments
        NSArray *args = [self getConstructorArguments];
        // TODO: Implement proper constructor argument handling when needed
        // For now, just use default init
        (void)args; // Suppress unused variable warning
        return [[self.class alloc] init];
    }
}

- (NSArray *)getConstructorArguments {
    return @[];
}

// MARK: - Cleanup

- (void)dispose {
    // In Objective-C, just clear the references
    // ARC will handle the memory management automatically
    _uiHandler = nil;
    _package = nil;
    _fileDescriptor = nil;
    _wrapperInfo = nil;
}

- (void)processData:(id<IScenegraphFileIndexItem>)item catchExceptions:(BOOL)catchex {
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package catchExceptions:(BOOL)catchex {
}

- (void)synchronizeUserData:(BOOL)catchExceptions fireEvent:(BOOL)fire {
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package file:(id<IPackedFile>)file catchExceptions:(BOOL)catchex {
}

@synthesize fileSignature;

@synthesize assignableTypes;

@end
