//
//  AccountTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/9/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class AccountTableViewController: UITableViewController {
    
// MARK: - Outlets
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var instPicker: UIPickerView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
// MARK: - Variables
    var institution: PlaidClient.Institution? = nil
    var responseTextField: UITextField? = nil
    var accessToken: String? = nil
    let textDelegate = TextFieldDelegate()
    let plaid = PlaidClient.Plaid()
    var tempTransactions: [PlaidClient.TempTransaction] = []
    var createdCategories: [Category] = []
    var createdSubcategories: [Subcategory] = []
    let instData = ["American Express", "Bank of America", "Capital One 360",
        "Charles Schwab", "Chase", "Citi Bank", "Fidelity",
        "PNC", "US Bank", "USAA", "Wells Fargo"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up navigation bar button items
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        // Insitution Picker View
        instPicker.hidden = true
        instPicker.dataSource = self
        instPicker.delegate = self
        
        // Text delegates
        usernameTextField.delegate = textDelegate
        passwordTextField.delegate = textDelegate
        
        // Fetched results controller
        self.executeFetch()
        fetchedResultsController.delegate = self
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Subcategory")
        let sortDescriptor = NSSortDescriptor(key: "category.catTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "category.catTitle",
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
// MARK: - Actions
    
    // Dismiss AccountTableViewController
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Save new account
    @IBAction func saveAction(sender: AnyObject) {
        // Activate activity indicator
        self.activityView.startAnimating()
        
        // Get institution type from selected institution string
        self.institutionFromString(institutionLabel.text!)
        
        // Submit add user request
        PlaidClient.sharedInstance().PS_addUser(.Connect, username: usernameTextField.text!, password: passwordTextField.text!, pin: pinTextField.text, institution: institution!) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            
            // Set access token
            self.accessToken = accessToken
            
            // Check response code
            if response != nil {
                let response = response as! NSHTTPURLResponse
                // Check response code and give solution
                self.checkResponseCode(response, transactions: transactions, mfaType: mfaType, mfa: mfa)
            // Network error
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    // Hide activity view
                    self.activityView.stopAnimating()
                    // Display alert
                    self.displayAlert("Network error",
                        message: "Please check your network connection and try again.")
                }
            }
        }
    }
    
// MARK: - Tableview Delegate
    
    // Presents CatChooserTableViewController to make a category selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row to make it visually reselectable.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //self.navigationItem.rightBarButtonItem = doneButton
        instPicker.hidden = false
        
    }
    
    // Make only "Choose Institution" row selectable
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row != 0 {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Picker View Data Source

extension AccountTableViewController: UIPickerViewDataSource {
    
    // Return number of components in picker view.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Return number of rows.
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return instData.count
    }
}

// MARK: - Picker View Delegate

extension AccountTableViewController: UIPickerViewDelegate {
   
    // Return row title.
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return instData[row]
    }
    
    // Change Institution label text based on seleced row.
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        institutionLabel.text = instData[row]
        instPicker.hidden = true
    }
}

// MARK: - Fetched Results Controller Delegate

extension AccountTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) { }
}
