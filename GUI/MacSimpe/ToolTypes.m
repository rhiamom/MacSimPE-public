///
//  ToolTypes.m
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/10/25.
//

#import "ToolTypes.h"

@implementation ToolHelper

+ (NSString *)displayNameForTool:(Tool)tool {
    switch (tool) {
        case ToolOpenPackage:
            return @"Open Package";
        case ToolCatalog:
            return @"Maxis Object Catalog";
        case ToolObjectWorkshop:
            return @"Object Workshop";
        case ToolNeighborhoodSimBrowser:
            return @"Neighborhood/Sim Browser";
        case ToolSimSurgery:
            return @"SimSurgery";
        case ToolBidouCareerEditor:
            return @"Bidou Career Editor";
        case ToolPluginView:
            return @"Plugin View";
        case ToolDetails:
            return @"Details";
        case ToolResource:
            return @"Resource";
        case ToolWrapper:
            return @"Wrapper";
        case ToolConverter:
            return @"Converter";
        case ToolHex:
            return @"Hex";
        case ToolFinder:
            return @"Finder";
    }
}

+ (NSString *)iconNameForTool:(Tool)tool {
    switch (tool) {
        case ToolOpenPackage:
            return @"folder.badge.plus";
        case ToolCatalog:
            return @"square.grid.2x2";
        case ToolObjectWorkshop:
            return @"hammer";
        case ToolNeighborhoodSimBrowser:
            return @"house.fill";
        case ToolSimSurgery:
            return @"cross.case.fill";
        case ToolBidouCareerEditor:
            return @"briefcase.fill";
        case ToolPluginView:
            return @"puzzlepiece";
        case ToolDetails:
            return @"info.circle";
        case ToolResource:
            return @"doc";
        case ToolWrapper:
            return @"shippingbox";
        case ToolConverter:
            return @"arrow.triangle.2.circlepath";
        case ToolHex:
            return @"number";
        case ToolFinder:
            return @"magnifyingglass";
    }
}

+ (NSArray<NSNumber *> *)topHalfTools {
    return @[@(ToolOpenPackage), @(ToolCatalog), @(ToolObjectWorkshop),
             @(ToolNeighborhoodSimBrowser), @(ToolSimSurgery), @(ToolBidouCareerEditor)];
}

+ (NSArray<NSNumber *> *)bottomHalfTools {
    return @[@(ToolPluginView), @(ToolDetails), @(ToolResource),
             @(ToolWrapper), @(ToolConverter), @(ToolHex), @(ToolFinder)];
}

@end
