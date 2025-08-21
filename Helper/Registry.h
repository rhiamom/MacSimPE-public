//
//  Registry.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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
// ***************************************************************************/


#import <Foundation/Foundation.h>

// Forward declarations
@class Registry;
@class XmlRegistryKey;

// MARK: - MetaData Languages (moved from MetaData class)
typedef NS_ENUM(NSInteger, MetaDataLanguages) {
    MetaDataLanguagesEnglish = 1,
    MetaDataLanguagesGerman = 2,
    MetaDataLanguagesSpanish = 3,
    MetaDataLanguagesFinnish = 4,
    MetaDataLanguagesSimplifiedChinese = 5,
    MetaDataLanguagesFrench = 6,
    MetaDataLanguagesJapanese = 7,
    MetaDataLanguagesItalian = 8,
    MetaDataLanguagesDutch = 9,
    MetaDataLanguagesDanish = 10,
    MetaDataLanguagesNorwegian = 11,
    MetaDataLanguagesHebrew = 12,
    MetaDataLanguagesRussian = 13,
    MetaDataLanguagesPortuguese = 14,
    MetaDataLanguagesPolish = 15,
    MetaDataLanguagesThai = 16,
    MetaDataLanguagesKorean = 17
};

/**
 * Handles Application Settings stored in NSUserDefaults (replaces Windows Registry)
 */
@interface Registry : NSObject

// MARK: - Constants
extern const uint8_t RegistryRecentCount;

// MARK: - Language Support
+ (NSInteger)getMatchingLanguage;

// MARK: - Initialization
- (instancetype)init;
- (void)reload;
- (void)flush;

// MARK: - Resource List Format Enums

typedef NS_ENUM(NSInteger, ResourceListExtensionFormats) {
    ResourceListExtensionFormatsHex = 0,
    ResourceListExtensionFormatsShort = 1,
    ResourceListExtensionFormatsLong = 2,
    ResourceListExtensionFormatsNone = 3
};

typedef NS_ENUM(NSInteger, ResourceListInstanceFormats) {
    ResourceListInstanceFormatsHexOnly = 0,
    ResourceListInstanceFormatsDecOnly = 1,
    ResourceListInstanceFormatsHexDec = 2
};

typedef NS_ENUM(NSInteger, ResourceListFormats) {
    ResourceListFormatsLongTypeNames = 0,
    ResourceListFormatsShortTypeNames = 1,
    ResourceListFormatsJustNames = 2,
    ResourceListFormatsJustLongType = 3
};

typedef NS_ENUM(NSInteger, ResourceListUnnamedFormats) {
    ResourceListUnnamedFormatsInstance = 0,
    ResourceListUnnamedFormatsGroupInstance = 1,
    ResourceListUnnamedFormatsFullTGI = 2
};

typedef NS_ENUM(NSInteger, ReportFormats) {
    ReportFormatsDescriptive = 0,
    ReportFormatsCsv = 1
};

// MARK: - Class Properties
@property (class, nonatomic, strong) Registry *windowsRegistry;
@property (nonatomic, strong) XmlRegistryKey *registryKey;

// MARK: - SimPE Directory Management
- (void)updateSimPeDirectory;
@property (nonatomic, readonly, copy) NSString *previousDataFolder;
@property (nonatomic, readonly, assign) int64_t previousVersion;

// MARK: - Basic Settings
@property (nonatomic, assign) BOOL silent;
@property (nonatomic, assign) BOOL fileTableSimpleSelectUseGroups;
@property (nonatomic, assign) BOOL showWaitBarPermanent;
@property (nonatomic, assign) BOOL useCache;
@property (nonatomic, assign) BOOL showStartupSplash;
@property (nonatomic, assign) BOOL showObjdNames;
@property (nonatomic, assign) BOOL allowChangeOfSecondaryAspiration;
@property (nonatomic, assign) BOOL showJointNames;
@property (nonatomic, assign) float importExportScaleFactor;
@property (nonatomic, assign) BOOL xpStyle;
@property (nonatomic, assign) BOOL hexViewState;
@property (nonatomic, assign) BOOL hiddenMode;
@property (nonatomic, assign) BOOL useMaxisGroupsCache;
@property (nonatomic, assign) BOOL decodeFilenamesState;

// MARK: - User Account
@property (nonatomic, copy) NSString *username;
@property (nonatomic, assign) uint32_t cachedUserId;
@property (nonatomic, assign) NSInteger languageCode;
@property (nonatomic, copy) NSString *password;

// MARK: - Version and Update Settings
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger maxSearchResults;
@property (nonatomic, assign) NSInteger owThumbSize;
@property (nonatomic, assign) BOOL loadMetaInfo;
@property (nonatomic, assign) BOOL checkForUpdates;
@property (nonatomic, assign) BOOL enableSound;
@property (nonatomic, assign) BOOL autoBackup;
@property (nonatomic, assign) BOOL waitingScreen;
@property (nonatomic, assign) BOOL waitingScreenTopMost;
@property (nonatomic, assign) BOOL loadOwFast;
@property (nonatomic, assign) BOOL usePackageMaintainer;
@property (nonatomic, assign) BOOL multipleFiles;
@property (nonatomic, assign) BOOL simpleResourceSelect;
@property (nonatomic, assign) BOOL firefoxTabbing;
@property (nonatomic, assign) BOOL wasQaUser;

// MARK: - Performance Settings
@property (nonatomic, assign) NSInteger bigPackageResourceCount;
@property (nonatomic, assign) NSInteger graphLineMode;
@property (nonatomic, assign) BOOL graphQuality;
@property (nonatomic, copy) NSString *gmdcExtension;
@property (nonatomic, assign) BOOL correctJointDefinitionOnExport;
@property (nonatomic, assign) BOOL deepSimScan;
@property (nonatomic, assign) BOOL deepSimTemplateScan;
@property (nonatomic, assign) BOOL showProgressWhenPackageLoads;
@property (nonatomic, assign) BOOL asynchronLoad;
@property (nonatomic, assign) BOOL asynchronSort;
@property (nonatomic, assign) BOOL resourceTreeAlwaysAutoselect;
@property (nonatomic, assign) NSInteger sortProcessCount;
@property (nonatomic, assign) BOOL updateResourceListWhenTgiChanges;
@property (nonatomic, assign) BOOL lockDocks;
@property (nonatomic, strong) NSDate *lastUpdateCheck;

// MARK: - Resource List Display Settings
@property (nonatomic, assign) ResourceListFormats resourceListFormat;
@property (nonatomic, assign) ResourceListUnnamedFormats resourceListUnknownDescriptionFormat;
@property (nonatomic, assign) ResourceListInstanceFormats resourceListInstanceFormat;
@property (nonatomic, assign) ResourceListExtensionFormats resourceListExtensionFormat;
@property (nonatomic, readonly, assign) BOOL resourceListShowExtensions;
@property (nonatomic, readonly, assign) BOOL resourceListInstanceFormatHexOnly;
@property (nonatomic, readonly, assign) BOOL resourceListInstanceFormatDecOnly;
@property (nonatomic, readonly, assign) BOOL resourceListInstanceFormatHexDec;

// MARK: - Class methods for static resource list format access
+ (ResourceListUnnamedFormats)resourceListUnknownDescriptionFormat;
+ (void)setResourceListUnknownDescriptionFormat:(ResourceListUnnamedFormats)format;
+ (ResourceListFormats)resourceListFormat;
+ (void)setResourceListFormat:(ResourceListFormats)format;

// MARK: - Report Settings
@property (nonatomic, assign) ReportFormats reportFormat;

// MARK: - Wrapper Priority Management
- (NSInteger)getWrapperPriority:(uint64_t)uid;
- (void)setWrapperPriority:(uint64_t)uid priority:(NSInteger)priority;

// MARK: - Recent Files Management
- (void)clearRecentFileList;
- (NSArray<NSString *> *)getRecentFiles;
- (void)addRecentFile:(NSString *)filename;

//   MARK: - Windows Registry Alternative Application Level Settings

+ (Registry *)windowsRegistry;

@end

// MARK: - App Preferences

@interface AppPreferences : NSObject

@property (class, nonatomic, assign) uint8_t languageCode;
@property (class, nonatomic, assign) BOOL hiddenMode;
@property (class, nonatomic, assign) BOOL useCache;
@property (class, nonatomic, copy) NSString *languageCache;
@property (class, nonatomic, copy) NSString *profile;
@property (class, nonatomic, assign) BOOL asynchronLoad;

@end

