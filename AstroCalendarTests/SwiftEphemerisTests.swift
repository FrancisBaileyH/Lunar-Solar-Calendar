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
//  SwiftEphemerisTests.swift
//  AstroCalendar
//
//  Created by CIS-Mac-16 on 2015-03-22.
//  Copyright (c) 2015 CIS-Mac-16. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         25/03/2015      Added in eclipse and riseSetTransit tests
//  Francis         07/04/2015      Changed handling of testGetEclipse function


import Foundation
import XCTest


class SwiftEphemerisTests : XCTestCase {
   
    
    let se = SwiftEphemeris()
    var date = NSDateComponents()
    var date2 = NSDateComponents()
    var date3 = NSDateComponents()
    let solEclipse = NSDateComponents()
    
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
        
        self.solEclipse.year = 2013
        self.solEclipse.month = 3
        self.solEclipse.day = 20
        self.solEclipse.hour = 0
        self.solEclipse.minute = 0
        self.solEclipse.second = 0

    
    }

    
    /* 
     * Test that lunar phase is within correct precision for sampel dates
    */
    func testGetPhase()
    {
        let phase = se.getEntityPhase(SE_MOON, utcDate: date) * 100 // get percent value
        let phase2 = se.getEntityPhase(SE_MOON, utcDate: date2) * 100 // get percent value
        let phase3 = se.getEntityPhase(SE_MOON, utcDate: date3) * 100 // get percent value
        
        XCTAssertEqualWithAccuracy(phase, 99.6, 0.5, "Phase is within precision.")
        XCTAssertEqualWithAccuracy(phase2, 0.5, 0.5, "Phase is within precision.")
        XCTAssertEqualWithAccuracy(phase3, 100, 0.5, "Phase is within precision.")
    }
    
    /* 
     * Test moonrise returns no nil when no moon rise found
    */
    func testGetSunSetSunriseTransit()
    {
        self.date.hour += 7
        let rise1 = se.getEntityRiseSetTransitTime(SE_MOON, movement: SE_CALC_RISE, gps: self.loc2, utcDate: self.date)!
        
        let actualRise = NSDateComponents()
        actualRise.year = 1995
        actualRise.month = 4
        actualRise.day = 17
        actualRise.hour = 3
        actualRise.minute = 36
        actualRise.second = 49
        
        XCTAssertEqual(actualRise.day, rise1.day, "Test that no moonrise returns previous date")
    }
    
    
    /*
     * Test that eclipse returned is the correct date
    */
    func testCheckEclipse()
    {
        let eclipse = se.findNextEclipse(SE_MOON, utcDate: self.solEclipse, gps: self.loc2)
        
        
        let maxEclipseTime = eclipse?.viewingStages[0] // retrieve first viewing time
        maxEclipseTime?.hour -= 7 //manually subtract GMT
        
        
        XCTAssertNil(maxEclipseTime, "Testing lunar eclipse time")
        
    }
    
    
    
    
    
    
}
