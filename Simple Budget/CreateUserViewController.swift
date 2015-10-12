//
//  CreateUserViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    
    var textDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.delegate = textDelegate
        self.passwordField.delegate = textDelegate
    }

    @IBAction func createUser(sender: AnyObject) {
        if usernameField.text.isEmpty {
            println("no username")
        }
        else if passwordField.text.isEmpty {
            println("no password")
        } else {
            
            let newUsername = usernameField.text
            let newPassword = passwordField.text
            
            NSUserDefaults.standardUserDefaults().setValue(newUsername, forKey: "username")
            NSUserDefaults.standardUserDefaults().setValue(newPassword, forKey: "password")
        }
    }
}
