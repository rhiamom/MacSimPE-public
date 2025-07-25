//
//  MemoryStream.h
//  SimPE for Mac
//

#import "Stream.h"

NS_ASSUME_NONNULL_BEGIN

@interface MemoryStream : Stream

@property (nonatomic, readonly) NSData *data;

- (instancetype)init;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithCapacity:(NSInteger)capacity;

- (NSData *)toData;

@end

NS_ASSUME_NONNULL_END
