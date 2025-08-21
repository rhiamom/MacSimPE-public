///
//  ToolTypes.m
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/10/25.
//
//***************************************************************************
//*  Copyright (C) 2025 by GramzeSweatShop                                  *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*  along with this program; if not, write to the                          *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/

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
