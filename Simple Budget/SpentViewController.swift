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
    
// MARK: - Table view data source
    
extension SpentViewController: UITableViewDataSource {
    
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
}

// MARK: - Table view delegate

extension SpentViewController: UITableViewDelegate {
    
    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SpentSubcatCell", forIndexPath: indexPath)
    
        // Define subcategory as Subcategory object
        let subcategory = fetchedResultsController.objectAtIndexPath(indexPath) as! Subcategory
        
        // Set title value
        cell.textLabel!.text = subcategory.subTitle
        
        // Cast transactions NSSet as an array
        let transactions = subcategory.transactions.allObjects as! [Transaction]

        // Convert amount strings to floats, then get the sum
        for transaction in transactions {
            // Define the transaction amount
            let transaction = transaction as Transaction
            let amountString = transaction.amount
            // Remove the "$" and ","
            let dropCommaInString = amountString.stringByReplacingOccurrencesOfString(",", withString: "")
            let editedString = dropCommaInString.stringByReplacingOccurrencesOfString("$", withString: "")

            // Convert to Float
            let amountFloat = Float(editedString)
            
            // Add the value to the amountArray
            amountArray.append(amountFloat!)
            
            // Find the sum of the values in the amountArray
            let sum = amountArray.sum()
            
            //Format the sum back into a string
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            formatter.locale = NSLocale(localeIdentifier: "en_US")
            let sumAmountString = formatter.stringFromNumber(sum)
            
            // Set amount label value
            cell.detailTextLabel!.text = sumAmountString
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
        
        return headerView
    }
    
    // Headerview height
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
    
    // Footerview height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 25
    }
}

// MARK: - Fetched Results Controller Delegate

extension SpentViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) { }
}

// MARK: - Additional Methods

extension SpentViewController {
    
    // Execute fetch request
    func executeFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

extension Array {
    // Support to get the sum of float values in an array
    func sumFloat() -> Float {return map{$0 as! Float}.reduce(0) { $0 + $1 }}
    
    // Make it type safe
    func sum() -> Element {
        if !isEmpty {
            if self[0] is Float  { return (sumFloat() as! Element) }
            }
        return 0 as! Element
    }
}