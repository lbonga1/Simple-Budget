//
//  AccountTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/9/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

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
    let instData = ["American Express", "Bank of America", "Capital One 360", "Charles Schwab", "Chase", "Citi Bank", "Fidelity", "PNC", "US Bank", "USAA", "Wells Fargo"]

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
    }
    
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
        PlaidClient.sharedInstance().PS_addUser(.Connect, username: usernameTextField.text!, password: passwordTextField.text!, pin: pinTextField.text, institution: institution!) {  (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            
            // Check response code
            if response != nil {
                let response = response as! NSHTTPURLResponse
                
                switch response.statusCode {
                // Successful
                case 200:
                    self.dismissViewControllerAnimated(true, completion: nil)
                // MFA response needed
                case 201:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkMfaType(mfaType, mfa: mfa)
                    }
                // User error
                case 400:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 401:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 402:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 403:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 404:
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
    
    
//    @IBAction func doneAction(sender: AnyObject) {
//        self.navigationItem.rightBarButtonItem = saveButton
//        instPicker.hidden = true
//    }
    
    
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

extension AccountTableViewController {
    
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
        PlaidClient.sharedInstance().PS_submitMFAResponse(PlaidData.sharedInstance().accessToken, code: false, response: responseTextField!.text!) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
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
                case 400:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 401:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 402:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 403:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Could not log in",
                            message: "Please check your credentials and try again.")
                    }
                // User error
                case 404:
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
}
