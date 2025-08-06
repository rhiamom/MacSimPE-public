//
//  CRCStandard.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop        *
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

/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Classless.Hasher - C#/.NET Hash and Checksum Algorithm Library.
 *
 * The Initial Developer of the Original Code is Classless.net.
 * Portions created by the Initial Developer are Copyright (C) 2004 the Initial
 * Developer. All Rights Reserved.
 *
 * Contributor(s):
 *        Jason Simeone (jay@classless.net)
 *
 * ***** END LICENSE BLOCK ***** */

#import <Foundation/Foundation.h>

/// Predefined standards for CRC algorithms.
typedef NS_ENUM(NSInteger, CRCStandard) {
    /// The standard CRC8 algorithm.
    CRCStandardCRC8,
    
    /// The reversed CRC8 algorithm.
    CRCStandardCRC8Reversed,
    
    /// The standard CRC16 algorithm.
    CRCStandardCRC16,
    
    /// The reversed CRC16 algorithm.
    CRCStandardCRC16Reversed,
    
    /// The standard CRC16-CCITT algorithm. Used in things such as X.25, SDLC, and HDLC.
    CRCStandardCRC16CCITT,
    
    /// The reversed CRC16-CCITT algorithm. Used in things such as XMODEM and Kermit.
    CRCStandardCRC16CCITTReversed,
    
    /// A variation on the CRC16 algorithm. Used in ARC.
    CRCStandardCRC16ARC,
    
    /// A variation on the CRC16 algorithm. Used in ZMODEM.
    CRCStandardCRC16ZMODEM,
    
    /// The standard CRC24 algorithm. Used in things such as PGP.
    CRCStandardCRC24,
    
    /// The standard CRC32 algorithm. Used in things such as AUTODIN II, Ethernet, and FDDI.
    CRCStandardCRC32,
    
    /// The reversed CRC32 algorithm. Used in things such as PKZip and SFV.
    CRCStandardCRC32Reversed,
    
    /// A variation on the CRC32 algorithm. Used in JAMCRC.
    CRCStandardCRC32JAMCRC,
    
    /// A variation on the CRC32 algorithm. Used in BZip2.
    CRCStandardCRC32BZIP2
};
#ifndef CRCStandard_h
#define CRCStandard_h


#endif /* CRCStandard_h */
