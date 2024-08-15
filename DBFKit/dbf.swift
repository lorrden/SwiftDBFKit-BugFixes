//
//  dbf.swift
//  DBFKit
//
//  Created by Michael Shapiro on 4/29/24.
//

import Foundation

/**
 * For managing DBF errors
 * - Version: 1.0
 * - Since: 1.0
 */
enum DBFError: Error {
    case COLUMN_ADD_ERR(String), ROW_ADD_ERR(String), READ_ERROR(String)
}

/**
 * A DBF table which stores all the data
 * - Version: 1.0
 * - Since: 1.0
 */
class DBFTable {
    
    /**
     * A column data type
     * - Version: 1.0
     * - Since: 1.0
     */
    enum ColumnType: Character {
        /// Represents the column type string
        /// - Version: 1.0
        /// - Since: 1.0
        case STRING = "C"
        /// Represents the column of type date
        /// - Version: 1.0
        /// - Since: 1.0
        case DATE = "D"
        /// Represents the column of type float (double)
        /// - Version: 1.0
        /// - Since: 1.0
        case FLOAT = "F"
        /// Represents the column of type numeric
        /// - Version: 1.0
        /// - Since: 1.0
        case NUMERIC = "N"
        /// Represents the column of type boolean
        /// - Version: 1.0
        /// - Since: 1.0
        case BOOL = "L"
    }
    
    /**
     * We will be using this to manage columns
     * - Version: 1.0
     * - Since: 1.0
     */
    struct DBFColumn {
        /**
         * The column type
         * - Version: 1.0
         * - Since: 1.0
         */
        let columnType: ColumnType
        /**
         * The column name
         * - Version: 1.0
         * - Since: 1.0
         */
        let name: String
        /**
         * The field length. Maximum allowed: 254
         * - Version: 1.0
         * - Since: 1.0
         */
        let count: Int
    }
    
    /**
     * A place to store all the columns
     * - Version: 1.0
     * - Since: 1.0
     */
    private var columns: [DBFColumn] = []
    
    /**
     * Determines if we are allowed to add more columns
     * - Version: 1.0
     * - Since: 1.0
     */
    private var isColumnLocked: Bool = false
    
    /**
     * The rows we are storing
     * - Version: 1.0
     * - Since: 1.0
     */
    private var rows: [[String]] = []
    /**
     * All deleted rows (records) from the dbf file
     * - Version: 1.0
     * - Since: 1.1
     */
    private var deleted_rows: [[String]] = []
    
    /**
     * Locks column adding
     * - Version: 1.0
     * - Since: 1.0
     */
    public func lockColumnAdding() {
        self.isColumnLocked = true
    }
    
    /**
     * Determines if columns can be added. This acts as a simple getter for isColumnLocked
     * - Returns: A boolean indicating if columns can be added
     * - Version: 1.0
     * - Since: 1.0
     */
    public func canAddColumns() -> Bool {
        return self.isColumnLocked
    }
    
    /**
     * Adds a column to the data table. Time complexity: O(1)
     * - Parameters:
     *  - name: Required. The column name to add
     *  - type: Required. The type of data the column conforms to
     *  - len: Required. The field maximum length. Maximum value 254 allowed
     * - Throws: An error if column adding is locked or the column name is not valid
     * - Version: 1.0
     * - Since: 1.0
     */
    public func addColumn(with name: String, dataType type: ColumnType, count len: Int) throws {
        // make sure we are allowed to add columns to the list
        if self.isColumnLocked {
            throw DBFError.COLUMN_ADD_ERR("Cannot add columns to DBF table because column adding is locked")
        }
        // make sure name has at least one valid character in it
        if name.replacingOccurrences(of: " ", with: "") == "" {
            throw DBFError.COLUMN_ADD_ERR("The column name must not be empty and have at least one valid character")
        }
        // make sure len is in proper amount
        if len < 1 || len > 254 {
            throw DBFError.COLUMN_ADD_ERR("Invalid number given for column length. Length should be 1 <= x <= 254 and is \(len)")
        }
        self.columns.append(DBFColumn(columnType: type, name: name, count: len))
    }
    
    /**
     * Adds a row to the DBF table. Time complexity: O(1)
     * - Parameters:
     *  - data: Required. An array of string to add for the data
     * - Throws: An error if the adding column property is not locked or if the number of values in data is not the same as the number of columns
     * - Version: 1.0
     * - Since: 1.0
     */
    public func addRow(with data: [String]) throws {
        // make sure adding columns is locked
        if !self.isColumnLocked {
            throw DBFError.ROW_ADD_ERR("Cannot add rows to the table because adding columns is not locked")
        }
        // make sure the length of data is the same as the number of columns in the table
        if data.count != self.columns.count {
            throw DBFError.ROW_ADD_ERR("Cannot add a row to the table because it does not have the same number of values as the number of columns added in the table. Row value count: \(data.count), Column count: \(self.columns.count)")
        }
        // now add
        self.rows.append(data)
    }
    /**
     * Adds a row to the DBF table. Time complexity: O(1)
     * - Parameters:
     *  - data: Required. An array of string to add for the data
     *  - deleted: Optional. If the row (record) is deleted
     * - Throws: An error if the adding column property is not locked or if the number of values in data is not the same as the number of columns
     * - Version: 1.0
     * - Since: 1.1
     */
    public func addRow(with data: [String], deleted: Bool) throws {
        // make sure adding columns is locked
        if !self.isColumnLocked {
            throw DBFError.ROW_ADD_ERR("Cannot add rows to the table because adding columns is not locked")
        }
        // make sure the length of data is the same as the number of columns in the table
        if data.count != self.columns.count {
            throw DBFError.ROW_ADD_ERR("Cannot add a row to the table because it does not have the same number of values as the number of columns added in the table. Row value count: \(data.count), Column count: \(self.columns.count)")
        }
        // check if record is deleted
        if deleted {
            // add to list of deleted rows
            self.deleted_rows.append(data)
            return
        }
        // now add
        self.rows.append(data)
    }
    
    /**
     * A simple getter for the columns added
     * - Returns: An array of all columns added
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getColumns() -> [DBFColumn] {
        return self.columns
    }
    
    /**
     * A simple getter for the rows
     * - Returns: An array of all rows added
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getRows() -> [[String]] {
        return self.rows
    }
    /**
     * A simple getter for deleted rows (records)
     * - Returns: An array of all rows which were removed from the dbf file
     * - Version: 1.0
     * - Since: 1.1
     */
    public func getDeletedRows() -> [[String]] {
        return self.deleted_rows
    }
    
    /**
     * Gets the total number of bytes the table will take up in the DBF file. Time complexity: O(n) where n is the number of columns
     * - Returns: A number indicating the number of bytes needed to write up the DBF file
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getTotalBytes() -> Int {
        var totalBytes: Int = 31
        // we need to get the number of bytes per record
        // go over each column and multiply each col expected total by the record count
        for i in self.columns {
            // one column already takes up 31 bytes of data
            totalBytes += 31
            totalBytes += i.count * self.rows.count
        }
        // add bytes to include spaces for separating rows
        totalBytes += self.rows.count
        // include another byte for col terminator
        totalBytes += 7
        return totalBytes
    }
    
    /**
     * Gets the total number of bytes the header of the table will take up in the DBF file. Time complexity: O(1)
     * - Returns: An integer representing how many bytes the header takes up
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getTotalBytesHeader() -> Int {
        var totalBytes: Int = 32 * self.columns.count + 1
        totalBytes += 32
        return totalBytes
    }
    
    /**
     * Gets the total number of bytes per record of the table that will take up in the DBF file. Time complexity: O(n) where n is the number of columns
     * - Returns: An integer representing how many bytes all the rows will take up
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getTotalBytesPerField() -> Int {
        var totalBytes: Int = 0
        for i in self.columns {
            totalBytes += i.count
        }
        totalBytes += 1
        totalBytes = totalBytes * self.rows.count
        return totalBytes
    }
    /**
     * Gets the total number of bytes one record takes up in the DBF file. Time complexity: O(n) where n is the number of columns
     * - Returns: An integer representing how many bytes on record (row) will take up
     * - Version: 1.0
     * - Since: 1.1
     */
    public func getTotalBytesOneRecord() -> Int {
        // add up all field count
        var totalBytes: Int = 0
        for i in self.columns {
            totalBytes += i.count
        }
        totalBytes += 1
        return totalBytes
    }
    /**
     * Gets the total number of records (both deleted and not deleted) in the table
     * - Returns: An integer representing how many records there are
     * - Version: 1.0
     * - Since: 1.1
     */
    public func getTotalRecordCount() -> Int {
        return self.rows.count + self.deleted_rows.count
    }
    
    /**
     * Gets the character of how a boolean would appear in the table. This should mainly be used to convert the boolean into a string, to which you want to insert into the row
     * > We use this function when you are trying to insert a boolean value into a particular row index. For instance, if a specific column accepts the value of boolean, you will need to convert your boolean into a string value the DBFTable (and the DBF file ultimately) can interpret. This function does the conversion for you
     * - Returns: A DBF representation of the boolean
     * - Version: 1.0
     * - Since: 1.0
     */
    public static func getBoolValue(bool value: Bool?) -> String {
        if value == nil {
            return "?" // uninitialized
        }
        if value! {
            return "T"
        }
        return "F"
    }
    
    /**
     * This function acts similarlily to getBoolValue, except it does it for the date!
     * - Parameters:
     *  - date: Required. The date to convert into DBF representation
     * - Returns: A DBF representation of the date
     * - Version: 1.0
     * - Since: 1.0
     */
    public static func getDateValue(date: Date) -> String {
        var d: String = ""
        let c: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let y: Int = c.year!
        let m: Int = c.month!
        let dd: Int = c.day!
        let ms: String = (m < 10 ? "0" : "") + String(m)
        let ds: String = (dd < 10 ? "0" : "") + String(dd)
        d += "\(y)\(ms)\(ds)"
        return d
    }
    
    /**
     * Gets the boolean value given a DBF boolean
     * - Parameters:
     *  - dbfValue: Required. The character to convert from DBF file bool
     * - Returns: A boolean or nil (if the dbfValue was uninitialized)
     * - Throws: An error if the character is invalid
     * - Version: 1.0
     * - Since: 1.0
     */
    public static func getBoolFromDBFValue(dbfValue: Character) throws -> Bool? {
        if dbfValue == "?" {
            return nil
        }
        if dbfValue.lowercased() == "t" || dbfValue.lowercased() == "y" {
            return true
        } else if dbfValue.lowercased() == "f" || dbfValue.lowercased() == "n" {
            return false
        }
        throw DBFError.READ_ERROR("Unknown DBF bool value \"\(dbfValue)\" given")
    }
}

/**
 * The core writer class
 * - Version: 1.0
 * - Since: 1.0
 */
class DBFWriter {
    
    /**
     * A dbf table to write from
     * - Version: 1.0
     * - Since: 1.0
     */
    public var dbfTable: DBFTable
    
    /**
     * Initializes the DBFWriter with a given table
     * - Parameters:
     *  - dbfTable: Required. The dbf table that will be written
     * - Version: 1.0
     * - Since: 1.0
     */
    init(dbfTable: DBFTable) {
        self.dbfTable = dbfTable
    }
    
    /**
     * Writes a record to a buffer
     * - Parameters:
     *  - buffer: Required. A pointer to a buffer to write to
     *  - record: The record to write
     * - Throws: An error on failure
     * - Version: 1.0
     * - Since: 1.1
     */
    private func writeBytesRecord(buffer: UnsafeMutablePointer<Data>, record: [String], current_offset: UnsafeMutablePointer<Int>) throws {
        // this function already assumes that the record was already marked with an '*' or ' '
        // all text should also be in ascii
        var zi: Int = 0
        for z in record {
            // make sure z is not larger than the max length allowed for the column
            if z.count > self.dbfTable.getColumns()[zi].count {
                throw DBFError.ROW_ADD_ERR("Row at index \(zi), element \(z) exceeds the maximum length for column")
            }
            for j in z {
                // should be 16 bit
                buffer.pointee.withUnsafeMutableBytes { (bytess: UnsafeMutableRawBufferPointer) in
                    bytess.storeBytes(of: UInt16(j.asciiValue!), toByteOffset: current_offset.pointee, as: UInt16.self)
                }
                current_offset.pointee += 1
            }
            // add spaces until we reach the max length for col
            let space_add: Int = (self.dbfTable.getColumns()[zi].count - z.count)
            var zzi: Int = 0
            while zzi < space_add {
                buffer.pointee.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
                    bytes.storeBytes(of: UInt16(0x0000), toByteOffset: current_offset.pointee, as: UInt16.self)
                }
                current_offset.pointee += 1
                zzi += 1
            }
            zi += 1
        }
    }
    
    /**
     * Writes up the bytes for the dbf data. Time complexity: O((n \* m) + (r \* n \* m)) where n is the number of columns, m is the maximum length of each column, and r is the number of rows
     * - Returns: A buffer
     * - Throws: An error on write
     * - Version: 1.1
     * - Since: 1.0
     */
    private func writeBytes() throws -> Data {
        let header_len: Int = self.dbfTable.getTotalBytesHeader()
        let bytes_len: Int = self.dbfTable.getTotalBytesPerField()
        let one_record_len: Int = self.dbfTable.getTotalBytesOneRecord()
        let buffer_len: Int = header_len + bytes_len + 1
        let num_records: Int = self.dbfTable.getTotalRecordCount()
        var buffer: Data = Data(repeating: 0, count: buffer_len)
        // write up header
        // byte 0 should be dbf version
        buffer[0] = 0x03
        // byte 1-3 should be date of last update
        buffer[1] = UInt8((Calendar.current.component(.year, from: Date())) - 1900)
        buffer[2] = UInt8((Calendar.current.component(.month, from: Date())))
        buffer[3] = UInt8(Calendar.current.component(.day, from: Date()))
        // number of records in the table
        buffer.withUnsafeMutableBytes { (bytess: UnsafeMutableRawBufferPointer) in
            bytess.storeBytes(of: UInt32(num_records.littleEndian), toByteOffset: 4, as: UInt32.self)
        }
        // length of header
        buffer.withUnsafeMutableBytes { (bytess: UnsafeMutableRawBufferPointer) in
            bytess.storeBytes(of: UInt16(header_len.littleEndian), toByteOffset: 8, as: UInt16.self)
        }
        // number of bytes per record
        buffer.withUnsafeMutableBytes { (bytess: UnsafeMutableRawBufferPointer) in
            bytess.storeBytes(of: UInt16(one_record_len.littleEndian), toByteOffset: 10, as: UInt16.self)
        }
        // columns (field descriptors)
        let cols: [DBFTable.DBFColumn] = self.dbfTable.getColumns()
        // loop over all cols and set them up
        var current_offset: Int = 32
        var byteoff: Int = 32
        for i in cols {
            // field name (in ascii)
            // in order to achieve this in ascii, we have to looop over each character and get the ascii char code
            for z in i.name {
                buffer[current_offset] = z.asciiValue!
                // adjust offset as needed
                current_offset += 1
            }
            let byteCont: Int = 11 - i.name.count
            current_offset += byteCont
            // starting from byte 43 (11)
            // field type (also should be in ascii)
            buffer[current_offset] = i.columnType.rawValue.asciiValue!
            // reserved
//            current_offset += 2
            // include max count
            buffer.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
                bytes.storeBytes(of: UInt16(i.count), toByteOffset: current_offset + 5, as: UInt16.self)
            }
            byteoff += 32
            current_offset = byteoff
        }
        // field descriptor array terminator
        buffer[current_offset] = 0x0D
        // now load records
        current_offset += 1
//        buffer[current_offset + 1] = 0x0020
//        current_offset += 2
        for i in self.dbfTable.getRows() {
            // add space to mark row present
            buffer[current_offset] = 0x0020
            current_offset += 1
            try self.writeBytesRecord(buffer: &buffer, record: i, current_offset: &current_offset)
        }
        // add any deleted rows
        for i in self.dbfTable.getDeletedRows() {
            // deleted rows are marked with an '*'
            buffer[current_offset] = 0x2A
            current_offset += 1
            try self.writeBytesRecord(buffer: &buffer, record: i, current_offset: &current_offset)
        }
        // eof flag
        buffer[current_offset] = 0x1A
        return buffer
    }
    
    /**
     * Writes to a given DBF file.
     * - Parameters:
     *  - file: Required. A URL to the file to write the DBF data to
     * - Throws: An error on write
     * - Version: 1.0
     * - Since: 1.0
     */
    public func write(to file: URL) throws {
        // get bytes
        let buffer: Data = try self.writeBytes()
        // write to url
        try buffer.write(to: file)
    }
}

// MARK: DBF READER

/**
 * A simple DBF file
 * - Version: 1.0
 * - Since: 1.0
 */
class DBFFile {
    
    // we will reserve a few variables blank (nil) until the file has been actually read
    
    /**
     * The DBF version being used. This automatically defaults to 3
     * - Version: 1.0
     * - Since: 1.0
     */
    private var dbfVersion: UInt8 = 0x03
    /**
     * Date of last update
     * - Version: 1.0
     * - Since: 1.0
     */
    private var lastUpdate: Date?
    /**
     * Our DBF table
     * - Version: 1.0
     * - Since: 1.0
     */
    private var dbfTable: DBFTable
    /**
     * A path to the DBF file
     * - Version: 1.0
     * - Since: 1.0
     */
    private var filePath: String?
    
    /**
     * The number of records read
     * - Version: 1.0
     * - Since: 1.0
     */
    private var numRecords: Int?
    
    /**
     * This will initialize the DBF File with an empty DBF Table
     * - Parameters:
     *  - path: Required. The path to the DBF file
     * - Version: 1.0
     * - Since: 1.0
     */
    init(path: String) {
        // initialize empty table
        self.filePath = path
        self.dbfTable = DBFTable()
    }
    
    /**
     * This will initialize the DBF File with a given table
     *
     *> Warning! This constructor will **not** allow you read a file. It is here for future development purposes
     * - Parameters:
     *  - dbf: Optional. A custom table to pass in
     * - Version: 1.0
     * - Since: 1.0
     */
    init(dataTable dbf: DBFTable) {
        self.dbfTable = dbf
    }
    
    /**
     * A simple getter for the DBF table
     * - Returns: The DBF table read
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getDBFTable() -> DBFTable {
        return self.dbfTable
    }
    
    /**
     * Gets the date of the last update made
     * - Returns: The date of the last update or nil if no dbf file was opened
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getLastUpdate() -> Date? {
        return self.lastUpdate
    }
    
    /**
     * Gets the version of the DBF file
     * - Returns: The version of the DBF file read
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getVersion() -> UInt8 {
        return self.dbfVersion
    }
    
    /**
     * Gets the number of records read
     * - Returns: The number of records read
     * - Version: 1.0
     * - Since: 1.0
     */
    public func getNumRecords() -> Int? {
        return self.numRecords
    }
    
    /**
     * Reads the DBF file given. Time complexity: O((n \* m) + r) where n is the number of columns written, m is the length of each column name, and r is the number of rows
     * - Throws: An error on read
     * - Version: 1.1
     * - Since: 1.0
     */
    public func read() throws {
        // make sure we have a valid path given
        if self.filePath == nil {
            throw DBFError.READ_ERROR("Cannot read DBF file because path is nil")
        }
        // also make sure path given is valid url
        if URL(string: self.filePath!) == nil {
            throw DBFError.READ_ERROR("Invalid file path given: \(self.filePath!)")
        }
        // open the file
//        let buffer: Data = try Data(contentsOf: URL(string: self.filePath!)!)
        let buffer: Data = try Data(contentsOf: URL(filePath: self.filePath!))
        // byte 0 should be version
        let version: UInt8 = buffer[0]
        self.dbfVersion = version
        // next three bytes should be date of last update
        let yearUpdate: Int = Int(buffer[1]) + 1900
        let monthUpdate: Int = Int(buffer[2])
        let dayUpdate: Int = Int(buffer[3])
        var dateComp: DateComponents = DateComponents()
        dateComp.year = yearUpdate
        dateComp.month = monthUpdate
        dateComp.day = dayUpdate
        self.lastUpdate = Calendar(identifier: .gregorian).date(from: dateComp)
        
        // next should be number of records
        let rec: Int = Int(buffer[4])
        self.numRecords = rec
        
        // use byte 10 for future comparison
        let one_record_bytes: Int = Int(buffer[10])
        
        // it is perfectly safe to skip to byte 32 where the col info begins
        // keep on collecting col info until the terminator is reached
        var current_byte: Int = 32
        var bytec: Int = 32
        var expected_record_count: Int = 1
        while buffer[current_byte] != 0x0D {
            // byte 0-10 is field name (32-42)
            var field_name: String = ""
            let maxFieldNameLen: Int = 11
            // keep on collected field name until 0x00 (space) is reached
            while buffer[current_byte] != 0x00 {
                field_name += String(UnicodeScalar(buffer[current_byte]))
                current_byte += 1
            }
            let toType: Int = maxFieldNameLen - field_name.count
            // next is field type
//            let field_type: Character = Character(UnicodeScalar(buffer[43]))
            let field_type: Character = Character(UnicodeScalar(buffer[current_byte + toType]))
            // make sure character is valid
            if DBFTable.ColumnType.init(rawValue: field_type) == nil {
                throw DBFError.READ_ERROR("Unknown DBF data type \(field_type). Please make sure it is supported")
            }
//            let byteLenStart: Int = 16
            // get field length
            let field_len = buffer[current_byte + toType + 5]
            expected_record_count += Int(field_len)
            // we don't need anymore data than this
            try self.dbfTable.addColumn(with: field_name, dataType: .init(rawValue: field_type)!, count: Int(field_len))
            bytec += 32
            current_byte = bytec
        }
        // make sure expected record count matches what was written earlier
        if expected_record_count != one_record_bytes {
            throw DBFError.READ_ERROR("Byte 10 in dbf file (number of records in one byte) does not match total number of bytes accross all fields")
        }
        // lock column add
        self.dbfTable.lockColumnAdding()
        // terminator reached, read records
        current_byte += 1
//        current_byte += 2
        var collect: String = "" // for storing data we pick up
        var values_collected: [String] = [] // for storing our collected values
        var col_index: Int = 0 // for storing what index of the column we are at
        var record_deleted: Bool = false
        while buffer[current_byte] != 0x1A {
            if values_collected.count == 0 && collect.count == 0 && buffer[current_byte] == 0x2A {
                // record deleted
                record_deleted = true
                current_byte += 1
            } else if values_collected.count == 0 && collect.count == 0 && buffer[current_byte] == 0x0020 {
                // record not deleted
                current_byte += 1
            } else if values_collected.count == 0 && collect.count == 0 {
                // strange character
                throw DBFError.READ_ERROR("Can't assert if the record is deleted")
            }
            // collect values as we pick them up
            collect += String(UnicodeScalar(buffer[current_byte]))
            current_byte += 1
            // check of collect has touched max length
            if collect.count == self.dbfTable.getColumns()[col_index].count {
                // touched
                values_collected.append(collect)
                collect = ""
                col_index += 1
                // make sure col index is still valid
                if col_index >= self.dbfTable.getColumns().count {
                    // add row
                    try self.dbfTable.addRow(with: values_collected, deleted: record_deleted)
                    record_deleted = false // reset as necessary
                    // if we have reached the record count, break out of the loop
                    if self.dbfTable.getRows().count == rec {
                        break
                    }
                    col_index = 0 // reset col index
                    // expect eof marker
                    if current_byte >= buffer.count {
                        break
                    }
                    // reset values collected
                    values_collected = []
                }
            }
        }
        // we read all data by this point
    }
}
