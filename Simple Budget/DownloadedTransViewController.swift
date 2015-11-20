//
//  DownloadedTransViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/19/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class DownloadedTransViewController: UIViewController {
    
// MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    
// MARK: - Variables
    
    var transactions: [PlaidClient.Transactions]!
    var selectedSubcategory: Subcategory!
    var tag: Int = 1
    var newDateString: String?
    var titleText: String?
    var dateText: String?
    var amountDouble: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation bar button items.
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton
    }

// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
// MARK: - Actions
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
    }
    
    @IBAction func unwindSegueCatChosen(unwindSegue: UIStoryboardSegue) {
        if let catChooser = unwindSegue.sourceViewController as? CatChooserTableViewController {
            selectedSubcategory = catChooser.selectedSubcategory
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chooseCategory") {
            let catChooserTVC = segue.destinationViewController as!
            CatChooserTableViewController
            catChooserTVC.tag = self.tag
        }
    }
}

// MARK: - Table view data source

extension DownloadedTransViewController: UITableViewDataSource {
    
    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
}

// MARK: - Table view delegate

extension DownloadedTransViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TransactionsCell", forIndexPath: indexPath) as! TransactionCell
        
        for transaction in transactions {
            self.titleText = transaction.name
            self.dateText = transaction.date
            self.amountDouble = transaction.amount
        }
        
        // Set title label value
        cell.titleLabel.text = self.titleText
        
        // Set date label value
        cell.dateLabel.text = self.dateText
        
        //Format the transaction amount into a currency string
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let amountString = formatter.stringFromNumber(self.amountDouble!)
        
        // Set amount label value
        cell.amountLabel.text = amountString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row to make it visually reselectable.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Push TransacationsViewController
        self.performSegueWithIdentifier("chooseCategory", sender: self)
    }
}
