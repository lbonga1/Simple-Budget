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
    @IBOutlet var connectButton: UIBarButtonItem!
    
    var testData: NSMutableArray = ["Test"]
    var currentlyEditingCategory = 0
    var currentlyEditingSubcategory: NSIndexPath? = nil
    var chosenSubcategory: Subcategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the add button on the right side of the navigation toolbar.
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = connectButton
        
        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
        println(fetchedResultsController.fetchedObjects)
    }

    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
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
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! UINavigationController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func addItemAction(sender: UIButton) {
        // Change navigation items
        self.parentViewController!.navigationItem.leftBarButtonItem = cancelButton
        self.parentViewController!.navigationItem.rightBarButtonItem = doneButton
        
        // Set current category to selected "add item" button's tag
        currentlyEditingCategory = sender.tag
        
        self.tableView.beginUpdates()
    
        
        // Defines the new cell to be added
        let newCell: AnyObject? = tableView.dequeueReusableCellWithIdentifier("BudgetSubcategoryCell") as! BudgetSubcategoryCell
        
    // TODO: ADD ITEM TO CORE DATA?
        self.testData.insertObject(newCell!, atIndex: self.testData.count)
        
        // Inserts new row into the table
        let lastRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let indexPath = NSIndexPath(forRow: lastRowIndex, inSection: currentlyEditingCategory)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        //currentlyEditingSubcategory = indexPath
        
        self.tableView.reloadData()
        
        self.tableView.endUpdates()
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = connectButton
        
        //TODO: REMOVE ITEM FROM CORE DATA?
        self.testData.removeLastObject()

        let lastRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let indexPath = NSIndexPath(forRow: lastRowIndex, inSection: currentlyEditingCategory)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        self.tableView.reloadData()
        
        self.tableView.endUpdates()
    }
    
    @IBAction func doneEditing(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = nil
        
        // Define the index path of the added Subcategory cell and cast as BudgetSubcategoryCell
        let lastRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let indexPath = NSIndexPath(forRow: lastRowIndex, inSection: currentlyEditingCategory)
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! BudgetSubcategoryCell
        
        let sectionHeaderView = tableView.headerViewForSection(currentlyEditingCategory)
        let sectionTitle = sectionHeaderView?.textLabel.text
            
        // Init the Category Object
        let newCategory = Category(catTitle: sectionTitle!, context: self.sharedContext)
        
        // Init the Subcategory object
        let newSubcategory = Subcategory(category: newCategory, subTitle: cell.subcategoryTitle.text!, totalAmount: cell.amountTextField.text!, context: self.sharedContext)
        
        // Add subcategory to fetched objects
        fetchedResultsController.performFetch(nil)
        
        // Save to Core Data
        dispatch_async(dispatch_get_main_queue()) {
            newSubcategory.category = newCategory
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
}

// MARK: - Table view data source
    
extension BudgetViewController: UITableViewDataSource {

    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 1
    }

    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            return currentSection.numberOfObjects
        }
        return 1
    }
}

// MARK: - Table view delegate

extension BudgetViewController: UITableViewDelegate {

    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BudgetSubcategoryCell", forIndexPath: indexPath) as! BudgetSubcategoryCell
        
        // Set title and amount values
        if fetchedResultsController.fetchedObjects!.count != 0 {
            let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
            cell.subcategoryTitle.text = subcategory.subTitle
            cell.amountTextField.text = subcategory.totalAmount
        } else {
            cell.subcategoryTitle.text = "New Subcategory"
            cell.amountTextField.text = "$0.00"
        }
        return cell
     }
    
    // Customize header text label before view is displayed
    func tableView(tableView:UITableView, willDisplayHeaderView view:UIView, forSection section:Int) {
        if let headerView: CustomHeaderView = view as? CustomHeaderView {
            headerView.configureTextLabel()
        }
    }
        
    // Defines the custom header view.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView: CustomHeaderView? = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerViewReuseIdentifier) as? CustomHeaderView

        if (headerView == nil) {
            // Customize background color and text color
            let textColor = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0)
            headerView = CustomHeaderView(backgroundColor: UIColor.whiteColor(), textColor: textColor)
        }
        // Set title label text
        if fetchedResultsController.fetchedObjects!.count != 0 {
            if let sections = fetchedResultsController.sections {
                let currentSection: AnyObject = sections[section]
                headerView?.textLabel.text = currentSection.name
            }
        } else {
            headerView!.textLabel.text = "New Category"
        }
        
        return headerView!
    

        
        
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
        
        //return headerView
    }
    
    // Header view height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
     
    // Defines the custom footer cells.
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! CustomFooterCell
        
        // Customize background color and button title
        footerCell.addItemButton.setTitle("+ Add Item", forState: .Normal)
        footerCell.backgroundColor = UIColor.whiteColor()
        
        // Get index path of "add item" button
        let pointInTable = footerCell.addItemButton.convertPoint(footerCell.addItemButton.bounds.origin, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        
        // Add tag and action to "add item" button
        if indexPath != nil {
            let currentSection = indexPath!.section
            footerCell.addItemButton.tag = currentSection
            footerCell.addItemButton.addTarget(self, action: Selector("addItemAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        }
            
        return footerCell
    }
    
    // Footer cell height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 32
    }

    // Editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
    
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Segue to TransactionsViewController upon selecting a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row to make it visually reselectable.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Cast chosenCell as BudgetSubcategoryCell
        let chosenCell = tableView.cellForRowAtIndexPath(indexPath) as! BudgetSubcategoryCell
        
        // Set chosenSubcategory value to the selected Subcategory
        chosenSubcategory = searchForSubcategory(chosenCell.subcategoryTitle.text!)
        
        // Push TransacationsViewController
        self.performSegueWithIdentifier("displayTransactions", sender: chosenSubcategory)
    }
}

// MARK: - Fetched Results Controller Delegate

extension BudgetViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case NSFetchedResultsChangeType.Insert:
                if let insertIndexPath = newIndexPath {
                    self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            case NSFetchedResultsChangeType.Delete:
                if let deleteIndexPath = indexPath {
                    self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            case NSFetchedResultsChangeType.Update:
                if let updateIndexPath = indexPath {
                    let cell = self.tableView.cellForRowAtIndexPath(updateIndexPath) as! BudgetSubcategoryCell
                    let subcategory = self.fetchedResultsController.objectAtIndexPath(updateIndexPath) as? Subcategory
                    
                    cell.subcategoryTitle.text = subcategory?.subTitle
                }
            case NSFetchedResultsChangeType.Move:
                if let deleteIndexPath = indexPath {
                    self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
                if let insertIndexPath = newIndexPath {
                    self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
    }
    
//    func controller(
//        controller: NSFetchedResultsController,
//        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
//        atIndex sectionIndex: Int,
//        forChangeType type: NSFetchedResultsChangeType) {
//            
//            switch type {
//            case .Insert:
//                let sectionIndexSet = NSIndexSet(index: sectionIndex)
//                self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
//            case .Delete:
//                let sectionIndexSet = NSIndexSet(index: sectionIndex)
//                self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
//            default:
//                ""
//            }
//    }

}

// MARK: - Additional Methods

extension BudgetViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayTransactions") {
            let transactionsVC = segue.destinationViewController as!
            TransactionsViewController
            transactionsVC.chosenSubcategory = self.chosenSubcategory
        }
    }
    
    // Support for finding selected Subcategory in core data
    func searchForSubcategory(subTitle: String) -> Subcategory {
        let subcategories = fetchedResultsController.fetchedObjects as! [Subcategory]
        
        return subcategories.filter { subcategory in
            subcategory.subTitle == subTitle
            }.first!
    }

    //    func deleteSubcategory() {
//        if let objectToDelete = self.subcatToDelete {
//            self.sharedContext.deleteObject(objectToDelete)
//            CoreDataStackManager.sharedInstance().saveContext()
//        }
//    }
}
