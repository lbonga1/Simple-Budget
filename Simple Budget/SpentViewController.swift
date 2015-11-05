//
//  SpentViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/22/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class SpentViewController: UIViewController {

// MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet weak var savedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets the add button on the right side of the navigation toolbar.
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        
        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Saved categories label is hidden if there are categories to display.
        if fetchedResultsController.fetchedObjects!.count == 0{
            savedLabel.hidden = false
        } else {
            savedLabel.hidden = true
        }
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Subcategory")
        let sortDescriptor = NSSortDescriptor(key: "subTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "Category.catTitle",
            cacheName: nil)
        
        return fetchedResultsController
        }()

    
// MARK: - Actions
    
    @IBAction func addNewTransaction(sender: AnyObject) {
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! NewTransTableViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
    
// MARK: - Table view data source and delegate
    
extension SpentViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fetchedResultsController.fetchedObjects!.count != 0 {
            return fetchedResultsController.fetchedObjects!.count
        }
        return 0
    }
    
    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects!.count != 0 {
            if let sections = fetchedResultsController.sections {
                let currentSection: AnyObject = sections[section]
                return currentSection.numberOfObjects
            }
        }
        return 0
    }
    
    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SpentSubcategoryCell", forIndexPath: indexPath) as! SpenRemSubcatCell
        
        // Set title and amount values
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        cell.subcategoryTitle.text = subcategory.subTitle
        
    // TODO: Change amount to sum of transaction amounts
        cell.amountLabel.text = subcategory.totalAmount
        
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
        
        return headerView
        
    }
    
    // Headerview height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    // Defines the custom footer cells.
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Create footer view
        let footerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footerView.contentView.backgroundColor = UIColor.whiteColor()
        
        return footerView
    }
    
    // Footerview height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 32
    }

}

// MARK: - Fetched Results Controller Delegate

extension SpentViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) { }
}