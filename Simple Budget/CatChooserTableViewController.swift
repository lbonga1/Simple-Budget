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
    var selectedIndexPath: IndexPath?
    var amountArray: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetched Results Controller
        executeFetch()
        fetchedResultsController.delegate = self
        
        // Tableview is automatically in editing mode
        tableView.setEditing(true, animated: false)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Sets up navigation bar items
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
    }

// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController<Subcategory> = {
        
        let fetchRequest = NSFetchRequest<Subcategory>(entityName: "Subcategory")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.catTitle", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "category.catTitle",
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
// MARK: - Actions
    
    // Dismiss view controller to cancel selection
    @IBAction func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // Segue back to NewTransTableViewController with selectedSubcategory data
    @IBAction func doneSelecting(_ sender: AnyObject) {
        
        // Unwind segue to NewTransTableViewController
        performSegue(withIdentifier: "returnToNewTrans", sender: self)
    }
    
// MARK: - Table view data source

    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    // Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
// MARK: - Table view delegate

    // Defines subcategory cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooserSubcategory", for: indexPath)
        
        // Set title value
        let subcategory = fetchedResultsController.object(at: indexPath) 
        cell.textLabel!.text = subcategory.subTitle
        
        // Cast transactions NSSet as an array
        let transactions = subcategory.transactions.allObjects as! [Transaction]
        
        // Convert amount strings to floats, then get the sum
        for transaction in transactions {
            // Define the transaction amount
            let transaction = transaction as Transaction
            let amountString = transaction.amount
            // Remove the "," and "$"
            let dropCommaInString = amountString.replacingOccurrences(of: ",", with: "")
            let editedString = dropCommaInString.replacingOccurrences(of: "$", with: "")
            // Convert to Float
            let amountFloat = Float(editedString)
            
            // Add the value to the amountArray
            amountArray.append(amountFloat!)
        }
        
        if transactions.count != 0 {
            // Find the sum of the values in the amountArray
            let sum = amountArray.sum()
            
            // Convert Subcategory budget amount to float
            let subcatAmountString = subcategory.totalAmount
            let dropCommaInString = subcatAmountString.replacingOccurrences(of: ",", with: "")
            let subcatEditedString = dropCommaInString.replacingOccurrences(of: "$", with: "")
            let subcatAmountFloat = Float(subcatEditedString)
            
            // Find the remaining amount
            let remainingAmount = (subcatAmountFloat! - sum)
            
            // Format the remaining amount back into a string
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
            formatter.locale = Locale(identifier: "en_US")
            let remAmountString = formatter.string(from: NSNumber(value:remainingAmount))
            
            // Set amount label value
            cell.detailTextLabel!.text = remAmountString
        } else {
            cell.detailTextLabel!.text = subcategory.totalAmount
        }
        
        // Empty the amountArray for the next Transaction array values
        amountArray.removeAll()

        return cell
    }
    
    
    // Customize header text label before view is displayed
    override func tableView(_ tableView:UITableView, willDisplayHeaderView view:UIView, forSection section:Int) {
        if let headerView: CustomHeaderView = view as? CustomHeaderView {
            headerView.configureTextLabel()
        }
    }
    
    // Defines the custom header view.
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView: CustomHeaderView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerViewReuseIdentifier) as? CustomHeaderView
        
        if (headerView == nil) {
            // Customize background color and text color
            let textColor = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0)
            headerView = CustomHeaderView(backgroundColor: UIColor.white, textColor: textColor)
        }
        // Set title label text
        if let sections = fetchedResultsController.sections {
            let currentSection: AnyObject = sections[section]
            headerView?.textLabel!.text = currentSection.name
        }
        
        return headerView!
    }
    
    // Height for headerview
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    // Defines the footer view.
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Create footer view
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        footerView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.1)
        
        return footerView
    }
    
    // Height for footerview
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 25
    }
    
    // Saves selectedSubcategory data when row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Allow only one subcategory selection, despite multiple selection enabled */
        // Keep track of selected cell
        if selectedIndexArray.count == 0 {
            // Add selected indexPath to array
            selectedIndexArray.add(indexPath)
            // Store the indexPath
            selectedIndexPath = indexPath
        } else {
            // Remove previously selected indexPath from array and deselect
            selectedIndexArray.removeLastObject()
            tableView.deselectRow(at: selectedIndexPath!, animated: true)
            // Add new indexPath to array
            selectedIndexArray.add(indexPath)
            // Store the new indexPath
            selectedIndexPath = indexPath
        }
        
        // Get index path for the selected subcategory
        let selectedSubcategoryIndex = tableView.indexPathForSelectedRow
        
        // Set selectedSubcategory to the correct value using fetchedResultsController
        selectedSubcategory = fetchedResultsController.object(at: selectedSubcategoryIndex!) as Subcategory
    }
}

// MARK: - Fetched Results Controller Delegate

extension CatChooserTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {   }
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
