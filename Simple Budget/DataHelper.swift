//
//  DataHelper.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/4/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

open class DataHelper {
    var error: NSError?
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    open func seedDataStore() {
        seedCategories()
        seedSubcategories()
    }

    fileprivate func seedCategories() {
        let categories = [
            (catTitle: "Savings", totalAmount: "$0.00"),
            (catTitle: "Housing", totalAmount: "$0.00"),
            (catTitle: "Food", totalAmount: "$0.00"),
            (catTitle: "Transportation", totalAmount: "$0.00"),
            (catTitle: "Lifestyle", totalAmount: "$0.00"),
            (catTitle: "Insurance & Tax", totalAmount: "$0.00"),
            (catTitle: "Debt", totalAmount: "$0.00")
        ]
        
        for category in categories {
            let newCategory = NSEntityDescription.insertNewObject(forEntityName: "Category", into: sharedContext) as! Category
            newCategory.catTitle = category.catTitle
            //newCategory.totalAmount = category.totalAmount
        }
        
        do {
            try sharedContext.save()
        } catch let error1 as NSError {
            error = error1
        }
    }
    
    fileprivate func seedSubcategories() {
        
        let categoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let allCategories = (try! sharedContext.fetch(categoryFetchRequest)) as! [Category]
        
        let savings = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Savings"
        }).first
        
        let housing = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Housing"
        }).first
        
        let food = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Food"
        }).first
        
        let transportation = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Transportation"
        }).first
        
        let lifestyle = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Lifestyle"
        }).first
        
        let insuranceTax = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Insurance & Tax"
        }).first
        
        let debt = allCategories.filter({(c: Category) -> Bool in
            return c.catTitle == "Debt"
        }).first
        
        let subcategories = [
            (subTitle: "Emergency Fund", category: savings!, totalAmount: "$0.00"),
            (subTitle: "Mortgage", category: housing!, totalAmount: "$0.00"),
            (subTitle: "Natural Gas/Propane", category: housing!, totalAmount: "$0.00"),
            (subTitle: "Electricity", category: housing!, totalAmount: "$0.00"),
            (subTitle: "Mobile Phone", category: housing!, totalAmount: "$0.00"),
            (subTitle: "Groceries", category: food!, totalAmount: "$0.00"),
            (subTitle: "Restaurants", category: food!, totalAmount: "$0.00"),
            (subTitle: "Auto Gas & Oil", category: transportation!, totalAmount: "$0.00"),
            (subTitle: "Car Replacement", category: transportation!, totalAmount: "$0.00"),
            (subTitle: "Clothing", category: lifestyle!, totalAmount: "$0.00"),
            (subTitle: "Entertainment", category: lifestyle!, totalAmount: "$0.00"),
            (subTitle: "Health Insurance", category: insuranceTax!, totalAmount: "$0.00"),
            (subTitle: "Life Insurance", category: insuranceTax!, totalAmount: "$0.00"),
            (subTitle: "Auto Insurance", category: insuranceTax!, totalAmount: "$0.00"),
            (subTitle: "Student Loans", category: debt!, totalAmount: "$0.00")
        ]
        
        for subcategory in subcategories {
            let newSubcategory = NSEntityDescription.insertNewObject(forEntityName: "Subcategory", into: sharedContext) as! Subcategory
            newSubcategory.subTitle = subcategory.subTitle
            newSubcategory.category = subcategory.category
            newSubcategory.totalAmount = subcategory.totalAmount
        }
        
        do {
            try sharedContext.save()
        } catch let error1 as NSError {
            error = error1
        }
    }
    
    open func printAllCategories() {
        let categoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let primarySortDescriptor = NSSortDescriptor(key: "catTitle", ascending: true)
        
        categoryFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allCategories = (try! sharedContext.fetch(categoryFetchRequest)) as! [Category]
        
        for category in allCategories {
            print("Category Title: \(category.catTitle)", terminator: "")
        }
    }

    open func printAllSubcategories() {
        let subcategoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Subcategory")
        let primarySortDescriptor = NSSortDescriptor(key: "subTitle", ascending: true)
        
        subcategoryFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allSubcategories = (try! sharedContext.fetch(subcategoryFetchRequest)) as! [Subcategory]
        
        for subcategory in allSubcategories {
            print("Subcategory Title: \(subcategory.subTitle)", terminator: "")
        }
    }
    
    open func printAllTransactions() {
        let subcategoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let primarySortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        subcategoryFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allTransactions = (try! sharedContext.fetch(subcategoryFetchRequest)) as! [Transaction]
        
        for transaction in allTransactions {
            print("Transaction Title: \(transaction.title)", terminator: "")
        }
    }
}
