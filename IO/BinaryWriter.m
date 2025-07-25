//
//  BinaryWriter.m
//  SimPE for Mac
//

#import "BinaryWriter.h"

@interface BinaryWriter ()
{
    Stream *_baseStream;
}
@end

@implementation BinaryWriter

- (instancetype)initWithStream:(Stream *)stream {
    self = [super init];
    if (self) {
        _baseStream = stream;
    }
    return self;
}

- (Stream *)baseStream {
    return _baseStream;
}

- (void)writeByte:(uint8_t)value {
    [_baseStream writeBytes:&value length:1];
}

- (void)writeSByte:(int8_t)value {
    [self writeByte:(uint8_t)value];
}

- (void)writeUInt16:(uint16_t)value {
    uint8_t bytes[2];
    // Little-endian
    bytes[0] = value & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    [_baseStream writeBytes:bytes length:2];
}

- (void)writeInt16:(int16_t)value {
    [self writeUInt16:(uint16_t)value];
}

- (void)writeUInt32:(uint32_t)value {
    uint8_t bytes[4];
    // Little-endian
    bytes[0] = value & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    bytes[2] = (value >> 16) & 0xFF;
    bytes[3] = (value >> 24) & 0xFF;
    [_baseStream writeBytes:bytes length:4];
}

- (void)writeInt32:(int32_t)value {
    [self writeUInt32:(uint32_t)value];
}

- (void)writeUInt64:(uint64_t)value {
    [self writeUInt32:(uint32_t)(value & 0xFFFFFFFF)];
    [self writeUInt32:(uint32_t)(value >> 32)];
}

- (void)writeInt64:(int64_t)value {
    [self writeUInt64:(uint64_t)value];
}

- (void)writeSingle:(float)value {
    uint32_t intValue = *(uint32_t*)&value;
    [self writeUInt32:intValue];
}

- (void)writeDouble:(double)value {
    uint64_t intValue = *(uint64_t*)&value;
    [self writeUInt64:intValue];
}

- (void)writeBoolean:(BOOL)value {
    [self writeByte:value ? 1 : 0];
}

- (void)writeChar:(unichar)value {
    [self writeUInt16:(uint16_t)value];
}

- (void)writeBytes:(NSData *)data {
    [_baseStream writeBytes:data.bytes length:data.length];
}

- (void)writeString:(NSString *)string {
    if (!string) string = @"";
    
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger length = stringData.length;
    
    // Write 7-bit encoded length (like .NET BinaryWriter)
    while (length >= 0x80) {
        [self writeByte:(uint8_t)((length & 0x7F) | 0x80)];
        length >>= 7;
    }
    [self writeByte:(uint8_t)length];
    
    // Write string data
    if (stringData.length > 0) {
        [self writeBytes:stringData];
    }
}

- (void)flush {
    [_baseStream flush];
}

- (void)close {
    [_baseStream close];
}

@end
