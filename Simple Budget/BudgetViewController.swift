//
//  BudgetViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class BudgetViewController: UIViewController {

// MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var testData: NSMutableArray = ["Test", "Test 2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the add button on the right side of the navigation toolbar.
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        
        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
// MARK: - Actions
    
    // Presents NewTransTableViewController to add a new transaction.
    @IBAction func addNewTransaction(sender: AnyObject) {
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! UINavigationController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func addItemAction(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.leftBarButtonItem = cancelButton
        self.parentViewController!.navigationItem.rightBarButtonItem = doneButton
        
        self.tableView.beginUpdates()
        // Defines the new cell to be added
        let newCell: AnyObject? = tableView.dequeueReusableCellWithIdentifier("BudgetSubcategoryCell") as! BudgetSubcategoryCell
        
        // Adds new cell to the array
        self.testData.insertObject(newCell!, atIndex: self.testData.count)
        
        // Inserts new row into the table
        var indexPath = NSIndexPath(forRow: self.testData.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        self.tableView.reloadData()
        
        self.tableView.endUpdates()
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = nil
        
        self.testData.removeLastObject()
        var indexPath = NSIndexPath(forRow: self.testData.count - 1, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        self.tableView.reloadData()
        
        self.tableView.endUpdates()
    }
    
    @IBAction func doneEditing(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = nil
        
//        var dictionary = [String : String]()
//        dictionary[Subcategory.Keys.Title] = "test"
//        dictionary[Subcategory.Keys.Amount] = "test"
//        
//        // Init the Subcategory object
//        let subcategory = Subcategory(dictionary: dictionary, context: self.sharedContext)
//        
//        // Add subcategory to fetched objects
//        fetchedResultsController.performFetch(nil)
//        
//        // Save to Core Data
//        dispatch_async(dispatch_get_main_queue()) {
//            CoreDataStackManager.sharedInstance().saveContext()
//        }
        
    }
    
// MARK: - Additional Methods
    // Defines intitial categories and subcategories
    func defaultCategories() -> [[String: AnyObject]] {
        return  [
            [
                "title": "Savings & Funds",
                "subcategories":
                    [
                        ["title": "Emergency Fund", "amount": "$0.00"]
                    ]
            ], [
                "title": "Housing",
                "subcategories":
                    [
                        ["title": "Mortgage", "amount": "$0.00"],
                        ["title": "Electricity", "amount": "$0.00"],
                        ["title": "Natural Gas/Propane", "amount": "$0.00"]
                    ]
            ], [
                "title": "Transportation",
                "subcategories":
                    [
                        ["title": "Auto Gas & Oil", "amount": "$0.00"]
                    ]
            ], [
                "title": "Food",
                "subcategories":
                    [
                        ["title": "Groceries", "amount": "$0.00"],
                        ["title": "Restaurants", "amount": "$0.00"]
                    ]
            ], [
                "title": "Lifestyle",
                "subcategories":
                    [
                        ["title": "Entertainment", "amount": "$0.00"],
                        ["title": "Clothing", "amount": "$0.00"]
                    ]
            ], [
                "title": "Insurance & Tax",
                "subcategories":
                    [
                        ["title": "Health Insurance", "amount": "$0.00"],
                        ["title": "Life Insurance", "amount": "$0.00"],
                        ["title": "Auto Insurance", "amount": "$0.00"]
                    ]
                ]
            ]
    }
    
}

// MARK: - Table view data source and delegate
    
extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {

    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let initialCategories = defaultCategories()
        
        if fetchedResultsController.fetchedObjects != nil {
            return fetchedResultsController.fetchedObjects!.count
        } else {
            return initialCategories.count
        }
    }

    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //let currentCategories = fetchedResultsController.fetchedObjects as? [Category]
        let initialCategories = defaultCategories()
        
        //return currentCategories[section].count
        return initialCategories[section].count
        //return testData[section].count
    }

    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BudgetSubcategoryCell", forIndexPath: indexPath) as! BudgetSubcategoryCell
        let category = fetchedResultsController.fetchedObjects as? [Category]
        
        cell.subcategoryTitle.text = category?[indexPath.row] as! String
        cell.amountTextField.text = "$0.00"

        return cell
     }
        
    // Defines the custom header cells.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
        
        headerCell.titleLabel.text = "Test title"
        headerCell.backgroundColor = UIColor.whiteColor()
        
        return headerCell
        
        }
        
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
     
    // Defines the custom footer cells.
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! CustomFooterCell
        
        footerCell.addItemButton.setTitle("+ Add Item", forState: .Normal)
        footerCell.backgroundColor = UIColor.whiteColor()
            
        return footerCell
    }
        
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 32
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
}

// MARK: - Fetched Results Controller Delegate

extension BudgetViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {   }
}
