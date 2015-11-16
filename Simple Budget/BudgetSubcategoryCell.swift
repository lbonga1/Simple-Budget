//
//  BudgetSubcategoryCell.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/18/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

class BudgetSubcategoryCell: UITableViewCell, UITextFieldDelegate {

// MARK: -Outlets
    @IBOutlet weak var subcategoryTitle: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set text field delegate
        amountTextField.delegate = self
    }
    
// MARK: - Text field delegate
    
    // Dismisses keyboard when user taps "return".
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    // Change characters of user's input into currency string
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Construct the text that will be in the field if this change is accepted
        let oldText = textField.text! as NSString
        var newText = oldText.stringByReplacingCharactersInRange(range, withString: string) as NSString!
        var newTextString = String(newText)
        
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        var digitText = ""
        for c in newTextString.unicodeScalars {
            if digits.longCharacterIsMember(c.value) {
                digitText.append(c)
            }
        }
        // Format to US currency
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let numberFromField = (NSString(string: digitText).doubleValue)/100
        newText = formatter.stringFromNumber(numberFromField)
        
        textField.text = newText as String
        
        return false
    }
    
    // Update amount value in core data when text field ends editing
    func textFieldDidEndEditing(textField: UITextField) {
        let batchRequest = NSBatchUpdateRequest(entityName: "Subcategory")
        batchRequest.propertiesToUpdate = ["totalAmount": amountTextField.text!]
        //batchRequest.predicate = NSPredicate(format: "subcategory == %@", BudgetViewController().editingTextFieldSubcategory!)
        batchRequest.resultType = .UpdatedObjectsCountResultType
        (try! self.sharedContext.executeRequest(batchRequest)) as! NSBatchUpdateResult
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()

}
