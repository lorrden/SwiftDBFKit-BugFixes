#  DBFKit

## About DBFKit
DBFKit is a very easy way to read and write DBF files. It has been implemented completely in Swift, and should work with most modern iOS and MacOS versions.

I decided to make this framework because I was working on a software (obviously I was using Swift to build an application) and I needed to be able to export DBF files. Since there is no framework or library written in Swift that achieves this, I built one.

DBFKit should work with any DBF version (such as FoxPro and dBase III) for both reading and writing. I used the famous python framework [dbfread](https://github.com/olemb/dbfread) to make sure all values can be properly read. Along with the reading capabilities of DBFKit I implemented on my own, I tested it with dbfread to make sure I get the same results.

## Table of Contents

- Installation
- How to use
- Research
- Time Complexity
- License

---

## Installation
### DBFKit - 1.2

To install, download the single "dbf.swift" file and include that in your application to use DBFKit related functions.

DBFKit is designed to work on both MacOS and iOS (any version should work, but later ones are reccomended)

## How to use

I have designed the API to be very easy to use. I will give a demonstration of how to use it here, but for more tutorials on the API, see the "Tutorial" folder.

### The DBFTable

Note that DBF files basically carry databases. These databases have tables which consist of columns and rows. So you will first need to make a table for writing.

```swift
import Foundation

// in order to write to DBF files, you must have a DBF table ready
// little note, when we write/read from DBF files, we are working with tables, dbf files are literally a database!

let table: DBFTable = DBFTable()

// now we start adding columns
// we must do it in a do-catch block as errors can occur on adding columns

do {
    // add column
    try table.addColumn(with: "user", dataType: .STRING, count: 10)
    try table.addColumn(with: "role", dataType: .STRING, count: 20)
    try table.addColumn(with: "password", dataType: .STRING, count: 20)
    
    // once we are done adding columns, we should lock column adding
    table.lockColumnAdding()
    
    // to add rows, we use the addRow function
    // this can also throw errors, so we need to execute it also in a do-catch block
    
    try table.addRow(with: ["John", "admin", "pass"])
    try table.addRow(with: ["Doe", "coordinator", "pass2"])
    try table.addRow(with: ["Anna", "normal_user", "pass3"])
    
    // you can also include deleted rows by adding on the deleted attribute
    try table.addRow(with: ["Old", "normal_user", "pass4"], deleted: true) // marks record as deleted
} catch {
    print("\(error)")
}
```

### Writing

We can use the **DBFWriter** class for easy writing.

```swift

// assume we have already set up the table "variable" from the previous example

let writer: DBFWriter = DBFWriter(dbfTable: table) // we pass in the table we made

// there is only one step left to do, call the write function!
// this can throw errors, so we must execute it in a do-catch block

do {
    try writer.write(to: URL(filePath: "path/to/file.dbf")!)
} catch {
    print("\(error)")
}
```
 ### Reading
 
 We can use the DBFFile class for reading dbf files.
 
 ```swift
 let reader: DBFFile = DBFFile(path: "path/to/file.dbf")
 
 // we need to call the read function to read the file
 // this must be done in a do-catch block
 
do {
    try reader.read() // easy!
    
    // now we can derive the data read by calling the getter to get the table
    
    let theTableRead: DBFTable = reader.getDBFTable()
    print(theTableRead.getColumns())
    print(theTableRead.getRows())
} catch {
    print("\(error)")
}
 ```
 
 ### Reading & Writing with Memo Fields
 
 If you are reading or writing a DBF and at least one Memo field is present, make sure you follow the example below, as it highlights how to do it properly.
 
 ```swift
let table: DBFTable = DBFTable()

// assume we have added some columns, and one of them is of type memo

do {
    // write the file like you normal would
    let writer: DBFWriter = DBFWriter(dbfTable: table)
    
    try writer.write(to: URL(filePath: "path/to/file.dbf")!)
    
    // DBFKit doesn't automatically write to the DBT file for memo fields
    // you have to execute that yourself
    
    try writer.writeDBT(to URL(filePath: "path/to/memo_file.dbt")!)
    
    // for reading memo fields, do the following
    let reader: DBFFile = DBFFile(path: "path/to/file.dbf")
    
    try reader.read()
    
    let index_of_memo: Int = Int(reader.getDBFTable().getRows()[0][0])! // we will assume first column is a memo field
    // all memo fields carry an index of where the actual memo data is stored in the dbt file
    // we just need to extract it using the method below
    
    let memo_data: String = reader.readMemo(file: URL(filePath: "path/to/memo_file.dbt")!, index: index_of_memo)
    print(memo_data)
} catch {
    print("\(error)")
}
 ```

## Research

Below are the sources I used to help me implement this.

- https://en.wikipedia.org/wiki/.dbf (contains info about DBF file structure)
- https://www.dbase.com/Knowledgebase/INT/db7_file_fmt.htm (more info on DBF file structure on official dBase website)
- http://www.dbase.com/help/Design_Tables/IDH_TABLEDES_FIELD_TYPES.htm (more info about the different field types)
- https://www.clicketyclick.dk/databases/xbase/format/dbt.html#DBT_STRUCT (DBT file structure info)

Along with this, I have included the "Developer" folder which showed the process of how I reversed engineered this, and how DBF files are actually written. 

## Time Complexity

I would like discuss the time complexity operations of DBFKit.

### Time Complexity for Writing

Let _n_ be the number of columns in the DBFTable, _m_ be the length of each column, and _r_ be the number of rows in the DBFTable.

The time complexity for writing to a DBF file given a DBFTable is expected to be **O((n \* m) + (r \* n \* m))**.

### Time Complexity for Reading

Let _n_ be the number of columns written in the DBF file, _m_ be the maximum length of each column, and _r_ be the number of rows written.

The time complexity for reading from a given DBF file is expected to be **O((n \* m) + r)**

Generally speaking, DBFKit goes quite fast.

## License

DBFKit is open source! You are free to use it, distribute it, and or modify it. I have licensed this project under MIT (see LICENSE file).
