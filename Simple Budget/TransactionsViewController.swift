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
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancelButton
        
        // Fetched Results Controller
        executeFetch()
        fetchedResultsController.delegate = self
        
        // Display no transactions label if there are no fetchedObjects
        if fetchedResultsController.fetchedObjects!.count == 0 {
            noTransactionsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noTransactionsLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = {
        
        // Fetch transactions
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
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
    @IBAction func addNewTransaction(_ sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewTransaction") as! UINavigationController
        
        present(controller, animated: true, completion: nil)
    }
    
    // Return to budgeting view controllers
    @IBAction func cancelAction(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table view data source

extension TransactionsViewController: UITableViewDataSource {
    
    // Returns the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    // Returns the number of rows in each section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
}

// MARK: - Table view delegate

extension TransactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        
        // Set title and amount values
        let transaction = fetchedResultsController.object(at: indexPath) 
        cell.titleLabel.text = transaction.title
        cell.amountLabel.text = transaction.amount
        
        // Change date format
        changeDateFormat(transaction.date)
        
        // Set date value
        cell.dateLabel.text = newDateString
            
        return cell
    }
}

// MARK: - Fetched Results Controller Delegate

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
}

// MARK: - Additional Methods 

extension TransactionsViewController {
    
    // Change date format to short style
    func changeDateFormat(_ dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let newDate = dateFormatter.date(from: dateString)
        newDateString = dateFormatter.string(from: newDate!)
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
