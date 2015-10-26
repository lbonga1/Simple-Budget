//
//  Subcategory.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

// Make Subcategory available to Objective-C code
@objc(Subcategory)

class Subcategory: NSManagedObject {
    
    struct Keys {
        static let Title = "title"
        static let Amount = "dollar_amount"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var categories: Category
    @NSManaged var title: String
    @NSManaged var amount: Double
    @NSManaged var transactions: NSSet
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Subcategories" type.
        let entity =  NSEntityDescription.entityForName("Subcategory", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        title = dictionary[Subcategory.Keys.Title] as! String
        amount = dictionary[Subcategory.Keys.Amount] as! Double
    }
}