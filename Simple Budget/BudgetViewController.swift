//
//  BudgetViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class BudgetViewController: DropDownViewController {

// MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var connectButton: UIBarButtonItem!
    
// MARK: - Variables
    var currentlyEditingCategory = 0
    var chosenSubcategory: Subcategory?
    var responseTextField: UITextField? = nil
    var subcatToDelete: Subcategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the add button on the right side of the navigation toolbar.
        parentViewController!.navigationItem.rightBarButtonItem = addButton
        parentViewController!.navigationItem.leftBarButtonItem = connectButton
        
        // Fetched results controller
        executeFetch()
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Reload data in case a transaction was added manually/downloaded
        tableView.reloadData()
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Subcategory")
        let sortDescriptor = NSSortDescriptor(key: "category.catTitle", ascending: true)
        let subSortDescriptor = NSSortDescriptor(key: "subTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, subSortDescriptor]
        
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
    
    // Add new Subcategory
    @IBAction func addItemAction(sender: UIButton) {
        // Set current category to selected "add item" button's tag
        currentlyEditingCategory = sender.tag
        
        // Display alert to save new subcategory title
        displayTitleAlert("Please enter a title for your new subcategory.")
        
        // Reload tableview data
        tableView.reloadData()
    }
    
    // Add new bank account
    @IBAction func connectAction(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewAccountNavController") as! UINavigationController
        
        presentViewController(controller, animated: true, completion: nil)
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
            configureCell(cell, atIndexPath: indexPath)
        }
        
        // Support for updating the budget amount in core data
        cell.amountUpdateHandler = { [unowned self] (currentCell: BudgetSubcategoryCell) -> Void in
            guard let path = tableView.indexPathForRowAtPoint(currentCell.center) else { return }
            let subcategory = self.fetchedResultsController.objectAtIndexPath(path) as! Subcategory
            
            // Set the new amount value
            subcategory.setValue(cell.amountTextField.text!, forKey: "totalAmount")
            
            // Save updates to core data
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        
        return cell
     }
    
    // Configure subcategory cells
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let cell = cell as! BudgetSubcategoryCell
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        cell.subcategoryTitle.text = subcategory.subTitle
        cell.amountTextField.text = subcategory.totalAmount
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
    }
    
    // Header view height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
     
    // Defines the custom footer cells.
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! CustomFooterCell

        let containerView = UIView(frame: footerCell.frame)
        
        footerCell.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Set section tag for "add item" button
        footerCell.addItemButton.tag = section
        
        // Customize background color
        footerCell.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.01)
        
        containerView.addSubview(footerCell)
        
        return containerView
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
        performSegueWithIdentifier("displayTransactions", sender: chosenSubcategory)
    }
    
    // Swipe to delete subcategories
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            subcatToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as? Subcategory
            confirmDelete()
        }
    }
}

// MARK: - Fetched Results Controller Delegate

extension BudgetViewController: NSFetchedResultsControllerDelegate {
    
    // Begin updates
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    // Changes to rows
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    // Changes to sections
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
    
    // End updates
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
    
    // Support for adding a new subcategory
    func addNewSubcategory() {
        // Get Category data from existing subcategory
        let existingRowIndex = tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let existingRowIndexPath = NSIndexPath(forRow: existingRowIndex, inSection: currentlyEditingCategory)
        let existingSubcategory = fetchedResultsController.objectAtIndexPath(existingRowIndexPath) as! Subcategory
        let category = existingSubcategory.category
        
        dispatch_async(dispatch_get_main_queue()) {
            // Init new subcategory object
            let newSubcategory = Subcategory(category: category, subTitle: self.responseTextField!.text!, totalAmount: "$0.00", context: self.sharedContext)
        
            newSubcategory.category = category
            
            // Save to core data
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            // Add new subcategory to fetched objects
            self.executeFetch()
        }
    }
    
    // Text field for subcategory title response
    func addTextField(textField: UITextField!) {
        responseTextField = textField
        responseTextField!.placeholder = "Enter title here."
    }
    
    // Display alert to set new subcategory title
    func displayTitleAlert(message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: { (alertController) -> Void in
            self.addNewSubcategory()
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Execute fetch request
    func executeFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Request confirmation to delete subcategory
    func confirmDelete() {
        let alert = UIAlertController(title: "Delete Subcategory", message: "All linked transactions will also be deleted.", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteSubcategory)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteSubcategory)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Subcategory deletion was confirmed
    func handleDeleteSubcategory(alertAction: UIAlertAction!) -> Void {
        // Delete subcategory on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            self.sharedContext.deleteObject(self.subcatToDelete!)
        
            // Save updates
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    // Delete Subcategory cancelled
    func cancelDeleteSubcategory(alertAction: UIAlertAction!) {
        subcatToDelete = nil
    }
}

