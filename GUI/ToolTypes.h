//
//  ToolTypes.h
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, Tool) {
    // Top half tools (main modes)
    ToolOpenPackage,
    ToolCatalog,
    ToolObjectWorkshop,
    ToolNeighborhoodSimBrowser,
    ToolSimSurgery,
    ToolBidouCareerEditor,
    
    // Bottom half tools (sub-modes for Resource Tree)
    ToolPluginView,
    ToolDetails,
    ToolResource,
    ToolWrapper,
    ToolConverter,
    ToolHex,
    ToolFinder
};

@interface ToolHelper : NSObject

+ (NSString *)displayNameForTool:(Tool)tool;
+ (NSString *)iconNameForTool:(Tool)tool;
+ (NSArray<NSNumber *> *)topHalfTools;
+ (NSArray<NSNumber *> *)bottomHalfTools;

@end

NS_ASSUME_NONNULL_END
