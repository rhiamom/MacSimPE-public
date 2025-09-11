//
//  FixObject.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
// *   rhiamom@mac.com                                                       *
// *                                                                         *
// *   This program is free software; you can redistribute it and/or modify  *
// *   it under the terms of the GNU General Public License as published by  *
// *   the Free Software Foundation; either version 2 of the License, or     *
// *   (at your option) any later version.                                   *
// *                                                                         *
// *   This program is distributed in the hope that it will be useful,       *
// *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
// *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
// *   GNU General Public License for more details.                          *
// *                                                                         *
// *   You should have received a copy of the GNU General Public License     *
// *   along with this program; if not, write to the                         *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import <Foundation/Foundation.h>
#import "FixGuid.h"

typedef NS_ENUM(uint8_t, FixVersion) {
    FixVersionUniversityReady = 0x00,
    FixVersionUniversityReady2 = 0x01
};

@class Rcol;
@class Cpf;
@class CpfItem;
@class IPackedFileDescriptor;
@class MaterialDefinition;

@interface FixObject : FixGuid

@property (nonatomic, assign) FixVersion fixVersion;
@property (nonatomic, assign) BOOL removeNonDefaultTextReferences;

- (instancetype)initWithPackage:(id<IPackageFile>)package
                        version:(FixVersion)version
           removeNonDefaultText:(BOOL)removeNonDefaultText;

+ (NSString *)getUniqueTxmtName:(NSString *)name
                         unique:(NSString *)unique
                     subsetName:(NSString *)subsetName
                      extension:(BOOL)extension;

- (NSString *)findReplacementName:(NSMutableDictionary *)map rcol:(Rcol *)rcol;
- (void)fixTxtrRef:(NSString *)propName
              matd:(MaterialDefinition *)matd
               map:(NSMutableDictionary *)map
              rcol:(Rcol *)rcol;
- (void)fixResource:(NSMutableDictionary *)map rcol:(Rcol *)rcol;
- (void)fixNames:(NSMutableDictionary *)map;
- (void)cleanUp;
- (void)fixGroup;
- (NSMutableDictionary *)getNameMap:(BOOL)uniqueName;
- (NSString *)buildRefString:(IPackedFileDescriptor *)pfd;
- (void)fix:(NSMutableDictionary *)map uniqueFamily:(BOOL)uniqueFamily;
- (void)fixObjd;
- (void)fixMmat:(NSMutableDictionary *)map
   uniqueFamily:(BOOL)uniqueFamily
      groupHash:(NSString *)groupHash;
- (void)fixCpfProperties:(Cpf *)cpf
              properties:(NSArray<NSString *> *)props
                 nameMap:(NSMutableDictionary *)nameMap
                  prefix:(NSString *)prefix
                  suffix:(NSString *)suffix;
- (void)fixCpfPropertiesWithValue:(Cpf *)cpf
                       properties:(NSArray<NSString *> *)props
                            value:(uint32_t)value;
- (CpfItem *)fixCpfProperty:(Cpf *)cpf
                   property:(NSString *)prop
                      value:(uint32_t)value;
- (void)fixFence;
- (void)fixSkin:(NSMutableDictionary *)nameMap
         refMap:(NSMutableDictionary *)refMap
      groupHash:(NSString *)groupHash;
- (void)fixXObject:(NSMutableDictionary *)nameMap
            refMap:(NSMutableDictionary *)refMap
         groupHash:(NSString *)groupHash;

@end
