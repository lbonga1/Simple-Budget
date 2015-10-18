//
//  Subcategories.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

// Make Subcategories available to Objective-C code
@objc(Subcategories)

class Subcategories: NSManagedObject {
    
    struct Keys {
        static let Title = "title"
        static let DollarAmount = "dollar_amount"
        static let PercentOfIncome = "percentage"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var categories: Categories
    @NSManaged var title: String
    @NSManaged var dollarAmount: Double
    @NSManaged var percentOfIcome: Int64
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Subcategories" type.
        let entity =  NSEntityDescription.entityForName("Subcategories", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        title = dictionary[Subcategories.Keys.Title] as! String
        dollarAmount = dictionary[Subcategories.Keys.DollarAmount] as! Double
        percentOfIcome = dictionary[Subcategories.Keys.PercentOfIncome] as! Int64
    }
}