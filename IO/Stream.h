//
//  Stream.h
//  SimPE for Mac
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SeekOrigin) {
    SeekOriginBegin = 0,
    SeekOriginCurrent = 1,
    SeekOriginEnd = 2
};

typedef NS_ENUM(NSInteger, FileAccess) {
    FileAccessRead = 1,
    FileAccessWrite = 2,
    FileAccessReadWrite = 3
};

@interface Stream : NSObject

@property (nonatomic, readonly) int64_t length;
@property (nonatomic, assign) int64_t position;
@property (nonatomic, readonly) BOOL canRead;
@property (nonatomic, readonly) BOOL canWrite;
@property (nonatomic, readonly) BOOL canSeek;

- (int64_t)seekToOffset:(int64_t)offset origin:(SeekOrigin)origin;
- (NSInteger)readBytes:(uint8_t *)buffer maxLength:(NSInteger)maxLength;
- (void)writeBytes:(const uint8_t *)buffer length:(NSInteger)length;
- (void)close;
- (void)flush;

@end

NS_ASSUME_NONNULL_END
