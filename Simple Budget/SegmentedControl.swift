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
        
        setBackgroundImage(backgroundImage, forState: .Normal, barMetrics: .Default)
        setBackgroundImage(backgroundImageSelected, forState: .Highlighted, barMetrics: .Default)
        setBackgroundImage(backgroundImageSelected, forState: .Selected, barMetrics: .Default)
        
        setDividerImage(dividerImage, forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
        setDividerImage(dividerImage, forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
        setDividerImage(dividerImage, forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    func setupFonts(){
        let font = UIFont(name: "Avenir-Book", size: 12)!
        let color = UIColor.blackColor()
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font
        ]
        
        setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        setTitleTextAttributes(normalTextAttributes, forState: .Highlighted)
        setTitleTextAttributes(normalTextAttributes, forState: .Selected)
    }
}
