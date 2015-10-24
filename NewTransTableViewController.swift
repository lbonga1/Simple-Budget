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
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation items
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton

        // Set date picker action target
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
    
    // Presents CatChooserTableViewController to make a category selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let categoryChooser = self.storyboard!.instantiateViewControllerWithIdentifier("CategoryChooser") as! CatChooserTableViewController
        self.navigationController!.pushViewController(categoryChooser, animated: true)    }
    
    // Make only "Choose Budget Category" row selectable
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row != 2 {
            return false
        } else {
            return true
        }
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
