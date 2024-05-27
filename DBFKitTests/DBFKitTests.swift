//
//  DBFKitTests.swift
//  DBFKitTests
//
//  Created by Michael Shapiro on 4/29/24.
//

import XCTest
@testable import DBFKit

final class DBFKitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    /**
     * Tests to make sure the TH Export dbf file can be read
     */
    func testReadThExport() {
        // make sure we stop on the test case that failed and don't continue
        self.continueAfterFailure = false
        
        // set up file
        let dbf: DBFFile = DBFFile(path: Bundle(for: type(of: self)).path(forResource: "thexport", ofType: "dbf")!)
        
        // read data
        do {
            try dbf.read()
        } catch {
            print("\(error)")
            XCTAssertTrue(false) // to stop test case
        }
        
        // check basic data
        // we should have 14 columns of data
        XCTAssertTrue(dbf.getDBFTable().getColumns().count == 15)
        // we should have one record
        XCTAssertTrue(dbf.getDBFTable().getRows().count == 1)
    }
    
    /**
     * Tests to make sure the TS Export dbf file can be read
     */
    func testReadTsExport() {
        self.continueAfterFailure = false
        
        let dbf: DBFFile = DBFFile(path: Bundle(for: type(of: self)).path(forResource: "tsexport", ofType: "dbf")!)
        
        do {
            try dbf.read()
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
        
        XCTAssertTrue(dbf.getDBFTable().getColumns().count == 13)
        XCTAssertTrue(dbf.getDBFTable().getRows().count == 1)
    }
    
    /**
     * Tests to make sure the TD Export dbf file can be read
     */
    func testReadTdExport() {
        self.continueAfterFailure = false
        
        let dbf: DBFFile = DBFFile(path: Bundle(for: type(of: self)).path(forResource: "tdexport", ofType: "dbf")!)
        
        do {
            try dbf.read()
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
        
        XCTAssertTrue(dbf.getDBFTable().getColumns().count == 9)
        XCTAssertTrue(dbf.getDBFTable().getRows().count == 6)
    }
    
    /**
     * For testing writing to DBF
     */
    func testWriteDBF() {
        self.continueAfterFailure = false
        
        // make our dbf table
        let dbfTable: DBFTable = DBFTable()
        
        // add some random info
        do {
            try dbfTable.addColumn(with: "something", dataType: .STRING, count: 2)
            try dbfTable.addColumn(with: "anotherCol", dataType: .STRING, count: 4)
            dbfTable.lockColumnAdding()
            try dbfTable.addRow(with: ["gg", "gg"]) // we test for row adding when it matches up to full col length and when it doesn't
            
            // init writer
            let writer: DBFWriter = DBFWriter(dbfTable: dbfTable)
            
            // write
            try writer.write(to: Bundle(for: type(of: self)).url(forResource: "writeme", withExtension: "dbf")!)
            
            // we can now use our reader to confirm that the result succeeded
            let reader: DBFFile = DBFFile(path: Bundle(for: type(of: self)).path(forResource: "writeme", ofType: "dbf")!)
            try reader.read()
            
            XCTAssertTrue(reader.getDBFTable().getColumns().count == 2)
            XCTAssertTrue(reader.getDBFTable().getRows()[0][0] == "gg")
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
        
        // success
    }
    
    /**
     * Another test for writing DBF files
     */
    func testWriteDBF2() {
        self.continueAfterFailure = false
        
        let dbfTable: DBFTable = DBFTable()
        
        do {
            try dbfTable.addColumn(with: "something", dataType: .STRING, count: 2)
            try dbfTable.addColumn(with: "num", dataType: .NUMERIC, count: 1)
            try dbfTable.addColumn(with: "else", dataType: .STRING, count: 3)
            
            dbfTable.lockColumnAdding()
            
            try dbfTable.addRow(with: ["gg", "1", "gg"])
            try dbfTable.addRow(with: ["rg", "2", "rg"])
            
            let writer: DBFWriter = DBFWriter(dbfTable: dbfTable)
            
            try writer.write(to: Bundle(for: type(of: self)).url(forResource: "writeme", withExtension: "dbf")!)
            
            let reader: DBFFile = DBFFile(path: Bundle(for: type(of: self)).path(forResource: "writeme", ofType: "dbf")!)
            
            try reader.read()
            
            XCTAssertTrue(reader.getDBFTable().getColumns().count == 3)
            XCTAssertTrue(reader.getNumRecords() == 2)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
    }
}
