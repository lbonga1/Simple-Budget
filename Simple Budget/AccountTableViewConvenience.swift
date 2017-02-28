//
//  AccountTableViewConvenience.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/23/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

extension AccountTableViewController {
    
    // Check response code and provide proper solution
    func checkResponseCode(_ response: HTTPURLResponse, transactions: [PlaidClient.Transactions]?, mfaType: String?, mfa: String?) {
        switch response.statusCode {
            // Successful
        case 200:
            // Sort/categorize downloaded transactions
            createTempTransactions(transactions!)
            // Hide activity view
            activityView.stopAnimating()
            // Return to Budget view
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(AccountTableViewController.dismiss as (AccountTableViewController) -> () -> ()), userInfo: nil, repeats: false)
            }
            
            // MFA response needed
        case 201:
            DispatchQueue.main.async {
                // Hide activity view
                self.activityView.stopAnimating()
                // Submit MFA responses
                self.checkMfaType(mfaType, mfa: mfa)
            }
            // User error
        case 400...404:
            DispatchQueue.main.async {
                // Hide activity view
                self.activityView.stopAnimating()
                // Display alert
                self.displayAlert("Could not log in",
                    message: "Please check your credentials and try again.")
            }
            // Server error
        default:
            DispatchQueue.main.async {
                // Hide activity view
                self.activityView.stopAnimating()
                // Display alert
                self.displayAlert("Server error",
                    message: "Please try again at a later time.")
            }
        }
    }
    
    // Check if MFA type is questions or code
    func checkMfaType(_ mfaType: String?, mfa: String?) {
        if mfaType == "questions" {
            displayResponseAlert(mfa!)
        } else {
            // TODO: handle code based mfa
        }
    }
    
    // Submit MFA answer
    func submitMfaQuestionsResponse() {
        PlaidClient.sharedInstance().PS_submitMFAResponse(self.accessToken!, code: false, response: responseTextField!.text!) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            // Check response code
            if response != nil {
                let response = response as! HTTPURLResponse
                // Check response code and give solution
                self.checkResponseCode(response, transactions: transactions!, mfaType: mfaType!, mfa: mfa!)
                // Network error
            } else {
                DispatchQueue.main.async {
                    // Hide activity view
                    self.activityView.stopAnimating()
                    // Display alert
                    self.displayAlert("Network error",
                        message: "Please check your network connection and try again.")
                }
            }
        }
    }
    
    // Categorize transactions, and create array of temporary transactions
    func createTempTransactions(_ transactions: [PlaidClient.Transactions]) {
        DispatchQueue.main.async {
            // Iterate through transactions
            for transaction in transactions {
                // Format the transaction amount into a currency string
                let amountString = PlaidClient().doubleToCurrency(transaction.amount)
                // Format the date style to short style
                let newDateString = PlaidClient().dateFormatter(transaction.date)
                
                // Downloaded transaction has no category data
                if transaction.category == nil {
                    // Create temp transaction with "Other" category and subcategory
                    let tempTransaction = PlaidClient.TempTransaction(catTitle: "Other", subTitle: "Other", date: newDateString, title: transaction.name, amount: amountString)
                    self.tempTransactions.append(tempTransaction)
                    
                    // Transaction category array contains one value
                } else if transaction.category!.count == 1 {
                    // Recategorize
                    let categoryFirstIndex = transaction.category![0] as! String
                    let newCatString = PlaidClient().changeCatString(categoryFirstIndex)
                    // Create temp transaction with available category and "Other" subcategory
                    let tempTransaction = PlaidClient.TempTransaction(catTitle: newCatString, subTitle: "Other", date: newDateString, title: transaction.name, amount: amountString)
                    self.tempTransactions.append(tempTransaction)
                    
                    // Transaction category array has more than one value
                } else {
                    // Recategorize
                    let categoryFirstIndex = transaction.category![0] as! String
                    let newCatString = PlaidClient().changeCatString(categoryFirstIndex)
                    // Regroup subcategories
                    let categorySecondIndex = transaction.category![1] as! String
                    let newSubcatString = PlaidClient().changeSubcatString(categorySecondIndex)
                    // Create temp transaction with available category and subcategory
                    let tempTransaction = PlaidClient.TempTransaction(catTitle: newCatString, subTitle: newSubcatString, date: newDateString, title: transaction.name, amount: amountString)
                    self.tempTransactions.append(tempTransaction)
                }
            }
            // Sort the transactions
            self.sortTempTransactions()
        }
    }
    
    // Sort temporary transactions into their correct category/subcategory
    func sortTempTransactions() {
        DispatchQueue.main.async{
            let subcategories = self.fetchedResultsController.fetchedObjects! as [Subcategory]
            let categories = subcategories.map { $0.category }
            // Iterate through temporary transactions
            for transaction in self.tempTransactions {
                // Search for Category in fetched objects
                let foundCategory = categories.filter{$0.catTitle == transaction.catTitle}.first
                // Search for Subcategory in fetched objects
                let foundSubcategory = subcategories.filter{$0.subTitle == transaction.subTitle}.first
                
                // Category was not found in fetched objects
                if foundCategory == nil {
                    // createdCategories is empty
                    if self.createdCategories.count == 0 {
                        // Init category/subcategory/transaction
                        let newCategory = Category(catTitle: transaction.catTitle!, context: self.sharedContext)
                        let newSubcategory = Subcategory(category: newCategory, subTitle: transaction.subTitle!, totalAmount: "$0.00", context: self.sharedContext)
                        let newTransaction = Transaction(subcategory: newSubcategory, date: transaction.date, title: transaction.title, amount: transaction.amount, notes: "", context: self.sharedContext)
                        newTransaction.subcategory = newSubcategory
                        
                        // Append created category and subcategory to arrays
                        self.createdCategories.append(newCategory)
                        self.createdSubcategories.append(newSubcategory)
                    } else {
                        // Filter createdCategories by transaction's catTitle
                        var filteredCategories = self.createdCategories.filter({$0.catTitle == transaction.catTitle})
                        // Category was not found
                        if filteredCategories.count == 0 {
                            // Init category/subcategory/transaction
                            let newCategory = Category(catTitle: transaction.catTitle!, context: self.sharedContext)
                            let newSubcategory = Subcategory(category: newCategory, subTitle: transaction.subTitle!, totalAmount: "$0.00", context: self.sharedContext)
                            let newTransaction = Transaction(subcategory: newSubcategory, date: transaction.date, title: transaction.title, amount: transaction.amount, notes: "", context: self.sharedContext)
                            newTransaction.subcategory = newSubcategory
                            
                            // Append created category and subcategory to arrays
                            self.createdCategories.append(newCategory)
                            self.createdSubcategories.append(newSubcategory)
                            // Category was found
                        } else {
                            // Filter createdSubcategories by transaction's subTitle
                            var filteredSubcategories = self.createdSubcategories.filter({$0.subTitle == transaction.subTitle})
                            // Subcategory was not found
                            if filteredSubcategories.count == 0 {
                                // Init subcategory/transaction
                                let newSubcategory = Subcategory(category: filteredCategories[0], subTitle: transaction.subTitle!, totalAmount: "$0.00", context: self.sharedContext)
                                let newTransaction = Transaction(subcategory: newSubcategory, date: transaction.date, title: transaction.title, amount: transaction.amount, notes: "", context: self.sharedContext)
                                newTransaction.subcategory = newSubcategory
                                
                                // Append subcategory to array
                                self.createdSubcategories.append(newSubcategory)
                                // Subcategory was found
                            } else {
                                // Category and subcategory have been created, init transaction with their data
                                let newTransaction = Transaction(subcategory: filteredSubcategories[0], date: transaction.date, title: transaction.title, amount: transaction.amount, notes: "", context: self.sharedContext)
                                newTransaction.subcategory = filteredSubcategories[0]
                            }
                        }
                    }
                    // Category was found in core data
                } else {
                    // Subcategory was not found in core data
                    if foundSubcategory == nil {
                        // Filter createdSubcategories by transaction's subTitle
                        var filteredSubcategories = self.createdSubcategories.filter({$0.subTitle == transaction.subTitle})
                        // Subcategory was not found
                        if filteredSubcategories.count == 0 {
                            // Init subcategory/transaction
                            let newSubcategory = Subcategory(category: foundCategory!, subTitle: transaction.subTitle!, totalAmount: "$0.00", context: self.sharedContext)
                            let newTransaction = Transaction(subcategory: newSubcategory, date: transaction.date, title: transaction.title, amount: transaction.amount, notes: "", context: self.sharedContext)
                            newTransaction.subcategory = newSubcategory
                            
                            // Append subcategory to array
                            self.createdSubcategories.append(newSubcategory)
                        } else {
                            // Category and subcategory have been created, init transaction with their data
                            let newTransaction = Transaction(subcategory: filteredSubcategories[0], date: transaction.date, title: transaction.title, amount: transaction.amount, notes: "", context: self.sharedContext)
                            newTransaction.subcategory = filteredSubcategories[0]
                        }
                    }
                }
            }
            // Save to core data and perform fetch
            self.saveAndFetch()
        }
    }
    
// MARK: - Helper Funcs

    // Execute fetch request
    func executeFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Save to core data and execute fetch request
    func saveAndFetch() {
        // Save core data
        do {
            try sharedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        // Execute fetch request
        executeFetch()
    }
    
    // Error alert
    func displayAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Text field for MFA question response
    func addTextField(_ textField: UITextField!) {
        responseTextField = textField
        responseTextField!.placeholder = "Enter your response."
    }
    
    // Display alert with text field for MFA question response
    func displayResponseAlert(_ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: addTextField)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: { (alertController) -> Void in
            self.submitMfaQuestionsResponse()
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Support for dismissing view controller after time interval
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Get institution type from selected string
    func institutionFromString(_ instType: String) {
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
    }
    
// MARK: - Formatters
    
    // Double to currency style formatter
    func doubleToCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "en_US")
        let amountString = formatter.string(from: NSNumber(value:amount))
        
        return amountString!
    }
    
    // Date formatter to short style
    func dateFormatter(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDate = dateFormatter.date(from: dateString)
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateStyle = .short
        let newDateString = newDateFormatter.string(from: newDate!)
        
        return newDateString
    }
}
