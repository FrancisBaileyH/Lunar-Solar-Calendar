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
//  ViewController.swift
//
//
//  Created by Andrei Puni on 25/12/14.
//  Copyright (c) 2014 Andrei Puni. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         07/04/2015      Added in eclipse data
//  Francis         07/04/2015      Hooked up cityLabel and settings update system
//  Francis         08/04/2015      Implemented UIImageView for Lunar Phase 
//  Daniel          12/04/2015      Implemented retrieval of GPS data from notification center
//  Francis         24/04/2015      Changed eclipse in updateView to match changes in Calendar.swift
//  Francis         26/04/2015      Changed the way controller handles settings updates

import UIKit


class ViewController: UIViewController, CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate, CVCalendarMenuViewDelegate {
    
      
  
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var moonriseLabel: UILabel!
    @IBOutlet weak var moonsetLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var phaseName: UILabel!
    @IBOutlet weak var eclipseLabel: UILabel!
    @IBOutlet weak var phaseImage: UIImageView!
    
    
    let settings = Settings.sharedInstance
    let formatter = Formatter()
    let calendar = Calendar.sharedInstance
    
    var currentDate : CVDate? = nil
    var location:Location = Location(city: "Unready", lon: 0, lat: 0, elevation: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnLocationUpdate", name: notificationKey, object: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
    }
    
    
    /*
     * When the view is switched back to, we want to 
     * refresh user settings in case they changed while
     * away from this view
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.actOnLocationUpdate()
    }
    
    
    func actOnLocationUpdate()
    {
        location = settings.getLocation()
        self.calendar.setTimeZone(settings.getTimeZone())
        self.calendar.setLocation(location)
        self.cityLabel.text = location.city?.capitalizedString
        self.updateCalendarView(self.calendarView.presentedDate)
    }
    
    
    
    /*
     * Required functions for CVCalendarViewDelegate
    */
    func dayLabelWeekdayInTextColor() -> UIColor {
        return .whiteColor()
    }

   
    func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool {
        return true
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    
    
    /*
     * Event handler for CVCalendar day pressed action
    */
    func didSelectDayView(dayView: DayView) {
        let date = dayView.date!
        
        self.currentDate = date
        self.updateCalendarView(date)
    }
    
    
    /*
     * Updates all labels and images in the Calendar View
    */
    func updateCalendarView(date: CVDate) {
        var curDate = date
        
        if let d = self.currentDate {
            curDate = d
        }
        
        let fromDate = NSDateComponents()
        fromDate.year = curDate.year
        fromDate.month = curDate.month
        fromDate.day = curDate.day
        fromDate.hour = 0
        
        let day = self.calendar.fetchEvents(fromDate, end: fromDate)[0]
        
        
        sunriseLabel.text = "--"
        sunsetLabel.text = "--"
        moonriseLabel.text = "--"
        moonsetLabel.text = "--"
        eclipseLabel.text = ""
        phaseName.text = day.phaseName
        
        if let sunrise = day.sunrise {
            sunriseLabel.text = formatter.timeF(sunrise)
        }
        
        if let sunset = day.sunset {
            sunsetLabel.text = formatter.timeF(sunset)
        }
        
        if let moonrise = day.moonrise {
            moonriseLabel.text = formatter.timeF(moonrise)
        }
        
        if let moonset = day.moonset {
            moonsetLabel.text = formatter.timeF(moonset)
        }
        
        if let eclipse = day.eclipse {
            eclipseLabel.text = eclipse.visibility + " " + eclipse.type + " eclipse visible starting at: " + formatter.timeF(eclipse.visibleAt) + ", today."
        }
        
        phaseImage.image = UIImage(named: day.phaseName)
        phaseLabel.text = String(format: "%.2f", day.phase) + "%"
        
    }
    
    
    /* 
     * Change monthLabel when calendar is swiped left or right
    */
    func presentedDateUpdated(date: CVDate) {
        monthLabel.text = date.globalDescription
    }
    
    /*
     * Setup default fonts for calendar
    */
    func dayLabelPresentWeekdayFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 16.0)!
    }
    func dayLabelWeekdayFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 18.0)!
    }
    
    func dayLabelPresentWeekdayBoldFont() -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
    }
    
    func dayLabelPresentWeekdayHighlightedFont() -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
    }
    
    func dayLabelPresentWeekdaySelectedFont() -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: 20.0)!
    }
    
    
}

    
    
   
    

