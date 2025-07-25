//
//  BinaryReader.h
//  SimPE for Mac
//

#import <Foundation/Foundation.h>
#import "Stream.h"

NS_ASSUME_NONNULL_BEGIN

@interface BinaryReader : NSObject

@property (nonatomic, readonly) Stream *baseStream;

- (instancetype)initWithStream:(Stream *)stream;

- (uint8_t)readByte;
- (int8_t)readSByte;
- (uint16_t)readUInt16;
- (int16_t)readInt16;
- (uint32_t)readUInt32;
- (int32_t)readInt32;
- (uint64_t)readUInt64;
- (int64_t)readInt64;
- (float)readSingle;
- (double)readDouble;
- (BOOL)readBoolean;
- (unichar)readChar;

- (NSData *)readBytes:(NSInteger)count;
- (NSString *)readString;

- (void)close;

@end

NS_ASSUME_NONNULL_END
