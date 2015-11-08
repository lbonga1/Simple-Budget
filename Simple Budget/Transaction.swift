//
//  Transactions.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

// Make Transaction available to Objective-C code
@objc(Transaction)

class Transaction: NSManagedObject {
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var subcategory: Subcategory
    @NSManaged var date: NSDate
    @NSManaged var title: String
    @NSManaged var amount: String
    @NSManaged var notes: String
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(subcategory: Subcategory, date: NSDate, title: String, amount: String, notes: String, context: NSManagedObjectContext) {
        // Get the entity associated with "Transaction" type.
        let entity =  NSEntityDescription.entityForName("Transaction", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init properties
        self.subcategory = subcategory
        self.date = date
        self.title = title
        self.amount = amount
        self.notes = notes
    }
}