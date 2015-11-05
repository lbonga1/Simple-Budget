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
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

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
            let newCategory = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: context) as! Category
            newCategory.catTitle = category.catTitle
            //newCategory.totalAmount = category.totalAmount
        }
    }
    
    private func seedSubcategories() {
        var error: NSError?
        
        let categoryFetchRequest = NSFetchRequest(entityName: "Category")
        let allCategories = (context.executeFetchRequest(categoryFetchRequest, error: &error)) as! [Category]
        
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
            (subTitle: "Emergency Fund", category: savings!),
            (subTitle: "Mortgage", category: housing!),
            (subTitle: "Natural Gas/Propane", category: housing!),
            (subTitle: "Electricity", category: housing!),
            (subTitle: "Mobile Phone", category: housing!),
            (subTitle: "Groceries", category: food!),
            (subTitle: "Restaurants", category: food!),
            (subTitle: "Auto Gas & Oil", category: transportation!),
            (subTitle: "Car Replacement", category: transportation!),
            (subTitle: "Clothing", category: lifestyle!),
            (subTitle: "Entertainment", category: lifestyle!),
            (subTitle: "Health Insurance", category: insuranceTax!),
            (subTitle: "Life Insurance", category: insuranceTax!),
            (subTitle: "Auto Insurance", category: insuranceTax!),
            (subTitle: "Student Loans", category: debt!)
        ]
        
        for subcategory in subcategories {
            let newSubcategory = NSEntityDescription.insertNewObjectForEntityForName("Subcategory", inManagedObjectContext: context) as! Subcategory
            newSubcategory.subTitle = subcategory.subTitle
            newSubcategory.category = subcategory.category
        }
    }

}
