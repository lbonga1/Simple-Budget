//
//  PlaidData.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/9/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class PlaidData: NSObject {
   
    var accessToken: String? = nil
//    var merchantName: String? = nil
//    var amount: String? = nil
//    var date: String? = nil
//    var category: Int? = nil
//    var catString: String? = nil
//    var subcatString: String? = nil
    

// MARK: - Shared Instance

    class func sharedInstance() -> PlaidData {
    
        struct Singleton {
            static var sharedInstance = PlaidData()
        }
    
        return Singleton.sharedInstance
    }
}