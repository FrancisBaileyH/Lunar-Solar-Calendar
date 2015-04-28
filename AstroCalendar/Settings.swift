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
//  Settings.swift
//  AstroCalendar
//
//  Created by Daniel Atkinson on 2015-03-06.
//  Copyright (c) 2015 Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Daniel          06/03/2015      Created file, added getters and setters for city,
//                                  date range, and language
//  Daniel          10/03/2015      Added startDate and endDate plus getters and setters
//  Daniel          12/03/2015      Converted startDate and endDate to use NSDateComponents
//  Daniel          24/03/2015      Converted startDate and endDate to return NSDate
//  Daniel          27/03/2015      Removed startDate, endDate and all related functions
//  Daniel          09/04/2015      Added GPS, checks for GPS, and a getter and setter for GPS
//  Daniel          10/04/2015      Got GPS writing co-ordinates and getLocation building
//                                  location variables from the co-ordinates
//  Daniel          12/04/2015      Added broadcast for when GPS finishes updating
//  Daniel          20/04/2015      Added recheck and timeout for GPS, fixed GPS permissions
//  Francis         26/04/2015      Reverted most changes and implemented simple Timeout function for GPS
//  Francis         27/04/2015      Implemented permissions checking for location access.

import UIKit
import Foundation
import CoreLocation

let notificationKey = "SettingsUpdated"

class Settings: NSObject, CLLocationManagerDelegate
{
    
    static let sharedInstance = Settings()
    
    
    // Reference to iOS Application User Defaults and variables for each key
    let defaults:NSUserDefaults;
    let lm:LocationTimeZoneManager;
    let locationManager:CLLocationManager;
    var city: String?


    var timezone: String?
    var location: String?
    var gps: Bool
    var locator: Location
    var tmpLocator: Location?
    
    var updatingLocation : Bool
    
    var gpsLocation: CLLocation?
    var placeMark: CLPlacemark?
    var lon: Double?
    var lat: Double?
    var elev: Double?
    
    var gpsTimeout : NSTimer?

    
    override init()
    {
        // Create reference to stored user defaults
        defaults = NSUserDefaults.standardUserDefaults();
        lm = LocationTimeZoneManager(locationRepo: SQLiteDB.sharedInstance("Cities"))
        
        
        updatingLocation = false
        
        // Create manager to access GPS functionality
        locationManager = CLLocationManager()

        locator = Location(city: "NA", lon: 0.0, lat: 0.0, elevation: 0.0)
        gps = false
        
        super.init()
        
        self.updateLocation(self.getGPS())
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    
    // This function is called everytime the location manager receives an update from the GPS
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        // Gets the last update in the array
        // There should only be one but if multiple come in at the same time
        // The last update will be the most recent
        gpsLocation = locations.last as! CLLocation!
        // Gets the accuracy of the GPS co-ordinates in meters
        let acc = gpsLocation?.horizontalAccuracy
        // If the co-ordinates are not accurate then ignore them
        if(acc > 100)
        {
            return
        }
        else
        {
            // Store longitude, latitude, and elevation
            lat = gpsLocation?.coordinate.latitude
            lon = gpsLocation?.coordinate.longitude
            elev = gpsLocation?.altitude
 
            
            self.locationManager.stopUpdatingLocation()
            
            CLGeocoder().reverseGeocodeLocation(locationManager.location, completionHandler: {
                placemarks, error in
                
                if error == nil && placemarks.count > 0 {
                    // Stores the place name in placeMark
                    self.placeMark = placemarks.last as? CLPlacemark
                    // Stop the location manager from trying to update the GPS
                    self.tmpLocator = nil
                    self.notifyOnChange()
                    
                } else if error == nil && placemarks.count <= 0 {
                    let lonStr = String(format: "%.2f", self.lon!)
                    let latStr = String(format: "%.2f", self.lat!)
                    self.placeMark = nil
                    self.tmpLocator = Location(city: latStr + ", " + lonStr, lon: self.lon!, lat: self.lat!, elevation: self.elev!)
                }
                
                if (self.tmpLocator != nil || self.placeMark != nil) && error == nil {
                    self.updatingLocation = false
                    self.gpsTimeout?.invalidate()
                    self.notifyOnChange()
                }
                
            })
            
        }
    }
    
    
    
    /*
     * Required to catch any errors that may occur
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)  {   }
    
    
    /*
     * Required to handle a change in location settings
    */
    func locationManager(manager:CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if getGPS() {
            self.checkLocationPermissions(status)
        }
    }
    
    
    
    // Checks for a default city
    // Return the city name as a string
    func getCity() -> String {
        // Check to see if there is a default city set
        // Default should be London, GMT unless set otherwise
        if defaults.objectForKey("defaultCity") != nil
        {
            // If there is a default key set the variable to it
            city = defaults.stringForKey("defaultCity")
        }
        else
        {
            // If there is no default city
            // Set city to London
            city = "london"
            // Set the default city value
            defaults.setObject(city, forKey: "defaultCity")
            // Should only execute if the application has not been run yet and has no default values
        }
        return city!
    }
    
    // Checks for timezone
    // Returns the timezone's name as a string
    func getTimeZone() -> NSTimeZone
    {
        // Check to see if GPS is on
        if(!getGPS())
        {
            // Check to see if there is a default city set
            // Default should be London, GMT unless set otherwise
            if defaults.objectForKey("defaultCity") != nil
            {
                // If there is a default key set the variable to it
                timezone = defaults.stringForKey("defaultCity")
            }
            else
            {
                // If there is no default city
                // Set timezone to London
                timezone = "london"
            }
            // Feed the city name into location manager and return the resulting timezone name
            return (lm.getTimeZoneFromCity(timezone!))!
        }
        else
        {
            // Fetch the timezone from the phone's set timezone
            return lm.getTimeZoneFromSystem()
        }
    }
    
    
    /*
     * Handle the event of a GPS failure or timeout
    */
    func handleGPSTimeout() {
        self.gpsTimeout?.invalidate()
        self.setGPS(false)
        self.notifyOnChange()
        self.showGlobalTimeoutAlert()
    }
    
    
    /* 
     * Notify all observing objects that settings has changed
    */
    func notifyOnChange() {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey, object: self)
    }
    
    
    /*
     * Show timeout alert on the RootViewController, so that whatever
     * view is currently opened will receive the alert
    */
    func showGlobalTimeoutAlert() {
        let alert = UIAlertController(title: "Timeout", message: "GPS timed out. Unable to fetch location. Falling back to your default location in the settings menu.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    // Checks for location
    // Returns the location as a location struct
    func getLocation() -> Location
    {
        // Check to see if GPS is on
        if(!getGPS())
        {
            // Check to see if there is a default city set
            // Default should be London, GMT unless set otherwise
            if defaults.objectForKey("defaultCity") != nil
            {
                // If there is a default key set the variable to it
                location = defaults.stringForKey("defaultCity")
            }
            else
            {
                // If there is no default city
                // Set location to London
                location = "london"
            }
            // Feed the city name into location manager and return the resulting location
            return(lm.getGPSFromCityName(location!))!
        }
        else
        {
            // Check to see if the GPS has created a ready and accurate GPS location
            if ((placeMark?.locality) != nil)
            {
                // If it has then build a location struct using the set variables
                locator = Location(city: placeMark!.locality, lon: lon!, lat: lat!, elevation: elev!)
            }
            else if self.tmpLocator != nil {
                locator = self.tmpLocator!
            }
            else
            {
                // If the GPS is not yet ready
                // Then return a location with the name Unready and 0s as its co-ordinates
                locator = Location(city: "Fetching Location", lon: 0, lat: 0, elevation: 0)
            }
            
            return locator
        }
    }
    
    // Checks the GPS
    // Returns the use of GPS as a boolean
    func getGPS() -> Bool
    {
        // Check to see if the GPS default has been set
        // Default should be false unless otherwise set
        if defaults.objectForKey("defaultGPS") != nil
        {
            // If there is a default key set the variable to it
            gps = defaults.boolForKey("defaultGPS")
        }
        else
        {
            // If there is no default GPS value
            // Then set the default key to be false
            defaults.setBool(false, forKey: "defaultGPS")
            gps = false
        }
        
        return gps
    }


    
    // Sets the key for default city to the incoming parameter
    // Accepts a single string
    func setCityName(newCity:String) -> Void {
        city = newCity
        defaults.setObject(city, forKey: "defaultCity")
        self.notifyOnChange()
    }
    
    // Sets the key for default GPS to the incoming parameter
    // Accepts a single boolean value
    func setGPS(flip:Bool) -> Void {
        
        defaults.setBool(flip, forKey: "defaultGPS")
        self.updateLocation(flip)
    }
    
    
    /*
     * Handle Location permissions, return true if location services is enabled
    */
    func checkLocationPermissions(auth: CLAuthorizationStatus?) -> Bool {
        
        var status = auth
        
        if auth == nil {
            status = CLLocationManager.authorizationStatus()
        }
        
        if status == .NotDetermined {
            if locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")) {
                locationManager.requestWhenInUseAuthorization()
            }
            
            return false
        }
        else if status != .AuthorizedAlways && status != .AuthorizedWhenInUse
        {
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to use GPS, please open up the application's settings and change location access to 'Always' or 'When In Use'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            
            alertController.addAction(openAction)
            
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            
            
            return false
        }
        else {
            return true
        }
    }
    
    
    
    /*
     * Checks to see if GPS is enabled and
     * retrieves location accordingly
    */
    func updateLocation(gpsEnabled: Bool) {
        
        if gpsEnabled {
            
            if self.checkLocationPermissions(nil) {
            
                self.placeMark = nil
                self.tmpLocator = nil
                
                self.gpsTimeout = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("handleGPSTimeout"), userInfo: nil, repeats: false)
                
                self.locationManager.startUpdatingLocation()
            }
            else {
                self.setGPS(false)
            }
            
        } else {
            gpsTimeout?.invalidate()
            locationManager.stopUpdatingLocation()
        }
        
        self.notifyOnChange()
    }
    
    
    
    // This function will erase all the keys listed below
    func wipeKeys() -> Void {
        defaults.setObject(nil, forKey: "defaultCity")
    }
    
    // This function will print the contents of all the keys listed below
    func printKeys() -> Void {
        println(defaults.stringForKey("defaultCity"))
    }
    
}