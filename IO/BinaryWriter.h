//
//  BinaryWriter.h
//  SimPE for Mac
//

#import <Foundation/Foundation.h>
#import "Stream.h"

NS_ASSUME_NONNULL_BEGIN

@interface BinaryWriter : NSObject

@property (nonatomic, readonly) Stream *baseStream;

- (instancetype)initWithStream:(Stream *)stream;

- (void)writeByte:(uint8_t)value;
- (void)writeSByte:(int8_t)value;
- (void)writeUInt16:(uint16_t)value;
- (void)writeInt16:(int16_t)value;
- (void)writeUInt32:(uint32_t)value;
- (void)writeInt32:(int32_t)value;
- (void)writeUInt64:(uint64_t)value;
- (void)writeInt64:(int64_t)value;
- (void)writeSingle:(float)value;
- (void)writeDouble:(double)value;
- (void)writeBoolean:(BOOL)value;
- (void)writeChar:(unichar)value;

- (void)writeBytes:(NSData *)data;
- (void)writeString:(NSString *)string;

- (void)flush;
- (void)close;

@end

NS_ASSUME_NONNULL_END
