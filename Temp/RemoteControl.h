//
//  RemoteControl.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
#import <Foundation/Foundation.h>
@protocol IPackageFile;
@protocol IPackedFileDescriptor;

typedef BOOL (^OpenPackedFileHandler)(id<IPackedFileDescriptor> pfd, id<IPackageFile> pkg);
typedef BOOL (^OpenPackageHandler)(NSString *filename);

@interface RemoteControl : NSObject
+ (void)setOpenPackedFileHandler:(OpenPackedFileHandler)handler;
+ (void)setOpenPackageHandler:(OpenPackageHandler)handler;

// Optional: call-throughs if other code wants to trigger them
+ (BOOL)openPackedFile:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)pkg;
+ (BOOL)openPackageWithFilename:(NSString *)filename;
@end
