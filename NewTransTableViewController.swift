//
//  NewTransTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class NewTransTableViewController: UITableViewController, UITextFieldDelegate {

// MARK: - Outlets
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var merchantTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
// MARK: - Variables
    var selectedSubcategory: Subcategory!
    let textDelegate = TextFieldDelegate()
    let currencyDelegate = CurrencyTextDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation items
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = addButton
        
        // Set text delegates
        self.amountTextField.delegate = currencyDelegate
        self.merchantTextField.delegate = textDelegate

        // Set date picker action target
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Date Picker is initially hidden
        datePicker.hidden = true
        
        // Defaults dateButton title to current date
        setCurrentDate()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Set categoryLabel to subcategory title if a subcategory has been selected.
        if selectedSubcategory != nil {
            categoryLabel.text = selectedSubcategory.subTitle
        }
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()

    
// MARK: - Tableview Delegate
    
    // Presents CatChooserTableViewController to make a category selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row to make it visually reselectable.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Present Category Chooser
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryChooser") as! UINavigationController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
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
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    // Dismiss date picker view
    @IBAction func doneAction(sender: AnyObject) {
        datePicker.hidden = true
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    // Dismiss NewTrans view to cancel adding a new transaction
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Save new transaction and dismiss view controller
    @IBAction func addAction(sender: AnyObject) {
        // Check to make sure required fields have been completed
        if amountTextField.text != nil && merchantTextField.text != nil && categoryLabel.text != "Choose Budget Category" {
            
            // Init transaction object
            let newTransaction = Transaction(subcategory: selectedSubcategory,
                date: dateButton.titleLabel!.text!,
                title: merchantTextField.text,
                amount: amountTextField.text,
                notes: notesTextView.text,
                context: self.sharedContext)
            
            // Save to Core Data
            dispatch_async(dispatch_get_main_queue()) {
                newTransaction.subcategory = self.selectedSubcategory
                CoreDataStackManager.sharedInstance().saveContext()
            }
            // Dismiss view controller
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            // Display error alert view
            displayAlert()
        }
    }
    
    @IBAction func unwindSegue(unwindSegue: UIStoryboardSegue) {
        if let newTrans = unwindSegue.sourceViewController as? CatChooserTableViewController {
            selectedSubcategory = newTrans.selectedSubcategory
        }
    }
}

// MARK: - Additional Methods

extension NewTransTableViewController {
    
    // Alert view for missing inputs.
    func displayAlert() {
        let alertController = UIAlertController(title: "Missing input", message: "Please complete all fields.", preferredStyle: .Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
// MARK: - Date Methods
    
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
}
