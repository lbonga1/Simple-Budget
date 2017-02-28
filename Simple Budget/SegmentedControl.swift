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
        
        setBackgroundImage(backgroundImage, for: UIControlState(), barMetrics: .default)
        setBackgroundImage(backgroundImageSelected, for: .highlighted, barMetrics: .default)
        setBackgroundImage(backgroundImageSelected, for: .selected, barMetrics: .default)
        
        setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: .selected, barMetrics: .default)
        setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: UIControlState(), barMetrics: .default)
        setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    
    func setupFonts(){
        let font = UIFont(name: "Avenir-Book", size: 12)!
        let color = UIColor.black
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font
        ]
        
        setTitleTextAttributes(normalTextAttributes, for: UIControlState())
        setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        setTitleTextAttributes(normalTextAttributes, for: .selected)
    }
}
