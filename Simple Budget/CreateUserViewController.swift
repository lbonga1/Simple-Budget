//
//  CreateUserViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {

// MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    
// MARK: - Variable
    var textDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text delegates
        self.usernameField.delegate = textDelegate
        self.passwordField.delegate = textDelegate
    }
    
// MARK: - Actions
    
    // Create user button tapped
    @IBAction func createUser(sender: AnyObject) {
        if usernameField.text!.isEmpty {
            // Display error message
            self.displayAlert()
        }
        else if passwordField.text!.isEmpty {
            // Display error message
            self.displayAlert()
        } else {
            let newUsername = usernameField.text
            let newPassword = passwordField.text
            
            // Save to NSUserDefaults
            NSUserDefaults.standardUserDefaults().setValue(newUsername, forKey: "username")
            NSUserDefaults.standardUserDefaults().setValue(newPassword, forKey: "password")
        }
        
        // Continue to Budget View Controller via navigation controller
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetNavController") as! UINavigationController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
// MARK: - Methods
    
    // Alert view for missing inputs.
    func displayAlert() {
        let alertController = UIAlertController(title: "Missing input", message: "Please complete all fields.", preferredStyle: .Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
