//
//  RemoteControl.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
#import "RemoteControl.h"

static OpenPackedFileHandler sPackedHandler = nil;
static OpenPackageHandler    sPackageHandler = nil;

@implementation RemoteControl

+ (void)setOpenPackedFileHandler:(OpenPackedFileHandler)handler {
    sPackedHandler = [handler copy];
}

+ (void)setOpenPackageHandler:(OpenPackageHandler)handler {
    sPackageHandler = [handler copy];
}

+ (BOOL)openPackedFile:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)pkg {
    return sPackedHandler ? sPackedHandler(pfd, pkg) : NO;
}

+ (BOOL)openPackageWithFilename:(NSString *)filename {
    return sPackageHandler ? sPackageHandler(filename) : NO;
}

@end
