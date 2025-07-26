//
//  IPackageHeaderHole.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
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
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 **************************************************************************/


  //Hole Index of the File
 //@remarks Holes are simple Placeholders filled with Data currently not useful.

@protocol IPackageHeaderHoleIndex <NSObject>


  //Returns the Number of items stored in the Index

@property (nonatomic, assign) int32_t count;

 //Returns the Offset for the Hole Index

@property (nonatomic, assign) uint32_t offset;

 //Returns the Size of the Hole Index

@property (nonatomic, assign) int32_t size;

//Returns the size of One Item stored in the index

@property (nonatomic, readonly) int32_t itemSize;

@end
