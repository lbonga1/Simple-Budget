//
//  AccountTableViewConvenience.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 11/23/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

extension AccountTableViewController {

    // Execute fetch request
    func executeFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Save to core data and execute fetch request
    func saveAndFetch() {
        // Save core data
        do {
            try self.sharedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        // Execute fetch request
        self.executeFetch()
    }
    
    // Error alert
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Check if MFA type is questions or code
    func checkMfaType(mfaType: String?, mfa: String?) {
        if mfaType == "questions" {
            self.displayResponseAlert(mfa!)
        } else {
            // TODO: handle code based mfa
        }
    }
    
    // Text field for MFA question response
    func addTextField(textField: UITextField!) {
        responseTextField = textField
        responseTextField!.placeholder = "Enter your response."
    }
    
    // Display alert with text field for MFA question response
    func displayResponseAlert(message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: { (alertController) -> Void in
            self.submitMfaQuestionsResponse()
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Submit MFA answer
    func submitMfaQuestionsResponse() {
        PlaidClient.sharedInstance().PS_submitMFAResponse(self.accessToken!, code: false, response: responseTextField!.text!) { (response, accessToken, mfaType, mfa, accounts, transactions, error) -> () in
            // Check response code
            if response != nil {
                let response = response as! NSHTTPURLResponse
                // Check response code and give solution
                self.checkResponseCode(response, transactions: transactions!, mfaType: mfaType!, mfa: mfa!)
                // Network error
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    // Hide activity view
                    self.activityView.stopAnimating()
                    // Display alert
                    self.displayAlert("Network error",
                        message: "Please check your network connection and try again.")
                }
            }
        }
    }
    
    // Check response code and provide proper solution
    func checkResponseCode(response: NSHTTPURLResponse, transactions: [PlaidClient.Transactions], mfaType: String?, mfa: String?) {
        switch response.statusCode {
            // Successful
        case 200:
            // Sort/categorize downloaded transactions
            self.parseTransactions(transactions)
            // Hide activity view
            self.activityView.stopAnimating()
            // Return to Budget view
            dispatch_async(dispatch_get_main_queue()) {
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(5), target: self, selector: "dismiss", userInfo: nil, repeats: false)
            }

        // MFA response needed
        case 201:
            dispatch_async(dispatch_get_main_queue()) {
                // Hide activity view
                self.activityView.stopAnimating()
                // Submit MFA responses
                self.checkMfaType(mfaType, mfa: mfa)
            }
            // User error
        case 400...404:
            dispatch_async(dispatch_get_main_queue()) {
                // Hide activity view
                self.activityView.stopAnimating()
                // Display alert
                self.displayAlert("Could not log in",
                    message: "Please check your credentials and try again.")
            }
            // Server error
        default:
            dispatch_async(dispatch_get_main_queue()) {
                // Hide activity view
                self.activityView.stopAnimating()
                // Display alert
                self.displayAlert("Server error",
                    message: "Please try again at a later time.")
            }
        }
    }
    
    // Init new category, subcategory, and transaction
    func initThreeObjects(catTitle: String, subTitle: String, date: String, title: String, amount: String) {
        let newCategory = Category(catTitle: catTitle, context: self.sharedContext)
        let newSubcategory = Subcategory(category: newCategory, subTitle: subTitle, totalAmount: "$0.00", context: self.sharedContext)
        let newTransaction = Transaction(subcategory: newSubcategory, date: date, title: title, amount: amount, notes: "", context: self.sharedContext)
        
        newTransaction.subcategory = newSubcategory
    }
    
    // Init new subcategory and transaction
    func initTwoObjects(category: Category, subTitle: String, date: String, title: String, amount: String) {
        let newSubcategory = Subcategory(category: category, subTitle: subTitle, totalAmount: "$0.00", context: self.sharedContext)
        let newTransaction = Transaction(subcategory: newSubcategory, date: date, title: title, amount: amount, notes: "", context: self.sharedContext)
        
        newTransaction.subcategory = newSubcategory
    }
    
    // Init a new transaction
    func initNewTransaction(subcategory: Subcategory, date: String, title: String, amount: String) -> Transaction {
        let newTransaction = Transaction(subcategory: subcategory, date: date, title: title, amount: amount, notes: "", context: self.sharedContext)
        
        return newTransaction
    }
    
    // Double to currency style formatter
    func doubleToCurrency(amount: Double) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let amountString = formatter.stringFromNumber(amount)
        
        return amountString!
    }
    
    // Date formatter to short style
    func dateFormatter(dateString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDate = dateFormatter.dateFromString(dateString)
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateStyle = .ShortStyle
        let newDateString = newDateFormatter.stringFromDate(newDate!)
        
        return newDateString
    }
    
    // Sort and categorize transaction data
    func parseTransactions(transactions: [PlaidClient.Transactions]) {
        dispatch_async(dispatch_get_main_queue()) {
        for transaction in transactions {
                // Format the transaction amount into a currency string
                let amountString = self.doubleToCurrency(transaction.amount)
            
                // Format the date style to short style
                let newDateString = self.dateFormatter(transaction.date)
            
                let subcategories = self.fetchedResultsController.fetchedObjects as! [Subcategory]
                // Downloaded transaction has no category data
                if transaction.category == nil {
                    // Search core data to find existing "Other" category
                    let categories = subcategories.map { $0.category }
                    let foundCategory = categories.filter{$0.catTitle == "Other"}.first
                    
                    // No "Other" category found
                    if foundCategory == nil {
                        // Init three objects
                        self.initThreeObjects("Other", subTitle: "Other", date: newDateString, title: transaction.name, amount: amountString)
                        
                        //self.saveAndFetch()
                        
                    // "Other" category found
                    } else {
                        // Search core data to find existing "Other" subcategory
                        let foundSubcategory = subcategories.filter{$0.subTitle == "Other"}.first
                        
                        // No "Other" subcategory found
                        if foundSubcategory == nil {
                            // Init two objects
                            self.initTwoObjects(foundCategory!, subTitle: "Other", date: newDateString, title: transaction.name, amount: amountString)
                            
                            //self.saveAndFetch()
                            
                        // "Other" subcategory found
                        } else {
                            // Init new transaction
                            let newTransaction = self.initNewTransaction(foundSubcategory!,
                                date: newDateString,
                                title: transaction.name,
                                amount: amountString)
                            
                            newTransaction.subcategory = foundSubcategory!
                            
                            //self.saveAndFetch()
                        }
                    }
                // Transaction category array contains one value
                } else if transaction.category!.count == 1 {
                    // Recategorize
                    let categoryFirstIndex = transaction.category![0] as! String
                    let newCatString = self.changeCatString(categoryFirstIndex)
                    
                    // Search for category in core data
                    let categories = subcategories.map { $0.category }
                    let foundCategory = categories.filter{$0.catTitle == newCatString}.first
                    
                    // No category found
                    if foundCategory == nil {
                        // Init three objects
                        self.initThreeObjects(newCatString, subTitle: "Other", date: newDateString, title: transaction.name, amount: amountString)
                        
                        //self.saveAndFetch()
                    // Category found
                    } else {
                        // Search for "Other" subcategory in core data
                        let foundSubcategory = subcategories.filter{$0.subTitle == "Other"}.first
                        
                        // No "Other" subcategory found
                        if foundSubcategory == nil {
                            // Init two objects
                            self.initTwoObjects(foundCategory!, subTitle: "Other", date: newDateString, title: transaction.name, amount: amountString)
                            
                            self.saveAndFetch()
                        
                        // "Other" subcategory found
                        } else {
                            // Init new transaction
                            let newTransaction = self.initNewTransaction(foundSubcategory!,
                                date: newDateString,
                                title: transaction.name,
                                amount: amountString)
                            
                            newTransaction.subcategory = foundSubcategory!
                            
                            //self.saveAndFetch()
                        }
                    }
                // Transaction category array has more than one value
                } else {
                    // Recategorize
                    let categoryFirstIndex = transaction.category![0] as! String
                    let newCatString = self.changeCatString(categoryFirstIndex)
                    // Regroup subcategories
                    let categorySecondIndex = transaction.category![1] as! String
                    let newSubcatString = self.changeSubcatString(categorySecondIndex)
                    
                    // Search for category in core data
                    let categories = subcategories.map { $0.category }
                    let foundCategory = categories.filter{$0.catTitle == newCatString}.first
                    
                    // No category found
                    if foundCategory == nil {
                        // Init three objects
                        self.initThreeObjects(newCatString, subTitle: newSubcatString, date: newDateString, title: transaction.name, amount: amountString)
                        
                        //self.saveAndFetch()
                    
                    // Category found
                    } else {
                        // Search for subcategory in core data
                        let foundSubcategory = subcategories.filter{$0.subTitle == newSubcatString}.first

                        // No subcategory found
                        if foundSubcategory == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                            // Init two objects
                            self.initTwoObjects(foundCategory!, subTitle: newSubcatString, date: newDateString, title: transaction.name, amount: amountString)
                            
                            //self.saveAndFetch()
                            }
                        
                        // Subcategory found
                        } else {
                            // Init new transaction
                            let newTransaction = self.initNewTransaction(foundSubcategory!,
                                date: newDateString,
                                title: transaction.name,
                                amount: amountString)
                            
                            newTransaction.subcategory = foundSubcategory!
                            
                            //self.saveAndFetch()
                        }
                    }
                }
            }
            self.saveAndFetch()
        }
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Get institution type from selected string
    func institutionFromString(instType: String) {
        switch instType {
        case "American Express":
            institution = .amex
        case "Bank of America":
            institution = .bofa
        case "Capital One 360":
            institution = .capone360
        case "Charles Schwab":
            institution = .chase
        case "Chase":
            institution = .citi
        case "Citi Bank":
            institution = .fidelity
        case "Fidelity":
            institution = .pnc
        case "PNC":
            institution = .schwab
        case "US Bank":
            institution = .us
        case "USAA":
            institution = .usaa
        case "Wells Fargo":
            institution = .wells
        default:
            break
        }
    }
    
    // Change transaction category details to fit existing categories
    func changeCatString(catString: String) -> String {
        switch catString {
        case "Food and Drink":
            return "Food"
        case "Travel":
            return "Transportation"
        case "Community", "Healthcare", "Recreation", "Service", "Shops":
            return "Lifestyle"
        case "Tax":
            return "Insurance & Tax"
        case "Payment":
            return "Debt"
        default:
            return "Other"
        }
    }
    
    // Regroup subcategories by changing transaction category string
    func changeSubcatString(subcatString: String) -> String {
        switch subcatString {
        case "Overdraft", "ATM", "Late Payment", "Fraud Dispute", "Foreign Transaction", "Wire Transfer", "Insufficient Funds", "Cash Advance", "Excess Activity":
            return "Bank Fees"
        case "Animal Shelter", "Cemetary", "Libraries", "Organizations and Associations", "Post Offices", "Public and Social Services", "Senior Citizen Services":
            return "Community"
        case "Assisted Living Services", "Disabled Persons Services", "Drug and Alcohol Services", "Healthcare Services", "Physicians", "Glasses and Optometrist":
            return "Healthcare"
        case "Day Care and Preschools", "Education":
            return "Education"
        case "Courts", "Government Departments and Agencies", "Government Lobbyists", "Housing Assistance and Shelters", "Law Enforcement", "Military":
            return "Government"
        case "Religious":
            return "Religion"
        case "Bar", "Breweries", "Internet Cafes":
            return "Bars & Breweries"
        case "Nightlife":
            return "Nightlife"
        case "Restaurants":
            return "Restaurants"
        case "Interest Earned", "Interest Charged":
            return "Interest"
        case "Credit Card", "Loan":
            return "Payment"
        case "Rent":
            return "Mortgage & Rent"
        case "Arts and Entertainment":
            return "Arts & Entertainment"
        case "Athletic Fields", "Baseball", "Basketball", "Batting Cages", "Boating", "Campgrounds and RV Parks", "Canoes and Kayaks", "Combat Sports", "Cycling", "Dance", "Equestrian", "Football", "Go Carts", "Golf", "Gun Ranges", "Gymnastics", "Gyms and Fitness Centers", "Hiking", "Hockey", "Hot Air Balloons", "Hunting and Fishing", "Miniature Golf", "Paintball", "Personal Trainers", "Race Tracks", "Racquet Sports", "Racquetball", "Rafting", "Recreation Centers", "Rock Climbing", "Running", "Scuba Diving", "Skating", "Sky Diving", "Snow Sports", "Soccer", "Sports and Recreation Camps", "Sports Clubs", "Stadiums and Arenas", "Swimming", "Tennis", "Water Sports", "Yoga and Pilates", "Zoo":
            return "Recreation"
        case "Landmarks", "Outdoors", "Parks":
            return "Parks & Outdoors"
        case "Advertising and Marketing":
            return "Advertising & Marketing"
        case "Automotive":
            return "Automotive Services"
        case "Business and Strategy Consulting", "Business Services":
            return "Business Services"
        case "Cable", "Internet Services", "Utilities", "Oil and Gas":
            return "Utilities"
        case "Computers":
            return "Computer Repair"
        case "Construction":
            return "Construction"
        case "Financial", "Credit Counseling and Bankruptcy Services":
            return "Financial Services"
        case "Home Improvement", "Household":
            return "Home Improvement"
        case "Insurance":
            return "Insurance"
        case "Manufacturing":
            return "Manufacturing"
        case "Personal Care":
            return "Personal Care"
        case "Real Estate":
            return "Real Estate"
        case "Art Restoration", "Audio Visual", "Automation and Control Systems", "Chemicals and Gasses", "Cleaning", "Dating and Escort", "Employment Agencies", "Engineering", "Entertainment", "Events and Event Planning", "Food and Beverage", "Funeral Services", "Geological", "Human Resources", "Immigration", "Import and Export", "Industrial Machinery and Vehicles", "Leather", "Legal", "Logging and Sawmills", "Machine Shops", "Management", "Media Production", "Metals", "Mining", "News Reporting", "Packaging", "Paper", "Petroleum", "Photography", "Plastics", "Rail", "Refrigeration and Ice", "Renewable Energy", "Repair Services", "Research", "Rubber", "Scientific", "Security and Safety", "Shipping and Freight", "Software Development", "Storage", "Subscription", "Tailors", "Telecommunication Services", "Textiles", "Tourist Information and Services", "Travel Agents and Tour Operators", "Veterinarians", "Water and Waste Management", "Web Design and Development", "Welding", "Agriculture and Forestry":
            return "Services"
        case "Automotive":
            return "Automotive Purchases"
        case "Clothing and Accessories":
            return "Clothing & Accessories"
        case "Computers and Electronics":
            return "Computers & Electronics"
        case "Food and Beverage Store", "Supermarkets and Groceries":
            return "Groceries"
        case "Outlet":
            return "Outlets"
        case "Pharmacies":
            return "Pharmacy"
        case "Adult", "Antiques", "Arts and Crafts", "Auctions", "Beauty Products", "Bicycles", "Boat Dealers", "Book Stores", "Cards and Stationery", "Children", "Construction Supplies", "Convenience Stores", "Costumes", "Dance and Music", "Department Stores", "Digital Purchase", "Discount Stores", "Electrical Equipment", "Equipment Rental", "Flea Markets", "Florists", "Furniture and Home Decor", "Gift and Novelty", "Hobby and Collectibles", "Hardware Store", "Industrial Supplies", "Jewelry and Watches", "Luggage", "Marine Supplies", "Music, Video and DVD", "Musical Instruments", "Newstands", "Office Supplies", "Pawn Shops", "Pets", "Photos and Frames", "Shopping Centers and Malls", "Sporting Goods", "Tobacco", "Toys", "Vintage and Thrift", "Warehouses and Wholesale Stores", "Wedding and Bridal", "Wholesale", "Lawn and Garden":
            return "Shopping"
        case "Gas Stations", "Fuel Dealer":
            return "Auto Gas & Oil"
        case "Refund", "Payment":
            return "Taxes"
        case "Internal Account Transfer", "ACH", "Billpay", "Check", "Credit", "Debit", "Deposit", "Keep the Change Savings Program", "Payroll", "Third Party", "Wire", "Withdrawl", "Save As You Go":
            return "Transfer"
        case "Airlines and Aviation Services", "Airports", "Boat", "Bus Stations", "Car and Truck Rentals", "Car Service", "Charter Buses", "Cruises", "Heliports", "Limos and Chauffeurs", "Lodging", "Parking", "Public Transportation Services", "Rail", "Taxi", "Tolls and Fees", "Transportation", "Transportation Centers":
            return "Travel"
        default:
            return "Other"
        }
    }
}