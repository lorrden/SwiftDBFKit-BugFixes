//
//  DBFKit.h
//  DBFKit
//
//  Created by Michael Shapiro on 4/29/24.
//

#import <Foundation/Foundation.h>

//! Project version number for DBFKit.
FOUNDATION_EXPORT double DBFKitVersionNumber;

//! Project version string for DBFKit.
FOUNDATION_EXPORT const unsigned char DBFKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DBFKit/PublicHeader.h>

//! For making DBF tables
FOUNDATION_EXPORT Class DBFTable;

//! Used for writing DBF files
FOUNDATION_EXPORT Class DBFWriter;

//! Can be used for reading DBF files
FOUNDATION_EXPORT Class DBFFile;
