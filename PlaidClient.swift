//
//  PlaidClient.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

public class PlaidClient: NSObject {
    
// MARK: - Variables
    
    var fetchedTransactions: Transactions? = nil
    let session = NSURLSession.sharedSession()

// MARK: - Core Data Convenience
    
    // Shared context
    var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
   
// MARK: - Add Connect or Auth User
    
    func PS_addUser(userType: Type, username: String, password: String, pin: String?, instiution: Institution, completion: (response: NSURLResponse?, accessToken: String, mfaType: String?, mfa: String?, accounts: [Account]?, transactions: [Transactions]?, error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        var institutionStr: String = institutionToString(institution: instiution)
        
        
        if userType == .Auth {
            //Fill in for Auth call
            
        } else if userType == .Connect {
            
            var optionsDict: [String:AnyObject] = ["list": true]
            
            let optionsDictStr = dictToString(optionsDict)
            
            var urlString:String?
            if pin != nil {
                urlString = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&username=\(username)&password=\(password.encodValue)&pin=\(pin!)&type=\(institutionStr)&\(optionsDictStr.encodValue)"
            } else {
                urlString = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&username=\(username)&password=\(password.encodValue)&type=\(institutionStr)&options=\(optionsDictStr.encodValue)"
            }
            
            //println("urlString: \(urlString!)")
            
            let url:NSURL! = NSURL(string: urlString!)
            var request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            let task = session.dataTaskWithRequest(request, completionHandler: {
                data, response, error in
                var error: NSError?
                var mfaDict: [[String:AnyObject]]?
                var type: String?
                
                let jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
                
                println(jsonResult!)
                
                if let token = jsonResult?.valueForKey("access_token") as? String {
                    if let mfaResponse = jsonResult?.valueForKey("mfa") as? NSArray {
                        if let questionDictionary = mfaResponse[0] as? NSDictionary {
                            if let questionString = questionDictionary["question"] as? String {
                                //println(questionString)
                                if let typeMfa = jsonResult?.valueForKey("type") as? String {
                                    type = typeMfa
                                    PlaidData.sharedInstance().accessToken = token
                                    completion(response: response, accessToken: token, mfaType: type, mfa: questionString, accounts: nil, transactions: nil, error: error)
                                }
                            }
                        }
                    } else {
                        let acctsArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as! [[String:AnyObject]]
                        let accts = acctsArray.map{Account(account: $0)}
                        
                        if let trxnArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as? [[String:AnyObject]] {
                            let transactions = trxnArray.map{Transactions(transactions: $0)}
                            if let categoryArray = jsonResult?.valueForKey("category") as? NSArray {
                                let categoryName = categoryArray[0] as! String
                                PlaidData.sharedInstance().categoryName = categoryName
                                
                                let subcategoryName = categoryArray[1] as! String
                                PlaidData.sharedInstance().subcategoryName = subcategoryName
                            }
                            
                            if let transactionName = jsonResult?.valueForKey("name") as? String {
                                PlaidData.sharedInstance().transactionName = transactionName
                            }
                            
                            if let transactionAmount = jsonResult?.valueForKey("amount") as? String {
                                PlaidData.sharedInstance().transactionAmount = transactionAmount
                            }
                            
                            if let transactionDate = jsonResult?.valueForKey("date") as? String {
                                PlaidData.sharedInstance().transactionDate = transactionDate
                                
                                
                                let newCategory = Category(catTitle: PlaidData.sharedInstance().categoryName, context: self.sharedContext)
                                
                                let newSubcategory = Subcategory(category: newCategory, subTitle: PlaidData.sharedInstance().subcategoryName, totalAmount: "$0.00", context: self.sharedContext)
                                
                                let newTransaction = Transaction(subcategory: newSubcategory, date: PlaidData.sharedInstance().transactionDate, title: PlaidData.sharedInstance().transactionName, amount: PlaidData.sharedInstance().transactionAmount, notes: "", context: self.sharedContext)

                                print(newTransaction)
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    CoreDataStackManager.sharedInstance().saveContext()
                                }
//                                        }
//                                    }
//                                }
                            }
                        
                        completion(response: response, accessToken: token, mfaType: nil, mfa: nil, accounts: accts, transactions: transactions, error: error)
                        }
                    }
                } else {
                    //Handle invalid cred login
                    completion(response: response, accessToken: "", mfaType: nil, mfa: nil, accounts: nil, transactions: nil, error: error)
                }
            })
            task.resume()
        }
    }
    
// MARK: - MFA funcs
    
    func PS_submitMFAResponse(accessToken: String, response: String, completion: (response: NSURLResponse?, mfaType: String?, mfa: String?,accounts: [Account]?, transactions: [Transactions]?, error: NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        
        let urlString:String = "\(baseURL)connect/step?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&mfa=\(response.encodValue)"
        println("urlString: \(urlString)")
        let url:NSURL! = NSURL(string: urlString)
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        println("MFA request: \(request)")
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            println("mfa response: \(response)")
            println("mfa data: \(data)")
            println(error)
            var error:NSError?
            var type: String?
            
            let jsonResult:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
            
            if let token = jsonResult?.valueForKey("access_token") as? String {
                if let mfaResponse = jsonResult?.valueForKey("mfa") as? NSArray {
                    if let questionDictionary = mfaResponse[0] as? NSDictionary {
                        if let questionString = questionDictionary["question"] as? String {
                            println(questionString)
                            if let typeMfa = jsonResult?.valueForKey("type") as? String {
                                type = typeMfa
                                PlaidData.sharedInstance().accessToken = token
                                completion(response: response, mfaType: type, mfa: questionString, accounts: nil, transactions: nil, error: error)
                            }
                        }
                    }
                }
            } else if jsonResult?.valueForKey("accounts") != nil {
                
                let acctsArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as! [[String:AnyObject]]
                let accts = acctsArray.map{Account(account: $0)}
                let trxnArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as! [[String:AnyObject]]
                let trxns = trxnArray.map{Transactions(transactions: $0)}
                
                completion(response: response, mfaType: nil, mfa: nil, accounts: accts, transactions: trxns, error: error)
            }
            
            //println("jsonResult: \(jsonResult!)")
        })
        task.resume()
    }
    
    
// MARK: - Get balance
    
    func PS_getUserBalance(accessToken: String, completion: (response: NSURLResponse?, accounts:[Account], error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        let urlString:String = "\(baseURL)balance?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)"
        let url:NSURL! = NSURL(string: urlString)
        
        let task = session.dataTaskWithURL(url) {
            data, response, error in
            var error: NSError?
            let jsonResult:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
            let dataArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as! [[String : AnyObject]]
            let userAccounts = dataArray.map{Account(account: $0)}
            completion(response: response, accounts: userAccounts, error: error)
        }
        task.resume()
    }
    
// MARK: - Get transactions (Connect)
    
    func PS_getUserTransactions(accessToken: String, showPending: Bool, beginDate: String?, endDate: String?, completion: (response: NSURLResponse?, transactions:[Transactions], error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        var optionsDict: [String:AnyObject] =
        [
            "pending": true
        ]
        
        if let beginDate = beginDate {
            optionsDict["gte"] = beginDate
        }
        
        if let endDate = endDate {
            optionsDict["lte"] = endDate
        }
        
        let optionsDictStr = dictToString(optionsDict)
        let urlString:String = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&\(optionsDictStr.encodValue)"
        let url:NSURL = NSURL(string: urlString)!
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            data, response, error in
            var error: NSError?
            let jsonResult:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
            let dataArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as! [[String:AnyObject]]
            let userTransactions = dataArray.map{Transactions(transactions: $0)}
            completion(response: response, transactions: userTransactions, error: error)
        }
        task.resume()
        
    }
    
    
// MARK: - Helper funcs
    
    func plaidDateFormatter(date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.stringFromDate(date)
        return dateStr
    }
    
    func dictToString(value: AnyObject) -> NSString {
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: nil, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            }
        }
        return ""
    }
    
    func institutionToString(#institution: Institution) -> String {
        var institutionStr: String {
            switch institution {
            case .amex:
                return "amex"
            case .bofa:
                return "bofa"
            case .capone360:
                return "capone360"
            case .chase:
                return "chase"
            case .citi:
                return "citi"
            case .fidelity:
                return "fidelity"
            case .pnc:
                return "pnc"
            case .schwab:
                return "schwab"
            case .us:
                return "us"
            case .usaa:
                return "usaa"
            case .wells:
                return "wells"
            }
        }
        return institutionStr
    }
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> PlaidClient {
        
        struct Singleton {
            static var sharedInstance = PlaidClient()
        }
        
        return Singleton.sharedInstance
    }
}

extension String {
    var encodValue:String {
        return self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
}
    
extension NSString {
    var encodValue:String {
        return self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
}
