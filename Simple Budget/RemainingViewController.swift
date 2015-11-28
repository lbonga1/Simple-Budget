//
//  RemainingViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/22/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class RemainingViewController: UIViewController {

// MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet weak var savedLabel: UILabel!
    
// MARK: - Variables
    var amountArray: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the add button on the right side of the navigation toolbar.
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        
        // Fetched Results Controller
        self.executeFetch()
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Saved categories label is hidden if there are categories to display.
        if fetchedResultsController.fetchedObjects!.count == 0 {
            savedLabel.hidden = false
        } else {
            savedLabel.hidden = true
        }
        
        // Reload data in case transactions are added from another tab.
        self.tableView.reloadData()
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Subcategory")
        let sortDescriptor = NSSortDescriptor(key: "category.catTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "category.catTitle",
            cacheName: nil)
        
        return fetchedResultsController
        }()

// MARK: - Actions
    
    // Presents NewTransTableViewController to add a new transaction.
    @IBAction func addNewTransaction(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! UINavigationController
        
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}

extension RemainingViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemSubcatCell", forIndexPath: indexPath)
        
        // Set title and amount values
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        cell.textLabel!.text = subcategory.subTitle
        
        // Cast transactions NSSet as an array
        let transactions = subcategory.transactions.allObjects as! [Transaction]
        
        // Convert amount strings to floats, then get the sum
        for transaction in transactions {
            // Define the transaction amount
            let transaction = transaction as Transaction
            let amountString = transaction.amount
            // Remove the "," and "$"
            let dropCommaInString = amountString.stringByReplacingOccurrencesOfString(",", withString: "")
            let editedString = dropCommaInString.stringByReplacingOccurrencesOfString("$", withString: "")
            // Convert to Float
            let amountFloat = Float(editedString)
            
            // Add the value to the amountArray
            amountArray.append(amountFloat!)
        }
        
        if transactions.count != 0 {
            // Find the sum of the values in the amountArray
            let sum = amountArray.sum()

            // Convert Subcategory budget amount to float
            let subcatAmountString = subcategory.totalAmount
            let dropCommaInString = subcatAmountString.stringByReplacingOccurrencesOfString(",", withString: "")
            let subcatEditedString = dropCommaInString.stringByReplacingOccurrencesOfString("$", withString: "")
            let subcatAmountFloat = Float(subcatEditedString)
        
            // Find the remaining amount
            let remainingAmount = (subcatAmountFloat! - sum)
        
            // Format the remaining amount back into a string
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            formatter.locale = NSLocale(localeIdentifier: "en_US")
            let remAmountString = formatter.stringFromNumber(remainingAmount)
        
            // Set amount label value
            cell.detailTextLabel!.text = remAmountString
        } else {
            cell.detailTextLabel!.text = "$0.00"
        }
        
        // Empty the amountArray for the next Transaction array values
        amountArray.removeAll()
        
        return cell
    }
    
    // Customize header text label before view is displayed
    func tableView(tableView:UITableView, willDisplayHeaderView view:UIView, forSection section:Int) {
        if let headerView: CustomHeaderView = view as? CustomHeaderView {
            headerView.configureTextLabel()
        }
    }
    
    // Defines the custom header cells.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as? CustomHeaderView
        
        if (headerView == nil) {
            // Customize background color and text color
            let textColor = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0)
            headerView = CustomHeaderView(backgroundColor: UIColor.whiteColor(), textColor: textColor)
        }
        
        // Set title label text
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            headerView?.textLabel!.text = currentSection.name
        }
        
        return headerView
    }
    
    // Height for headerview
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    // Defines the footer view.
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Create footer view
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
        footerView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.1)
        
        return footerView
    }

    // Height for footerview
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 25
    }
}

// MARK: - Fetched Results Controller Delegate

extension RemainingViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) { }
}

// MARK: - Additional Methods

extension RemainingViewController {
    
    // Execute fetch request
    func executeFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
