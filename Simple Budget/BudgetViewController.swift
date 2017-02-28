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
        parent!.navigationItem.rightBarButtonItem = addButton
        parent!.navigationItem.leftBarButtonItem = connectButton
        
        // Fetched results controller
        executeFetch()
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Reload data in case a transaction was added manually/downloaded
        tableView.reloadData()
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController<Subcategory> = {
        
        let fetchRequest = NSFetchRequest<Subcategory>(entityName: "Subcategory")
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
    @IBAction func addNewTransaction(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewTransaction") as! UINavigationController
        
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // Add new Subcategory
    @IBAction func addItemAction(_ sender: UIButton) {
        // Set current category to selected "add item" button's tag
        currentlyEditingCategory = sender.tag
        
        // Display alert to save new subcategory title
        displayTitleAlert("Please enter a title for your new subcategory.")
        
        // Reload tableview data
        tableView.reloadData()
    }
    
    // Add new bank account
    @IBAction func connectAction(_ sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewAccountNavController") as! UINavigationController
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - Table view data source
    
extension BudgetViewController: UITableViewDataSource {

    // Returns the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 1
    }

    // Returns the number of rows in each section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetSubcategoryCell", for: indexPath) as! BudgetSubcategoryCell

        // Set title and amount values
        if fetchedResultsController.fetchedObjects!.count != 0 {
            configureCell(cell, atIndexPath: indexPath)
        }
        
        // Support for updating the budget amount in core data
        cell.amountUpdateHandler = { [unowned self] (currentCell: BudgetSubcategoryCell) -> Void in
            guard let path = tableView.indexPathForRow(at: currentCell.center) else { return }
            let subcategory = self.fetchedResultsController.object(at: path) 
            
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
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let cell = cell as! BudgetSubcategoryCell
        let subcategory = fetchedResultsController.object(at: indexPath) 
        cell.subcategoryTitle.text = subcategory.subTitle
        cell.amountTextField.text = subcategory.totalAmount
    }
    
    // Customize header text label before view is displayed
    func tableView(_ tableView:UITableView, willDisplayHeaderView view:UIView, forSection section:Int) {
        if let headerView: CustomHeaderView = view as? CustomHeaderView {
            headerView.configureTextLabel()
        }
    }
        
    // Defines the custom header view.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView: CustomHeaderView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerViewReuseIdentifier) as? CustomHeaderView

        if (headerView == nil) {
            // Customize background color and text color
            let textColor = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0)
            headerView = CustomHeaderView(backgroundColor: UIColor.white, textColor: textColor)
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
     
    // Defines the custom footer cells.
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") as! CustomFooterCell

        let containerView = UIView(frame: footerCell.frame)
        
        footerCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set section tag for "add item" button
        footerCell.addItemButton.tag = section
        
        // Customize background color
        footerCell.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.01)
        
        containerView.addSubview(footerCell)
        
        return containerView
    }
    
    // Footer cell height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 25
    }
    
    // Segue to TransactionsViewController upon selecting a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row to make it visually reselectable.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Set chosenSubcategory to the correct Subcategory object from fetchedResultsController
        chosenSubcategory = fetchedResultsController.object(at: indexPath) as Subcategory
        
        // Push TransacationsViewController
        performSegue(withIdentifier: "displayTransactions", sender: chosenSubcategory)
    }
    
    // Swipe to delete subcategories
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            subcatToDelete = fetchedResultsController.object(at: indexPath) as Subcategory
            confirmDelete()
        }
    }
}

// MARK: - Fetched Results Controller Delegate

extension BudgetViewController: NSFetchedResultsControllerDelegate {
    
    // Begin updates
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Changes to rows
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    // Changes to sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    // End updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - Additional Methods

extension BudgetViewController {
    
    // Transfer chosen subcategory data to view transactions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "displayTransactions") {
            let transactionsVC = segue.destination as!
            TransactionsViewController
            transactionsVC.chosenSubcategory = self.chosenSubcategory
        }
    }
    
    // Support for adding a new subcategory
    func addNewSubcategory() {
        // Get Category data from existing subcategory
        let existingRowIndex = tableView!.numberOfRows(inSection: currentlyEditingCategory) - 1
        let existingRowIndexPath = IndexPath(row: existingRowIndex, section: currentlyEditingCategory)
        let existingSubcategory = fetchedResultsController.object(at: existingRowIndexPath) 
        let category = existingSubcategory.category
        
        DispatchQueue.main.async {
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
    func addTextField(_ textField: UITextField!) {
        responseTextField = textField
        responseTextField!.placeholder = "Enter title here."
    }
    
    // Display alert to set new subcategory title
    func displayTitleAlert(_ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: addTextField)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: { (alertController) -> Void in
            self.addNewSubcategory()
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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
        let alert = UIAlertController(title: "Delete Subcategory", message: "All linked transactions will also be deleted.", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteSubcategory)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteSubcategory)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Subcategory deletion was confirmed
    func handleDeleteSubcategory(_ alertAction: UIAlertAction!) -> Void {
        // Delete subcategory on the main queue
        DispatchQueue.main.async {
            self.sharedContext.delete(self.subcatToDelete!)
        
            // Save updates
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    // Delete Subcategory cancelled
    func cancelDeleteSubcategory(_ alertAction: UIAlertAction!) {
        subcatToDelete = nil
    }
}

