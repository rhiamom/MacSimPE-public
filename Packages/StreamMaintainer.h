//
//  StreamMaintainer.h
//  MacSimpe
//
//  Translated from StreamMaintainer.cs
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

typedef NS_ENUM(NSUInteger, StreamState) {
    /// The Stream is Open
    StreamStateOpened,
    /// The Stream is Closed
    StreamStateClosed,
    /// The stream is not available
    StreamStateRemoved
};

@class FileStream;

@interface StreamItem : NSObject

@property (nonatomic, strong, readonly) FileStream *fileStream;
@property (nonatomic, assign, readonly) StreamState streamState;

/// Creates a new Instance
/// @param fs The FileStream you want to use
- (instancetype)initWithFileStream:(FileStream *)fs;

/// Change the internal FileStream
/// @param fs The new FileStream
- (void)setFileStream:(FileStream *)fs;

/// Changes the Permissions for this Stream
/// @param fileAccess File Access you need
/// @returns true if the FileMode was changed
/// @remarks won't do anything if the Stream is null!
- (BOOL)setFileAccess:(NSString *)fileAccess;

/// Closes the Stream if opened
- (void)close;

@end

@interface StreamFactory : NSObject

/// marks a stream locked, which means, that it cannot be closed
/// @param filename The filename to lock
/// @returns true if successful
+ (BOOL)lockStream:(NSString *)filename;

/// marks a stream unlocked, which means, that it can be closed
/// @param filename The filename to unlock
/// @returns true if successful
+ (BOOL)unlockStream:(NSString *)filename;

/// Returns true, if the passed Stream is locked
/// @param filename The filename to check
/// @param checkFileTable true, if you want to check the FileTable for references (which count as locked)
/// @returns true if the stream is locked
+ (BOOL)isLocked:(NSString *)filename checkFileTable:(BOOL)checkFileTable;

/// Unlocks all Streams
+ (void)unlockAll;

/// Debug method to write stream info to console
+ (void)writeToConsole;

/// Removes all Files from the Teleport Folder
+ (void)cleanupTeleport;

/// Returns a valid stream Item for the passed Filename
/// @param filename The name of the File you want to open
/// @returns a valid StreamItem
/// @remarks If this File was not known yet, a new StreamItem will be generated for it and returned. The StreamItem will not contain a Stream in that case!
+ (StreamItem *)getStreamItem:(NSString *)filename;

/// Returns a valid stream Item for the passed Filename
/// @param filename The name of the File you want to open
/// @param createNew If true and this File was not known yet, a new StreamItem will be generated for it and returned. The StreamItem will not contain a Stream in that case!
/// @returns a valid StreamItem or nil if not found and createNew was false
+ (StreamItem *)getStreamItem:(NSString *)filename createNew:(BOOL)createNew;

/// Returns true if a FileStream for this file exists
/// @param name The filename to check
/// @returns true if a stream is available
+ (BOOL)isStreamAvailable:(NSString *)name;

/// Returns a Usable Stream for that File
/// @param filename The name of the File
/// @param fileAccess The Access Attributes
/// @returns a StreamItem (StreamState is Removed if the File did not exist!)
+ (StreamItem *)useStream:(NSString *)filename fileAccess:(NSString *)fileAccess;

/// Returns a Usable Stream for that File
/// @param filename The name of the File
/// @param fileAccess The Access Attributes
/// @param create true if the file should be created if not available
/// @returns a StreamItem (StreamState is Removed if the File did not exist!)
+ (StreamItem *)useStreamCreate:(NSString *)filename fileAccess:(NSString *)fileAccess create:(BOOL)create;

/// Returns nil or a StreamItem that was already created
/// @param fs The Stream you are looking for
/// @returns the Stream Item or nil if none was found
+ (StreamItem *)findStreamItem:(FileStream *)fs;

/// Closes a FileStream if opened and known by the Factory
/// @param filename The name of the File
/// @returns true if the File is closed now
+ (BOOL)closeStream:(NSString *)filename;

/// Closes all opened Streams (that are not locked and not referenced in the FileTable)
+ (void)closeAll;

/// Closes all opened Streams (that are not locked and not referenced in the FileTable)
/// @param force true, if you want to close all Resources without checking the lock state
+ (void)closeAll:(BOOL)force;

@end
