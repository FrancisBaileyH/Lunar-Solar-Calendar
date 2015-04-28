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
//  Calendar.swift
//  AstroCalendar
//
//  Created by Francis Bailey on 2015-03-13.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         18/03/2015      Changed from using database to Swiss ephemeris
//  Francis         25/03/2015      Added in toTimezone function, fixed looping of days
//  Francis         26/03/2015      Changed visibility of variables, added getters and setters and fetchEvents nows returns an array instead of void
//  Francis         30/03/2015      Added in internal functions to clean up the fetchEvents method
//  Francis         02/04/2015      Modified getMoonset to match getMoonrise
//  Francis         06/04/2015      Added in newMoon function
//  Francis         07/04/2015      Added in getEclipse function
//  Francis         08/04/2015      Implemented logic to calculate First Quarter and Third Quarter Moon Phases
//  Francis         10/04/2015      Changed calendarUtil to use GMT timezone so that no DST is applied when converting NSDate. This solves DST bug
//  Francis         16/04/2015      Moved getSunrise/Set into one function as well as getMoonrise/Set. Removed code where Moon Data 24 hours after specified date 
//                                  was pulled and checked against. This is no longer necessary since DST bug fix.
//  Francis         18/04/2015      Fixed issue with getEclipseForToday() outputting eclipses for several years ahead. Also changed the way the CalendarDay array was handled. 
//  Francis         24/04/2015      Fixed another issue with getEclipseForToday(), not returning eclipses on certain dates. 
//  Francis         26/04/2015      Changed class to use Singleton pattern
//  Francis         27/04/2015      Fixed bug where eclipses would not show up if they started on the 1st of a month


import Foundation


struct ConsumableEclipse {
    let visibleAt: NSDateComponents
    let type: String
    let visibility: String
}



class Calendar {

    
    
    static let sharedInstance = Calendar()
    
    
    private var days : [CalendarDay]
    private var calendarUtil : NSCalendar
    
    private let se : SwiftEphemeris
    private var timezone : NSTimeZone
    private var location : Location
    
    
    /*
     * Setup fallback values for parameterless construction of the calendar class
    */
    convenience init() {
        self.init(zone: NSTimeZone(name: "America/Vancouver")!, gps: Location(city: "kelowna", lon: -119.443606, lat: 49.880134, elevation:350 ))
    }
    
    
    init(zone: NSTimeZone, gps: Location)
    {
        self.timezone = zone
        self.location = gps
        self.calendarUtil = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        self.days = [CalendarDay]()
        self.se = SwiftEphemeris()
        self.calendarUtil.timeZone = NSTimeZone(name: "GMT")!
    }
    
    
    /*
     * start   : NSDateComponent - the starting range to calculate for
     * end     : NSDateComponents - the ending range to calculate for
     *
     * @return : [CalendarDay] - return a copy of the days array
    */
    func fetchEvents( start: NSDateComponents, end: NSDateComponents ) -> [CalendarDay]
    {
        let startDate = self.calendarUtil.dateFromComponents(start)!
        let endDate = self.calendarUtil.dateFromComponents(end)!
        let dates = DateRange(calendar: self.calendarUtil, startDate: NSDate(timeInterval: -60*60*24, sinceDate: startDate), endDate: endDate, stepUnits: NSCalendarUnit.CalendarUnitDay, stepValue: 1)
        

        var daysTmp = [CalendarDay]()
        

        for date in dates {
            let localDate = self.calendarUtil.components( .CalendarUnitMinute | .CalendarUnitHour | .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: date)
            
            let localDatePlus24 = self.calendarUtil.components(.CalendarUnitHour | .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate(timeInterval: 60*60*24, sinceDate: date))
            
            let utcDate = self.toTimeZone(localDate, toLocal: false)
            let utcDatePlus24 = self.toTimeZone(localDatePlus24, toLocal: false)
            
            let sunrise   = self.getSunriseOrSet(utcDate, getSunset: false)
            let sunset    = self.getSunriseOrSet(utcDate, getSunset: true)
            let moonrise  = self.getMoonriseOrSet(utcDate, localDate: localDate, getMoonset: false)
            let moonset   = self.getMoonriseOrSet(utcDate, localDate: localDate, getMoonset: true)
            let phase     = self.getMoonPhase(utcDate)
            let phaseName = self.getMoonPhaseName(utcDate, utcDatePlus24: utcDatePlus24)
            let eclipse   = self.getEclipseForToday(utcDate, localDate: localDate)
            
            daysTmp.append(CalendarDay(date: localDate, sunrise: sunrise, sunset: sunset, moonrise: moonrise, moonset: moonset, phaseName: phaseName, phase: phase, eclipse: eclipse ))
        }
        self.days = daysTmp
        return daysTmp
    }
    
    
    /*
     * Check to see what points are intersected within a 24 hour period
     * if the phaseAngle crosses over a specific point or is within a 
     * specific range we can determine what phase it's in
     *
     * utcDate : NSDateComponents - a date in UTC time
     * utcDatePlus24 : NSDateComponents - same date as above but 24 hours later
     *
     * @return : String - the name of the phaseAngle
    */
    internal func getMoonPhaseName(utcDate: NSDateComponents, utcDatePlus24: NSDateComponents) -> String {
        
        let angleStart = se.getEntityPhaseAngle(SE_MOON, comparisonBody: SE_SUN, utcDate: utcDate)
        let anglePlus24 = se.getEntityPhaseAngle(SE_MOON, comparisonBody: SE_SUN, utcDate: utcDatePlus24)
        
        var phaseName : String

        
        if 180 >= angleStart && 180 <= anglePlus24 {
            phaseName = "Full Moon"
        }
        else if anglePlus24 < angleStart {
            phaseName = "New Moon"
        }
        else if angleStart <= 90 && anglePlus24 >= 90 {
            phaseName = "First Quarter"
        }
        else if angleStart <= 270 && anglePlus24 >= 270 {
            phaseName = "Third Quarter"
        }
        else if anglePlus24 > 0 && anglePlus24 < 90  {
            phaseName = "Waxing Crescent"
        }
        else if anglePlus24 >= 90 && anglePlus24 < 180 {
            phaseName = "Waxing Gibbous"
        }
        else if anglePlus24 > 180 && anglePlus24 < 270 {
            phaseName = "Waning Gibbous"
        }
        else if anglePlus24 >= 270 && anglePlus24 < 360 {
            phaseName = "Waning Crescent"
        }
        else {
            phaseName = "Unknown"
        }
        
        
        return phaseName
    }
    
    
    /*
     * get the lunar phase and multiply by 100 to get percentage between 0 and 100
     *
     * utcDate : NSDateComponents - the date in UTC time that you wish to find phase for
     *
     * @return : Double - phase in percentage between 0 and 100
    */
    internal func getMoonPhase(utcDate: NSDateComponents) -> Double {
        return se.getEntityPhase(SE_MOON, utcDate: utcDate) * 100
    }
    
    
    /*
     * We fetch the moonrise or moonset for the current date and check      
     * check if the dates match the current date
     *
     * utcDate : NSDateComponents - a date in UTC time
     * localDate: NSDateComponents - a date in Local time
     * getMoonset : Bool - fetch moonset if true otherwise fetch moonrise
     *
     * @return : NSDateComponents - time of rise/set if one is found
    */
    internal func getMoonriseOrSet(utcDate: NSDateComponents, localDate: NSDateComponents, getMoonset: Bool) -> NSDateComponents? {
        
        let type = getMoonset ? SE_CALC_SET : SE_CALC_RISE
        
        var moonData = se.getEntityRiseSetTransitTime(SE_MOON, movement: type, gps: self.location, utcDate: utcDate)

        if moonData?.year != nil {
            moonData = self.toTimeZone(moonData!, toLocal: true)
            
            if moonData?.day != localDate.day {
                moonData = nil
            }
        }
        
        return moonData
    }
    
   
    /*
     * Calls getEclipse and checks for lunar eclipse first. If the eclipse dates
     * don't match up, it checks the solar eclipse and if those dates don't       
     * match utcDate then no eclipse exists for that day
     *
     * utcDate : NSDateComponents - the date in UTC to check for an eclipse
     *
     * @return : Eclipse? - returns an Eclipse struct if an eclipse of any kind occurs for the specified date.
    */
    internal func getEclipseForToday(utcDate: NSDateComponents, localDate: NSDateComponents) -> ConsumableEclipse? {

        if let lunarE = self.getEclipse(SE_MOON, utcDate: utcDate, localDate: localDate) {
            return lunarE
        }
        if let solarE = self.getEclipse(SE_SUN, utcDate: utcDate, localDate: localDate) {
            return solarE
        }

        return nil
    }

    
    /* 
     * Loops through all viewing times of eclipse and converting them to localTime, the first time that matches the
     * localDate will be considered the first viewable time of the eclipse.
     *
     * eclipseType : Int32   - Can either be SE_MOON or SE_SUN
     * utcDate     : utcDate - date in utc
     *
     * @return     : Eclipse - returns an eclipse struct for the **NEXT** eclipse from the utcDate provided, if one is found
    */
    internal func getEclipse(eclipseType: Int32, utcDate: NSDateComponents, localDate: NSDateComponents) -> ConsumableEclipse? {
        
        if let eclipse = se.findNextEclipse(eclipseType, utcDate: utcDate, gps: self.location) {

            for date in eclipse.viewingStages {
                let localTime = self.toTimeZone(date, toLocal: true)
                
                if localTime.day == localDate.day && localTime.month == localDate.month && localTime.year == localDate.year {
                    return ConsumableEclipse(visibleAt: localTime, type: eclipse.type, visibility: eclipse.visibility)
                }
            }
            
        }
        
        return nil
    }

    
    
    /*
     * Get the sunrise or set for the current day
     *
     * utcDate : NSDateComponents - date in utc, advised to be starting at midnight
     *
     * @return : NSDateComponents - return a sunrise/set if one is found
    */
    internal func getSunriseOrSet(utcDate: NSDateComponents, getSunset: Bool) -> NSDateComponents? {
        
        let type = getSunset ? SE_CALC_SET : SE_CALC_RISE
        let sunData = se.getEntityRiseSetTransitTime(SE_SUN, movement: type, gps: self.location, utcDate: utcDate)
        
        if sunData == nil {
            return nil
        }
        
        return self.toTimeZone(sunData!, toLocal: true)
    }

    
    
    /*
     * Apply timezone and daylight savings to a given date
     * date    : NSDateComponents - date to convert (local, utc, etc)
     * toLocal : Bool - determines whether or not you're converting from local time or UTC
     *
     * @return : NSDateComponents - returns a date in either Local or UTC time
    */
    internal func toTimeZone(date: NSDateComponents, toLocal: Bool) -> NSDateComponents
    {
        var dateNS = self.calendarUtil.dateFromComponents(date)!
        var seconds = Double(self.timezone.secondsFromGMTForDate(dateNS))
        
        if !toLocal {
            seconds = -seconds
        }
        
        dateNS = NSDate(timeInterval: seconds, sinceDate: dateNS)
        
        return self.calendarUtil.components(.CalendarUnitSecond | .CalendarUnitMinute | .CalendarUnitHour | .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: dateNS)

    }
    
   
    
    /*
     * Setters for location and timezone
    */
    func setTimeZone(zone: NSTimeZone) {
        self.timezone = zone
        //self.calendarUtil.timeZone = zone
    }
    
    func setLocation(gps: Location) {
        self.location = gps
    }
    
    func getLocation() -> Location {
        return self.location
    }
    
    
    func toArray() -> [CalendarDay] {
        return self.days
    }
    
    
    
}


/*
 * Allows us to iterate through a range of dates
 * Credit to Adam Preble
 * Orginal code found https://gist.github.com/preble/b08b6d9ee161534e6c1f
*/
func < (left: NSDate, right: NSDate) -> Bool {
    return left.compare(right) == NSComparisonResult.OrderedAscending
}

struct DateRange : SequenceType {
    
    var calendar: NSCalendar
    var startDate: NSDate
    var endDate: NSDate
    var stepUnits: NSCalendarUnit
    var stepValue: Int
    
    func generate() -> Generator {
        return Generator(range: self)
    }
    
    struct Generator: GeneratorType {
        
        var range: DateRange
        
        mutating func next() -> NSDate? {
            let nextDate = range.calendar.dateByAddingUnit(range.stepUnits,
                value: range.stepValue,
                toDate: range.startDate,
                options: NSCalendarOptions.allZeros)
            if range.endDate < nextDate! {
                return nil
            }
            else {
                range.startDate = nextDate!
                return nextDate
            }
        }
    }
}



