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
//  ReportCollectionViewController.swift
//
//
//  Created by Adam Smith on 25/12/14.
//  Copyright (c) 2015 Okanagan College All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Adam            23/03/2015      initial setup
//  Adam            28/04/2015      changed to UICollectionView
//  Adam            07/04/2015      added in view controls for generating report
//  Francis         09/04/2015      added in email functionality
//  Francis         24/04/2015      fixed display bug, causing eclipse times to show up repeatedly
//  Francis         26/04/2015      Updated handling of settings updates and added in phase Illumination to report. 
//  Francis         27/04/2015      Removed changing of Select date text, so that it now only says "Select Date"

import UIKit
import MessageUI


class ReportCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate , UITextFieldDelegate{
    
    let calendar = Calendar.sharedInstance
    let settings = Settings.sharedInstance
    let formatter = Formatter()
    
    lazy var emailConverter = CalendarEmailConverter()
    
    var days = [CalendarDay]()
    var datePickerView: UIDatePicker = UIDatePicker()
    var tempFromDate:  NSDate?
    var datePickerDate : NSDate?
    var toDate: NSDateComponents!
    var fromDate: NSDateComponents!
    var reportRange: Int = 0
    var customView:UIView!
    
    
    
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var reportRangeSeg: UISegmentedControl!
    @IBOutlet weak var reportCollectionView: UICollectionView!
    @IBOutlet weak var dateField: UITextField!
    

        
    let loading = UIAlertController(title: nil, message: "Loading Report", preferredStyle: .Alert)
    
    
    
    func donePicker(){
      
        dateField.resignFirstResponder()
        showLoadingAlert()
        hideLoadingAlert()
    }
    
    func cancelPicker(){
        dateField.resignFirstResponder()
        
        dateField.text = "Select Date"
    }
    
   
    
    
    
    
    //Handles report range selection
    @IBAction func rangeChanged(sender: UISegmentedControl) {
        showLoadingAlert()
        
        switch reportRangeSeg.selectedSegmentIndex{
        case 0:
            reportRange = 0
                        
        case 1:
            reportRange = 1
        
        default:
            break;
        
        }
        
        hideLoadingAlert()
    }
    
    func showLoadingAlert() {
        self.presentViewController(loading, animated: true, completion: buildCal)
    }
    
    func hideLoadingAlert() {
        loading.dismissViewControllerAnimated(true, completion: nil)
    }
  
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        dateRangeLabel.text = ""
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnLocationUpdate", name: notificationKey, object: nil)
        
        tempFromDate = NSDate(timeIntervalSince1970: 0)
        datePickerDate = NSDate()
        
        
        dateField.delegate = self
        customView = UIView (frame: CGRectMake(0, 100, 320, 200))
        
        datePickerView = UIDatePicker(frame: CGRectMake(0, 0, 320, 200))
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.maximumDate = formatter.addYears(tempFromDate!, yearsToAdd: 3430)
    
        customView .addSubview(datePickerView)
        dateField.inputView = customView
        var toolbar: UIToolbar = UIToolbar(frame: CGRectMake(100, 100, 100, 44))
        
        var doneButton:UIBarButtonItem = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: "donePicker")
       
        var cancelButton:UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelPicker")
        doneButton.width = (self.reportCollectionView.frame.width/3)*1.5
        cancelButton.width = self.reportCollectionView.frame.width/3
        let toolbarButtonItems = [cancelButton, doneButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
        
        dateField.backgroundColor = toolbar.backgroundColor


        datePickerView.addTarget(self, action: "datePickerSelected:", forControlEvents: UIControlEvents.ValueChanged)
        dateField.inputAccessoryView = toolbar
        
    }
        
   
    func datePickerSelected(sender: UIDatePicker) {
            var timeFormatter = NSDateFormatter()
            timeFormatter.dateStyle = .ShortStyle

            datePickerDate = sender.date
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    
    func actOnLocationUpdate()
    {
        self.refreshSettings()
        self.days = [CalendarDay]()
        dateRangeLabel.text = ""
        reportCollectionView.reloadData()
    }
    
    
    func refreshSettings() {
        let location = settings.getLocation()
        self.calendar.setTimeZone(settings.getTimeZone())
        self.calendar.setLocation(location)
        self.locationLabel.text = location.city?.capitalizedString
    }
    
    
  
    
    /*
     * handles the tapping of the export to email button
    */
    @IBAction func exportToEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    
    /*
     * Creates pre generated html table from current data and configures
     * mail controller to be displayed to user
    */
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject("AstroCalendar Generated Report")
        mailComposerVC.setMessageBody(emailConverter.convertToHTML(self.days), isHTML: true)
        
        return mailComposerVC
    }
    
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send the email report at this time. Please check your email configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

   

     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }


     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return days.count
    }

     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell: ReportCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ReportCollectionViewCell
       
        
       
        cell.sunriseLabel.text = "--"
        cell.sunsetLabel.text = "--"
        cell.moonriseLabel.text = "--"
        cell.moonsetLabel.text = "--"
        cell.eclipseLabel.text = ""
        
        if let sunrise = days[indexPath.row].sunrise {
            cell.sunriseLabel.text = formatter.timeF(sunrise)
        }
        
        if let sunset = days[indexPath.row].sunset {
            cell.sunsetLabel.text = formatter.timeF(sunset)
            }
        
        if let moonrise = days[indexPath.row].moonrise {
            cell.moonriseLabel.text = formatter.timeF(moonrise)
        }
        if let moonset = days[indexPath.row].moonset {
            cell.moonsetLabel.text = formatter.timeF(moonset)
        }

        if let eclipse = days[indexPath.row].eclipse {
            cell.eclipseLabel.text = eclipse.visibility + " " + eclipse.type + " eclipse visible starting at:  \(formatter.timeF(eclipse.visibleAt))"
        }
        
        cell.phasePercent.text = String( format: "%.2f", days[indexPath.row].phase) + "%"
        
        cell.dateLabel.text = formatter.dateF(days[indexPath.row].date)
        cell.phaseImage.image = UIImage(named: days[indexPath.row].phaseName)
        cell.phaseLabel.text = days[indexPath.row].phaseName
        
        
    return cell
    }
   
  
    func buildCal(){
        
        
        fromDate = formatter.setDateComponent(datePickerDate!)
        
        if (reportRange == 0) {
            toDate = formatter.setDateComponent(formatter.addDays(datePickerDate!, daysToAdd: 6))
        }
        else if (reportRange == 1) {
            toDate = formatter.setDateComponent(formatter.addMonths(datePickerDate!, monthsToAdd: 1))
        }
        
        
        
        self.days = calendar.fetchEvents(fromDate!, end: toDate!)
        
        self.dateRangeLabel.text = "\(formatter.dateF(fromDate))\n\(formatter.dateF(toDate))"
     
        reportCollectionView.reloadData()
       
    }
    
    


}
