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
//  SwiftEphemeris.swift
//  AstroCalendar
//
//  Created by Francis Bailey on 2015-03-18.
//  Copyright (c) 2015 Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         20/03/2015      Added swe_set_ephe_path to init
//  Francis         22/03/2015      Removed pressure and temp parameters, set defaults instead
//  Francis         25/03/2015      Changed checkEphemeris function to use swe_eclipse_when_loc
//  Francis         29/03/2015      Changed getEntityPhase to return more data
//  Francis         30/03/2015      Added in getEntityPhaseAngle and reverted changes to getEntityPhase
//  Francis         07/04/2015      Added eclipse struct and changed the way findNextEclipse functions
//  Francis         10/04/2015      Fixed getJulianDayUT to use hour specified in NSDateComponents. This solves the DST bug 
//  Francis         18/04/2015      Added swe_close() to deinit to free up resources used by swiss ephemeris
//  Francis         24/04/2015      Added in getEclipseType and changed the way eclipses are handled in getNextEclipse()
//  Francis         27/04/2015      Changed the way getNextEclipse functions to fix bug where eclipses did not show if they started on the 1st of a month



import Foundation


struct Eclipse {
    let viewingStages : [NSDateComponents]
    let type : String
    let visibility : String
}



class SwiftEphemeris {
    

    
    /* 
     * Set the path to the directory where all ephemeris files are stored
     * in this instance, they're stored in the main bundle.
    */
    init()
    {
        swe_set_ephe_path(NSBundle.mainBundle().bundlePath)
    }
    
 
 
    
    /*
     * Retrieves the rise, set, or transit time of a given body from Earth
     *
     * body     : Int32 - planet or moon to get data for (All numbers defined in swephexp.h)
     * movement : Int32 - choose from transit, rise or set
     * gps      : [Double] - contains values [ longitude, latitude, elevation(metres)
     * date     : NSDateComponents - date to caluclate for
     *
     * @return NSDateComponents? - returns gregorian date if one is found
    */
    func getEntityRiseSetTransitTime( body: Int32, movement : Int32, gps : Location, utcDate: NSDateComponents ) -> NSDateComponents?
    {
        let julianDay : Double = self.getJulianDayUT(utcDate)
        let temp = 15.0
        let pressure = 1015.0
        
        var location : [Double] = [gps.lon, gps.lat, gps.elevation]
        
        var data : Double = 0
        
        
        /*
         * julianDay    : Double
         * planetNumber : Int32  - planet or moon
         * starName     : char * - name of star (keep nil for now)
         * ephemerisFlag: Int32  - keep as Swiss ephemeris by default
         * movementType : Int32  - rise, set, transit, etc
         * location     : double* - 3 element array [ lon, lat, elevation(m) ]
         * atPress      : double - atmospheric pressure in mBar
         * atTemp       : double - atmospheric temperature in celsius
         * data         : double* - Julian Day number is set in Data
         * err          : char * - Errors are stored here
        */
        let ret_flag = swe_rise_trans( julianDay, body, nil, SEFLG_SWIEPH, movement, &location, pressure, temp, &data, nil )
        
        // -2 indicates that no risings or settings were found
        if ret_flag == -2 {
            return nil
        }

        return self.convertJulianNumber(data)
    }
    

    
    
    /*
     * Finds the illumination percentage for a given celestial body
     *
     * body : Int32 - planet or moon to get data for
     * gps  : [Double] - contains values [ lon, lat, elevation(metres) ]
     * date : NSDateComponents - expects Year, Month, Day, Hour
     *
     * @return - Double : target phase
    */
    func getEntityPhase( body: Int32, utcDate: NSDateComponents ) -> Double
    {
        var data = [Double](count: 20, repeatedValue: 0.0)
        let julianDay = self.getJulianDayUT(utcDate)
        let phase = 1
        
        let ret_flag = swe_pheno_ut(julianDay, body, SEFLG_SWIEPH, &data, nil)
        
        return data[1]
    }
    
    
    /*
     * Finds the type of eclipse and the earliest time that the eclipse is visible for a given date
     *
     * eclipseType : Int32 - if nil, calcuates SOLAR eclipse, else lunar
     * date        : NSDateComponents - expects Year, Month, Day, Hour
     * gps         : [Double] - expects values [ lon, lat, elevation(metres) ]
     *
     * @return - [Double] : if lunar:
     * [ time of maximum eclipse,
     * nil,
     * time of partial phase being,
     * time partial phase end
     * time of totality begin
     * time of penumberal phase begin
     * time of penumbral phase end
     * time of moonrise
     * time of moonset
     * ]
     
     * if Solar:
     * tret[0]          time of maximum eclipse
     * tret[1]          time of first contact
     * tret[2]          time of second contact
     * tret[3]          time of third contact
     * tret[4]          time of forth contact
     * tret[5]          time of sunrise between first and forth contact (not implemented so far)
     * tret[6]          time of sunset beween first and forth contact  (not implemented so far)
    */
    func findNextEclipse( eclipseType: Int32?, utcDate: NSDateComponents, gps: Location ) -> Eclipse?
    {
        var tret = [Double](count: 10, repeatedValue: 0.0)
        var data = [Double](count: 20, repeatedValue: 0.0)
        
        
        let julianDay = self.getJulianDayUT(utcDate)
        
        var ret_flag : Int32
        var location : [Double] = [ gps.lon, gps.lat, gps.elevation ]
        var eclipse : Eclipse?
        let type : String
        
        var viewingStages = [Double]()
        
        
        
        if eclipseType == SE_MOON {
            ret_flag = swe_lun_eclipse_when_loc(julianDay, SEFLG_SWIEPH, &location, &tret, &data, 0, nil)
            type = "Lunar"
            
            viewingStages.append(tret[2]) // partial begin
            viewingStages.append(tret[4]) // totality begin
            viewingStages.append(tret[0]) // max time
            viewingStages.append(tret[5]) // totality end
            viewingStages.append(tret[3]) // partial end
            
        }
        else {
            ret_flag = swe_sol_eclipse_when_loc(julianDay, SEFLG_SWIEPH, &location, &tret, &data, 0, nil)
            type = "Solar"
            
            viewingStages.append(tret[1]) // first contact
            viewingStages.append(tret[2]) // second contact
            viewingStages.append(tret[0]) // max time
            viewingStages.append(tret[3]) // third contact
            viewingStages.append(tret[4]) // fourth contact
        }
        
        if ret_flag >= 0 {
            
            var viewingStagesUTC = [NSDateComponents]()
            
            viewingStages.sort {
                return $0 < $1
            }
            
            for day in viewingStages {
                let date = self.convertJulianNumber(day)
                viewingStagesUTC.append(date)
            }
            
            return Eclipse(viewingStages: viewingStagesUTC, type: type, visibility: self.getEclipseType(ret_flag))
        }
        
        

        return nil
    }
    
    
    /*
     * Convert ret_flags from the eclipse function into meaningful
     * string representations
     *
     * retFlag : Int32 - return flag from eclipse function call
     * 
     * @return : String - returns type if found otherwise an empty string
    */
    internal func getEclipseType(retFlag: Int32) -> String {
        let type : String
        
        
        if (retFlag & SE_ECL_TOTAL) > 0 {
            type = "Total"
        }
        else if (retFlag & SE_ECL_PARTIAL) > 0 {
            type = "Partial"
        }
        else if (retFlag & SE_ECL_PENUMBRAL) > 0 {
            type = "Penumbral"
        }
        else if (retFlag & SE_ECL_ANNULAR) > 0 {
            type = "Annular"
        }
        else if (retFlag & SE_ECL_ANNULAR_TOTAL) > 0 {
            type = "Total Annular"
        }
        else {
            type = ""
        }
        
        return type
    }
    
    
    /* 
     * Calculate the phase angle between two given bodies
     *
     * targetBody : Int32 - the entity for which you wish to calculate the phase angle
     * comparisonBody : Int32 - the entity used to compare angles with
     * utcDate : NSDateComponents - a date in utc time
     *
     * @return : Double - return the angle from 0 - 360
    */
    func getEntityPhaseAngle( targetBody: Int32, comparisonBody: Int32, utcDate: NSDateComponents ) -> Double {
        
        let julianDay = self.getJulianDayUT(utcDate)
        
        var tBodyData = [Double](count: 10, repeatedValue: 0.0)
        var cBodyData = [Double](count: 20, repeatedValue: 0.0)
        
        swe_calc_ut(julianDay, targetBody, SEFLG_SWIEPH, &tBodyData, nil)
        swe_calc_ut(julianDay, comparisonBody, SEFLG_SWIEPH, &cBodyData, nil)
        
        return swe_difdegn(tBodyData[0], cBodyData[0])
    }
    
  
    
    /* 
     * Calcuate the JulianDay number for a given date
     * requires Year, Month, Day and Hour
     *
     * @return - Double : Julian day number from **BEGINNING** of UTC day
    */
    func getJulianDayUT( date: NSDateComponents ) -> Double {
        let yearIn = Int32(date.year)
        let monthIn = Int32(date.month)
        let dayIn = Int32(date.day)
        let hourIn = Double(date.hour)

        return swe_julday(yearIn, monthIn, dayIn, hourIn, SE_GREG_CAL)
    }
   
    
    /*
     * Convert Julian Number back into gregorian calendar date
     *
     * @return - NSDateComponents : Gregorian Calendar date in UTC
    */
    func convertJulianNumber( julianNumber: Double ) -> NSDateComponents
    {
        var min, hour, day, month, year : Int32
        var sec : Double

        year = 0
        month = 0
        day = 0
        hour = 0
        min = 0
        sec = 0

        swe_jdut1_to_utc(julianNumber, SE_GREG_CAL, &year, &month, &day, &hour, &min, &sec)
        
        var date = NSDateComponents()
        date.year = Int(year)
        date.month = Int(month)
        date.day = Int(day)
        date.hour = Int(hour)
        date.minute = Int(min)
        date.second = Int(sec)
        
        
        return date
    }
    
    
    
    /*
     * Close all resources opened by Swiss Ephemeris
    */
    deinit {
        swe_close()
    }
    
   
    
}