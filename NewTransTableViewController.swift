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

        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Date Picker is initially hidden
        datePicker.hidden = true
        
        // Defaults dateButton title to current date
        setCurrentDate()
    }
    
    // Changes dateButton title to user selected date
    func datePickerChanged(datePicker:UIDatePicker) {
        setDate(datePicker.date)
    }
    
    // Retrieves current date
    func setCurrentDate() {
        let currentDate = NSDate()
        setDate(currentDate)
    }
    
    // Creates a string from NSDate to change dateButton title
    func setDate(newDate: NSDate) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        var strDate = dateFormatter.stringFromDate(newDate)
        dateButton.setTitle(strDate, forState: .Normal)
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO: Open categories selection if selected row is "Choose Budget Category"
    }
    
    
    

    
// MARK: - Actions
    
    // Allows user to change the date of the transaction
    @IBAction func changeDate(sender: AnyObject) {
        datePicker.hidden = false
    }
    
    // Dismiss NewTrans view to cancel adding a new transaction
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
