// Copyright © 2015 Okanagan College
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



//
//  CalendarTests.swift
//  AstroCalendar
//
//  Created by Francis Bailey on 2015-04-07.
//  Copyright (c) 2015 Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//


import Foundation
import XCTest


class MockDB : ReadableRepository {
    
    func query( query : String, parameters : [AnyObject]? ) -> [ReadableRepositoryRow] {
        
        let mRow = MockRow()
        println(parameters)
        if let city: AnyObject = parameters?[0] {
            if String(city as! NSString) == "london" {
                mRow["TimeZone"] = MockColumn(value: "Europe/London")
                mRow["City"] = MockColumn(value: "london")
                mRow["Lon"] = MockColumn(value: "-0.127758")
                mRow["Lat"] = MockColumn(value: "51.50735")
                mRow["Elev"] = MockColumn(value: "21")
            }
        }
        
        return [ mRow ]
        
    }
    
    required init( filename : String, gid : String ) {
        
    }
}

@objc class MockRow : ReadableRepositoryRow {
    
    @objc var data = Dictionary<String, ReadableRepositoryCol>()
    
    @objc subscript(key: String) -> ReadableRepositoryCol? {
        get {
            return data[key]
        }
        
        set(newVal) {
            data[key] = newVal
        }
    }
    
    @objc func description()->String {
        return data.description
    }
}
    

@objc class MockColumn : ReadableRepositoryCol {
    
    var value : String
    
    init(value: String)
    {
        self.value = value
    }
    
    @objc func asString()->String {
        return value
    }
    
    @objc func asInt()->Int {
        return 0
    }
    
    @objc func asDouble()->Double {
        return 0.0
    }
    
    @objc func asData()->NSData? {
        return nil
    }
    
    @objc func asDate()->NSDate? {
        return nil
    }
    
    @objc func description()->String {
        return ""
    }
}


class LocationTimeZoneManagerTests: XCTestCase {

    
    let lm = LocationTimeZoneManager(locationRepo: MockDB(filename: "none", gid: "none"))
    
    
    let city1 = "london"
    let city2 = "nowhere"

   
    /*
     * Assert that for non existent database values a nil value is returned
    */
    func testGetTimeZoneFromCity() {
        
        XCTAssertNotNil(lm.getTimeZoneFromCity(city1), "Check that timezone is returned for london")
        XCTAssertNil(lm.getTimeZoneFromCity(city2), "Check that timezone for nowhere returns nil")
    }
    
    
    func testGetGPSFromCity() {
        AssertNil(lm.getGPSFromCityName(city2), message: "Check that nil is returned for a non existent city")
    }
    
    
    /*
     * This function allows us to perform nil assertions on structs
    */
    func AssertNil<T>(@autoclosure expression:  () -> T?, message: String = "",
        file: String = __FILE__, line: UInt = __LINE__) {
            
            XCTAssert(expression() == nil, message, file:file, line:line);
    }
    
    
    

}
