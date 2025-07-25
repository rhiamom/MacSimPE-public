//
//  FileStream.h
//  SimPE for Mac
//

#import "Stream.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileStream : Stream

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithPath:(NSString *)path access:(FileAccess)access;
- (instancetype)initWithData:(NSData *)data access:(FileAccess)access;

@end

NS_ASSUME_NONNULL_END
