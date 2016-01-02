//
//  SegmentedControl.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 1/1/16.
//  Copyright © 2016 Lauren Bongartz. All rights reserved.
//

import UIKit

class SegmentedControl: UISegmentedControl {

    func initUI(){
        setupBackground()
        setupFonts()
    }
    
    func setupBackground(){
        let backgroundImage = UIImage(named: "SegmentUnselected")
        let dividerImage = UIImage(named: "SegmentSeparator")
        let backgroundImageSelected = UIImage(named: "SegmentSelected")
        
        self.setBackgroundImage(backgroundImage, forState: .Normal, barMetrics: .Default)
        self.setBackgroundImage(backgroundImageSelected, forState: .Highlighted, barMetrics: .Default)
        self.setBackgroundImage(backgroundImageSelected, forState: .Selected, barMetrics: .Default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    func setupFonts(){
        let font = UIFont(name: "Avenir-Book", size: 17)!
        let color = UIColor.blackColor()
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Highlighted)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Selected)
    }
}
