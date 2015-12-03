//
//  PlaidConstants.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

extension PlaidClient {
   
    struct Plaid {
        static var baseURL: String!
        static var clientId: String!
        static var secret: String!
        
        static func initializePlaid(clientId: String, secret: String, appStatus: BaseURL) {
            Plaid.clientId = clientId
            Plaid.secret = secret
            switch appStatus {
            case .Production:
                baseURL = "https://api.plaid.com/"
            case .Testing:
                baseURL = "https://tartan.plaid.com/"
            }
        }
    }
    
    enum BaseURL {
        case Production
        case Testing
    }
    
    enum Type {
        case Auth
        case Connect
        case Balance
    }
    
    enum Institution {
        case amex
        case bofa
        case capone360
        case schwab
        case chase
        case citi
        case fidelity
        case pnc
        case us
        case usaa
        case wells
    }
    
   struct Account {
        let institutionName: String
        let id: String
        let user: String
        let balance: Double
        let productName: String
        let lastFourDigits: String
        let limit: NSNumber?
        
        init (account: [String:AnyObject]) {
            let meta = account["meta"] as! [String:AnyObject]
            let accountBalance = account["balance"] as! [String:AnyObject]
            
            institutionName = account["institution_type"] as! String
            id = account["_id"] as! String
            user = account["_user"] as! String
            balance = accountBalance["current"] as! Double
            productName = meta["name"] as! String
            lastFourDigits = meta["number"] as! String
            limit = meta["limit"] as? NSNumber
        }
    }
    
   struct Transactions {
        let account: String
        let id: String
        let amount: Double
        let date: String
        let name: String
        let pending: Bool
        
        let address: String?
        let city: String?
        let state: String?
        let zip: String?
        let storeNumber: String?
        let latitude: Double?
        let longitude: Double?
        
        let trxnType: String?
        let locationScoreAddress: Double?
        let locationScoreCity: Double?
        let locationScoreState: Double?
        let locationScoreZip: Double?
        let nameScore: Double?
        
        let category:NSArray?
        
        init(transactions: [String:AnyObject]) {
            let meta = transactions["meta"] as! [String:AnyObject]
            let location = meta["location"] as? [String:AnyObject]
            let coordinates = location?["coordinates"] as? [String:AnyObject]
            let score = transactions["score"] as? [String:AnyObject]
            let locationScore = score?["location"] as? [String:AnyObject]
            let type = transactions["type"] as? [String:AnyObject]
            
            account = transactions["_account"] as! String
            id = transactions["_id"] as! String
            amount = transactions["amount"] as! Double
            date = transactions["date"] as! String
            name = transactions["name"] as! String
            pending = transactions["pending"] as! Bool
            
            address = location?["address"] as? String
            city = location?["city"] as? String
            state = location?["state"] as? String
            zip = location?["zip"] as? String
            storeNumber = location?["store_number"] as? String
            latitude = coordinates?["lat"] as? Double
            longitude = coordinates?["lon"] as? Double
            
            trxnType = type?["primary"] as? String
            locationScoreAddress = locationScore?["address"] as? Double
            locationScoreCity = locationScore?["city"] as? Double
            locationScoreState = locationScore?["state"] as? Double
            locationScoreZip = locationScore?["zip"] as? Double
            nameScore = score?["name"] as? Double
            
            category = transactions["category"] as? NSArray
        }
    }
    
    struct TempTransaction {
        let catTitle: String?
        let subTitle: String?
        let date: String
        let title: String
        let amount: String
    }
}