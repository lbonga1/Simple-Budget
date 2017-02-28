//
//  PlaidConvenience.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 12/1/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

extension PlaidClient {
    
// MARK: - Formatters
    
    // Double to currency style formatter
    func doubleToCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "en_US")
        let amountString = formatter.string(from: NSNumber(value:amount))
        
        return amountString!
    }
    
    // Date formatter to short style
    func dateFormatter(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDate = dateFormatter.date(from: dateString)
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateStyle = .short
        let newDateString = newDateFormatter.string(from: newDate!)
        
        return newDateString
    }
    
// MARK: - Helper funcs
    
    enum JsonError:Error {
        case writing
        case reading
        case empty
    }
    
    enum PlaidError:Error {
        case badAccessToken
        case credentialsMissing(String)
        case invalidCredentials(String)
        case incorrectMfa(String)
        case institutionNotAvailable
    }
    
    func dictToString(_ value: AnyObject) -> NSString {
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: []) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string
                }
            }
        }
        return ""
    }
    
    func institutionToString(_ institution: Institution) -> String {
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
    
    
    // Change transaction category details to fit existing categories
    func changeCatString(_ catString: String) -> String {
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
    func changeSubcatString(_ subcatString: String) -> String {
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
