//
//  Transactions.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

// Make Transactions available to Objective-C code
@objc(Transactions)

class Transactions: NSManagedObject {
    
    struct Keys {
        static let Date = "date"
        static let Title = "title"
        static let Amount = "amount"
        static let Notes = "notes"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var categories: Categories
    @NSManaged var subcategories: Subcategories
    @NSManaged var date: NSDate
    @NSManaged var title: String
    @NSManaged var amount: Double
    @NSManaged var notes: String
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Transactions" type.
        let entity =  NSEntityDescription.entityForName("Transactions", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        date = dictionary[Transactions.Keys.Date] as! NSDate
        title = dictionary[Transactions.Keys.Title] as! String
        amount = dictionary[Transactions.Keys.Amount] as! Double
        notes = dictionary[Transactions.Keys.Notes] as! String
    }
}