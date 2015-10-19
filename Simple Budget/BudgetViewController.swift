//
//  BudgetViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class BudgetViewController: UIViewController {

// MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addBarButtonItem: UIBarButtonItem!
    
    var testData: NSMutableArray = ["Test", "Test 2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the add button on the right side of the navigation toolbar.
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    // Presents NewTransTableViewController to add a new transaction.
    @IBAction func addNewTransaction(sender: AnyObject) {
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! NewTransTableViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func addItemAction(sender: AnyObject) {
        self.tableView.beginUpdates()
        self.testData.insertObject("Test 3", atIndex: self.testData.count)
        var indexPath = NSIndexPath(forRow: self.testData.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
    
//    func defaultCategories() -> [String: AnyObject] {
//        return  [
//            [
//                "title" : "Savings",
//                "dollarMmount" : 0.00,
//                "percentage" : 0,
//            ], [
//                "title" : "Housing",
//                "dollarAmount" : 0.00,
//                "percentage" : 0,
//            ], [
//                "title" : "Transportation",
//                "dollarAmount" : 0.00,
//                "percentage" : 0,
//            ], [
//                "title" : "Food",
//                "dollarAmount" : 0.00,
//                "percentage" : 0,
//            ], [
//                "title" : "Lifestyle",
//                "dollarAmount" : 0.00,
//                "percentage" : 0,
//            ], [
//                "title" : "Insurance & Tax",
//                "dollarAmount" : 0.00,
//                "percentage" : 0,
//            ], [
//                "title" : "Debt",
//                "dollarAmount" : 0.00,
//                "percentage" : 0,
//            ]
//        ]
//    }
    
}

// MARK: - Table view data source and delegate
    
    extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {

    // Returns the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    // Returns the number of rows in each section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return testData.count
    }

    // Defines the budget item cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BudgetCell", forIndexPath: indexPath) as! BudgetCell

        cell.subcategoryTitle.text = testData[indexPath.row] as? String
        cell.amountLabel.text = "$0.00"

        return cell
     }
        
    // Defines the custom header cells.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
        
        headerCell.titleLabel.text = "Test title"
        headerCell.backgroundColor = UIColor.whiteColor()
        
        return headerCell
        
        }
        
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
     
    // Defines the custom footer cells.
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! CustomFooterCell
        
        footerCell.addItemButton.setTitle("Test footer", forState: .Normal)
        footerCell.backgroundColor = UIColor.whiteColor()
            
        return footerCell
    }
        
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 32

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */







}
