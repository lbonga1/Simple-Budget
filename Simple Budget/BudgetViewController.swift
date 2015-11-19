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
    
// MARK: - Variables
    var currentlyEditingCategory = 0
    var chosenSubcategory: Subcategory?
    var newSubcategory: Subcategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the add button on the right side of the navigation toolbar.
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = connectButton
        
        // Fetched results controller
        self.executeFetch()
        fetchedResultsController.delegate = self
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
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! UINavigationController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Add new Subcategory
    @IBAction func addItemAction(sender: UIButton) {
        // Change navigation items
        self.parentViewController!.navigationItem.leftBarButtonItem = cancelButton
        self.parentViewController!.navigationItem.rightBarButtonItem = doneButton
        
        // Set current category to selected "add item" button's tag
        currentlyEditingCategory = sender.tag
        
        //self.tableView.beginUpdates()
        
        self.addNewSubcategory()
        
        self.executeFetch()
        
        self.tableView.reloadData()
        
        //self.tableView.endUpdates()
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = connectButton
        
        self.tableView.beginUpdates()

        self.deleteLastObject()
        
        self.executeFetch()
        
        self.tableView.reloadData()
        
        self.tableView.endUpdates()
    }
    
    @IBAction func doneEditing(sender: AnyObject) {
        // Change navigation items
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController!.navigationItem.leftBarButtonItem = nil
        
        // Init new subcategory and save to core data
        self.updateNewSubcategory()
        
        self.executeFetch()
    }
    
    // Add new bank account
    @IBAction func connectAction(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewAccountNavController") as! UINavigationController
        
        self.presentViewController(controller, animated: true, completion: nil)
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
        
        cell.amountUpdateHandler = { [unowned self] (currentCell: BudgetSubcategoryCell) -> Void in
            guard let path = tableView.indexPathForRowAtPoint(currentCell.center) else { return }
            let subcategory = self.fetchedResultsController.objectAtIndexPath(path) as! Subcategory
            print("the selected item is \(subcategory.subTitle), currently \(subcategory.totalAmount), change to \(cell.amountTextField.text)")
            
            let batchRequest = NSBatchUpdateRequest(entityName: "Subcategory")
            batchRequest.propertiesToUpdate = ["totalAmount": cell.amountTextField.text!]
            batchRequest.predicate = NSPredicate(format: "subTitle == %@", subcategory.subTitle)
            batchRequest.resultType = .UpdatedObjectsCountResultType
            (try! self.sharedContext.executeRequest(batchRequest)) as! NSBatchUpdateResult
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
                headerView?.textLabel!.text = currentSection.name
            }
        } else {
            headerView!.textLabel!.text = "New Category"
        }
        
        return headerView!

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
        footerCell.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.01)
        
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
        
        return 25
    }
    
    // Segue to TransactionsViewController upon selecting a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row to make it visually reselectable.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Set chosenSubcategory to the correct Subcategory object from fetchedResultsController
        chosenSubcategory = fetchedResultsController.objectAtIndexPath(indexPath) as? Subcategory
        
        // Push TransacationsViewController
        self.performSegueWithIdentifier("displayTransactions", sender: chosenSubcategory)
    }
}

// MARK: - Fetched Results Controller Delegate

extension BudgetViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let updateIndexPath = indexPath {
                let cell = self.tableView.cellForRowAtIndexPath(updateIndexPath) as! BudgetSubcategoryCell
                let subcategory = self.fetchedResultsController.objectAtIndexPath(updateIndexPath) as? Subcategory
                
                cell.subcategoryTitle.text = subcategory?.subTitle
                cell.amountTextField.text = subcategory?.totalAmount
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

// MARK: - Additional Methods

extension BudgetViewController {
    
    // Transfer chosen subcategory data to view transactions
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
    
    // Support for adding a new subcategory
    func addNewSubcategory() {
//        // Inserts new row into the table
//        let lastRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
//        let indexPath = NSIndexPath(forRow: lastRowIndex, inSection: currentlyEditingCategory)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        // Get Category data from existing subcategory
        let existingRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory)
        let existingRowIndexPath = NSIndexPath(forRow: existingRowIndex, inSection: currentlyEditingCategory)
        let existingSubcategory = fetchedResultsController.objectAtIndexPath(existingRowIndexPath) as! Subcategory
        let category = existingSubcategory.category
        
        // Init new subcategory object
        newSubcategory = Subcategory(category: category, subTitle: "New Subcategory", totalAmount: "$0.00", context: self.sharedContext)
        
        do {
            // Save to core data
            try self.sharedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // Support for updating new subcategory object
    func updateNewSubcategory() {
        // Define the index path of the added Subcategory cell and cast as BudgetSubcategoryCell
        let lastRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let indexPath = NSIndexPath(forRow: lastRowIndex, inSection: currentlyEditingCategory)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BudgetSubcategoryCell
        
        // Perform batch update request
        let batchRequest = NSBatchUpdateRequest(entityName: "Subcategory")
        batchRequest.propertiesToUpdate = [
            "subTitle": cell.subcategoryTitle.text!,
            "totalAmount": cell.amountTextField.text!
        ]
        batchRequest.predicate = NSPredicate(format: "subcategory == %@", newSubcategory!)
        batchRequest.resultType = .UpdatedObjectsCountResultType
        (try! self.sharedContext.executeRequest(batchRequest)) as! NSBatchUpdateResult
        
    }
    
    // Cancel adding a new subcategory, and delete the last object added
    func deleteLastObject() {
        // Delete the last row added
        let lastRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let indexPath = NSIndexPath(forRow: lastRowIndex, inSection: currentlyEditingCategory)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        // Define and delete the last subcategory object added
        let objectToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.sharedContext.deleteObject(objectToDelete)
        
        // Save core data
        do {
            try self.sharedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // Execute fetch request
    func executeFetch() {
        do {
            // Add subcategory to fetched objects
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
