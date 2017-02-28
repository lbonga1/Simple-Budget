//
//  CustomHeaderView.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 10/18/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

private let headerViewTitleFont = UIFont(name: "Avenir-Book", size: 17)

let headerViewReuseIdentifier: String = "HeaderView"

class CustomHeaderView: UITableViewHeaderFooterView {
    
    fileprivate var textColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(backgroundColor: UIColor, textColor: UIColor) {
        super.init(reuseIdentifier: headerViewReuseIdentifier)
        contentView.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    func configureTextLabel() {
        textLabel!.textColor = textColor
        textLabel!.font = headerViewTitleFont
    }
}
