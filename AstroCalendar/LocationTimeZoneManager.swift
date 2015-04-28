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
//  LocationTimeZoneManager.swift
//  AstroCalendar
//
//  Created by Francis Bailey on 2015-03-25.
//  Copyright (c) Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         26/03/2015      Added in getTimeZoneFromCity and getGPSFromCity
//  Francis         27/03/2015      Removed usage of APTimeZones library
//  Francis         30/03/2015      Added in use of Location Struct
//  Francis         26/04/2015      Removed capitilization of cities from getAllLocations()



import Foundation
import CoreLocation


struct Location {
    let city : String?
    let lon : Double
    let lat: Double
    let elevation: Double
}


class LocationTimeZoneManager {
    
    let locationRepository : ReadableRepository
    
    
    init( locationRepo: ReadableRepository ) {
        self.locationRepository = locationRepo
    }
    
    
    /*
     * @return : NSTimeZone - returns the default timezone
    */
    func getTimeZoneFromSystem() -> NSTimeZone {
        return NSTimeZone.localTimeZone()
    }
    
    
    /*
     * city : String - a city name to look up against the database
     * 
     * @return : [Double]? - if city found returns [ lon, lat, elevation(meters)]
    */
    func getGPSFromCityName(city: String) -> Location? {
        let data = self.locationRepository.query("SELECT Lon, Lat, Elev FROM CityList WHERE City = ?", parameters:[city])
        
        if data[0]["Lon"] == nil {
            return nil
        }
        
        let lon = data[0]["Lon"]?.asDouble()
        let lat = data[0]["Lat"]?.asDouble()
        let elv = data[0]["Elev"]?.asDouble()
        
        return Location( city: city, lon: lon!, lat: lat!, elevation: elv! )
    }
    
    
    /*
     * city : String - a city name to look up against the database
     *
     * @return : [NSTimeZone]? - if city found returns
    */
    func getTimeZoneFromCity(city: String) -> NSTimeZone? {
        let data = self.locationRepository.query("SELECT TimeZone FROM CityList WHERE City = ?", parameters:[city])
        var test = data[0]["TimeZone"]?.asString()

        if let tz = data[0]["TimeZone"] {
            return NSTimeZone(name: tz.asString())
        } else {
            return nil
        }
    }
    
    
    /*
     * @return : [String] of all Cities currently in the database
    */
    func getAllLocations() -> [String] {
        let data = self.locationRepository.query("SELECT City FROM CityList ORDER BY City", parameters: nil)
        var cityList = [String]()
        
        for d in data {
            let name = d["City"]!
            cityList.append(name.asString())
        }
        
        return cityList
    }
    
}