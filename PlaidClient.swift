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
    var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
   
// MARK: - Add Connect or Auth User
    func PS_addUser(userType: Type, username: String, password: String, pin: String?, institution: Institution, completion: (response: NSURLResponse?, accessToken: String, mfaType: String?, mfa: String?, accounts: [Account]?, transactions: [Transactions]?, error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        let institutionStr: String = institutionToString(institution: institution)
        
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
                                //println(questionString)
                                if let typeMfa = jsonResult?.valueForKey("type") as? String {
                                    type = typeMfa
                                    PlaidData.sharedInstance().accessToken = token
                                    completion(response: response, accessToken: token, mfaType: type, mfa: questionString, accounts: nil, transactions: nil, error: error)
                                }
                            }
                        }
                    } else {
//                        let acctsArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as! [[String:AnyObject]]
//                        let accts = acctsArray.map{Account(account: $0)}
//                        let trxnArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as! [[String:AnyObject]]
//                        let trxns = trxnArray.map{Transactions(transactions: $0)}
//                        
//                        completion(response: response, accessToken: token, mfaType: nil, mfa: nil, accounts: accts, transactions: trxns, error: error)
                        
                        let acctsArray = jsonResult?.valueForKey("accounts") as! NSArray
                        //let accts = acctsArray.map{Account(account: $0)}
                        print("Accounts: \(acctsArray)")
                        let trxnArray = jsonResult?.valueForKey("transactions") as! NSArray
                        //let trxns = trxnArray.map{Transactions(transactions: $0)}
                        print("Transactions: \(trxnArray)")
                        
                        completion(response: response, accessToken: "", mfaType: nil, mfa: nil, accounts: nil, transactions: nil, error: error)
                    }
                } else {
                    //Handle invalid cred login
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
//                    let acctsArray:[[String:AnyObject]] = jsonResult?.valueForKey("accounts") as! [[String:AnyObject]]
//                    let accts = acctsArray.map{Account(account: $0)}
//                    let trxnArray:[[String:AnyObject]] = jsonResult?.valueForKey("transactions") as! [[String:AnyObject]]
//                    let trxns = trxnArray.map{Transactions(transactions: $0)}
//                
//                    completion(response: response, accessToken: nil, mfaType: nil, mfa: nil, accounts: accts, transactions: trxns, error: error)
                    
                    let acctsArray = jsonResult?.valueForKey("accounts") as! NSArray
                    //let accts = acctsArray.map{Account(account: $0)}
                        print(acctsArray)
                    let trxnArray = jsonResult?.valueForKey("transactions") as! NSArray
                    //let trxns = trxnArray.map{Transactions(transactions: $0)}
                        print(trxnArray)
                    
                    completion(response: response, accessToken: nil, mfaType: nil, mfa: nil, accounts: nil, transactions: nil, error: error)
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
    
    func institutionToString(institution institution: Institution) -> String {
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
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
}
    
extension NSString {
    var encodValue:String {
        return self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
}
