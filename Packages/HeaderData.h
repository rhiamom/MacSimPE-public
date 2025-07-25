//
//  HeaderData.h
//  SimPE for Mac
//

#import <Foundation/Foundation.h>

// Forward declarations
@class BinaryReader;
@class BinaryWriter;
@class HeaderIndex;
@class HeaderHole;
@protocol IPackageHeader;
@protocol IPackageHeaderIndex;
@protocol IPackageHeaderHoleIndex;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint32_t, IndexTypes) {
    IndexTypesShortFileIndex = 0,
    IndexTypesLongFileIndex = 7
};

/// Structural Data of a .package Header
@interface HeaderData : NSObject <IPackageHeader>

// MARK: - Properties
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) int32_t majorVersion;
@property (nonatomic, readonly) int32_t minorVersion;
@property (nonatomic, readonly) int64_t version;
@property (nonatomic, assign) uint32_t created;
@property (nonatomic, readonly) int32_t modified;
@property (nonatomic, readonly) id<IPackageHeaderIndex> index;
@property (nonatomic, readonly) id<IPackageHeaderHoleIndex> holeIndex;
@property (nonatomic, assign) IndexTypes indexType;
@property (nonatomic, readonly) BOOL isVersion0101;

// MARK: - Internal Properties (for File.m access)
@property (nonatomic, readonly) HeaderIndex *headerIndex;  // Direct access to HeaderIndex
@property (nonatomic, readonly) HeaderHole *hole;          // Direct access to HeaderHole

// MARK: - Initialization
- (instancetype)init;

// MARK: - File Processing Methods
- (void)loadFromReader:(BinaryReader *)reader;
- (void)saveToWriter:(BinaryWriter *)writer;

// MARK: - Cloning
- (id)clone;

@end

NS_ASSUME_NONNULL_END
