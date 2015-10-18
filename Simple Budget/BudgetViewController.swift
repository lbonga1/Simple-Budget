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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    @IBAction func addNewTransaction(sender: AnyObject) {
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as! NewTransTableViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
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

// MARK: - Table view data source
    
    extension BudgetViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BudgetCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = "Test"

        return cell
        }
        
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
        
        headerCell.titleLabel.text = "Test title"
        
        return headerCell
        
        }
        
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
        footerView.backgroundColor = UIColor.lightGrayColor()
            
        return footerView
    }
        
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
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
