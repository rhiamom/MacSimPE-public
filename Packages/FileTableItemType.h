//
//  FileTablePaths.h
//  MacSimpe
//

#import <Foundation/Foundation.h>

@class ExpansionItem;

@interface FileTablePaths : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *paths;
@property (nonatomic, strong) ExpansionItem *expansion;

- (instancetype)initWithExpansion:(ExpansionItem *)expansion;
- (void)addPath:(NSString *)path;
- (NSArray<NSString *> *)allPaths;

@end
