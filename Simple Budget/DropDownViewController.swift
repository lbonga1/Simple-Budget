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
    var selectedIndex: IndexPath?
    var dropDownCanExpand: Bool = true
    var accessoryView = UIImageView()
    let titleView = UILabel()
    
// MARK: Navigation title functions
    
    func initNavigationItemTitleView() {
        titleView.text = getFullMonthString(currentMonth)
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width + 15
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 40))
        titleView.center.x = self.view.center.x
        navigationItem.titleView = titleView
        
        accessoryView = UIImageView(frame: CGRect(x: width - 3, y: 16, width: 11, height: 11))
        accessoryView.image = UIImage(named: "AccessoryDown")
        titleView.addSubview(accessoryView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(DropDownViewController.titleWasTapped))
        recognizer.numberOfTapsRequired = 1
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    func titleWasTapped() {
        if monthDropDown.isHidden == true {
            view.bringSubview(toFront: monthDropDown)
            monthDropDown.isHidden = false
            
            accessoryView.image = UIImage(named: "AccessoryUp")
            animateDropDown()
        } else {
            accessoryView.image = UIImage(named: "AccessoryDown")
            animateDropDown()
        }
    }
    
    func animateDropDown() {
        if dropDownCanExpand == true {
            UIView.animate (withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.monthDropDown.center.y = 95
                }, completion: { _ in
                    self.dropDownCanExpand = false
            })
        } else {
            UIView.animate (withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.monthDropDown.center.y = -30
                }, completion: { _ in
                    self.dropDownCanExpand = true
                    self.monthDropDown.isHidden = true
            })
        }
    }
    
    func changeVisualSelection(_ selectedIndex: IndexPath?, indexPath: IndexPath, collectionView: UICollectionView, titleView: UILabel) {
        var selectedIndex = selectedIndex
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! CustomMonthCell
        selectedIndex = indexPath
        selectedCell.alpha = 0.95
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        titleView.text = getFullMonthString(selectedCell.monthLabel.text!)
    }
    
    func adjustTitleView(_ titleView: UILabel, accessoryView: UIImageView, parentView: UIView) {
        var newTitleFrame = titleView.frame
        newTitleFrame.size.width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width + 15
        print(newTitleFrame.size.width)
        newTitleFrame.size.height = 40
        titleView.frame = newTitleFrame
        titleView.center.x = parentView.center.x
        print(titleView.frame.size.width)
        print(parentView.center.x)
        print(titleView.center.x)
        
        var newAccessoryFrame = accessoryView.frame
        newAccessoryFrame = CGRect(x: newTitleFrame.size.width - 3, y: 16, width: 11, height: 11)
        accessoryView.frame = newAccessoryFrame
    }
    
// MARK: - Collection View functions
    
    func initCollectionView(_ dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        layout.itemSize = CGSize(width: 45, height: 45)
        layout.scrollDirection = .horizontal
        
        monthDropDown = UICollectionView(frame: CGRect(x: 0, y: -30, width: self.view.frame.width, height: 60), collectionViewLayout: layout)
        monthDropDown.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        monthDropDown.dataSource = dataSource
        monthDropDown.delegate = delegate
        monthDropDown.register(CustomMonthCell.self, forCellWithReuseIdentifier: "MonthCell")
        monthDropDown.backgroundColor = UIColor.white
        monthDropDown.showsHorizontalScrollIndicator = false
        
        let view = UIView(frame: CGRect(x: 0, y: -30, width: self.view.frame.width, height: 60))
        view.backgroundColor = UIColor(patternImage:UIImage(named:"Login")!)
        monthDropDown.backgroundView = view
        
        view.addSubview(monthDropDown)
        
        monthDropDown.layer.shadowColor = UIColor.black.cgColor
        monthDropDown.layer.shadowOffset = CGSize(width: 0, height: 1)
        monthDropDown.layer.shadowOpacity = 0.8
        monthDropDown.layer.shadowRadius = 1.0
        monthDropDown.clipsToBounds = false
        monthDropDown.layer.masksToBounds = false
    }
    
    func configureCell(_ cell: CustomMonthCell, indexPath: IndexPath, monthArray: [Int], currentYear: Int) {
        
        cell.layer.cornerRadius = 7.0
        cell.backgroundColor = UIColor.white
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

// MARK: - Helper functions
    
    func getCurrentMonthYear() {
        let calendar = Calendar.current
        let date = Date()
        let currentMonth = (calendar as NSCalendar).component(.month, from: date) + 12
        let currentMonthString = intToString(currentMonth)
        let currentYear = (calendar as NSCalendar).component(.year, from: date)
        
        let newMonthRange = (currentMonth - 12)...(currentMonth + 12)
        let newMonthArray = [Int](newMonthRange)
        
        // Save to NSUserDefaults
        UserDefaults.standard.set(newMonthArray, forKey: "monthArray")
        UserDefaults.standard.setValue(currentMonthString, forKey: "currentMonth")
        UserDefaults.standard.setValue(currentYear, forKey: "currentYear")
    }
    
    func intToString(_ month: Int) -> String {
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
    
    func getFullMonthString(_ month: String) -> String {
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
//        layer.addSublayer(shapeLayer)
//    }
//}
