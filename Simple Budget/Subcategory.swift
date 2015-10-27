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
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var category: Category
    @NSManaged var subTitle: String
    @NSManaged var totalAmount: String
    @NSManaged var transactions: NSSet
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(subTitle: String, totalAmount: String, context: NSManagedObjectContext) {
        // Get the entity associated with "Subcategories" type.
        let entity =  NSEntityDescription.entityForName("Subcategory", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
    }
}