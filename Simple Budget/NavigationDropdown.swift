//
//  NavigationDropdown.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 12/28/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class NavigationDropdown {
    
    func getCurrentMonthYear() {
        let calendar = NSCalendar.currentCalendar()
        let date = NSDate()
        let currentMonth = calendar.component(.Month, fromDate: date) + 12
        let currentMonthString = intToString(currentMonth)
        let currentYear = calendar.component(.Year, fromDate: date)
        
        let newMonthRange = (currentMonth - 12)...(currentMonth + 12)
        let newMonthArray = [Int](newMonthRange)
        
        // Save to NSUserDefaults
        NSUserDefaults.standardUserDefaults().setObject(newMonthArray, forKey: "monthArray")
        NSUserDefaults.standardUserDefaults().setValue(currentMonthString, forKey: "currentMonth")
        NSUserDefaults.standardUserDefaults().setValue(currentYear, forKey: "currentYear")
    }
    
    func intToString(month: Int) -> String {
        switch month {
        case 1, 13, 25:
            return "Jan"
        case 2, 14, 26:
            return "Feb"
        case 3, 15, 27:
            return "Mar"
        case 4, 16, 28:
            return "Apr"
        case 5, 17, 29:
            return "May"
        case 6, 18, 30:
            return "Jun"
        case 7, 19, 31:
            return "Jul"
        case 8, 20, 32:
            return "Aug"
        case 9, 21, 33:
            return "Sep"
        case 10, 22, 34:
            return "Oct"
        case 11, 23, 35:
            return "Nov"
        case 12, 24, 36:
            return "Dec"
        default:
            return "Error"
        }
    }
    
    func getFullMonthString(month: String) -> String {
        switch month {
        case "Jan":
            return "January"
        case "Feb":
            return "February"
        case "Mar":
            return "March"
        case "Apr":
            return "April"
        case "May":
            return "May"
        case "Jun":
            return "June"
        case "Jul":
            return "July"
        case "Aug":
            return "August"
        case "Sep":
            return "September"
        case "Oct":
            return "October"
        case "Nov":
            return "November"
        case "Dec":
            return "December"
        default:
            return "Error"
        }
    }

}