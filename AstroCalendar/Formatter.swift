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
//  Formatter.swift
//  AstroCalendar
//
//  Created by Corey Frank on 2015-03-26.
//  Copyright (c) 2015 Okanagan College All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         29/03/2015      Added zeroAppender function
//  Adam            7/04/2015       Added NSdate to NSDatecomponents converter
//  Francis         21/04/2015      Used zeroAppender on month and day in the dateF function


import Foundation

class Formatter {
    
      let calendarUtil = NSCalendar.currentCalendar()
    
    func timeF (myDate: NSDateComponents) -> String{
        var myString: String
        
        myString = "\(self.zeroAppender(myDate.hour)):\(self.zeroAppender(myDate.minute)):\(self.zeroAppender(myDate.second))"
        return myString
    }
    
    func dateF (myDate: NSDateComponents) -> String {
        var myString: String
        myString = "\(String(self.zeroAppender(myDate.day)))-\(String(self.zeroAppender(myDate.month)))-\(String(myDate.year))"
        return myString
    }
    
    internal func zeroAppender( number: Int ) -> String {
        if number < 10 {
            return "0" + String(number)
        }
        
        return String(number)
    }
    
    
    //converts NSdate to NSDateComponents
    func setDateComponent(date: NSDate) -> NSDateComponents{
     
        let components = calendarUtil.components(.CalendarUnitYear | .CalendarUnitDay | .CalendarUnitMonth, fromDate: date)
        return components
    }
    
    //adds months to NSDate object
    func addMonths(date: NSDate,monthsToAdd: Int) -> NSDate {
    var components = NSDateComponents()
        components.month = monthsToAdd
        
        let futureDate = NSCalendar.currentCalendar()
.dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
        return futureDate!
    
    }
    
    func addDays(date: NSDate,daysToAdd: Int) -> NSDate {
        var components = NSDateComponents()
        components.day = daysToAdd
        
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
        return futureDate!
    }

    func addYears(date: NSDate,yearsToAdd: Int) -> NSDate {
        var components = NSDateComponents()
        components.year = yearsToAdd
        
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
        return futureDate!
}
    
   
    
    
    
}