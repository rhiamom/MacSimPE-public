//
//  SidebarView.h
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/10/25.
//

#import <Cocoa/Cocoa.h>
#import "ToolTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class AppState;
@protocol SidebarViewDelegate;

@interface SidebarView : NSView

@property (nonatomic, weak, nullable) id<SidebarViewDelegate> delegate;
@property (nonatomic, assign) Tool selectedTool;
@property (nonatomic, strong) AppState *appState;

- (instancetype)initWithFrame:(NSRect)frameRect appState:(AppState *)appState;
- (void)updateToolSelection:(Tool)tool;

@end

@protocol SidebarViewDelegate <NSObject>
@optional
- (void)sidebarView:(SidebarView *)sidebar didSelectTool:(Tool)tool;
- (void)sidebarViewDidRequestOpenPackage:(SidebarView *)sidebar;
@end

NS_ASSUME_NONNULL_END
