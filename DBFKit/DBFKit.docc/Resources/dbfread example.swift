//
//  dbfread example.swift
//  
//
//  Created by Michael Shapiro on 5/1/24.
//

import Foundation
import DBFKit

// using a reader is very easy

// first initialize the reader class

let ourFile: DBFFile = DBFFile(path: "path/to/dbf/file.dbf")

// next execute the read function inside a do-catch block

do {
    try ourFile.read()
} catch {
    print("\(error)")
}

// assuming ourFile.read didn't give any errors, we can just access the DBFTable now

let theTableRead: DBFTable = ourFile.getDBFTable()

// we can also retrieve other useful information captured during the read such as DBF file version

let versionRead: UInt8 = ourFile.getVersion() // the version captured during read
let numRecordsRead: Int = ourFile.getNumRecords()! // number of records read
let lastUpdate: Date = ourFile.getLastUpdate()! // the last time the dbf file was updated
