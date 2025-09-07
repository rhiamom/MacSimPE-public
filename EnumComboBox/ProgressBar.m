//
//  ProgressBar.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/4/25.
//
// ***************************************************************************
// *   Copyright (C) 2025 by GramzeSweatShop                                 *
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

#import "ProgressBar.h"

@interface ProgressBar ()
@property (nonatomic, strong, readwrite) NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) NSTextField *textLabel;
@end

@implementation ProgressBar

// MARK: - Initialization

- (instancetype)initWithFrame:(NSRect)frameRect {
    return [self initWithFrame:frameRect style:ProgressBarStyleBar];
}

- (instancetype)initWithFrame:(NSRect)frameRect style:(ProgressBarStyle)style {
    self = [super initWithFrame:frameRect];
    if (self) {
        _style = style;
        _minimumValue = 0.0;
        _maximumValue = 100.0;
        _value = 0.0;
        _showsPercentage = NO;
        
        [self setupProgressIndicator];
        [self setupTextLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _style = ProgressBarStyleBar;
        _minimumValue = 0.0;
        _maximumValue = 100.0;
        _value = 0.0;
        _showsPercentage = NO;
        
        [self setupProgressIndicator];
        [self setupTextLabel];
    }
    return self;
}

// MARK: - Setup

- (void)setupProgressIndicator {
    self.progressIndicator = [[NSProgressIndicator alloc] initWithFrame:self.bounds];
    self.progressIndicator.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self updateProgressIndicatorStyle];
    [self addSubview:self.progressIndicator];
}

- (void)setupTextLabel {
    // Text label for showing percentage or custom text
    self.textLabel = [[NSTextField alloc] init];
    self.textLabel.editable = NO;
    self.textLabel.selectable = NO;
    self.textLabel.bordered = NO;
    self.textLabel.backgroundColor = [NSColor clearColor];
    self.textLabel.alignment = NSTextAlignmentCenter;
    self.textLabel.font = [NSFont systemFontOfSize:11];
    self.textLabel.textColor = [NSColor controlTextColor];
    self.textLabel.hidden = !self.showsPercentage;
    [self addSubview:self.textLabel];
}

- (void)updateProgressIndicatorStyle {
    switch (self.style) {
        case ProgressBarStyleBar:
            self.progressIndicator.style = NSProgressIndicatorStyleBar;
            break;
        case ProgressBarStyleSpinning:
            self.progressIndicator.style = NSProgressIndicatorStyleSpinning;
            break;
    }
    
    self.progressIndicator.minValue = self.minimumValue;
    self.progressIndicator.maxValue = self.maximumValue;
    self.progressIndicator.doubleValue = self.value;
    self.progressIndicator.indeterminate = self.indeterminate;
}

// MARK: - Layout

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    // Progress indicator fills the entire view
    self.progressIndicator.frame = self.bounds;
    
    // Position text label in center if showing percentage
    if (self.showsPercentage && !self.textLabel.hidden) {
        NSSize textSize = [self.textLabel.stringValue sizeWithAttributes:@{NSFontAttributeName: self.textLabel.font}];
        CGFloat x = (self.bounds.size.width - textSize.width) / 2.0;
        CGFloat y = (self.bounds.size.height - textSize.height) / 2.0;
        self.textLabel.frame = NSMakeRect(x, y, textSize.width, textSize.height);
    }
}

// MARK: - Properties

- (void)setStyle:(ProgressBarStyle)style {
    if (_style != style) {
        _style = style;
        [self updateProgressIndicatorStyle];
    }
}

- (void)setIndeterminate:(BOOL)indeterminate {
    if (_indeterminate != indeterminate) {
        _indeterminate = indeterminate;
        self.progressIndicator.indeterminate = indeterminate;
        [self updateTextDisplay];
    }
}

- (void)setMinimumValue:(double)minimumValue {
    if (_minimumValue != minimumValue) {
        _minimumValue = minimumValue;
        self.progressIndicator.minValue = minimumValue;
        [self updateTextDisplay];
    }
}

- (void)setMaximumValue:(double)maximumValue {
    if (_maximumValue != maximumValue) {
        _maximumValue = maximumValue;
        self.progressIndicator.maxValue = maximumValue;
        [self updateTextDisplay];
    }
}

- (void)setValue:(double)value {
    if (_value != value) {
        _value = value;
        self.progressIndicator.doubleValue = value;
        [self updateTextDisplay];
    }
}

- (NSInteger)percentage {
    if (self.maximumValue <= self.minimumValue) return 0;
    
    double range = self.maximumValue - self.minimumValue;
    double progress = self.value - self.minimumValue;
    return (NSInteger)round((progress / range) * 100.0);
}

- (void)setPercentage:(NSInteger)percentage {
    double range = self.maximumValue - self.minimumValue;
    double newValue = self.minimumValue + (range * (percentage / 100.0));
    self.value = newValue;
}

- (void)setShowsPercentage:(BOOL)showsPercentage {
    if (_showsPercentage != showsPercentage) {
        _showsPercentage = showsPercentage;
        [self updateTextDisplay];
    }
}

- (void)setCustomText:(NSString *)customText {
    if (![_customText isEqualToString:customText]) {
        _customText = [customText copy];
        [self updateTextDisplay];
    }
}

- (void)setControlSize:(NSControlSize)controlSize {
    self.progressIndicator.controlSize = controlSize;
    
    // Adjust font size based on control size
    switch (controlSize) {
        case NSControlSizeRegular:
            self.textLabel.font = [NSFont systemFontOfSize:11];
            break;
        case NSControlSizeSmall:
            self.textLabel.font = [NSFont systemFontOfSize:9];
            break;
        case NSControlSizeMini:
            self.textLabel.font = [NSFont systemFontOfSize:8];
            break;
        default:
            break;
    }
    
    [self layoutSubviews];
}

- (NSControlSize)controlSize {
    return self.progressIndicator.controlSize;
}

- (void)setProgressColor:(NSColor *)progressColor {
    if (@available(macOS 10.14, *)) {
        // On macOS 10.14+, we can tint the progress indicator
        self.progressIndicator.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        // Note: Direct color tinting of NSProgressIndicator is limited
        // For full color customization, would need custom drawing
    }
}

- (NSColor *)progressColor {
    if (@available(macOS 10.14, *)) {
        // Return the current accent color or a default
        return [NSColor controlAccentColor];
    }
    return [NSColor blueColor];
}

// MARK: - Progress Control

- (void)startAnimation {
    [self.progressIndicator startAnimation:nil];
}

- (void)stopAnimation {
    [self.progressIndicator stopAnimation:nil];
}

- (void)setValue:(double)value animated:(BOOL)animated {
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.25;
            context.allowsImplicitAnimation = YES;
            self.progressIndicator.doubleValue = value;
        } completionHandler:^{
            self->_value = value;
            [self updateTextDisplay];
        }];
    } else {
        self.value = value;
    }
}

- (void)incrementBy:(double)delta {
    self.value = self.value + delta;
}

- (void)reset {
    self.value = self.minimumValue;
}

- (void)complete {
    self.value = self.maximumValue;
}

// MARK: - Private Methods

- (void)updateTextDisplay {
    if (self.indeterminate || self.style == ProgressBarStyleSpinning) {
        // Don't show percentage for indeterminate progress
        self.textLabel.hidden = YES;
        return;
    }
    
    BOOL shouldShowText = self.showsPercentage || self.customText.length > 0;
    self.textLabel.hidden = !shouldShowText;
    
    if (shouldShowText) {
        if (self.customText.length > 0) {
            self.textLabel.stringValue = self.customText;
        } else if (self.showsPercentage) {
            self.textLabel.stringValue = [NSString stringWithFormat:@"%ld%%", (long)self.percentage];
        }
        
        [self layoutSubviews];
    }
}

// MARK: - NSView

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (BOOL)isFlipped {
    return YES;
}

- (NSSize)intrinsicContentSize {
    switch (self.style) {
        case ProgressBarStyleBar:
            switch (self.controlSize) {
                case NSControlSizeRegular:
                    return NSMakeSize(NSViewNoIntrinsicMetric, 20);
                case NSControlSizeSmall:
                    return NSMakeSize(NSViewNoIntrinsicMetric, 16);
                case NSControlSizeMini:
                    return NSMakeSize(NSViewNoIntrinsicMetric, 12);
                default:
                    return NSMakeSize(NSViewNoIntrinsicMetric, 20);
            }
        case ProgressBarStyleSpinning:
            switch (self.controlSize) {
                case NSControlSizeRegular:
                    return NSMakeSize(32, 32);
                case NSControlSizeSmall:
                    return NSMakeSize(16, 16);
                case NSControlSizeMini:
                    return NSMakeSize(10, 10);
                default:
                    return NSMakeSize(32, 32);
            }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Additional custom drawing could go here if needed
    // For now, we rely on NSProgressIndicator's native drawing
}

// MARK: - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> style=%ld indeterminate=%@ value=%.2f/%.2f (%.0f%%)",
            NSStringFromClass([self class]), self,
            (long)self.style, self.indeterminate ? @"YES" : @"NO",
            self.value, self.maximumValue,
            (double)self.percentage];
}

@end
