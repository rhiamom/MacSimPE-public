//
//  Elements.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/5/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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

#import "Elements.h"
#import "IFileWrapperSaveExtension.h"
#import "Fami.h"
#import "Xml.h"
#import "SDesc.h"
#import "PictureWrapper.h"
#import "FamilyTies.h"
#import "SRel.h"
#import "Objd.h"
#import "Helper.h"
#import "Localization.h"
#import "Registry.h"
#import "GUIDGetterForm.h"
#import "FixGuid.h"
#import "FamiFlags.h"
#import "Boolset.h"

@implementation Elements

@synthesize wrapper, picwrapper, simnamechanged;

- (id)init {
    self = [super initWithWindowNibName:@"Elements"];
    if (self) {
        intern = NO;
        simnamechanged = NO;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Additional setup after loading the window
}

#pragma mark - Actions

- (IBAction)commitFamiClick:(id)sender {
    if (wrapper != nil) {
        @try {
            [[NSCursor waitCursor] push];
            Fami *fami = (Fami *)wrapper;
            
            [fami setMoney:[[tbmoney stringValue] intValue]];
            [fami setFriends:[[tbfamily stringValue] intValue]];
            
            // Parse hex values
            NSScanner *scanner = [NSScanner scannerWithString:[tbflag stringValue]];
            unsigned int flagValue;
            [scanner scanHexInt:&flagValue];
            [fami setFlags:flagValue];
            
            scanner = [NSScanner scannerWithString:[tbalbum stringValue]];
            unsigned int albumValue;
            [scanner scanHexInt:&albumValue];
            [fami setAlbumGUID:albumValue];
            
            scanner = [NSScanner scannerWithString:[tbsubhood stringValue]];
            unsigned int subhoodValue;
            [scanner scanHexInt:&subhoodValue];
            [fami setSubHoodNumber:subhoodValue];
            
            [fami setVacationLotInstance:[Helper stringToUInt32:[tbvac stringValue]
                                                        default:[fami vacationLotInstance]
                                                           base:16]];
            [fami setCurrentlyOnLotInstance:[Helper stringToUInt32:[tbblot stringValue]
                                                            default:[fami currentlyOnLotInstance]
                                                               base:16]];
            [fami setBusinessMoney:[Helper stringToInt32:[tbbmoney stringValue]
                                                  default:[fami businessMoney]
                                                     base:10]];
            
            [fami setCastAwayFood:[Helper stringToInt32:[tbcafood1 stringValue]
                                                 default:[fami castAwayFood]
                                                    base:10]];
            [fami setCastAwayResources:[Helper stringToInt32:[tbcares stringValue]
                                                      default:[fami castAwayResources]
                                                         base:10]];
            [fami setCastAwayFoodDecay:[Helper stringToInt32:[tbcaunk stringValue]
                                                      default:[fami castAwayFoodDecay]
                                                         base:16]];
            
            // Handle members array
            NSInteger memberCount = [lbmembers numberOfRows];
            NSMutableArray *members = [NSMutableArray arrayWithCapacity:memberCount];
            
            for (NSInteger i = 0; i < memberCount; i++) {
                id<IAlias> alias = [lbmembers.dataSource tableView:lbmembers
                                                 objectValueForTableColumn:nil
                                                                       row:i];
                [members addObject:@([alias aliasId])];
                
                SDesc *sdesc = [fami getDescriptionFile:[alias aliasId]];
                [sdesc setFamilyInstance:(uint16_t)[[fami fileDescriptor] instance]];
                [sdesc synchronizeUserData];
            }
            
            [fami setMembers:members];
            
            scanner = [NSScanner scannerWithString:[tblotinst stringValue]];
            unsigned int lotInstValue;
            [scanner scanHexInt:&lotInstValue];
            [fami setLotInstance:lotInstValue];
            
            // Name was changed
            if (![[tbname stringValue] isEqualToString:[fami name]]) {
                [fami setName:[tbname stringValue]];
            }
            
            [wrapper synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[LocalizationManager sharedManager] getString:@"committed"]];
            [alert runModal];
            [alert release];
            
        } @catch (NSException *ex) {
            [Helper exceptionMessage:[[LocalizationManager sharedManager] getString:@"cantcommitfamily"]
                           exception:ex];
        } @finally {
            [NSCursor pop];
        }
    }
}

- (IBAction)commitXmlClick:(id)sender {
    if (wrapper != nil) {
        @try {
            Xml *xml = (Xml *)wrapper;
            [xml setText:[rtb string]];
            [wrapper synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[LocalizationManager sharedManager] getString:@"commited"]];
            [alert runModal];
            [alert release];
        } @catch (NSException *ex) {
            // Handle exception silently
        }
    }
}

- (IBAction)famiSimAddClick:(id)sender {
    if ([cbsims indexOfSelectedItem] >= 0) {
        id selectedItem = [cbsims objectValueOfSelectedItem];
        
        // Check if item already exists in members list
        BOOL exists = NO;
        NSInteger rowCount = [lbmembers numberOfRows];
        for (NSInteger i = 0; i < rowCount; i++) {
            id existingItem = [lbmembers.dataSource tableView:lbmembers
                                        objectValueForTableColumn:nil
                                                               row:i];
            if ([existingItem isEqual:selectedItem]) {
                exists = YES;
                break;
            }
        }
        
        if (!exists) {
            // Add item to members list (implementation depends on data source)
            [lbmembers.dataSource tableView:lbmembers
                              setObjectValue:selectedItem
                              forTableColumn:nil
                                         row:rowCount];
            [lbmembers reloadData];
        }
    }
}

- (IBAction)simSelectionChange:(id)sender {
    NSPopUpButton *comboBox = (NSPopUpButton *)sender;
    [llFamiAddSim setEnabled:([comboBox indexOfSelectedItem] >= 0 &&
                              [comboBox numberOfItems] > 0)];
}

- (IBAction)famiMemberSelectionClick:(id)sender {
    NSTableView *tableView = (NSTableView *)sender;
    [llFamiDeleteSim setEnabled:([tableView selectedRow] >= 0)];
    [llFamiDeleteSim setNeedsDisplay:YES];
}

- (IBAction)famiDeleteSimClick:(id)sender {
    NSInteger selectedRow = [lbmembers selectedRow];
    if (selectedRow >= 0) {
        // Remove item from data source
        [lbmembers.dataSource tableView:lbmembers
                          setObjectValue:nil
                          forTableColumn:nil
                                     row:selectedRow];
        [lbmembers reloadData];
    }
}

#pragma mark - Family Ties

- (IBAction)familyTieSimIndexChanged:(id)sender {
    [btdeletetie setEnabled:NO];
    if ([cbtiesims indexOfSelectedItem] < 0) return;
    
    FamilyTieSim *sim = (FamilyTieSim *)[cbtiesims objectValueOfSelectedItem];
    
    // Clear and reload ties list
    [lbties.dataSource removeAllObjects];
    NSArray *ties = [sim ties];
    for (FamilyTieItem *tie in ties) {
        [lbties.dataSource addObject:tie];
    }
    [lbties reloadData];
}

- (IBAction)allTieableSimsIndexChanged:(id)sender {
    [btaddtie setEnabled:NO];
    [btnewtie setEnabled:NO];
    if ([cballtieablesims indexOfSelectedItem] < 0) return;
    [btnewtie setEnabled:YES];
    if ([cbtiesims indexOfSelectedItem] < 0) return;
    [btaddtie setEnabled:YES];
}

- (IBAction)deleteTieClick:(id)sender {
    [btaddtie setEnabled:NO];
    NSInteger selectedRow = [lbties selectedRow];
    if (selectedRow < 0) return;
    
    [lbties.dataSource removeObjectAtIndex:selectedRow];
    [lbties reloadData];
}

- (IBAction)addTieClick:(id)sender {
    if ([cballtieablesims indexOfSelectedItem] < 0) return;
    if ([cbtietype indexOfSelectedItem] < 0) return;
    
    @try {
        FamilyTies *famt = (FamilyTies *)wrapper;
        LocalizedFamilyTieTypes *ftt = (LocalizedFamilyTieTypes *)[cbtietype objectValueOfSelectedItem];
        FamilyTieSim *fts = (FamilyTieSim *)[cballtieablesims objectValueOfSelectedItem];
        FamilyTieItem *tie = [[FamilyTieItem alloc] initWithType:ftt
                                                        instance:[fts instance]
                                                      familyTies:famt];
        [lbties.dataSource addObject:tie];
        [lbties reloadData];
        [tie release];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:[[LocalizationManager sharedManager] getString:@"cantaddtie"]
                       exception:ex];
    }
}

- (IBAction)commitSimTieClicked:(id)sender {
    if ([cbtiesims indexOfSelectedItem] < 0) return;
    
    if (wrapper != nil) {
        @try {
            FamilyTies *famt = (FamilyTies *)wrapper;
            FamilyTieSim *fts = (FamilyTieSim *)[cbtiesims objectValueOfSelectedItem];
            
            NSMutableArray *ftis = [NSMutableArray array];
            NSInteger rowCount = [lbties numberOfRows];
            for (NSInteger i = 0; i < rowCount; i++) {
                FamilyTieItem *item = [lbties.dataSource objectAtIndex:i];
                [ftis addObject:item];
            }
            [fts setTies:ftis];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:[[LocalizationManager sharedManager] getString:@"cantcommitfamt"]
                           exception:ex];
        }
    }
}

- (IBAction)tieIndexChanged:(id)sender {
    [btdeletetie setEnabled:NO];
    if ([lbties selectedRow] < 0) return;
    [btdeletetie setEnabled:YES];
}

- (IBAction)commitTieClick:(id)sender {
    [self commitSimTieClicked:nil];
    if (wrapper != nil) {
        @try {
            FamilyTies *famt = (FamilyTies *)wrapper;
            
            NSMutableArray *sims = [NSMutableArray array];
            NSInteger itemCount = [cbtiesims numberOfItems];
            for (NSInteger i = 0; i < itemCount; i++) {
                FamilyTieSim *sim = [cbtiesims itemObjectValueAtIndex:i];
                [sims addObject:sim];
            }
            [famt setSims:sims];
            
            [famt synchronizeUserData];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:[[LocalizationManager sharedManager] getString:@"cantcommittie"]
                           exception:ex];
        }
    }
}

- (IBAction)addSimToTiesClick:(id)sender {
    if ([cballtieablesims indexOfSelectedItem] < 0) return;
    FamilyTieSim *sim = (FamilyTieSim *)[cballtieablesims objectValueOfSelectedItem];
    [sim setTies:@[]];
    
    // Check if the tie exists
    BOOL exists = NO;
    NSInteger itemCount = [cbtiesims numberOfItems];
    for (NSInteger i = 0; i < itemCount; i++) {
        FamilyTieSim *exsim = [cbtiesims itemObjectValueAtIndex:i];
        if ([exsim instance] == [sim instance]) {
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        [cbtiesims addItemWithObjectValue:sim];
    }
}

#pragma mark - Relationships

- (IBAction)relationshipFileCommit:(id)sender {
    if (wrapper != nil) {
        @try {
            SRel *srel = (SRel *)wrapper;
            [srel setShortterm:[[tbshortterm stringValue] intValue]];
            [srel setLongterm:[[tblongterm stringValue] intValue]];
            
            NSArray *checkboxes = @[cbcrush, cblove, cbengaged, cbmarried,
                                   cbfriend, cbbuddie, cbsteady, cbenemy];
            
            Boolset *bs1 = [[srel relationState] value];
            for (NSInteger i = 0; i < 16; i++) {
                if (i < [checkboxes count] && checkboxes[i] != nil) {
                    NSButton *checkbox = checkboxes[i];
                    [bs1 setBit:i value:([checkbox state] == NSOnState)];
                }
            }
            [[srel relationState] setValue:bs1];
            
            if ([cbfamtype indexOfSelectedItem] > 0) {
                LocalizedRelationshipTypes *relType = [cbfamtype objectValueOfSelectedItem];
                [srel setFamilyRelation:relType];
            }
            
            [wrapper synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[LocalizationManager sharedManager] getString:@"commited"]];
            [alert runModal];
            [alert release];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:@"Unable to Save Relationship Information!"
                           exception:ex];
        }
    }
}

#pragma mark - Object Description

- (IBAction)commitObjdClicked:(id)sender {
    if (wrapper != nil) {
        @try {
            [[NSCursor waitCursor] push];
            Objd *objd = (Objd *)wrapper;
            
            // Process elements in pnelements
            NSArray *subviews = [pnelements subviews];
            for (NSView *view in subviews) {
                if ([view isKindOfClass:[NSTextField class]]) {
                    NSTextField *textField = (NSTextField *)view;
                    NSString *tagString = [textField identifier];
                    if (tagString != nil) {
                        ObjdItem *item = [[objd attributes] objectForKey:tagString];
                        
                        NSScanner *scanner = [NSScanner scannerWithString:[textField stringValue]];
                        unsigned int value;
                        [scanner scanHexInt:&value];
                        [item setVal:(uint16_t)value];
                        
                        [[objd attributes] setObject:item forKey:tagString];
                    }
                }
            }
            
            NSScanner *scanner = [NSScanner scannerWithString:[tblottype stringValue]];
            unsigned int typeValue;
            [scanner scanHexInt:&typeValue];
            [objd setType:(uint16_t)typeValue];
            
            scanner = [NSScanner scannerWithString:[tbsimid stringValue]];
            unsigned int guidValue;
            [scanner scanHexInt:&guidValue];
            [objd setGuid:guidValue];
            
            [objd setFileName:[tbsimname stringValue]];
            
            scanner = [NSScanner scannerWithString:[tborgguid stringValue]];
            unsigned int orgGuidValue;
            [scanner scanHexInt:&orgGuidValue];
            [objd setOriginalGuid:orgGuidValue];
            
            scanner = [NSScanner scannerWithString:[tbproxguid stringValue]];
            unsigned int proxyGuidValue;
            [scanner scanHexInt:&proxyGuidValue];
            [objd setProxyGuid:proxyGuidValue];
            
            [objd synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[LocalizationManager sharedManager] getString:@"commited"]];
            [alert runModal];
            [alert release];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:[[LocalizationManager sharedManager] getString:@"cantcommitobjd"]
                           exception:ex];
        } @finally {
            [NSCursor pop];
        }
    }
}

- (IBAction)getGUIDClicked:(id)sender {
    GUIDGetterForm *form = [[GUIDGetterForm alloc] init];
    Registry *reg = [Helper windowsRegistry];
    
    @try {
        NSScanner *scanner = [NSScanner scannerWithString:[tbsimid stringValue]];
        unsigned int oldguid;
        [scanner scanHexInt:&oldguid];
        
        uint32_t guid = [form getNewGUID:[reg username]
                                password:[reg password]
                                 oldGuid:oldguid];
        
        [reg setUsername:[[form tbusername] stringValue]];
        [reg setPassword:[[form tbpassword] stringValue]];
        [tbsimid setStringValue:[NSString stringWithFormat:@"0x%@", [Helper hexString:guid]]];
        
        if ([cbupdate state] == NSOnState) {
            FixGuid *fg = [[FixGuid alloc] initWithPackage:[(Objd *)wrapper package]];
            NSMutableArray *guidSets = [NSMutableArray array];
            GuidSet *gs = [[GuidSet alloc] init];
            [gs setOldguid:oldguid];
            [gs setGuid:guid];
            [guidSets addObject:gs];
            [gs release];
            
            [fg fixGuids:guidSets];
            [fg release];
            
            [(Objd *)wrapper setGuid:guid];
            [wrapper synchronizeUserData];
        }
    } @catch (NSException *ex) {
        // Handle exception silently
    } @finally {
        [form release];
    }
}

- (IBAction)simNameChanged:(id)sender {
    simnamechanged = YES;
}

- (IBAction)flagChanged:(id)sender {
    if ([tbflag tag] != 0) return;
    [tbflag setTag:1];
    
    @try {
        NSScanner *scanner = [NSScanner scannerWithString:[tbflag stringValue]];
        unsigned int flag;
        [scanner scanHexInt:&flag];
        
        FamiFlags *flags = [[FamiFlags alloc] initWithValue:(uint16_t)flag];
        
        [cbphone setState:([flags hasPhone] ? NSOnState : NSOffState)];
        [cbcomputer setState:([flags hasComputer] ? NSOnState : NSOffState)];
        [cbbaby setState:([flags hasBaby] ? NSOnState : NSOffState)];
        [cblot setState:([flags newLot] ? NSOnState : NSOffState)];
        
        [flags release];
    } @catch (NSException *ex) {
        // Handle exception silently
    } @finally {
        [tbflag setTag:0];
    }
}

- (IBAction)changeFlags:(id)sender {
    if ([tbflag tag] != 0) return;
    [tbflag setTag:1];
    
    @try {
        NSScanner *scanner = [NSScanner scannerWithString:[tbflag stringValue]];
        unsigned int flag;
        [scanner scanHexInt:&flag];
        flag = flag & 0xffff0000;
        
        FamiFlags *flags = [[FamiFlags alloc] initWithValue:0];
        
        [flags setHasPhone:([cbphone state] == NSOnState)];
        [flags setHasComputer:([cbcomputer state] == NSOnState)];
        [flags setHasBaby:([cbbaby state] == NSOnState)];
        [flags setNewLot:([cblot state] == NSOnState)];
        
        flag = flag | [flags value];
        [tbflag setStringValue:[NSString stringWithFormat:@"0x%@", [Helper hexString:flag]]];
        
        [flags release];
    } @catch (NSException *ex) {
        // Handle exception silently
    } @finally {
        [tbflag setTag:0];
    }
}

- (IBAction)btPicExportClick:(id)sender {
    Picture *wrp = (Picture *)picwrapper;
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"png"]];
    
    if ([savePanel runModal] == NSModalResponseOK) {
        @try {
            NSImage *image = [wrp image];
            NSData *imageData = [image TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSData *pngData = [imageRep representationUsingType:NSBitmapImageFileTypePNG
                                                     properties:@{}];
            [pngData writeToURL:[savePanel URL] atomically:YES];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:ex];
        }
    }
}

- (IBAction)label15Click:(id)sender {
    // Empty implementation
}

- (IBAction)changedMoney:(id)sender {
    if (intern) return;
    intern = YES;
    
    Fami *fami = (Fami *)wrapper;
    NSTextField *textField = (NSTextField *)sender;
    
    int32_t money = [Helper stringToInt32:[textField stringValue]
                                   default:[fami money]
                                      base:10];
    [fami setMoney:money];
    [fami setCastAwayFood:money];
    
    if (textField != tbmoney) {
        [tbmoney setStringValue:[NSString stringWithFormat:@"%d", [fami money]]];
    }
    if (textField != tbcafood1) {
        [tbcafood1 setStringValue:[NSString stringWithFormat:@"%d", [fami castAwayFood]]];
    }
    
    intern = NO;
}

- (IBAction)changedBMoney:(id)sender {
    if (intern) return;
    intern = YES;
    
    Fami *fami = (Fami *)wrapper;
    NSTextField *textField = (NSTextField *)sender;
    
    int32_t businessMoney = [Helper stringToInt32:[textField stringValue]
                                           default:[fami businessMoney]
                                              base:10];
    [fami setBusinessMoney:businessMoney];
    [fami setCastAwayFoodDecay:businessMoney];
    
    if (textField != tbbmoney) {
        [tbbmoney setStringValue:[NSString stringWithFormat:@"%d", [fami businessMoney]]];
    }
    if (textField != tbcaunk) {
        [tbcaunk setStringValue:[NSString stringWithFormat:@"%d", [fami castAwayFoodDecay]]];
    }
    
    intern = NO;
}

#pragma mark - Progress Bar Handling

- (void)progressBarMaximize:(NSView *)parent {
    NSArray *subviews = [parent subviews];
    for (NSView *view in subviews) {
        if ([view isKindOfClass:[NSProgressIndicator class]]) {
            NSProgressIndicator *progressBar = (NSProgressIndicator *)view;
            if ([progressBar maxValue] < 1000) {
                [progressBar setDoubleValue:[progressBar maxValue]];
            } else {
                [progressBar setDoubleValue:[progressBar maxValue] - 1];
            }
        }
    }
    [self progressBarUpdate:parent];
}

- (void)progressBarUpdate:(NSView *)parent {
    NSArray *subviews = [parent subviews];
    for (NSView *view in subviews) {
        if ([view isKindOfClass:[NSProgressIndicator class]]) {
            [self progressBarUpdate:(NSProgressIndicator *)view withEvent:nil];
        }
    }
}

- (void)progressBarUpdate:(NSProgressIndicator *)pb withEvent:(NSEvent *)event {
    if (event != nil) {
        NSPoint location = [event locationInWindow];
        NSPoint localPoint = [pb convertPoint:location fromView:nil];
        double ratio = localPoint.x / NSWidth([pb bounds]);
        double newValue = MAX([pb minValue], MIN([pb maxValue], ratio * [pb maxValue]));
        [pb setDoubleValue:newValue];
    }
    
    NSArray *parentSubviews = [[pb superview] subviews];
    for (NSView *view in parentSubviews) {
        if ([view isKindOfClass:[NSTextField class]]) {
            NSTextField *textField = (NSTextField *)view;
            NSString *pbName = [pb identifier];
            NSString *expectedName = [pbName stringByReplacingOccurrencesOfString:@"pb" withString:@"tb"];
            if ([[textField identifier] isEqualToString:expectedName]) {
                NSNumber *tag = [pb.userInfo objectForKey:@"tag"];
                if (tag != nil) {
                    [textField setStringValue:[NSString stringWithFormat:@"%.0f",
                                             [pb doubleValue] - [tag doubleValue]]];
                } else {
                    [textField setStringValue:[NSString stringWithFormat:@"%.0f", [pb doubleValue]]];
                }
            }
        }
    }
}

- (void)getAssignedProgressbar:(NSTextField *)textField {
    NSArray *parentSubviews = [[textField superview] subviews];
    for (NSView *view in parentSubviews) {
        if ([view isKindOfClass:[NSProgressIndicator class]]) {
            NSProgressIndicator *progressBar = (NSProgressIndicator *)view;
            NSString *tfName = [textField identifier];
            NSString *expectedName = [tfName stringByReplacingOccurrencesOfString:@"tb" withString:@"pb"];
            if ([[progressBar identifier] isEqualToString:expectedName]) {
                // Store reference somehow - perhaps in a dictionary or as associated object
                objc_setAssociatedObject(textField, @"progressBar", progressBar, OBJC_ASSOCIATION_ASSIGN);
                break;
            }
        }
    }
}

- (void)progressBarTextChanged:(id)sender {
    NSTextField *textField = (NSTextField *)sender;
    NSProgressIndicator *progressBar = objc_getAssociatedObject(textField, @"progressBar");
    
    if (progressBar == nil) {
        [self getAssignedProgressbar:textField];
        progressBar = objc_getAssociatedObject(textField, @"progressBar");
    }
    if (progressBar == nil) return;
    
    @try {
        NSNumber *tag = [progressBar.userInfo objectForKey:@"tag"];
        double value = [[textField stringValue] doubleValue];
        if (tag != nil) {
            value = MAX(0, MIN([progressBar maxValue], value + [tag doubleValue]));
        } else {
            value = MAX(0, MIN([progressBar maxValue], value));
        }
        [progressBar setDoubleValue:value];
    } @catch (NSException *ex) {
        // Handle exception silently
    }
}

- (void)progressBarTextLeave:(id)sender {
    if (![sender isKindOfClass:[NSTextField class]]) return;
    NSTextField *textField = (NSTextField *)sender;
    NSProgressIndicator *progressBar = objc_getAssociatedObject(textField, @"progressBar");
    
    if (progressBar == nil) {
        [self getAssignedProgressbar:textField];
        progressBar = objc_getAssociatedObject(textField, @"progressBar");
    }
    if (progressBar == nil) return;
    
    @try {
        NSNumber *tag = [progressBar.userInfo objectForKey:@"tag"];
        if (tag != nil) {
            [textField setStringValue:[NSString stringWithFormat:@"%.0f",
                                     [progressBar doubleValue] - [tag doubleValue]]];
        } else {
            [textField setStringValue:[NSString stringWithFormat:@"%.0f", [progressBar doubleValue]]];
        }
    } @catch (NSException *ex) {
        // Handle exception silently
    }
}

@end
