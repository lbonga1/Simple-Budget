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
    
// MARK: - Variable
    var amountUpdateHandler: ((BudgetSubcategoryCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set text field delegate
        amountTextField.delegate = self
    }
    
// MARK: - Text field delegate
    
    // Dismisses keyboard when user taps "return".
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    // Change characters of user's input into currency string
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Construct the text that will be in the field if this change is accepted
        let oldText = textField.text! as NSString
        var newText = oldText.replacingCharacters(in: range, with: string) as NSString!
        var newTextString = String(describing: newText)
        
        let digits = CharacterSet.decimalDigits
        var digitText = ""
        for c in newTextString.unicodeScalars {
            if digits.contains(UnicodeScalar(c.value)!) {
                digitText.append(String(c))
            }
        }
        // Format to US currency
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "en_US")
        let numberFromField = (NSString(string: digitText).doubleValue)/100
        newText = formatter.string(from: NSNumber(value:numberFromField)) as NSString?
        
        textField.text = newText as String?
        
        return false
    }
    
    // Update amount value in core data when text field ends editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        amountUpdateHandler?(self)
    }
}
