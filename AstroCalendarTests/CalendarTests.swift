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
//  Created by Francis Bailey on 2015-03-24.
//  Copyright (c) 2015 Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         25/03/2015      Added in toTimeZone test


import Foundation
import XCTest

class CalendarTests: XCTestCase {
    

    //let cal = Calendar()
    var date = NSDateComponents()
    var date2 = NSDateComponents()
    var date3 = NSDateComponents()
    let date4 = NSDateComponents()
    
    
    
    
    let tz1 = NSTimeZone(name: "America/Vancouver")
    let tz2 = NSTimeZone(name: "Europe/London")
    let tz3 = NSTimeZone(name: "America/Regina")
    
    
    var loc = Location(city: "london", lon: -0.126236, lat: 51.500152, elevation: 25) // London, UK
    var loc2 = Location(city: "kelowna", lon: -119.443606, lat: 49.880134, elevation: 355) // Kelowna, BC
    var loc3 = Location(city: "windhoek", lon: 17.0832300, lat: -22.5594100, elevation: 1700) // Windhoek Namibia
    
    
    override func setUp() {
        self.date.year = 1995
        self.date.month = 4
        self.date.day = 16
        self.date.hour = 0
        self.date.minute = 0
        self.date.second = 0
        
        self.date2.year = 2015
        self.date2.month = 7
        self.date2.day = 16
        self.date2.hour = 0
        self.date2.minute = 0
        self.date2.second = 0
        
        self.date3.year = 2001
        self.date3.month = 1
        self.date3.day = 10
        self.date3.hour = 0
        self.date3.minute = 0
        self.date3.second = 0
        
        self.date4.year = 2001
        self.date4.month = 1
        self.date4.day = 10
        self.date4.hour = 0
        self.date4.minute = 0
        self.date4.second = 0

        
    }
    
    /* 
     * Test conversion from local to utc with one date using DST and one not in Kelowna, Canada
    */
    func testToTimeZone() {
        let cal = Calendar(zone: self.tz1!,  gps: self.loc2 )
        
        let testUTCTime = NSDateComponents()
        testUTCTime.year = 2015
        testUTCTime.month = 7
        testUTCTime.day = 16
        testUTCTime.hour = 7
        testUTCTime.minute = 0
        testUTCTime.second = 0
        
        var tmpUTC = cal.toTimeZone(self.date2, toLocal: false)
        XCTAssertEqual(testUTCTime, tmpUTC, "Test conversion from local to UTC")
        
        var tmpLocal = cal.toTimeZone(tmpUTC, toLocal: true)
        XCTAssertEqual(tmpLocal, self.date2, "Test conversion from UTC to local")
       
        testUTCTime.hour = 8 // difference should now be 8 hours with no DST
        testUTCTime.month = 2
        self.date2.month = 2
        
        tmpUTC = cal.toTimeZone(self.date2, toLocal: false)
        XCTAssertEqual(testUTCTime, tmpUTC, "Test conversion from local to UTC w/out  DST")
        
        tmpLocal = cal.toTimeZone(tmpUTC, toLocal: true)
        XCTAssertEqual(tmpLocal, self.date2, "Test conversion from UTC to local w/out DST")
    }
    
   
}