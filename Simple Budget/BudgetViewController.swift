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
    
        //tableView.registerClass(CustomHeaderCell.self, forHeaderFooterViewReuseIdentifier: "HeaderCell")
        
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
//        let primarySortDescriptor = NSSortDescriptor(key: "catTitle", ascending: true)
//        let secondarySortDescriptor = NSSortDescriptor(key: "subcategory", ascending: true)
//        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        let sortDescriptor = NSSortDescriptor(key: "catTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "catTitle",
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
        
        let indexPath = tableView.indexPathForSelectedRow()
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! BudgetSubcategoryCell
        let headerView = tableView.headerViewForSection(indexPath!.section)
        
        // Init the Subcategory object
        let newSubcategory = Subcategory(subTitle: cell.subcategoryTitle.text, totalAmount: cell.amountTextField.text!, context: self.sharedContext)
        
        //let newCategory = Category(catTitle: , subcategory: newSubcategory, context: self.sharedContext)
        
        
        // Add subcategory to fetched objects
        fetchedResultsController.performFetch(nil)
        
        // Save to Core Data
        dispatch_async(dispatch_get_main_queue()) {
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
}

// MARK: - Table view data source and delegate
    
extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {

    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fetchedResultsController.fetchedObjects != nil {
            if let sections = fetchedResultsController.sections {
                return sections.count
            }
        }
        return testData.count
    }

    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects != nil {
            if let sections = fetchedResultsController.sections {
                let currentSection: AnyObject = sections[section]
                return currentSection.numberOfObjects
            }
        }
        return testData.count
    }

    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BudgetSubcategoryCell", forIndexPath: indexPath) as! BudgetSubcategoryCell
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        
        // Set title and amount values
        cell.subcategoryTitle.text = subcategory.subTitle
        cell.amountTextField.text = subcategory.totalAmount

        return cell
     }
        
    // Defines the custom header cells.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
        headerCell.backgroundColor = UIColor.whiteColor()
        
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            headerCell.titleLabel.text = currentSection.name
        } else {
            headerCell.titleLabel.text = "New Category"
        }
        
//        // Create header view
//        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        headerView.contentView.backgroundColor = UIColor.whiteColor()
//        
//        // Create title label
//        var titleLabel = UILabel(frame: CGRectMake(0, 0, 200, 27))
//        titleLabel.textColor = UIColor.darkGrayColor()
//        titleLabel.font = UIFont(name: "Avenir-Book", size: 17.0)
//        titleLabel.textAlignment = NSTextAlignment.Left
//        
//        if let sections = fetchedResultsController.sections {
//            let currentSection: AnyObject = sections[section]
//            titleLabel.text = currentSection.name
//        }
//
//        // Create "Planned" label
//        var plannedLabel = UILabel(frame: CGRectMake(0, 0, 80, 27))
//        plannedLabel.text = "Planned"
//        plannedLabel.textColor = UIColor.lightGrayColor()
//        plannedLabel.font = UIFont(name: "Avenir-Book", size: 17.0)
//        plannedLabel.textAlignment = NSTextAlignment.Right
//        
//        // Add labels to header view
//        headerView.contentView.addSubview(titleLabel)
//        headerView.contentView.addSubview(plannedLabel)
//    
//        return headerView
        
        return headerCell
    }
    
    // Header view height
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
    
    // Footer cell height
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

// MARK: - Additional Methods

extension BudgetViewController {
    
    // Load json file that contains default categories data
    func loadDefaultData() {
        // Create filepath
        var filepath:String = NSBundle.mainBundle().pathForResource("defaults", ofType: "json")!
        
        // Create optional for NSError
        var error:NSError?
        
        // Retrieve Data
        var JSONData = NSData(contentsOfFile: filepath, options: NSDataReadingOptions.DataReadingMapped, error: &error)
        // Create another error optional
        var jsonerror:NSError?
        // We don't know the type of object we'll receive back so use AnyObject
        let swiftObject:AnyObject = NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.AllowFragments, error:&jsonerror)!
        // JSONObjectWithData returns AnyObject so the first thing to do is to downcast this to a known type
        if let nsDictionaryObject = swiftObject as? NSDictionary {
            if let swiftDictionary = nsDictionaryObject as Dictionary? {
                println(swiftDictionary)
            }
        }
        else if let nsArrayObject = swiftObject as? NSArray {
            if let swiftArray = nsArrayObject as Array? {
                println(swiftArray)
            }
        }
    }
}
