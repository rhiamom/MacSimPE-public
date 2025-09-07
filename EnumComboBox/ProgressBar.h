//
//  ProgressBar.h
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ProgressBarStyle) {
    ProgressBarStyleBar,        // Standard horizontal progress bar
    ProgressBarStyleSpinning    // Spinning progress indicator
};

/**
 * Mac-native progress bar wrapper using NSProgressIndicator
 * Provides a clean interface similar to Windows Forms ProgressBar
 * but using proper AppKit controls with platform-appropriate styling
 */
@interface ProgressBar : NSView

// MARK: - Properties

/**
 * The underlying NSProgressIndicator
 */
@property (nonatomic, strong, readonly) NSProgressIndicator *progressIndicator;

/**
 * Style of the progress indicator
 */
@property (nonatomic, assign) ProgressBarStyle style;

/**
 * Whether the progress is indeterminate (unknown duration)
 */
@property (nonatomic, assign) BOOL indeterminate;

/**
 * Minimum value (default: 0)
 */
@property (nonatomic, assign) double minimumValue;

/**
 * Maximum value (default: 100)
 */
@property (nonatomic, assign) double maximumValue;

/**
 * Current progress value
 */
@property (nonatomic, assign) double value;

/**
 * Current progress as a percentage (0-100)
 */
@property (nonatomic, assign) NSInteger percentage;

/**
 * Whether to display percentage text on the progress bar
 */
@property (nonatomic, assign) BOOL showsPercentage;

/**
 * Custom text to display instead of percentage
 */
@property (nonatomic, copy, nullable) NSString *customText;

// MARK: - Initialization

/**
 * Initialize with default bar style
 */
- (instancetype)initWithFrame:(NSRect)frameRect;

/**
 * Initialize with specific style
 */
- (instancetype)initWithFrame:(NSRect)frameRect style:(ProgressBarStyle)style;

// MARK: - Progress Control

/**
 * Start animation for indeterminate progress
 */
- (void)startAnimation;

/**
 * Stop animation for indeterminate progress
 */
- (void)stopAnimation;

/**
 * Set progress value with optional animation
 */
- (void)setValue:(double)value animated:(BOOL)animated;

/**
 * Increment progress by specified amount
 */
- (void)incrementBy:(double)delta;

/**
 * Reset progress to minimum value
 */
- (void)reset;

/**
 * Set progress to maximum value (complete)
 */
- (void)complete;

// MARK: - Appearance

/**
 * Set the control size (regular, small, mini)
 */
@property (nonatomic, assign) NSControlSize controlSize;

/**
 * Tint color for the progress bar (macOS 10.14+)
 */
@property (nonatomic, strong, nullable) NSColor *progressColor NS_AVAILABLE_MAC(10_14);

@end

NS_ASSUME_NONNULL_END
