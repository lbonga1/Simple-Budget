//
//  NewTransTableViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class NewTransTableViewController: UITableViewController {

// MARK: - Outlets

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.addTarget(self, action: Selector("dataPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        datePicker.hidden = true

    }
    
    
    func datePickerChanged(datePicker:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        dateButton.setTitle(strDate, forState: .Normal)
    }


}
