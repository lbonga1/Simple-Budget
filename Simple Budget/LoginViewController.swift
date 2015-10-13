//
//  LoginViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().valueForKey("username") == nil {
            let storyboard = self.storyboard
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("CreateUser") as! CreateUserViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func userLogin(sender: AnyObject) {
        var checkUser = NSUserDefaults.standardUserDefaults().stringForKey("username")
        var checkPassword = NSUserDefaults.standardUserDefaults().stringForKey("password")
        
        if usernameField.text == checkUser && passwordField.text == checkPassword {
            let storyboard = self.storyboard
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Budget") as! BudgetViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}

