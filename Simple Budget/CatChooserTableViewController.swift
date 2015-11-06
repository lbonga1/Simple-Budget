//
//  CatChooserTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/23/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class CatChooserTableViewController: UITableViewController {

// MARK: - Outlets
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
// MARK: - Variables
    var selectedCategory: Category?
    var selectedSubcategory: Subcategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
        // Tableview is automatically in editing mode.
        self.tableView.setEditing(true, animated: false)
        
        // Sets up navigation bar items
        self.parentViewController!.navigationItem.rightBarButtonItem = doneButton
        self.parentViewController!.navigationItem.leftBarButtonItem = cancelButton
    }

// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Subcategory")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "subTitle", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "Category.catTitle",
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
// MARK: - Actions
    
    // Dismiss view controller to cancel selection
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Segue back to NewTransTableViewController with selectedSubcategory data
    @IBAction func doneSelecting(sender: AnyObject) {
        performSegueWithIdentifier("returnToNewTrans", sender: self)
    }
    
// MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fetchedResultsController.fetchedObjects!.count != 0 {
            return fetchedResultsController.fetchedObjects!.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects!.count != 0 {
            if let sections = fetchedResultsController.sections {
                let currentSection: AnyObject = sections[section]
                return currentSection.numberOfObjects
            }
        }
        return 0
    }
    
// MARK: - Table view delegate

    // Defines subcategory cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BudgetSubcategoryCell", forIndexPath: indexPath) as! SpenRemSubcatCell
        
        // Set title and amount values
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        cell.subcategoryTitle.text = subcategory.subTitle
        
    // TODO: Change to remaining amount (budgeted - transactions)
        cell.amountLabel.text = ""

        return cell
    }
    
    override func tableView(tableView:UITableView, willDisplayHeaderView view:UIView, forSection section:Int) {
        if let headerView: CustomHeaderView = view as? CustomHeaderView {
            headerView.configureTextLabel()
        }
    }
    
    // Defines the custom header view.
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView: CustomHeaderView? = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerViewReuseIdentifier) as? CustomHeaderView
        
        if (headerView == nil) {
            // Customize background color and text color
            let textColor = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0)
            headerView = CustomHeaderView(backgroundColor: UIColor.whiteColor(), textColor: textColor)
        }
        // Set title label text
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            headerView?.textLabel.text = currentSection.name
        }
        
        return headerView!
    }
    
    // Inits Category and Subcategory objects when a row is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get index path
        let indexPath = tableView.indexPathForSelectedRow()
        
        if indexPath != nil {
            // Define selected cell
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath!) as! SpenRemSubcatCell
            
            // Define sectionHeaderView and title
            let sectionHeaderView = tableView.headerViewForSection(indexPath!.section)
            let sectionTitle = sectionHeaderView?.textLabel.text
            
            // Init Category object
            selectedCategory = Category(catTitle: sectionTitle!, context: self.sharedContext)
            
            // Init Subcategory object
            selectedSubcategory = Subcategory(
                category: selectedCategory!,
                subTitle: selectedCell.subcategoryTitle.text,
                totalAmount: selectedCell.amountLabel.text!,
                context: self.sharedContext
            )
        }
    }
}

// MARK: - Fetched Results Controller Delegate

extension CatChooserTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {   }
}

// MARK: Additional methods 

extension CatChooserTableViewController {
    
    // Carry selectedSubcategory object data back to NewTransTableViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "returnToNewTrans" {
            let newTrans = segue.destinationViewController as!
            NewTransTableViewController
            
            newTrans.selectedSubcategory = selectedSubcategory
        }
    }
}
