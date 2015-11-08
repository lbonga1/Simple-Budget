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
    @IBOutlet weak var tableView: UITableView!
    
// MARK: - Variables
    
    var chosenSubcategory: Subcategory!
    var error: NSError?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets the add button on the right side of the navigation toolbar.
        self.navigationItem.rightBarButtonItem = addButton
        
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
        let sortDescriptor = NSSortDescriptor(key: "subTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let subcategory = self.chosenSubcategory
        let predicate = NSPredicate(format: "subTitle == %@", subcategory!.subTitle)
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
// MARK: - Actions
    
    @IBAction func addNewTransaction(sender: AnyObject) {
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! UINavigationController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension TransactionsViewController: UITableViewDataSource {
    
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
        //return chosenSubcategory!.transactions.count
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
        cell.dateLabel.text = setDate(transaction.date)
            
//        let cell = tableView.dequeueReusableCellWithIdentifier("TransactionCell", forIndexPath: indexPath) as! TransactionCell
//        let transactions = chosenSubcategory?.transactions as! [Transaction]
//        
//        for transaction in transactions {
//            cell.titleLabel.text = transaction.title
//            cell.amountLabel.text = transaction.amount
//            cell.dateLabel.text = setDate(transaction.date)
//        }
        return cell
    }
}

// MARK: - Fetched Results Controller Delegate

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) { }
}

extension TransactionsViewController {
    
    func setDate(date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        var strDate = dateFormatter.stringFromDate(date)
        
        return strDate
    }
    
}
