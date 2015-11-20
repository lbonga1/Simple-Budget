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
    
    let session = NSURLSession.sharedSession()
//    var merchantName: String? = nil
//    var amount: String? = nil
//    var date: String? = nil
//    var category: Int? = nil
//    var catString: String? = nil
//    var subcatString: String? = nil
    
// MARK: - Core Data Convenience
    
    // Shared context
    var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
   
// MARK: - Add Connect or Auth User
    func PS_addUser(userType: Type, username: String, password: String, pin: String?, institution: Institution, completion: (response: NSURLResponse?, accessToken: String, mfaType: String?, mfa: String?, accounts: [Account]?, transactions: [Transactions]?, error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        let institutionStr: String = institutionToString(institution)
        
        let optionsDict: [String:AnyObject] =
        [
            "list":true
        ]
        
        let optionsDictStr = dictToString(optionsDict)
        
        var urlString:String?
        if pin != nil {
            urlString = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&username=\(username)&password=\(password.encodValue)&pin=\(pin!)&type=\(institutionStr)&\(optionsDictStr.encodValue)"
        }
        else {
            urlString = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&username=\(username)&password=\(password.encodValue)&type=\(institutionStr)&options=\(optionsDictStr.encodValue)"
        }
        
        let url:NSURL! = NSURL(string: urlString!)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            var type:String?
            
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                guard jsonResult?.valueForKey("code") as? Int != 1303 else { throw PlaidError.InstitutionNotAvailable }
                guard jsonResult!.valueForKey("code") as? Int != 1200 else {throw PlaidError.InvalidCredentials(jsonResult!.valueForKey("resolve") as! String)}
                guard jsonResult!.valueForKey("code") as? Int != 1005 else {throw PlaidError.CredentialsMissing(jsonResult!.valueForKey("resolve") as! String)}
                guard jsonResult!.valueForKey("code") as? Int != 1601 else {throw PlaidError.InstitutionNotAvailable}
                
                if let token = jsonResult?.valueForKey("access_token") as? String {
                    if let mfaResponse = jsonResult?.valueForKey("mfa") as? NSArray {
                        if let questionDictionary = mfaResponse[0] as? NSDictionary {
                            if let questionString = questionDictionary["question"] as? String {
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
                        let trxnArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as! [[String:AnyObject]]
                        let trxns = trxnArray.map{Transactions(transactions: $0)}

//                        // Extract transaction data
//                        for tr in trxnArray {
//                            // Transaction amount
//                            let numberAmount = tr["amount"]
//                            let stringAmount = numberAmount?.stringValue
//                            self.amount = stringAmount!
//                            
//                            self.merchantName = tr["name"] as? String
//                            
//                            // Date
//                            self.date = tr["date"] as? String
//
//                            // Category ID
//                            if let categoryString = tr["category_id"] as? String {
//                                if let categoryID = Int(categoryString) {
//                                    self.category = categoryID
//                                }
//                            } else {
//                                self.category = 0
//                            }
//                            
//                            // Convert category ID to string
//                            self.catString = self.catIdToCatString(self.category!)
//                            
//                            // Convert category ID to  subcategory string
//                            self.subcatString = self.catIdToSubcatString(self.category!)
//                            
//                            let newCategory = Category(catTitle: self.catString!, context: self.sharedContext)
//                            
//                            let newSubcategory = Subcategory(category: newCategory, subTitle: self.subcatString!, totalAmount: "$0.00", context: self.sharedContext)
//                            
//                           let newTransaction = Transaction(subcategory: newSubcategory, date: self.date!, title: self.merchantName!, amount: self.amount!, notes: "", context: self.sharedContext)
//                            
//                            // Save to Core Data
//                            dispatch_async(dispatch_get_main_queue()) {
//                                newSubcategory.category = newCategory
//                                newTransaction.subcategory = newSubcategory
//                                CoreDataStackManager.sharedInstance().saveContext()
//                            }
//                        }
                        
                        completion(response: response, accessToken: token, mfaType: nil, mfa: nil, accounts: accts, transactions: trxns, error: error)
                    }
                } else {
                    completion(response: response, accessToken: "", mfaType: nil, mfa: nil, accounts: nil, transactions: nil, error: error)
                }
            } catch {
                print("Error (PS_addUser): \(error)")
            }
        })
        task.resume()
    }
    
// MARK: - MFA funcs
    func PS_submitMFAResponse(accessToken: String, code: Bool?, response: String, completion: (response: NSURLResponse?, accessToken: String?, mfaType: String?, mfa: String?, accounts: [Account]?, transactions: [Transactions]?, error: NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        var urlString:String?
        
        let optionsDict: [String:AnyObject] =
        [
            "send_method":["type":response]
        ]
        
        let optionsDictStr = dictToString(optionsDict)
        
        if code == true {
            urlString = "\(baseURL)connect/step?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&options=\(optionsDictStr.encodValue)"
            print("urlString: \(urlString!)")
        } else {
            urlString = "\(baseURL)connect/step?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&mfa=\(response.encodValue)"
        }
        
        let url:NSURL! = NSURL(string: urlString!)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            var type: String?
            
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                guard jsonResult?.valueForKey("code") as? Int != 1303 else { throw PlaidError.InstitutionNotAvailable }
                guard jsonResult?.valueForKey("code") as? Int != 1203 else { throw PlaidError.IncorrectMfa(jsonResult!.valueForKey("resolve") as! String)}
                guard jsonResult?.valueForKey("accounts") != nil else { throw JsonError.Empty }
                
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
                    }
                } else {
                    let acctsArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as! [[String:AnyObject]]
                    let accts = acctsArray.map{Account(account: $0)}
                    let trxnArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as! [[String:AnyObject]]
                    let trxns = trxnArray.map{Transactions(transactions: $0)}
                
                    completion(response: response, accessToken: nil, mfaType: nil, mfa: nil, accounts: accts, transactions: trxns, error: error)
                    
//                    let acctsArray = jsonResult?.valueForKey("accounts") as! NSArray
//                    //let accts = acctsArray.map{Account(account: $0)}
//                        print(acctsArray)
//                    let trxnArray = jsonResult?.valueForKey("transactions") as! NSArray
//                    //let trxns = trxnArray.map{Transactions(transactions: $0)}
//                        print(trxnArray)
//                    
//                    completion(response: response, accessToken: nil, mfaType: nil, mfa: nil, accounts: nil, transactions: nil, error: error)
                }
            } catch {
                print("MFA error (PS_submitMFAResponse): \(error)")
            }
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
            
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                print("jsonResult: \(jsonResult!)")
                guard jsonResult?.valueForKey("code") as? Int != 1303 else { throw PlaidError.InstitutionNotAvailable }
                guard jsonResult?.valueForKey("code") as? Int != 1105 else { throw PlaidError.BadAccessToken }
                guard let dataArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as? [[String : AnyObject]] else { throw JsonError.Empty }
                let userAccounts = dataArray.map{Account(account: $0)}
                completion(response: response, accounts: userAccounts, error: error)
                
            } catch {
                print("JSON parsing error (PS_getUserBalance): \(error)")
            }
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
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            data, response, error in
            
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                guard jsonResult?.valueForKey("code") as? Int != 1303 else { throw PlaidError.InstitutionNotAvailable }
                guard let dataArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as? [[String:AnyObject]] else { throw JsonError.Empty }
                let userTransactions = dataArray.map{Transactions(transactions: $0)}
                completion(response: response, transactions: userTransactions, error: error)
            } catch {
                print("JSON parsing error (PS_getUserTransactions: \(error)")
            }
        }
        task.resume()
    }
    
// MARK: - Helper funcs
    
    enum JsonError:ErrorType {
        case Writing
        case Reading
        case Empty
    }
    
    enum PlaidError:ErrorType {
        case BadAccessToken
        case CredentialsMissing(String)
        case InvalidCredentials(String)
        case IncorrectMfa(String)
        case InstitutionNotAvailable
    }
    
    func plaidDateFormatter(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.stringFromDate(date)
        return dateStr
    }
    
    func dictToString(value: AnyObject) -> NSString {
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: []) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            }
        }
        return ""
    }
    
    func institutionToString(institution: Institution) -> String {
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
    
//    func catIdToCatString(id: Int) -> String {
//        switch id {
//        case 13001000...13003000, 13000000, 13005000...13005059, 19025000...19025004, 19047000:
//            return "Food"
//        case 18006000...18006009, 19005000...19005007, 19026000:
//            return "Transportation"
//        case 18030000, 20000000...20002000:
//            return "Insurance & Tax"
//        case 16002000, 18009000, 18031000, 18068000...18068005, 18050000...18050010:
//            return "Housing"
//        case 10000000...11000000, 12000000...12001000, 12003000, 12013000, 12015000...12017000, 12019000, 12019001, 12002000...12002002, 12006000, 12007000...14002020, 12005000, 12008000...12008011, 19029000, 12004000, 12009000...12012003, 12014000, 12018000...12018004, 13004000...13004006, 16002000...17001019, 17001000, 17002000...17022000, 17024000, 17026000, 17028000...17048000, 17023000...17023004, 17025000...17025005, 17027000...17027003, 18001000...18001010, 18007000...18008001, 18012000...18012002, 18020000...18020014, 18024000...18025000, 18045000...18045010, 19012000...19012008, 19013000...19013003, 19040000...19040008, 19043000, 19000000...19004000, 19006000...19011000, 19014000...19024000, 19027000...19039000, 19041000, 19042000, 19044000...19046000, 19048000...19054000, 22000000...22018000:
//            return "Lifestyle"
//        case 15000000...15002000, 16000000, 16001000, 16003000, 18013000...18013010, 18037000...18037020, 18000000, 18003000...18005000, 18010000, 18011000, 18014000...18019000, 18021000...18023000, 18026000...18029000, 18032000...18036000, 18038000...18044000, 18046000...18049000, 18051000...18067000, 18069000...18074000, 21000000...21013000:
//            return "Other"
//        default:
//            return "Other"
//        }
//    }
//    
//    // Use category IDs to return a subcategory string
//    func catIdToSubcatString(id: Int) -> String {
//        switch id {
//        case 10000000...11000000:
//            return "Bank Fees"
//        case 12000000...12001000, 12003000, 12013000, 12015000...12017000, 12019000, 12019001:
//            return "Community"
//        case 12002000...12002002, 12006000, 12007000...14002020:
//            return "Healthcare"
//        case 12005000, 12008000...12008011, 19029000:
//            return "Education"
//        case 12004000, 12009000...12012003, 12014000:
//            return "Government"
//        case 12018000...12018004:
//            return "Religion"
//        case 13001000...13003000:
//            return "Bars & Breweries"
//        case 13004000...13004006:
//            return "Nightlife"
//        case 13000000, 13005000...13005059:
//            return "Restaurants"
//        case 15000000...15002000:
//            return "Interest"
//        case 16000000, 16001000, 16003000:
//            return "Payment"
//        case 16002000:
//            return "Mortgage & Rent"
//        case 16002000...17001019:
//            return "Arts & Entertainment"
//        case 17001000, 17002000...17022000, 17024000, 17026000, 17028000...17048000:
//            return "Recreation"
//        case 17023000...17023004, 17025000...17025005, 17027000...17027003:
//            return "Parks & Outdoors"
//        case 18001000...18001010:
//            return "Advertising & Marketing"
//        case 18006000...18006009:
//            return "Automotive Services"
//        case 18007000...18008001:
//            return "Business Services"
//        case 18009000, 18031000, 18068000...18068005:
//            return "Utilities"
//        case 18012000...18012002:
//            return "Computer Repair"
//        case 18013000...18013010:
//            return "Construction"
//        case 18020000...18020014:
//            return "Financial Services"
//        case 18024000...18025000:
//            return "Home Improvement"
//        case 18030000:
//            return "Insurance"
//        case 18037000...18037020:
//            return "Manufacturing"
//        case 18045000...18045010:
//            return "Personal Care"
//        case 18050000...18050010:
//            return "Real Estate"
//        case 18000000, 18003000...18005000, 18010000, 18011000, 18014000...18019000, 18021000...18023000, 18026000...18029000, 18032000...18036000, 18038000...18044000, 18046000...18049000, 18051000...18067000, 18069000...18074000:
//            return "Services"
//        case 19005000...19005007:
//            return "Automotive Purchases"
//        case 19012000...19012008:
//            return "Clothing & Accessories"
//        case 19013000...19013003:
//            return "Computers & Electronics"
//        case 19025000...19025004, 19047000:
//            return "Groceries"
//        case 19040000...19040008:
//            return "Outlets"
//        case 19043000:
//            return "Pharmacy"
//        case 19000000...19004000, 19006000...19011000, 19014000...19024000, 19027000...19039000, 19041000, 19042000, 19044000...19046000, 19048000...19054000:
//            return "Shopping"
//        case 19026000:
//            return "Auto Gas & Oil"
//        case 20000000...20002000:
//            return "Taxes"
//        case 21000000...21013000:
//            return "Transfer"
//        case 22000000...22018000:
//            return "Travel"
//        default:
//            return "Other"
//        }
//    }
    
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
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
}
    
extension NSString {
    var encodValue:String {
        return self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
}
