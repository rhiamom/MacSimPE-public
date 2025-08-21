//
//  ErrorWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/17/25.
//

#import "ErrorWrapper.h"
#import "IWrapperRegistry.h"
#import "AbstractWrapperInfo.h"
#import "Localization.h"
#import "BinaryReader.h"
#import "MemoryStream.h"

@interface ErrorWrapper ()
@property (nonatomic, strong, readwrite) NSString *filename;
@property (nonatomic, strong, readwrite) NSException *exception;
@end

@implementation ErrorWrapper

// MARK: - Initialization

- (instancetype)initWithFilename:(NSString *)filename exception:(NSException *)exception {
    self = [super init];
    if (self) {
        _filename = filename;
        _exception = exception;
        _priority = -1;
    }
    return self;
}

// MARK: - IWrapper Protocol

- (NSString *)wrapperFileName {
    return [self.filename lastPathComponent];
}

- (void)registerWithRegistry:(id<IWrapperRegistry>)registry {
    [registry registerWrapper:self];
}

- (BOOL)checkVersion:(uint32_t)version {
    return NO;
}

- (BOOL)allowMultipleInstances {
    return NO;
}

- (NSString *)description {
    return @"Error Wrapper";
}

- (id<IWrapperInfo>)wrapperDescription {
    NSString *exceptionDetails = [NSString stringWithFormat:@"%@:%@",
                                 self.exception.name,
                                 self.exception.reason];
    
    return [[AbstractWrapperInfo alloc] initWithName:[self wrapperFileName]
                                              author:[Localization getString:@"Unknown"]
                                         description:exceptionDetails
                                             version:1];
}

// MARK: - IFileWrapper Protocol

- (NSData *)fileSignature {
    return [NSData data];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[];
}

// MARK: - IPackedFileWrapper Protocol

- (void)refreshUI {
    // Empty implementation
}

- (NSString *)resourceName {
    return @"";
}

- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package
           catchExceptions:(BOOL)catchEx {
    // Empty implementation
}

- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package
               file:(id<IPackedFile>)file
    catchExceptions:(BOOL)catchEx {
    // Empty implementation
}

- (void)processData:(id<IScenegraphFileIndexItem>)item catchExceptions:(BOOL)catchEx {
    // Empty implementation
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package {
    // Empty implementation
}

- (void)processData:(id<IPackedFileDescriptor>)pfd
            package:(id<IPackageFile>)package
               file:(id<IPackedFile>)file {
    // Empty implementation
}

- (void)processData:(id<IScenegraphFileIndexItem>)item {
    // Empty implementation
}

- (NSString *)descriptionText {
    return @"Error Object";
}

- (NSString *)descriptionHeader {
    return @"Error";
}

- (BinaryReader *)storedData {
    return nil;
}

- (void)loadUI {
    // Empty implementation
}

- (void)fixWithRegistry:(id<IWrapperRegistry>)registry {
    // Empty implementation
}

- (MemoryStream *)content {
    return nil;
}

- (id<IPackageFile>)package {
    return nil;
}

- (id<IPackedFileUI>)uiHandler {
    return nil;
}

- (void)setUiHandler:(id<IPackedFileUI>)uiHandler {
    // Empty implementation
}

- (id<IFileWrapper>)activate {
    return self;
}

- (void)refresh {
    // Default implementation - subclasses should override if needed
}

- (void)fix:(id<IWrapperRegistry>)registry {
    // Default implementation - subclasses can override to fix/repair data
}

- (void)processData:(id<IScenegraphFileIndexItem>)item catchex:(BOOL)catchex {
    // Default implementation - subclasses should override to handle scenegraph items
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package catchex:(BOOL)catchex {
    // Default implementation - subclasses should override to handle package data
}

- (void)processData:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package file:(id<IPackedFile>)file catchex:(BOOL)catchex {
    // Default implementation - subclasses should override to handle file data
}


- (NSString *)fileExtension {
    return @".err";
}

- (id<IPackedFileDescriptor>)fileDescriptor {
    return nil;
}

// MARK: - Memory Management

- (void)dealloc {
    // Cleanup if needed
}

@synthesize resourceDescription;

@end
