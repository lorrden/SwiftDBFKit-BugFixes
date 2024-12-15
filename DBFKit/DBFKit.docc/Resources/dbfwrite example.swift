//
//  dbfwrite example.swift
//  
//
//  Created by Michael Shapiro on 5/1/24.
//

import Foundation
import DBFKit

let ourTable: DBFTable = DBFTable() // we will assume that this table already has some columns and rows in it for simplicity

// initialize the DBFWriter class with our table

let ourWriter: DBFWriter = DBFWriter(dbfTable: ourTable)

// from here, there is only one step left to complete
// we execute the write function

do {
    // try to write to our path
    try ourWriter.write(to: URL(fileURLWithPath: "path/to/our/dbf/file.dbf")!)
    
    for i in ourTable.getColumns() {
        if i.columnType == .MEMO {
            try ourWriter.writeDBT(to: URL(filePath: "path/to/our/dbt.dbt")) // for specifically writing DBT files if a memo field is present
            break
        }
    }
} catch {
    print("\(error)")
}
