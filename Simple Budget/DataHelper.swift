//
//  DataHelper.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/4/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

public class DataHelper {
    var error: NSError?
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    public func seedDataStore() {
        seedCategories()
        seedSubcategories()
    }

    private func seedCategories() {
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
            let newCategory = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: sharedContext) as! Category
            newCategory.catTitle = category.catTitle
            //newCategory.totalAmount = category.totalAmount
        }
        
        sharedContext.save(&error)
    }
    
    private func seedSubcategories() {
        
        let categoryFetchRequest = NSFetchRequest(entityName: "Category")
        let allCategories = (sharedContext.executeFetchRequest(categoryFetchRequest, error: &error)) as! [Category]
        
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
            let newSubcategory = NSEntityDescription.insertNewObjectForEntityForName("Subcategory", inManagedObjectContext: sharedContext) as! Subcategory
            newSubcategory.subTitle = subcategory.subTitle
            newSubcategory.category = subcategory.category
            newSubcategory.totalAmount = subcategory.totalAmount
        }
        
        sharedContext.save(&error)
    }
    
    public func printAllCategories() {
        let categoryFetchRequest = NSFetchRequest(entityName: "Category")
        let primarySortDescriptor = NSSortDescriptor(key: "catTitle", ascending: true)
        
        categoryFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allCategories = (sharedContext.executeFetchRequest(categoryFetchRequest, error: &error)) as! [Category]
        
        for category in allCategories {
            print("Category Title: \(category.catTitle)")
        }
    }

    public func printAllSubcategories() {
        let subcategoryFetchRequest = NSFetchRequest(entityName: "Subcategory")
        let primarySortDescriptor = NSSortDescriptor(key: "subTitle", ascending: true)
        
        subcategoryFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allSubcategories = (sharedContext.executeFetchRequest(subcategoryFetchRequest, error: &error)) as! [Subcategory]
        
        for subcategory in allSubcategories {
            print("Subcategory Title: \(subcategory.subTitle)")
        }
    }
}
