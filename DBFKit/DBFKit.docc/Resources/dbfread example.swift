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
    
    // you can also read any memo fields by converting their strings read into ints
    for i in ourFile.getDBFTable().getColumns() {
        if i.columnType == .MEMO {
            let memo_data: String = try ourFile.readMemo(file: URL(filePath: "path/to/dbt.dbt"), index: Int(ourFile.getDBFTable().getRows()[0][0])!) // assuming col 0 is memo field
        }
    }
} catch {
    print("\(error)")
}

// assuming ourFile.read didn't give any errors, we can just access the DBFTable now

let theTableRead: DBFTable = ourFile.getDBFTable()

// we can also retrieve other useful information captured during the read such as DBF file version

let versionRead: UInt8 = ourFile.getVersion() // the version captured during read
let numRecordsRead: Int = ourFile.getNumRecords()! // number of records read
let lastUpdate: Date = ourFile.getLastUpdate()! // the last time the dbf file was updated
