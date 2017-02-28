//
//  CustomMonthCell.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 12/29/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class CustomMonthCell: UICollectionViewCell {
    
    var monthLabel: UILabel!
    var yearLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure Month label
        monthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*2/3))
        monthLabel.font = UIFont(name: "Avenir-Book", size: 17)
        monthLabel.textAlignment = .center
        contentView.addSubview(monthLabel)
        
        // Configure Year label
        yearLabel = UILabel(frame: CGRect(x: 0, y: monthLabel.frame.size.height, width: frame.size.width, height: frame.size.height/3))
        yearLabel.font = UIFont(name: "Avenir-Book", size: 12)
        yearLabel.textAlignment = .center
        contentView.addSubview(yearLabel)
        
    }
}
