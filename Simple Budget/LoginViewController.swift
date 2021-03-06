//
//  LoginViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
// MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
// MARK: - Variable
    var textDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DropDownViewController().getCurrentMonthYear()
        
        // Text delegates
        usernameField.delegate = textDelegate
        passwordField.delegate = textDelegate
    }
    
    override func viewDidAppear(animated: Bool) {
        // Redirect to CreateUserVC if app is being launched for the first time
        if NSUserDefaults.standardUserDefaults().valueForKey("username") == nil {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("CreateUser") as! CreateUserViewController
            
            presentViewController(controller, animated: true, completion: nil)
        }
    }

// MARK: - Actions
    
    // Login button tapped
    @IBAction func userLogin(sender: AnyObject) {
        let checkUser = NSUserDefaults.standardUserDefaults().stringForKey("username")
        let checkPassword = NSUserDefaults.standardUserDefaults().stringForKey("password")
        
        // Present BudgetVC if username and password are correct
        if usernameField.text == checkUser && passwordField.text == checkPassword {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetNavController") as! UINavigationController
            presentViewController(controller, animated: true, completion: nil)
        } else {
            // Otherwise display error message
            displayAlert()
        }
    }

// MARK: - Methods
    
    // Alert view for incorrect user inputs.
    func displayAlert() {
        let alertController = UIAlertController(title: "Username/password incorrect", message: "Please try again.", preferredStyle: .Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

