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
    
    // Dismiss to budgeting view controllers
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        
        let instName = self.stringToInstitution(string: institutionLabel.text!)
        
        PS_addUser(.Connect, usernameTextField.text, passwordTextField.text, pinTextField.text, instName) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            // Respond to results
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

    func stringToInstitution(#string: String) -> Institution {
        var institution: Institution {
            switch string {
            case "American Express":
                return .amex
            case "Bank of America":
                return .bofa
            case "Capital One 360":
                return .capone360
            case "Chase":
                return .chase
            case "Citi":
                return .citi
            case "Fidelity":
                return .fidelity
            case "PNC":
                return .pnc
            case "Charles Schwab":
                return .schwab
            case "US Bank":
                return .us
            case "USAA":
                return .usaa
            case "Wells Fargo":
                return .wells
            default:
                break
            }
           return institution
        }
    }

}
