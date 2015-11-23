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
    var selectedSubcategory: Subcategory?
    var selectedIndexArray: NSMutableArray = []
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetched Results Controller
        self.executeFetch()
        fetchedResultsController.delegate = self
        
        // Tableview is automatically in editing mode
        self.tableView.setEditing(true, animated: false)
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Sets up navigation bar items
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
    }

// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Subcategory")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.catTitle", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "category.catTitle",
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
        
        // Unwind segue to NewTransTableViewController
        performSegueWithIdentifier("returnToNewTrans", sender: self)
    }
    
// MARK: - Table view data source

    // Number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    // Number of rows in section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
// MARK: - Table view delegate

    // Defines subcategory cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooserSubcategory", forIndexPath: indexPath)
        
        // Set title and amount values
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        cell.textLabel!.text = subcategory.subTitle
        
    // TODO: Change to remaining amount (budgeted - transactions)
        cell.detailTextLabel!.text = ""

        return cell
    }
    
    
    // Customize header text label before view is displayed
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
            headerView?.textLabel!.text = currentSection.name
        }
        
        return headerView!
    }
    
    // Height for headerview
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    // Defines the footer view.
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Create footer view
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
        footerView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.1)
        
        return footerView
    }
    
    // Height for footerview
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 25
    }
    
    // Saves selectedSubcategory data when row is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* Allow only one subcategory selection, despite multiple selection enabled */
        // Keep track of selected cell
        if selectedIndexArray.count == 0 {
            // Add selected indexPath to array
            selectedIndexArray.addObject(indexPath)
            // Store the indexPath
            selectedIndexPath = indexPath
        } else {
            // Remove previously selected indexPath from array and deselect
            selectedIndexArray.removeLastObject()
            tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            // Add new indexPath to array
            selectedIndexArray.addObject(indexPath)
            // Store the new indexPath
            selectedIndexPath = indexPath
        }
        
        // Get index path for the selected subcategory
        let selectedSubcategoryIndex = tableView.indexPathForSelectedRow
        
        // Set selectedSubcategory to the correct value using fetchedResultsController
        selectedSubcategory = fetchedResultsController.objectAtIndexPath(selectedSubcategoryIndex!) as? Subcategory
    }
}

// MARK: - Fetched Results Controller Delegate

extension CatChooserTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {   }
}

// MARK: - Additional Methods 

extension CatChooserTableViewController {
    
    // Execute fetch request
    func executeFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
