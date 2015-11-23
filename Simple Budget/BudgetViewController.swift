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
    @IBOutlet var connectButton: UIBarButtonItem!
    
// MARK: - Variables
    var currentlyEditingCategory = 0
    var chosenSubcategory: Subcategory?
    var newSubcategory: Subcategory?
    var responseTextField: UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation toolbar title
        self.parentViewController!.navigationItem.title = "Budget"
        
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
        // Set current category to selected "add item" button's tag
        currentlyEditingCategory = sender.tag
        
//        // Add a blank subcategory object
//        self.addNewSubcategory()
        
        self.displayTitleAlert("Please enter a title for your new subcategory.")
        
        // Add new subcategory to fetched object
        self.executeFetch()
        
        // Reload tableview data
        self.tableView.reloadData()
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
            self.configureCell(cell, atIndexPath: indexPath)
//            let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
//            cell.subcategoryTitle.text = subcategory.subTitle
//            cell.amountTextField.text = subcategory.totalAmount
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

//
//        // Create "Planned" label
//        var plannedLabel = UILabel(frame: CGRectMake(0, 0, 80, 27))
//        plannedLabel.text = "Planned"
//        plannedLabel.textColor = UIColor.lightGrayColor()
//        plannedLabel.font = UIFont(name: "Avenir-Book", size: 17.0)
//        plannedLabel.textAlignment = NSTextAlignment.Right
//        
//        headerView.contentView.addSubview(plannedLabel)
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
//            if let updateIndexPath = indexPath {
//                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
                let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
                let subcategory = self.fetchedResultsController.objectAtIndexPath(indexPath!) as? Subcategory
//
                cell?.textLabel!.text = subcategory?.subTitle
                //cell?.detailTextLabel!.text = subcategory?.totalAmount
            //}
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
        // Get Category data from existing subcategory
        let existingRowIndex = self.tableView!.numberOfRowsInSection(currentlyEditingCategory) - 1
        let existingRowIndexPath = NSIndexPath(forRow: existingRowIndex, inSection: currentlyEditingCategory)
        let existingSubcategory = fetchedResultsController.objectAtIndexPath(existingRowIndexPath) as! Subcategory
        let category = existingSubcategory.category
        
        // Init new subcategory object
        newSubcategory = Subcategory(category: category, subTitle: responseTextField!.text!, totalAmount: "$0.00", context: self.sharedContext)
        
        // Save to core data
        do {
            try self.sharedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
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
            //self.saveSubcatTitle()
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
}
