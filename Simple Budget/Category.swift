//
//  Category.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/11/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import CoreData

// Make Category available to Objective-C code
@objc(Category)

class Category: NSManagedObject {
    
    struct Keys {
        static let Title = "title"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var title: String
    @NSManaged var subcategory: NSSet

    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Categories" type.
        let entity =  NSEntityDescription.entityForName("Category", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        title = dictionary[Category.Keys.Title] as! String
    }
}