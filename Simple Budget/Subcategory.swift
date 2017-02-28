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
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(category: Category, subTitle: String, totalAmount: String, context: NSManagedObjectContext) {
        // Get the entity associated with "Subcategory" type.
        let entity =  NSEntityDescription.entity(forEntityName: "Subcategory", in: context)!
        // Inherited init method
        super.init(entity: entity,insertInto: context)
        // Init properties
        self.category = category
        self.subTitle = subTitle
        self.totalAmount = totalAmount
    }
}
