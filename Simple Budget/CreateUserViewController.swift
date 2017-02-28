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
        usernameField.delegate = textDelegate
        passwordField.delegate = textDelegate
    }
    
// MARK: - Actions
    
    // Create user button tapped
    @IBAction func createUser(_ sender: AnyObject) {
        if usernameField.text!.isEmpty {
            // Display error message
            displayAlert()
        }
        else if passwordField.text!.isEmpty {
            // Display error message
            displayAlert()
        } else {
            let newUsername = usernameField.text
            let newPassword = passwordField.text
            
            // Save to NSUserDefaults
            UserDefaults.standard.setValue(newUsername, forKey: "username")
            UserDefaults.standard.setValue(newPassword, forKey: "password")
        }
        
        // Continue to Budget View Controller via navigation controller
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BudgetNavController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
// MARK: - Methods
    
    // Alert view for missing inputs.
    func displayAlert() {
        let alertController = UIAlertController(title: "Missing input", message: "Please complete all fields.", preferredStyle: .alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
