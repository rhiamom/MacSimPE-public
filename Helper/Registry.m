//
//  Registry.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop         *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "Registry.h"
#import "Helper.h"

const uint8_t RegistryRecentCount = 15;

// Static variables for AppPreferences
static NSString *_profile = @"";

@implementation Registry

// Static variable for class property
static Registry *_windowsRegistry = nil;

// MARK: - Class Properties

+ (Registry *)windowsRegistry {
    if (!_windowsRegistry) {
        _windowsRegistry = [[Registry alloc] init];
    }
    return _windowsRegistry;
}

+ (void)setWindowsRegistry:(Registry *)registry {
    _windowsRegistry = registry;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reload];
        if ([Helper qaRelease]) {
            self.wasQaUser = YES;
        }
    }
    return self;
}

- (void)reload {
    // On macOS, settings are automatically loaded from NSUserDefaults
    // No need to explicitly reload like Windows Registry
}

- (void)flush {
    // Force synchronization of NSUserDefaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// MARK: - Language Support

+ (NSInteger)getMatchingLanguage {
    NSString *languageCode = [[NSLocale currentLocale] languageCode];
    if (!languageCode) return MetaDataLanguagesEnglish;
    
    languageCode = [languageCode uppercaseString];
    
    if ([languageCode isEqualToString:@"DE"]) return MetaDataLanguagesGerman;
    if ([languageCode isEqualToString:@"ES"]) return MetaDataLanguagesSpanish;
    if ([languageCode isEqualToString:@"FI"]) return MetaDataLanguagesFinnish;
    if ([languageCode isEqualToString:@"ZH"]) return MetaDataLanguagesSimplifiedChinese;
    if ([languageCode isEqualToString:@"FR"]) return MetaDataLanguagesFrench;
    if ([languageCode isEqualToString:@"JA"]) return MetaDataLanguagesJapanese;
    if ([languageCode isEqualToString:@"IT"]) return MetaDataLanguagesItalian;
    if ([languageCode isEqualToString:@"NL"]) return MetaDataLanguagesDutch;
    if ([languageCode isEqualToString:@"DA"]) return MetaDataLanguagesDanish;
    if ([languageCode isEqualToString:@"NO"]) return MetaDataLanguagesNorwegian;
    if ([languageCode isEqualToString:@"HE"]) return MetaDataLanguagesHebrew;
    if ([languageCode isEqualToString:@"RU"]) return MetaDataLanguagesRussian;
    if ([languageCode isEqualToString:@"PT"]) return MetaDataLanguagesPortuguese;
    if ([languageCode isEqualToString:@"PL"]) return MetaDataLanguagesPolish;
    if ([languageCode isEqualToString:@"TH"]) return MetaDataLanguagesThai;
    if ([languageCode isEqualToString:@"KO"]) return MetaDataLanguagesKorean;
    
    return MetaDataLanguagesEnglish;
}

// MARK: - SimPE Directory Management

- (void)updateSimPeDirectory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[Helper simPePath] forKey:@"SimPE_Path"];
    [defaults setObject:[Helper simPeDataPath] forKey:@"SimPE_DataPath"];
    [defaults setObject:[Helper simPePluginPath] forKey:@"SimPE_PluginPath"];
    [defaults setInteger:[Helper simPeVersionLong] forKey:@"SimPE_LastVersion"];
}

- (NSString *)previousDataFolder {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SimPE_DataPath"] ?: @"";
}

- (int64_t)previousVersion {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"SimPE_LastVersion"];
}

// MARK: - Property Implementations (using NSUserDefaults)

- (BOOL)silent {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"PescadoMode"];
}

- (void)setSilent:(BOOL)silent {
    [[NSUserDefaults standardUserDefaults] setBool:silent forKey:@"PescadoMode"];
}

- (BOOL)fileTableSimpleSelectUseGroups {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"FileTableSimpleSelectUseGroups"] ?: YES;
}

- (void)setFileTableSimpleSelectUseGroups:(BOOL)fileTableSimpleSelectUseGroups {
    [[NSUserDefaults standardUserDefaults] setBool:fileTableSimpleSelectUseGroups forKey:@"FileTableSimpleSelectUseGroups"];
}

- (BOOL)showWaitBarPermanent {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowWaitBarPermanent"] ?: YES;
}

- (void)setShowWaitBarPermanent:(BOOL)showWaitBarPermanent {
    [[NSUserDefaults standardUserDefaults] setBool:showWaitBarPermanent forKey:@"ShowWaitBarPermanent"];
}

- (BOOL)useCache {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UseCache"] ?: YES;
}

- (void)setUseCache:(BOOL)useCache {
    [[NSUserDefaults standardUserDefaults] setBool:useCache forKey:@"UseCache"];
}

- (BOOL)showStartupSplash {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStartupSplash"] ?: YES;
}

- (void)setShowStartupSplash:(BOOL)showStartupSplash {
    [[NSUserDefaults standardUserDefaults] setBool:showStartupSplash forKey:@"ShowStartupSplash"];
}

- (BOOL)showObjdNames {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowObjdNames"];
}

- (void)setShowObjdNames:(BOOL)showObjdNames {
    [[NSUserDefaults standardUserDefaults] setBool:showObjdNames forKey:@"ShowObjdNames"];
}

- (BOOL)allowChangeOfSecondaryAspiration {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"AllowChangeOfSecondaryAspiration"] ?: YES;
}

- (void)setAllowChangeOfSecondaryAspiration:(BOOL)allowChangeOfSecondaryAspiration {
    [[NSUserDefaults standardUserDefaults] setBool:allowChangeOfSecondaryAspiration forKey:@"AllowChangeOfSecondaryAspiration"];
}

- (BOOL)showJointNames {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowJointNames"] ?: YES;
}

- (void)setShowJointNames:(BOOL)showJointNames {
    [[NSUserDefaults standardUserDefaults] setBool:showJointNames forKey:@"ShowJointNames"];
}

- (float)importExportScaleFactor {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImExportScale"];
    return value ? [value floatValue] : 1.0f;
}

- (void)setImportExportScaleFactor:(float)importExportScaleFactor {
    [[NSUserDefaults standardUserDefaults] setFloat:importExportScaleFactor forKey:@"ImExportScale"];
}

- (BOOL)xpStyle {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"XPStyle"] ?: YES;
}

- (void)setXpStyle:(BOOL)xpStyle {
    [[NSUserDefaults standardUserDefaults] setBool:xpStyle forKey:@"XPStyle"];
}

- (BOOL)hexViewState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"HexViewEnabled"];
}

- (void)setHexViewState:(BOOL)hexViewState {
    [[NSUserDefaults standardUserDefaults] setBool:hexViewState forKey:@"HexViewEnabled"];
}

- (BOOL)hiddenMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"EnableSimPEHiddenMode"];
}

- (void)setHiddenMode:(BOOL)hiddenMode {
    [[NSUserDefaults standardUserDefaults] setBool:hiddenMode forKey:@"EnableSimPEHiddenMode"];
}

- (BOOL)useMaxisGroupsCache {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UseMaxisGroupsCache"];
}

- (void)setUseMaxisGroupsCache:(BOOL)useMaxisGroupsCache {
    [[NSUserDefaults standardUserDefaults] setBool:useMaxisGroupsCache forKey:@"UseMaxisGroupsCache"];
}

- (BOOL)decodeFilenamesState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DecodeFilenames"] ?: YES;
}

- (void)setDecodeFilenamesState:(BOOL)decodeFilenamesState {
    [[NSUserDefaults standardUserDefaults] setBool:decodeFilenamesState forKey:@"DecodeFilenames"];
}

- (NSString *)username {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"] ?: @"";
}

- (void)setUsername:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"Username"];
}

- (uint32_t)cachedUserId {
    return (uint32_t)[[NSUserDefaults standardUserDefaults] integerForKey:@"CUi"];
}

- (void)setCachedUserId:(uint32_t)cachedUserId {
    [[NSUserDefaults standardUserDefaults] setInteger:cachedUserId forKey:@"CUi"];
}

- (NSInteger)languageCode {
    NSInteger code = [[NSUserDefaults standardUserDefaults] integerForKey:@"Language"];
    return code != 0 ? code : [Registry getMatchingLanguage];
}

- (void)setLanguageCode:(NSInteger)languageCode {
    [[NSUserDefaults standardUserDefaults] setInteger:languageCode forKey:@"Language"];
}

- (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"] ?: @"";
}

- (void)setPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"Password"];
}

- (NSInteger)version {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Version"];
}

- (void)setVersion:(NSInteger)version {
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"Version"];
}

- (NSInteger)maxSearchResults {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxSearchResults"];
    return value != 0 ? value : 2000;
}

- (void)setMaxSearchResults:(NSInteger)maxSearchResults {
    [[NSUserDefaults standardUserDefaults] setInteger:maxSearchResults forKey:@"MaxSearchResults"];
}

- (NSInteger)owThumbSize {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"OWThumbSize"];
    return value != 0 ? value : 16;
}

- (void)setOwThumbSize:(NSInteger)owThumbSize {
    [[NSUserDefaults standardUserDefaults] setInteger:owThumbSize forKey:@"OWThumbSize"];
}

- (BOOL)loadMetaInfo {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LoadMetaInfos"] ?: YES;
}

- (void)setLoadMetaInfo:(BOOL)loadMetaInfo {
    [[NSUserDefaults standardUserDefaults] setBool:loadMetaInfo forKey:@"LoadMetaInfos"];
}

- (BOOL)checkForUpdates {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"CheckForUpdates"];
}

- (void)setCheckForUpdates:(BOOL)checkForUpdates {
    [[NSUserDefaults standardUserDefaults] setBool:checkForUpdates forKey:@"CheckForUpdates"];
}

- (BOOL)enableSound {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"EnableSound"] ?: YES;
}

- (void)setEnableSound:(BOOL)enableSound {
    [[NSUserDefaults standardUserDefaults] setBool:enableSound forKey:@"EnableSound"];
}

- (BOOL)autoBackup {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoBackup"];
}

- (void)setAutoBackup:(BOOL)autoBackup {
    [[NSUserDefaults standardUserDefaults] setBool:autoBackup forKey:@"AutoBackup"];
}

- (BOOL)waitingScreen {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"WaitingScreen"] ?: YES;
}

- (void)setWaitingScreen:(BOOL)waitingScreen {
    [[NSUserDefaults standardUserDefaults] setBool:waitingScreen forKey:@"WaitingScreen"];
}

- (BOOL)waitingScreenTopMost {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"WaitingScreenTopMost"];
}

- (void)setWaitingScreenTopMost:(BOOL)waitingScreenTopMost {
    [[NSUserDefaults standardUserDefaults] setBool:waitingScreenTopMost forKey:@"WaitingScreenTopMost"];
}

- (BOOL)loadOwFast {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LoadOWFast"];
}

- (void)setLoadOwFast:(BOOL)loadOwFast {
    [[NSUserDefaults standardUserDefaults] setBool:loadOwFast forKey:@"LoadOWFast"];
}

- (BOOL)usePackageMaintainer {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UsePkgMaintainer"] ?: YES;
}

- (void)setUsePackageMaintainer:(BOOL)usePackageMaintainer {
    [[NSUserDefaults standardUserDefaults] setBool:usePackageMaintainer forKey:@"UsePkgMaintainer"];
}

- (BOOL)multipleFiles {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MultipleFiles"] ?: YES;
}

- (void)setMultipleFiles:(BOOL)multipleFiles {
    [[NSUserDefaults standardUserDefaults] setBool:multipleFiles forKey:@"MultipleFiles"];
}

- (BOOL)simpleResourceSelect {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SimpleResourceSelect"] ?: YES;
}

- (void)setSimpleResourceSelect:(BOOL)simpleResourceSelect {
    [[NSUserDefaults standardUserDefaults] setBool:simpleResourceSelect forKey:@"SimpleResourceSelect"];
}

- (BOOL)firefoxTabbing {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"FirefoxTabbing"] ?: YES;
}

- (void)setFirefoxTabbing:(BOOL)firefoxTabbing {
    [[NSUserDefaults standardUserDefaults] setBool:firefoxTabbing forKey:@"FirefoxTabbing"];
}

- (BOOL)wasQaUser {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"WasQAUser"];
}

- (void)setWasQaUser:(BOOL)wasQaUser {
    [[NSUserDefaults standardUserDefaults] setBool:wasQaUser forKey:@"WasQAUser"];
}

- (NSInteger)bigPackageResourceCount {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"BigPackageResourceCount"];
    return value != 0 ? value : 1000;
}

- (void)setBigPackageResourceCount:(NSInteger)bigPackageResourceCount {
    [[NSUserDefaults standardUserDefaults] setInteger:bigPackageResourceCount forKey:@"BigPackageResourceCount"];
}

- (NSInteger)graphLineMode {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"GraphLineMode"];
    return value != 0 ? value : 0x02;
}

- (void)setGraphLineMode:(NSInteger)graphLineMode {
    [[NSUserDefaults standardUserDefaults] setInteger:graphLineMode forKey:@"GraphLineMode"];
}

- (BOOL)graphQuality {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"GraphQuality"] ?: YES;
}

- (void)setGraphQuality:(BOOL)graphQuality {
    [[NSUserDefaults standardUserDefaults] setBool:graphQuality forKey:@"GraphQuality"];
}

- (NSString *)gmdcExtension {
    NSString *ext = [[NSUserDefaults standardUserDefaults] stringForKey:@"GmdcExtension"];
    if (!ext) ext = @".obj";
    return [ext stringByReplacingOccurrencesOfString:@"*" withString:@""];
}

- (void)setGmdcExtension:(NSString *)gmdcExtension {
    [[NSUserDefaults standardUserDefaults] setObject:gmdcExtension forKey:@"GmdcExtension"];
}

- (BOOL)correctJointDefinitionOnExport {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"CorrectJointDefinitionOnExport"];
}

- (void)setCorrectJointDefinitionOnExport:(BOOL)correctJointDefinitionOnExport {
    [[NSUserDefaults standardUserDefaults] setBool:correctJointDefinitionOnExport forKey:@"CorrectJointDefinitionOnExport"];
}

- (BOOL)deepSimScan {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DeepSimScan"] ?: YES;
}

- (void)setDeepSimScan:(BOOL)deepSimScan {
    [[NSUserDefaults standardUserDefaults] setBool:deepSimScan forKey:@"DeepSimScan"];
}

- (BOOL)deepSimTemplateScan {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:@"DeepSimTemplateScan"];
    return value && self.deepSimScan;
}

- (void)setDeepSimTemplateScan:(BOOL)deepSimTemplateScan {
    [[NSUserDefaults standardUserDefaults] setBool:deepSimTemplateScan forKey:@"DeepSimTemplateScan"];
}

- (BOOL)showProgressWhenPackageLoads {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowProgressWhenPackageLoads"];
}

- (void)setShowProgressWhenPackageLoads:(BOOL)showProgressWhenPackageLoads {
    [[NSUserDefaults standardUserDefaults] setBool:showProgressWhenPackageLoads forKey:@"ShowProgressWhenPackageLoads"];
}

- (BOOL)asynchronLoad {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronLoad"];
}

- (void)setAsynchronLoad:(BOOL)asynchronLoad {
    [[NSUserDefaults standardUserDefaults] setBool:asynchronLoad forKey:@"AsynchronLoad"];
}

- (BOOL)asynchronSort {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"AsynchronSort"] ?: YES;
}

- (void)setAsynchronSort:(BOOL)asynchronSort {
    [[NSUserDefaults standardUserDefaults] setBool:asynchronSort forKey:@"AsynchronSort"];
}

- (BOOL)resourceTreeAlwaysAutoselect {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ResoruceTreeAllwaysAutoselect"] ?: YES;
}

- (void)setResourceTreeAlwaysAutoselect:(BOOL)resourceTreeAlwaysAutoselect {
    [[NSUserDefaults standardUserDefaults] setBool:resourceTreeAlwaysAutoselect forKey:@"ResoruceTreeAllwaysAutoselect"];
}

- (NSInteger)sortProcessCount {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"SortProcessCount"];
    return value != 0 ? value : 16;
}

- (void)setSortProcessCount:(NSInteger)sortProcessCount {
    [[NSUserDefaults standardUserDefaults] setInteger:sortProcessCount forKey:@"SortProcessCount"];
}

- (BOOL)updateResourceListWhenTgiChanges {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UpdateResourceListWhenTGIChanges"] ?: YES;
}

- (void)setUpdateResourceListWhenTgiChanges:(BOOL)updateResourceListWhenTgiChanges {
    [[NSUserDefaults standardUserDefaults] setBool:updateResourceListWhenTgiChanges forKey:@"UpdateResourceListWhenTGIChanges"];
}

- (BOOL)lockDocks {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LockDocks"];
}

- (void)setLockDocks:(BOOL)lockDocks {
    [[NSUserDefaults standardUserDefaults] setBool:lockDocks forKey:@"LockDocks"];
}

- (NSDate *)lastUpdateCheck {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdateCheck"];
    return date ?: [[NSDate date] dateByAddingTimeInterval:-48*60*60]; // 2 days ago default
}

- (void)setLastUpdateCheck:(NSDate *)lastUpdateCheck {
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdateCheck forKey:@"LastUpdateCheck"];
}

// MARK: - Resource List Format Properties

- (ResourceListFormats)resourceListFormat {
    return (ResourceListFormats)[[NSUserDefaults standardUserDefaults] integerForKey:@"ResourceListFormat"];
}

- (void)setResourceListFormat:(ResourceListFormats)resourceListFormat {
    [[NSUserDefaults standardUserDefaults] setInteger:resourceListFormat forKey:@"ResourceListFormat"];
}

- (ResourceListUnnamedFormats)resourceListUnknownDescriptionFormat {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"ResourceListUnknownDescriptionFormat"];
    return value != 0 ? (ResourceListUnnamedFormats)value : ResourceListUnnamedFormatsGroupInstance;
}

- (void)setResourceListUnknownDescriptionFormat:(ResourceListUnnamedFormats)resourceListUnknownDescriptionFormat {
    [[NSUserDefaults standardUserDefaults] setInteger:resourceListUnknownDescriptionFormat forKey:@"ResourceListUnknownDescriptionFormat"];
}

- (ResourceListInstanceFormats)resourceListInstanceFormat {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"ResourceListInstanceFormat"];
    return value != 0 ? (ResourceListInstanceFormats)value : ResourceListInstanceFormatsHexDec;
}

- (void)setResourceListInstanceFormat:(ResourceListInstanceFormats)resourceListInstanceFormat {
    [[NSUserDefaults standardUserDefaults] setInteger:resourceListInstanceFormat forKey:@"ResourceListInstanceFormat"];
}

- (ResourceListExtensionFormats)resourceListExtensionFormat {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"ResourceListExtensionFormat"];
    return value != 0 ? (ResourceListExtensionFormats)value : ResourceListExtensionFormatsShort;
}

- (void)setResourceListExtensionFormat:(ResourceListExtensionFormats)resourceListExtensionFormat {
    [[NSUserDefaults standardUserDefaults] setInteger:resourceListExtensionFormat forKey:@"ResourceListExtensionFormat"];
}

- (BOOL)resourceListShowExtensions {
    return self.resourceListExtensionFormat != ResourceListExtensionFormatsNone;
}

- (BOOL)resourceListInstanceFormatHexOnly {
    return self.resourceListInstanceFormat == ResourceListInstanceFormatsHexOnly;
}

- (BOOL)resourceListInstanceFormatDecOnly {
    return self.resourceListInstanceFormat == ResourceListInstanceFormatsDecOnly;
}

- (BOOL)resourceListInstanceFormatHexDec {
    return self.resourceListInstanceFormat == ResourceListInstanceFormatsHexDec;
}

// MARK: - Report Format

- (ReportFormats)reportFormat {
    return (ReportFormats)[[NSUserDefaults standardUserDefaults] integerForKey:@"ReportFormat"];
}

- (void)setReportFormat:(ReportFormats)reportFormat {
    [[NSUserDefaults standardUserDefaults] setInteger:reportFormat forKey:@"ReportFormat"];
}

// MARK: - Wrapper Priority Management

- (NSInteger)getWrapperPriority:(uint64_t)uid {
    NSString *key = [Helper hexStringUInt64:uid];
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"WrapperPriority_%@", key]];
}

- (void)setWrapperPriority:(uint64_t)uid priority:(NSInteger)priority {
    NSString *key = [Helper hexStringUInt64:uid];
    [[NSUserDefaults standardUserDefaults] setInteger:priority forKey:[NSString stringWithFormat:@"WrapperPriority_%@", key]];
}

// MARK: - Recent Files Management

- (void)clearRecentFileList {
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"RecentFiles"];
}

- (NSArray<NSString *> *)getRecentFiles {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"RecentFiles"] ?: @[];
}

- (void)addRecentFile:(NSString *)filename {
    if (!filename || [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return;
    }
    
    filename = [filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray<NSString *> *recentFiles = [[self getRecentFiles] mutableCopy];
    
    // Remove if already exists
    [recentFiles removeObject:filename];
    
    // Insert at beginning
    [recentFiles insertObject:filename atIndex:0];
    
    // Limit to RECENT_COUNT
    while (recentFiles.count > RegistryRecentCount) {
        [recentFiles removeLastObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[recentFiles copy] forKey:@"RecentFiles"];
}

// MARK: - Class Methods for Resource List Format Access

+ (ResourceListUnnamedFormats)resourceListUnknownDescriptionFormat {
    return (ResourceListUnnamedFormats)[[NSUserDefaults standardUserDefaults] integerForKey:@"ResourceListUnknownDescriptionFormat"];
}

+ (void)setResourceListUnknownDescriptionFormat:(ResourceListUnnamedFormats)format {
    [[NSUserDefaults standardUserDefaults] setInteger:format forKey:@"ResourceListUnknownDescriptionFormat"];
}

+ (ResourceListFormats)resourceListFormat {
    return (ResourceListFormats)[[NSUserDefaults standardUserDefaults] integerForKey:@"ResourceListFormat"];
}

+ (void)setResourceListFormat:(ResourceListFormats)format {
    [[NSUserDefaults standardUserDefaults] setInteger:format forKey:@"ResourceListFormat"];
}

@end

// MARK: - AppPreferences Implementation

@implementation AppPreferences

+ (NSString *)profile {
    return _profile;
}

+ (void)setProfile:(NSString *)profile {
    _profile = [profile copy];
}

+ (uint8_t)languageCode {
    NSInteger code = [[NSUserDefaults standardUserDefaults] integerForKey:@"SimPELanguageCode"];
    return code == 0 ? 1 : (uint8_t)code;
}

+ (void)setLanguageCode:(uint8_t)languageCode {
    [[NSUserDefaults standardUserDefaults] setInteger:languageCode forKey:@"SimPELanguageCode"];
}

+ (BOOL)hiddenMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SimPEHiddenMode"];
}

+ (void)setHiddenMode:(BOOL)hiddenMode {
    [[NSUserDefaults standardUserDefaults] setBool:hiddenMode forKey:@"SimPEHiddenMode"];
}

+ (BOOL)useCache {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SimPEUseCache"];
}

+ (void)setUseCache:(BOOL)useCache {
    [[NSUserDefaults standardUserDefaults] setBool:useCache forKey:@"SimPEUseCache"];
}

+ (NSString *)languageCache {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SimPELanguageCache"] ?: @"";
}

+ (void)setLanguageCache:(NSString *)languageCache {
    [[NSUserDefaults standardUserDefaults] setObject:languageCache forKey:@"SimPELanguageCache"];
}

+ (BOOL)asynchronLoad {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SimPEAsynchronLoad"];
}

+ (void)setAsynchronLoad:(BOOL)asynchronLoad {
    [[NSUserDefaults standardUserDefaults] setBool:asynchronLoad forKey:@"SimPEAsynchronLoad"];
}

@end
