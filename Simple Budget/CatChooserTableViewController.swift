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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }

// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
// MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return fetchedResultsController.fetchedObjects!.count
    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

}

// MARK: - Fetched Results Controller Delegate

extension CatChooserTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {   }
}
