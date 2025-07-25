//
//  Stream.m
//  SimPE for Mac
//

#import "Stream.h"

@implementation Stream

- (int64_t)length {
    // Base implementation - subclasses should override
    return 0;
}

- (int64_t)position {
    // Base implementation - subclasses should override
    return 0;
}

- (void)setPosition:(int64_t)position {
    // Base implementation - subclasses should override
    [self seekToOffset:position origin:SeekOriginBegin];
}

- (BOOL)canRead {
    // Base implementation - subclasses should override
    return NO;
}

- (BOOL)canWrite {
    // Base implementation - subclasses should override
    return NO;
}

- (BOOL)canSeek {
    // Base implementation - subclasses should override
    return NO;
}

- (int64_t)seekToOffset:(int64_t)offset origin:(SeekOrigin)origin {
    // Base implementation - subclasses should override
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:@"Subclasses must implement seekToOffset:origin:"
                                 userInfo:nil];
}

- (NSInteger)readBytes:(uint8_t *)buffer maxLength:(NSInteger)maxLength {
    // Base implementation - subclasses should override
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:@"Subclasses must implement readBytes:maxLength:"
                                 userInfo:nil];
}

- (void)writeBytes:(const uint8_t *)buffer length:(NSInteger)length {
    // Base implementation - subclasses should override
    @throw [NSException exceptionWithName:@"NotImplementedException"
                                   reason:@"Subclasses must implement writeBytes:length:"
                                 userInfo:nil];
}

- (void)close {
    // Base implementation - subclasses can override
}

- (void)flush {
    // Base implementation - subclasses can override
}

@end
