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
//  SettingsViewController.swift
//  AstroCalendar
//
//  Created by Adam Smith on 2015-03-15.
//  Copyright (c) 2015 Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Adam            15/03/2015      Created file and Location pickers
//  Daniel          17/03/2015      Added pickers for Start and End date and connected to Settings class
//  Daniel          20/03/2015      Connected Location picker to cities database
//  Daniel          24/03/2015      Removed start and end date pickers, added date range picker
//  Daniel          26/03/2015      Converted file to support adding data to two UIPickerViews in one view
//  Daniel          02/04/2015      Modified file to merge, made range picker start at set default
//  Daniel          07/04/2015      Removed date range picker, fixed UI layout, hooked up GPS switch
//  Daniel          20/04/2015      Fixed UI bug where GPS was being set to false but switch still
//                                     showed as true
//  Francis         21/04/2015      Modified about button

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var gpsSwitch: UISwitch!
    @IBOutlet weak var gpsNoteLabel: UILabel!
    
    let settings = Settings.sharedInstance
    let lm = LocationTimeZoneManager(locationRepo: SQLiteDB.sharedInstance("Cities"))
    var pickerData = [String]()
    var locationOptions = [String]()
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
  
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationPicker.tag = 1
        locationOptions = lm.getAllLocations()
        
        var city = settings.getCity()
        var row = find(locationOptions, city)
        locationPicker.selectRow(Int(row!), inComponent: 0, animated:true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnLocationUpdate", name: notificationKey, object: nil)
        
        let gpsIsSet = settings.getGPS()
        gpsSwitch.on = gpsIsSet
    
        if !gpsIsSet {
            gpsNoteLabel.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func gpsChange(sender: UISwitch) {
        settings.setGPS(sender.on)
        
        if sender.on {
            gpsNoteLabel.hidden = false
        } else {
            gpsNoteLabel.hidden = true
        }
    }

    
    
    /*
     * If the GPS timed out, we set the toggle to false
    */
    func actOnLocationUpdate()
    {
        gpsSwitch.on = settings.getGPS()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var locationSelected = locationOptions[row]
        settings.setCityName(locationSelected.lowercaseString)
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) ->Int{
        return locationOptions.count
    }
    
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
        let data = locationOptions[row].capitalizedString
        var myData = NSAttributedString(string: data, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myData
    }
    
    
    @IBAction func aboutPressed(sender: AnyObject) {
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String
        let about = UIAlertController(title: "", message: "AstroCalendar Version: " + version! + "\n © Okanagan College 2015", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        about.addAction(OKAction)
        self.presentViewController(about, animated: true, completion: nil)
    }
}

















