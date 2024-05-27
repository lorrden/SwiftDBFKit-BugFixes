//
//  dbftable example.swift
//  
//
//  Created by Michael Shapiro on 5/1/24.
//

import Foundation
import DBFKit // we should import this to use it

// we should make our table with DBFTable

let ourDBFTable: DBFTable = DBFTable()

// that's it! we initialized the table!

// for adding columns we must wrap it around a do-catch as any error could occur on add

do {
    // you can use the following ColumnType enumerations when adding your column
    // NUMERIC, STRING, FLOAT, DATE, BOOL
    try ourDBFTable.addColumn(with: "id", dataType: .NUMERIC, count: 1) // we make a column with the name "id", and a data type of number. We are saying here how our numbers should take at most 1 byte
    try ourDBFTable.addColumn(with: "student", dataType: .STRING, count: 10) // we make another column with the name "student", a data type of string, and a maximum data length of 10
    try ourDBFTable.addColumn(with: "grade", dataType: .STRING, count: 2) // we make another column with the name "grade", a data type of string, and a maximum data length of 2
    
    // once we are done adding columns, we must signal the table to lock column adding to enable adding rows
    ourDBFTable.lockColumnAdding()
    
    // now we can add rows in the same way we added the columns
    try ourDBFTable.addRow(with: ["1", "Dave", "A"]) // we added a row with the values given to the side
    try ourDBFTable.addRow(with: ["2", "Anna", "A"])
    try ourDBFTable.addRow(with: ["3", "Levy", "B+"])
    try ourDBFTable.addRow(with: ["4", "Josh", "C-"])
} catch {
    print("\(error)")
}

let ourColumnsAdded: [DBFTable.DBFColumn] = ourDBFTable.getColumns() // this gets all the columns added
let ourRowsAdded: [[String]] = ourDBFTable.getRows() // this gets all the rows added
