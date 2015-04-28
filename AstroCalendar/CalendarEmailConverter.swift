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
//  CalendarEmailConverter.swift
//  AstroCalendar
//
//  Created by Francis Bailey on 2015-04-09.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         21/04/2015      Changed format of phase percent
//  Francis         27/04/2015      Fixed typo on html table

import Foundation


class CalendarEmailConverter {
    
    private let formatter : Formatter
    
    init() {
        self.formatter = Formatter()
    }
    
    
    /*
     * Convert the calendar data into an html table
    */
    func convertToHTML(days: [CalendarDay]) -> String {
        var body : String = "<html><head><style>td { white-space: nowrap; min-width: 36px; padding: 5px 10px } td, th, table { border: 1px solid #000000; } </style></head><body><table>"
            body += "<tr style='border: 1px solid #000000'>"
            body += "<th style='border: 1px solid #000000'>Date</th>"
            body += "<th style='border: 1px solid #000000'>Sunrise</th>"
            body += "<th style='border: 1px solid #000000'>Sunset</th>"
            body += "<th style='border: 1px solid #000000'>Moonrise</th>"
            body += "<th style='border: 1px solid #000000'>Moonset</th>"
            body += "<th style='border: 1px solid #000000'>Phase Name</th>"
            body += "<th style='border: 1px solid #000000'>Illumination of Moon</th>"
            body += "<th style='border: 1px solid #000000'>Eclipse</th></tr>"
        
        for day in days {
            body += "<tr style='border: 1px solid #000000'>"
            body += "<td style='border: 1px solid #000000'>" + formatter.dateF(day.date) + "</td>"
            body += "<td style='border: 1px solid #000000'>" + (day.sunrise != nil ? formatter.timeF(day.sunrise!) : "--") + "</td>"
            body += "<td style='border: 1px solid #000000'>" + (day.sunset != nil ? formatter.timeF(day.sunset!) : "--") + "</td>"
            body += "<td style='border: 1px solid #000000'>" + (day.moonrise != nil ? formatter.timeF(day.moonrise!) : "--") + "</td>"
            body += "<td style='border: 1px solid #000000'>" + (day.moonset != nil ? formatter.timeF(day.moonset!) : "--") + "</td>"
            body += "<td style='border: 1px solid #000000'>" + day.phaseName + "</td>"
            body += "<td style='border: 1px solid #000000'> %" + (NSString(format: "%.2f", day.phase) as! String) + "</td>"
            
            body += "<td>"
            
            if let ec = day.eclipse {
                body += ec.visibility + " " + ec.type + " eclipse visible starting at: " + formatter.timeF(ec.visibleAt) 
            } else {
                body += "&nbsp;"
            }
           
            body += "</td></tr>"
        
        }
        
        body += "</table></body></html>"
        
        return body
    }
}