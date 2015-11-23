//
//  TransactionsViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/7/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class TransactionsViewController: UIViewController {
    
// MARK: - Outlets
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTransactionsLabel: UILabel!
    
// MARK: - Variables
    var chosenSubcategory: Subcategory!
    var newDateString: String?
    var error: NSError?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets up navigation buttons.
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        // Fetched Results Controller
        self.executeFetch()
        fetchedResultsController.delegate = self
        
        // Display no transactions label if there are no fetchedObjects
        if fetchedResultsController.fetchedObjects!.count == 0 {
            noTransactionsLabel.hidden = false
            tableView.hidden = true
        } else {
            noTransactionsLabel.hidden = true
            tableView.hidden = false
        }
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Fetch transactions
        let fetchRequest = NSFetchRequest(entityName: "Transaction")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Limit results to only the chosen subcategory
        let predicate = NSPredicate(format: "subcategory == %@", self.chosenSubcategory)
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
// MARK: - Actions
    
    // Present newTransVC to add a new transaction
    @IBAction func addNewTransaction(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! UINavigationController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Return to budgeting view controllers
    @IBAction func cancelAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: - Table view data source

extension TransactionsViewController: UITableViewDataSource {
    
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

extension TransactionsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TransactionCell", forIndexPath: indexPath) as! TransactionCell
        
        // Set title and amount values
        let transaction = fetchedResultsController.objectAtIndexPath(indexPath) as! Transaction
        cell.titleLabel.text = transaction.title
        cell.amountLabel.text = transaction.amount
        
        // Change date format
        self.changeDateFormat(transaction.date)
        
        // Set date value
        cell.dateLabel.text = newDateString
            
        return cell
    }
}

// MARK: - Fetched Results Controller Delegate

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) { }
}

// MARK: - Additional Methods 

extension TransactionsViewController {
    
    // Change date format to short style
    func changeDateFormat(dateString: String) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let newDate = dateFormatter.dateFromString(dateString)
        
        newDateString = dateFormatter.stringFromDate(newDate!)
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
