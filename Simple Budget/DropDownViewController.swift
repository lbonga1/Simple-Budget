//
//  DropDownViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 12/28/15.
//  Copyright © 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class DropDownViewController: UIViewController {
    
// MARK: - Variables
    
    var monthDropDown: UICollectionView!
    var monthArray: [Int] = []
    var currentMonth: String!
    var currentYear: Int!
    var selectedIndex: NSIndexPath?
    var dropDownCanExpand: Bool = true
    var accessoryView = UIImageView()
    let titleView = UILabel()

// MARK: - Helper functions
    
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
    
    func configureCell(cell: CustomMonthCell, indexPath: NSIndexPath, monthArray: [Int], currentYear: Int) {
        
        cell.layer.cornerRadius = 7.0
        cell.backgroundColor = UIColor.whiteColor()
        cell.alpha = 0.75
        
        cell.monthLabel.text = intToString(monthArray[indexPath.row])
        
        if monthArray[indexPath.row] > 12 && monthArray[indexPath.row] < 25 {
            cell.yearLabel.text = String(currentYear)
        } else if monthArray[indexPath.row] < 13 {
            cell.yearLabel.text = String(currentYear - 1)
        } else {
            cell.yearLabel.text = String(currentYear + 1)
        }
    }
    
    func changeVisualSelection(var selectedIndex: NSIndexPath?, indexPath: NSIndexPath, collectionView: UICollectionView, titleView: UILabel) {
        
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! CustomMonthCell
        selectedIndex = indexPath
        selectedCell.alpha = 0.95
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        titleView.text = getFullMonthString(selectedCell.monthLabel.text!)
    }
    
    func adjustTitleView(titleView: UILabel, accessoryView: UIImageView, parentView: UIView) {
        var newTitleFrame = titleView.frame
        newTitleFrame.size.width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width + 15
        print(newTitleFrame.size.width)
        newTitleFrame.size.height = 40
        titleView.frame = newTitleFrame
        titleView.center.x = parentView.center.x
        print(titleView.frame.size.width)
        print(parentView.center.x)
        print(titleView.center.x)
    
        var newAccessoryFrame = accessoryView.frame
        newAccessoryFrame = CGRectMake(newTitleFrame.size.width - 3, 16, 11, 11)
        accessoryView.frame = newAccessoryFrame
    }
    
    func initCollectionView(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .Horizontal
        
        monthDropDown = UICollectionView(frame: CGRectMake(0, -30, self.view.frame.width, 60), collectionViewLayout: layout)
        monthDropDown.dataSource = dataSource
        monthDropDown.delegate = delegate
        monthDropDown.registerClass(CustomMonthCell.self, forCellWithReuseIdentifier: "MonthCell")
        monthDropDown.backgroundColor = UIColor.whiteColor()
        monthDropDown.showsHorizontalScrollIndicator = false
        
        let view = UIView(frame: CGRectMake(0, -30, self.view.frame.width, 60))
        view.backgroundColor = UIColor(patternImage:UIImage(named:"Login")!)
        monthDropDown.backgroundView = view
        
        self.view.addSubview(monthDropDown)
        
        monthDropDown.layer.shadowColor = UIColor.blackColor().CGColor
        monthDropDown.layer.shadowOffset = CGSizeMake(0, 1)
        monthDropDown.layer.shadowOpacity = 0.8
        monthDropDown.layer.shadowRadius = 1.0
        monthDropDown.clipsToBounds = false
        monthDropDown.layer.masksToBounds = false
    }
    
    func initNavigationItemTitleView() {
        titleView.text = getFullMonthString(currentMonth)
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width + 15
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 40))
        titleView.center.x = self.view.center.x
        parentViewController!.navigationItem.titleView = titleView
        
        accessoryView = UIImageView(frame: CGRectMake(width - 3, 16, 11, 11))
        accessoryView.image = UIImage(named: "AccessoryDown")
        titleView.addSubview(accessoryView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: "titleWasTapped")
        recognizer.numberOfTapsRequired = 1
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    func titleWasTapped() {
        if monthDropDown.hidden == true {
            self.view.bringSubviewToFront(monthDropDown)
            monthDropDown.hidden = false
            accessoryView.image = UIImage(named: "AccessoryUp")
            animateDropDown()
        } else {
            accessoryView.image = UIImage(named: "AccessoryDown")
            animateDropDown()
        }
    }
    
    func animateDropDown() {
        if self.dropDownCanExpand == true {
            UIView.animateWithDuration (0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.monthDropDown.center.y = 95
                }, completion: { _ in
                    self.dropDownCanExpand = false
            })
        } else {
            UIView.animateWithDuration (0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.monthDropDown.center.y = -30
                }, completion: { _ in
                    self.dropDownCanExpand = true
                    self.monthDropDown.hidden = true
            })
        }
    }
}

//extension UICollectionViewCell {
//    func addRemoveDashedBorder() {
//        let color = UIColor.blackColor().CGColor
//        
//        let shapeLayer: CAShapeLayer = CAShapeLayer()
//        let frameSize = self.frame.size
//        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
//        
//        shapeLayer.bounds = shapeRect
//        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
//        shapeLayer.fillColor = UIColor.clearColor().CGColor
//        shapeLayer.strokeColor = color
//        shapeLayer.lineWidth = 1.5
//        shapeLayer.lineJoin = kCALineJoinRound
//        shapeLayer.lineDashPattern = [6,3]
//        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).CGPath
//        
//        self.layer.addSublayer(shapeLayer)
//    }
//}
