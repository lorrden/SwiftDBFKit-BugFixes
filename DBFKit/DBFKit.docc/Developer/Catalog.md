#  DBFKit Function & Class Catalog

In this section, you will find a simplified version of everything in the Tutorial folder. Note that this only shows all the functions and classes DBFKit has. For more examples of usage, see the Tutorial folder

## DBFTable (Class)

This is probably one of the most important classes there are for DBFKit. This is how you will make your table for both reading and writing. The class has the following data (note that all private functions are for internal use only)

- init (empty constructor)
- ColumnType (enum)
- DBFColumn (struct)
- columns (private, array of DBFColumn)
- isColumnLocked (private, bool)
- rows (private, an array of an array of strings)
- lockColumnAdding (public function)
- canAddColumns (public function)
- addColumn (public function)
- addRow (public function)
- addRow (public function, overloaded with 'deleted' parameter to signal a row (record) as deleted)
- getColumns (public function)
- getRows (public function)
- getDeletedRows (public function)
- getTotalBytes (public function)
- getTotalBytesHeader (public function)
- getTotalBytesPerField (public function)
- getBoolValue (public static function)
- getDateValue (public static function)
- getBoolFromDBFValue (public static function)
- convertToTimestamp (public static function)
- convertTimestampToDate (public static function)
- DATE\_COUNT (public static variable)
- BOOL\_COUNT (public static variable)
- MEMO\_COUNT (public static variable)
- LONG\_COUNT (public static variable)
- DOUBLE\_COUNT (public static variable)
- TIMESTAMP\_COUNT (public static variable)

### Sample Usage of Each Method

```swift
import Foundation
import DBFKit

let theTable: DBFTable = DBFTable() // empty constructor

// the ColumnType enum has four different types of column types we can use for column usage.
// listed below are the different types of columns supported

let colType1 = theTable.ColumnType.STRING // for string (Character DBF type) column type
let colType2 = theTable.ColumnType.DATE // date (Date DBF type) column type
let colType3 = theTable.ColumnType.FLOAT // float (Float DBF type) column type
let colType4 = theTable.ColumnType.NUMERIC // number (Numeric DBF type) column type
let colType5 = theTable.ColumnType.BOOL // boolean (Logical DBF type) column type
let colType6 = theTable.ColumnType.MEMO // memo column type
let colType7 = theTable.ColumnType.OLE // OLE column type
let colType8 = theTable.ColumnType.BINARY // binary column type
let colType9 = theTable.ColumnType.LONG // long column type
let colType10 = theTable.ColumnType.AUTOINCREMENT // autoincrement column type
let colType11 = theTable.ColumnType.DOUBLE // double column type

// the DBFTable.DBFColumn struct has the following data attached:
// note that the "count" parameter in DBFColumn dictates the maximum data length allowed for a particular element in a row

let exampleColumnStruct: DBFTable.DBFColumn = DBFTable.DBFColumn(columnType: .STRING, name: "example name", count: 10)

// we add columns as follows

do {
    // since errors could occur on adding columns and rows, we have to wrap it all in a do-catch
    try theTable.addColumn(with: "example name", dataType: .STRING, count: 10)

    // once we are done adding columns, we must lock column adding
    theTable.lockColumnAdding()
    
    // now we can add rows
    theTable.addRow(with: ["some data"])
} catch {
    print("\(error)")
}

// getTotalBytes is a function used internally by DBFKit, but this simply gets the number of bytes the table will take up in the actual DBF file
// the same goes for getTotalBytesHeader and getTotalBytesPerField
// getBoolValue should be used when your column type is of type BOOL
// since we can only insert strings into rows using the addRow function, getBoolValue helps convert your bool into a string the DBFReader/Writer can interpret
// getDateValue acts similarlily to getBoolValue, but is meant for dates obviously!
// getBoolValue is supposed to be able to take the DBF value and return the boolean representation of it
// likewise convertToTimestamp converts a given date to a dbf string which DBFKit can write 
// convertTimestampToDate converts out of whatever convertToTimestamp makes
```

## DBFWriter (Class)

This is what's used to write the DBF files. It has a few key properties worth mentioning

- init (dbfTable, accepts a DBFTable)
- dbfTable (public var, DBFTable type)
- writeBytes (private (for internal use) function)
- write (public function)
- encryption\_flag (public variable)
- dbt\_data (private variable)
- dbf\_next\_block\_index (private variable)
- initDBT (private function)
- deinitDBT (private function)
- writeBytesDBT (string, accepts any string) (private function)
- writeDBT (public function)

```swift
import Foundation
import DBFKit

// this is easy to use
let theTable: DBFTable = DBFTable()

let writer: DBFWriter = DBFWriter(dbfTable: theTable)

// we can always access and change the table via the dbfTable variable

theTable.dbfTable = theTable // for easy changing

do {
    // we must do the writing in a do-catch block to catch errors
    try writer.write(to: URL(fileURLWithPath: "insert/path/here/dbf")!)

    // if you have any memo fields, you should write to the DBT file
    try writer.writeDBT(to: URL(fileURLWithPath: "path/to/dbt.dbt")!) // once again ONLY execute this if you have a ColumnType.MEMO present in your DBFTable
} catch {
    print("\(error)")
}
```

## DBFFile (Class)

The last important class. This class is mainly used for reading DBF files. It contains the properties

- init (path, accepts a string which should indicate the path to the dbf file)
- init (dbfTable, accepts a DBFTable. This has no functionality at the moment, but in future version there will be functionality present for accepting a DBFTable as an argument)
- dbfVersion (private variable, the dbf file version read from)
- lastUpdate (private variable, date of last update for DBF file)
- dbfTable (private variable, the dbf table stored from reading)
- filePath (private variable, the path to the dbf file)
- numRecords (private variable, number of records read)
- getDBFTable (public function, a getter for dbfTable)
- getLastUpdate (public function, a getter for lastUpdate)
- getVersion (public function, a getter for dbfVersion)
- getNumRecords (public function, a getter for numRecords)
- read (public function, reads the dbf file given a path)
- is\_encrypted (public variable, determines if the dbf file read has the encryption flag present)
- incomplete\_transaction (public variable, determines if the dbf file read has an incomplete transaction flag present)
- readMemo (public function)

```swift
import Foundation
import DBFKit

let reader: DBFFile = DBFFile(path: "path/to/file.dbf")

// read file in do-catch to avoid errors

do {
    try reader.read()

    let tableRead: DBFTable = reader.getDBFTable() // the DBF table read from the file
    let recordsRead: Int = reader.getNumRecords()! // num records (rows) read
    let lastUpdate: Date = reader.getLastUpdate()! // date of last update
    let version: UInt8 = reader.getVersion() // version of dbf file read

    // if you have any memo fields to read, execute the following
    let memo_data: String = reader.readMemo(dbt: URL(filePath: "path/to/dbt.dbt"), index: 1)
} catch {
    print("\(error)")
}
```
