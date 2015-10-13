//
//  NewTransTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class NewTransTableViewController: UITableViewController {

// MARK: - Outlets

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.addTarget(self, action: Selector("dataPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        datePicker.hidden = true
        
        setCurrentDate()

    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        setDate(datePicker.date)
        
//        var dateFormatter = NSDateFormatter()
//        
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        
//        var strDate = dateFormatter.stringFromDate(datePicker.date)
//        dateButton.setTitle(strDate, forState: .Normal)
    }
    
    func setCurrentDate() {
        let currentDate = NSDate()
        setDate(currentDate)
    }
    
    func setDate(newDate: NSDate) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        var strDate = dateFormatter.stringFromDate(newDate)
        dateButton.setTitle(strDate, forState: .Normal)
    
    }
    
// MARK: - Actions
    
    @IBAction func changeDate(sender: AnyObject) {
        datePicker.hidden = false
    }


}
