//
//  PlaidClient.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

open class PlaidClient: NSObject {
    
// MARK: - Variables
    
    let session = URLSession.shared
    
// MARK: - Core Data Convenience
    
    // Shared context
    var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
   
// MARK: - Add Connect or Auth User
    
    func PS_addUser(_ userType: Type, username: String, password: String, pin: String?, institution: Institution, completion: @escaping (_ response: URLResponse?, _ accessToken: String, _ mfaType: String?, _ mfa: String?, _ accounts: [Account]?, _ transactions: [Transactions]?, _ error: NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        let institutionStr: String = institutionToString(institution)
        
        let optionsDict: [String:AnyObject] = ["list": true as AnyObject]
        
        let optionsDictStr = dictToString(optionsDict as AnyObject)
        
        var urlString:String?
        if pin != nil {
            urlString = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&username=\(username)&password=\(password.encodValue)&pin=\(pin!)&type=\(institutionStr)&\(optionsDictStr.encodValue)"
        } else {
            urlString = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&username=\(username)&password=\(password.encodValue)&type=\(institutionStr)&options=\(optionsDictStr.encodValue)"
        }
        
        let url:URL! = URL(string: urlString!)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            var type:String?
            
            if data == nil {
                completion(nil, "", nil, nil, nil, nil, nil)
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
                    if let token = jsonResult?.value(forKey: "access_token") as? String {
                        if let mfaResponse = jsonResult?.value(forKey: "mfa") as? NSArray {
                            if let questionDictionary = mfaResponse[0] as? NSDictionary {
                                if let questionString = questionDictionary["question"] as? String {
                                    if let typeMfa = jsonResult?.value(forKey: "type") as? String {
                                        type = typeMfa

                                        completion(response, token, type, questionString, nil, nil, error as NSError?)
                                    }
                                }
                            }
                        } else {
                            let acctsArray:[[String:AnyObject]] = jsonResult?.value(forKey: "accounts") as! [[String:AnyObject]]
                            let accts = acctsArray.map{Account(account: $0)}
                            let trxnArray:[[String:AnyObject]] = jsonResult?.value(forKey: "transactions") as! [[String:AnyObject]]
                            let trxns = trxnArray.map{Transactions(transactions: $0)}
                        
                            completion(response, token, nil, nil, accts, trxns, error as NSError?)
                        }
                    } else {
                        completion(response, "", nil, nil, nil, nil, error as NSError?)
                    }
                } catch {
                    print("Error (PS_addUser): \(error)")
                }
            }
        })
        task.resume()
    }
    
// MARK: - MFA funcs
    
    func PS_submitMFAResponse(_ accessToken: String, code: Bool?, response: String, completion: @escaping (_ response: URLResponse?, _ accessToken: String?, _ mfaType: String?, _ mfa: String?, _ accounts: [Account]?, _ transactions: [Transactions]?, _ error: NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        var urlString:String?
        
        let optionsDict: [String:[String:AnyObject]] = ["send_method": ["type": response as AnyObject]]
        
        let optionsDictStr = dictToString(optionsDict as AnyObject)
        
        if code == true {
            urlString = "\(baseURL)connect/step?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&options=\(optionsDictStr.encodValue)"
            print("urlString: \(urlString!)")
        } else {
            urlString = "\(baseURL)connect/step?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&mfa=\(response.encodValue)"
        }
        
        let url:URL! = URL(string: urlString!)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            var type: String?
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                guard jsonResult?.value(forKey: "code") as? Int != 1303 else { throw PlaidError.institutionNotAvailable }
                guard jsonResult?.value(forKey: "code") as? Int != 1203 else { throw PlaidError.incorrectMfa(jsonResult!.value(forKey: "resolve") as! String)}
                guard jsonResult?.value(forKey: "accounts") != nil else { throw JsonError.empty }
                
                if let token = jsonResult?.value(forKey: "access_token") as? String {
                    if let mfaResponse = jsonResult?.value(forKey: "mfa") as? NSArray {
                        if let questionDictionary = mfaResponse[0] as? NSDictionary {
                            if let questionString = questionDictionary["question"] as? String {
                                if let typeMfa = jsonResult?.value(forKey: "type") as? String {
                                    type = typeMfa
                                    
                                    completion(response, token, type, questionString, nil, nil, error as NSError?)
                                }
                            }
                        }
                    }
                } else {
                    let acctsArray:[[String:AnyObject]] = jsonResult?.value(forKey: "accounts") as! [[String:AnyObject]]
                    let accts = acctsArray.map{Account(account: $0)}
                    let trxnArray:[[String:AnyObject]] = jsonResult?.value(forKey: "transactions") as! [[String:AnyObject]]
                    let trxns = trxnArray.map{Transactions(transactions: $0)}
                
                    completion(response, nil, nil, nil, accts, trxns, error as NSError?)
                }
            } catch {
                print("MFA error (PS_submitMFAResponse): \(error)")
            }
        })
        task.resume()
    }
    
// MARK: - Get balance
    
    func PS_getUserBalance(_ accessToken: String, completion: @escaping (_ response: URLResponse?, _ accounts:[Account], _ error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        let urlString:String = "\(baseURL)balance?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)"
        let url:URL! = URL(string: urlString)
        
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                print("jsonResult: \(jsonResult!)")
                guard jsonResult?.value(forKey: "code") as? Int != 1303 else { throw PlaidError.institutionNotAvailable }
                guard jsonResult?.value(forKey: "code") as? Int != 1105 else { throw PlaidError.badAccessToken }
                guard let dataArray:[[String:AnyObject]] = jsonResult?.value(forKey: "accounts") as? [[String : AnyObject]] else { throw JsonError.empty }
                let userAccounts = dataArray.map{Account(account: $0)}
                completion(response, userAccounts, error as NSError?)
                
            } catch {
                print("JSON parsing error (PS_getUserBalance): \(error)")
            }
        }) 
        task.resume()
    }
    
// MARK: - Get transactions (Connect)
    
    func PS_getUserTransactions(_ accessToken: String, showPending: Bool, beginDate: String?, endDate: String?, completion: @escaping (_ response: URLResponse?, _ transactions:[Transactions], _ error:NSError?) -> ()) {
        let baseURL = Plaid.baseURL!
        let clientId = Plaid.clientId!
        let secret = Plaid.secret!
        
        var optionsDict: [String:AnyObject] = ["pending": true as AnyObject]
        
        if let beginDate = beginDate {
            optionsDict["gte"] = beginDate as AnyObject?
        }
        
        if let endDate = endDate {
            optionsDict["lte"] = endDate as AnyObject?
        }
        
        let optionsDictStr = dictToString(optionsDict as AnyObject)
        let urlString:String = "\(baseURL)connect?client_id=\(clientId)&secret=\(secret)&access_token=\(accessToken)&\(optionsDictStr.encodValue)"
        let url:URL = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                guard jsonResult?.value(forKey: "code") as? Int != 1303 else { throw PlaidError.institutionNotAvailable }
                guard let dataArray:[[String:AnyObject]] = jsonResult?.value(forKey: "transactions") as? [[String:AnyObject]] else { throw JsonError.empty }
                let userTransactions = dataArray.map{Transactions(transactions: $0)}
                completion(response, userTransactions, error as NSError?)
            } catch {
                print("JSON parsing error (PS_getUserTransactions: \(error)")
            }
        }) 
        task.resume()
    }
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> PlaidClient {
        
        struct Singleton {
            static var sharedInstance = PlaidClient()
        }
        
        return Singleton.sharedInstance
    }
}

// MARK: - Extensions

extension String {
    var encodValue:String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
}
    
extension NSString {
    var encodValue:String {
        return self.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!
    }
}
