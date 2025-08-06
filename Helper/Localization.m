//
//  Localization.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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

#import "Localization.h"

@interface Localization ()
@property (nonatomic, strong) NSBundle *localizationBundle;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *localizedStrings;
@end

@implementation Localization

// MARK: - Singleton

+ (instancetype)shared {
    static Localization *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // Use the main bundle for localization
    self.localizationBundle = [NSBundle mainBundle];
    
    // Load the localized strings dictionary
    [self loadLocalizedStrings];
}

- (void)loadLocalizedStrings {
    // Load strings from Localizable.strings file
    NSString *path = [self.localizationBundle pathForResource:@"Localizable" ofType:@"strings"];
    if (path) {
        self.localizedStrings = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    // If no Localizable.strings found, create a default dictionary with known strings
    if (!self.localizedStrings) {
        self.localizedStrings = [self createDefaultLocalizedStrings];
    }
}

- (NSDictionary<NSString *, NSString *> *)createDefaultLocalizedStrings {
    // Create a dictionary with the key strings from the .resx file
    return @{
        @"unknown": @"Unknown",
        @"unk": @"UNK",
        @"userdefined": @"User Defined",
        @"sdesc": @"Sim Description",
        @"srel": @"Sim Relations",
        @"famt": @"Family Ties",
        @"str": @"Text Lists",
        @"realsize": @"Real Size",
        @"none": @"None",
        @"proceed": @"Proceed?",
        @"yes": @"Yes",
        @"no": @"No",
        @"cancel": @"Cancel",
        @"ok": @"OK",
        @"question": @"Question",
        @"confirm": @"Confirmation",
        @"warning": @"Warning!",
        @"information": @"Information",
        @"unnamed": @"Unnamed",
        @"filenotfound": @"File not found",
        @"savechanges?": @"Save changes?",
        @"delete?": @"Delete?",
        @"backup?": @"Create Copy?",
        @"commited": @"Changes were committed",
        @"AllRes": @"All Resources",
        @"Loading embedded resource names...": @"Loading embedded resource names...",
        @"Loading package...": @"Loading package...",
        @"Searching - Please Wait": @"Searching - Please Wait",
        @"Please Wait": @"Please Wait",
        @"Starting SimPE...": @"Starting SimPE...",
        @"Validating SimPE registry": @"Validating SimPE registry",
        @"Checking commandline parameters": @"Checking commandline parameters",
        @"Creating GUI": @"Creating GUI",
        @"Starting Main Form": @"Starting Main Form",
        @"Loading Plugins...": @"Loading Plugins...",
        @"Enabling RemoteControl": @"Enabling RemoteControl",
        @"Starting Resource Loader": @"Starting Resource Loader",
        @"Building View Filter": @"Building View Filter",
        @"Searching": @"Searching",
        
        // Error messages
        @"err000": @"Error while loading a Packed File.",
        @"errwritingfile": @"Error while writing to File",
        @"err001": @"Error while writing Package Descriptor",
        @"err002": @"Cannot extract to ",
        @"err003": @"Error while trying to replace a packed File with {0}.",
        @"erropenfile": @"Error while trying to open ",
        @"err004": @"Error while trying to open a recent File.",
        @"errregistry": @"Error while trying to access the Registry",
        @"err005": @"Error while trying to delete a Packed File",
        @"err006": @"Error while tyring to add a Packed File",
        @"err007": @"Unable to Maximize Interesst of all Sims",
        @"errconvert": @"Error Assigning a Value",
        @"errunsupportedimage": @"The Imagetype is not supported",
        @"byteviewerror": @"Error while displaying the Byte View",
        
        // Ask dialogs
        @"ask000": @"Do you want to stop the Extraction?",
        @"askdelete": @"Do you really want to delete the selected Files?",
        @"usebigfile?": @"This File is bigger than 10kb, load it anyway? (This will take a While!)",
        @"backuprestore": @"Would you like to create a copy of the current Neighborhood before you overwrite it with this Backup?",
        @"backupdelete": @"Do you really want to delete all Files stored in {0}?",
        @"unsavedchanges": @"Some Files in the Package have unsaved changes which will be lost when you open a new neighborhood. \n\nDo you want to continue anyway?",
        
        // Family tie types
        @"MyMotherIs": @"Parent A is",
        @"MyFatherIs": @"Parent B is",
        @"ImMarriedTo": @"I'm married to",
        @"MySiblingIs": @"My Sibling is",
        @"MyChildIs": @"My Child is",
        
        // Age groups
        @"YoungAdult": @"Young Adult",
        
        // Language names
        @"English_uk": @"English (uk)",
        @"Brazilian": @"Portuguese (Brazil)",
        
        // Object categories
        @"Other": @"Other",
        @"Fun": @"Fun",
        @"Economy": @"Economy",
        @"Savegames": @"Savegames",
        
        // Career names
        @"Unemployed": @"Unemployed",
        @"Military": @"Military",
        @"Politics": @"Politics",
        @"Science": @"Science",
        @"Medical": @"Medical",
        @"Athletic": @"Athletic",
        @"LawEnforcement": @"Law Enforcement",
        @"Culinary": @"Culinary",
        @"Slacker": @"Slacker",
        @"Criminal": @"Criminal",
        @"Paranormal": @"Paranormal",
        @"NaturalScientist": @"Natural Scientist",
        @"ShowBiz": @"Show Biz",
        @"Artist": @"Artist",
        @"Adventurer": @"Adventurer",
        @"Education": @"Education",
        @"Gamer": @"Gamer",
        @"Journalism": @"Journalism",
        @"Law": @"Law",
        @"Music": @"Music",
        @"Construction": @"Construction",
        @"Dance": @"Dance",
        @"Entertainment": @"Entertainment",
        @"Intelligence": @"Intelligence",
        @"Ocenography": @"Ocenography"
    };
}

// MARK: - Public Class Methods

+ (NSString *)getString:(NSString *)key {
    return [[self shared] getString:key];
}

+ (NSBundle *)bundle {
    return [[self shared] localizationBundle];
}

+ (NSLocale *)locale {
    return [NSLocale currentLocale];
}

// MARK: - Public Instance Methods

- (NSString *)getString:(NSString *)key {
    if (!key) {
        return @"";
    }
    
    // First try to get from the loaded dictionary
    NSString *result = self.localizedStrings[key];
    
    // If not found, try case-insensitive lookup
        if (!result) {
            NSString *trimmedKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *lowercaseKey = [trimmedKey lowercaseString];
            result = self.localizedStrings[lowercaseKey];
        }
    
    // If still not found, try NSLocalizedString
    if (!result) {
        result = NSLocalizedString(key, nil);
        if ([result isEqualToString:key]) {
            result = nil; // NSLocalizedString returned the key, meaning no translation found
        }
    }
    
    // If still not found, return the original key
    if (!result) {
        result = key;
    }
    
    return result;
}

@end
