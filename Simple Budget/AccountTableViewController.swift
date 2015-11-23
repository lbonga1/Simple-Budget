//
//  AccountTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/9/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class AccountTableViewController: UITableViewController, UITextFieldDelegate {
    
// MARK: - Outlets
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var instPicker: UIPickerView!
    
// MARK: - Variables
    var institution: PlaidClient.Institution? = nil
    var responseTextField: UITextField? = nil
    let textDelegate = TextFieldDelegate()
    let plaid = PlaidClient.Plaid()
    var downloadedTransactions: [PlaidClient.Transactions]?
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
        
        let instType = institutionLabel.text!
       
        // Get Institution from institution label text
        switch instType {
        case "American Express":
            institution = .amex
        case "Bank of America":
            institution = .bofa
        case "Capital One 360":
            institution = .capone360
        case "Charles Schwab":
            institution = .chase
        case "Chase":
            institution = .citi
        case "Citi Bank":
            institution = .fidelity
        case "Fidelity":
            institution = .pnc
        case "PNC":
            institution = .schwab
        case "US Bank":
            institution = .us
        case "USAA":
            institution = .usaa
        case "Wells Fargo":
            institution = .wells
        default:
            break
        }
        
        // Submit add user request
        PlaidClient.sharedInstance().PS_addUser(.Connect, username: usernameTextField.text!, password: passwordTextField.text!, pin: pinTextField.text, institution: institution!) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            
            // Check response code
            if response != nil {
                let response = response as! NSHTTPURLResponse
                
                switch response.statusCode {
                // Successful
                case 200:
                    for transaction in transactions! {
                        //Format the transaction amount into a currency string
                        let formatter = NSNumberFormatter()
                        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                        formatter.locale = NSLocale(localeIdentifier: "en_US")
                        let amountString = formatter.stringFromNumber(transaction.amount)
                                                
                        if transaction.category == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                // Init new "Other" category
                                let newCategory = Category(catTitle: "Other", context: self.sharedContext)
                                
                                // Init new "Other" subcategory
                                let newSubcategory = Subcategory(category: newCategory,
                                    subTitle: "Other",
                                    totalAmount: "$0.00",
                                    context: self.sharedContext)
                                
                                // Init new transaction
                                let newTransaction = Transaction(subcategory: newSubcategory,
                                    date: transaction.date,
                                    title: transaction.name,
                                    amount: amountString!,
                                    notes: "",
                                    context: self.sharedContext)
                                
                                newTransaction.subcategory = newSubcategory
                                
                                // Save core data
                                do {
                                    try self.sharedContext.save()
                                } catch let error as NSError {
                                    print("Could not save \(error), \(error.userInfo)")
                                }
                                
                                // Add new objects to fetched objects
                                self.executeFetch()
                            }
                        } else if let categoryFirstIndex = transaction.category![1] as? String {
                            let subcategory = self.fetchedResultsController.fetchedObjects as! [Subcategory]
                            let foundSubcategory = subcategory.filter{$0.subTitle == categoryFirstIndex}.first
                        
                            if foundSubcategory != nil {
                                // Init new transaction
                                dispatch_async(dispatch_get_main_queue()) {
                                    let newTransaction = Transaction(subcategory: foundSubcategory!,
                                        date: transaction.date,
                                        title: transaction.name,
                                        amount: amountString!,
                                        notes: "",
                                        context: self.sharedContext)
                            
                                    newTransaction.subcategory = foundSubcategory!
                            
                                    // Save to Core Data
                                    do {
                                        try self.sharedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save \(error), \(error.userInfo)")
                                    }
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    // Init new category
                                    let newCategory = Category(catTitle: "Other", context: self.sharedContext)
                                    
                                    // Init new subcategory
                                    let newSubcategory = Subcategory(category: newCategory,
                                        subTitle: categoryFirstIndex,
                                        totalAmount: "$0.00",
                                        context: self.sharedContext)
                                    
                                    // Init new transaction
                                    let newTransaction = Transaction(subcategory: newSubcategory,
                                        date: transaction.date,
                                        title: transaction.name,
                                        amount: amountString!,
                                        notes: "",
                                        context: self.sharedContext)
                            
                                    newTransaction.subcategory = newSubcategory
                            
                                    // Save core data
                                    do {
                                        try self.sharedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save \(error), \(error.userInfo)")
                                    }
                            
                                    // Add new objects to fetched objects
                                    self.executeFetch()
                                }
                            }
                        }
                    }
                    
                    // Return to Budget view
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
//                    self.downloadedTransactions = transactions
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self.performSegueWithIdentifier("downloadedTransactions", sender: self)
//                    }
                // MFA response needed
                case 201:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkMfaType(mfaType, mfa: mfa)
                    }
                // User error
                case 400...404:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // Server error
                default:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Server error",
                            message: "Please try again at a later time.")
                    }
                }
            // Network error
            } else {
                dispatch_async(dispatch_get_main_queue()) {
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

extension AccountTableViewController {
    
//    // Transfer downloaded transactions data to dowloadedTransVC
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "downloadedTransactions") {
//            let downloadedTransVC = segue.destinationViewController as!
//            DownloadedTransViewController
//            downloadedTransVC.transactions = self.downloadedTransactions
//        }
//    }
    
    // Error alert
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Check if MFA type is questions or code
    func checkMfaType(mfaType: String?, mfa: String?) {
        if mfaType == "questions" {
            self.displayResponseAlert(mfa!)
        } else {
           // TODO: handle code based mfa
        }
    }
    
    // Text field for MFA question response
    func addTextField(textField: UITextField!) {
        responseTextField = textField
        responseTextField!.placeholder = "Enter your response."
    }
    
    // Display alert with text field for MFA question response
    func displayResponseAlert(message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: { (alertController) -> Void in
            self.submitMfaQuestionsResponse()
            })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Submit MFA answer
    func submitMfaQuestionsResponse() {
        PlaidClient.sharedInstance().PS_submitMFAResponse(PlaidData.sharedInstance().accessToken!, code: false, response: responseTextField!.text!) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            // Check response code
            if response != nil {
                let response = response as! NSHTTPURLResponse
                
                switch response.statusCode {
                // Successful
                case 200:
                    print("successful")
                // MFA response needed
                case 201:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkMfaType(mfaType, mfa: mfa)
                    }
                // User error
                case 400...404:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // Server error
                default:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Server error",
                            message: "Please try again at a later time.")
                    }
                }
            // Network error
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Network error",
                        message: "Please check your network connection and try again.")
                }
            }
        }
    }
    
    // Execute fetch request
    func executeFetch() {
        do {
            // Add subcategory to fetched objects
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
//    // Use category IDs to return a subcategory string
//    func catIdToSubcatString(id: Int) -> String {
//        switch id {
//        case 10000000...11000000:
//            return "Bank Fees"
//        case 12000000...12001000, 12003000, 12013000, 12015000...12017000, 12019000, 12019001:
//            return "Community"
//        case 12002000...12002002, 12006000, 12007000...14002020:
//            return "Healthcare"
//        case 12005000, 12008000...12008011, 19029000:
//            return "Education"
//        case 12004000, 12009000...12012003, 12014000:
//            return "Government"
//        case 12018000...12018004:
//            return "Religion"
//        case 13001000...13003000:
//            return "Bars & Breweries"
//        case 13004000...13004006:
//            return "Nightlife"
//        case 13000000, 13005000...13005059:
//            return "Restaurants"
//        case 15000000...15002000:
//            return "Interest"
//        case 16000000, 16001000, 16003000:
//            return "Payment"
//        case 16002000:
//            return "Mortgage & Rent"
//        case 16002000...17001019:
//            return "Arts & Entertainment"
//        case 17001000, 17002000...17022000, 17024000, 17026000, 17028000...17048000:
//            return "Recreation"
//        case 17023000...17023004, 17025000...17025005, 17027000...17027003:
//            return "Parks & Outdoors"
//        case 18001000...18001010:
//            return "Advertising & Marketing"
//        case 18006000...18006009:
//            return "Automotive Services"
//        case 18007000...18008001:
//            return "Business Services"
//        case 18009000, 18031000, 18068000...18068005:
//            return "Utilities"
//        case 18012000...18012002:
//            return "Computer Repair"
//        case 18013000...18013010:
//            return "Construction"
//        case 18020000...18020014:
//            return "Financial Services"
//        case 18024000...18025000:
//            return "Home Improvement"
//        case 18030000:
//            return "Insurance"
//        case 18037000...18037020:
//            return "Manufacturing"
//        case 18045000...18045010:
//            return "Personal Care"
//        case 18050000...18050010:
//            return "Real Estate"
//        case 18000000, 18003000...18005000, 18010000, 18011000, 18014000...18019000, 18021000...18023000, 18026000...18029000, 18032000...18036000, 18038000...18044000, 18046000...18049000, 18051000...18067000, 18069000...18074000:
//            return "Services"
//        case 19005000...19005007:
//            return "Automotive Purchases"
//        case 19012000...19012008:
//            return "Clothing & Accessories"
//        case 19013000...19013003:
//            return "Computers & Electronics"
//        case 19025000...19025004, 19047000:
//            return "Groceries"
//        case 19040000...19040008:
//            return "Outlets"
//        case 19043000:
//            return "Pharmacy"
//        case 19000000...19004000, 19006000...19011000, 19014000...19024000, 19027000...19039000, 19041000, 19042000, 19044000...19046000, 19048000...19054000:
//            return "Shopping"
//        case 19026000:
//            return "Auto Gas & Oil"
//        case 20000000...20002000:
//            return "Taxes"
//        case 21000000...21013000:
//            return "Transfer"
//        case 22000000...22018000:
//            return "Travel"
//        default:
//            return "Other"
//        }
//    }
}
