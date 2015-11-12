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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var institutionLabel: UILabel!
    
// MARK: - Variables
    let textDelegate = TextFieldDelegate()
    let plaid = Plaid()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
// MARK: - Actions
    
    
    @IBAction func doneAction(sender: AnyObject) {
        
        //let instName = self.stringToInstitution(string: institutionLabel.text!)
        
        PS_addUser(.Connect, usernameTextField.text, passwordTextField.text, pinTextField.text, Institution.wells) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
     
            if response != nil {
                let response = response as! NSHTTPURLResponse
                
                switch response.statusCode {
                case 200:
                    println("test success")
                case 201:
                    println("mfa required")
                case 400:
                    self.displayAlert("Could not log in",
                        message: "Please check your credentials and try again.")
                case 401:
                    self.displayAlert("Could not log in",
                        message: "Please check your credentials and try again.")
                case 402:
                    self.displayAlert("Could not log in",
                        message: "Please check your credentials and try again.")
                case 403:
                    self.displayAlert("Could not log in",
                        message: "Please check your credentials and try again.")
                case 404:
                    self.displayAlert("Could not log in",
                        message: "Please check your credentials and try again.")
                default:
                    self.displayAlert("Server error",
                        message: "Please try again at a later time.")
                }
            } else {
                 dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Network error",
                        message: "Please check your network connection and try again.")
                }
            }
        }
    }
        
    
// MARK: - Tableview Delegate
    
//    // Presents CatChooserTableViewController to make a category selection
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        // Deselect row to make it visually reselectable.
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        // Present Category Chooser
//        let storyboard = self.storyboard
//        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryChooser") as! UINavigationController
//        self.presentViewController(controller, animated: true, completion: nil)
//    }
    
    // Make only "Choose Institution" row selectable
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row != 0 {
            return false
        } else {
            return true
        }
    }
}

extension AccountTableViewController {
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addTextField(textField: UITextField!){
        textField.placeholder = "Enter your response."
    }
    
    func displayResponseAlert(message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

//    func stringToInstitution(#string: String) -> Institution {
//        var institution: Institution {
//            switch string {
//            case "American Express":
//                return .amex
//            case "Bank of America":
//                return .bofa
//            case "Capital One 360":
//                return .capone360
//            case "Chase":
//                return .chase
//            case "Citi":
//                return .citi
//            case "Fidelity":
//                return .fidelity
//            case "PNC":
//                return .pnc
//            case "Charles Schwab":
//                return .schwab
//            case "US Bank":
//                return .us
//            case "USAA":
//                return .usaa
//            case "Wells Fargo":
//                return .wells
//            default:
//                break
//            }
//           return institution
//        }
//    }
    
}
