//
//  ParentViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 1/1/16.
//  Copyright © 2016 Lauren Bongartz. All rights reserved.
//

import UIKit

class ParentViewController: DropDownViewController {
    
    enum TabIndex : Int {
        case FirstChildTab = 0
        case SecondChildTab = 1
        case ThirdChildTab = 2
    }
    
// MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: SegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
// MARK: - Variables
    
    var currentViewController: UIViewController?
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("Budget")
        return firstChildTabVC
    }()
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("Spent")
        return secondChildTabVC
    }()
    lazy var thirdChildTabVC : UIViewController? = {
        let thirdChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("Remaining")
        return thirdChildTabVC
    }()
    
// MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initBackgroundGradient()
        initBackgroundImage()
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.FirstChildTab.rawValue
        displayCurrentTab(TabIndex.FirstChildTab.rawValue)
        
        // Set variables from NSUserDefaults data
        monthArray = NSUserDefaults.standardUserDefaults().objectForKey("monthArray") as! [Int]
        currentMonth = NSUserDefaults.standardUserDefaults().valueForKey("currentMonth") as! String
        currentYear = NSUserDefaults.standardUserDefaults().valueForKey("currentYear") as! Int
        
        // Set up title view and month drop down view
        initNavigationItemTitleView()
        initCollectionView(self, delegate: self)
        monthDropDown.reloadData()
        
        // Initially hide the month drop down
        monthDropDown.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        // Scroll to current month collection view cell
        let indexPath = NSIndexPath(forItem: 12, inSection: 0)
        monthDropDown.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
// MARK: - Actions
    
    @IBAction func changeSegmentTab(sender: UISegmentedControl) {
        currentViewController!.view.removeFromSuperview()
        currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
}

extension ParentViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return monthArray.count
    }
}

extension ParentViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MonthCell", forIndexPath: indexPath) as! CustomMonthCell
        
        configureCell(cell, indexPath: indexPath, monthArray: monthArray, currentYear: currentYear)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if selectedIndex != nil {
            collectionView.deselectItemAtIndexPath(selectedIndex!, animated: true)
        }
        
        changeVisualSelection(selectedIndex, indexPath: indexPath, collectionView: collectionView, titleView: titleView)
        
        adjustTitleView(titleView, accessoryView: accessoryView, parentView: self.view)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cellToDeselect = collectionView.cellForItemAtIndexPath(indexPath)
        cellToDeselect?.alpha = 0.75
    }
}

    
// MARK: Changing segment tab functions

extension ParentViewController {
    
    func initBackgroundGradient() {
        var backgroundGradient: CAGradientLayer
        let colorTop = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0).CGColor
        let colorBottom = UIColor.whiteColor().CGColor
        backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 2)
    }
    
    func initBackgroundImage() {
        let titleBackgroundView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 60))
        titleBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "Login")!)
        view.addSubview(titleBackgroundView)
        view.sendSubviewToBack(titleBackgroundView)
        
        let tableBackgroundView = UIView(frame: CGRectMake(0, 100, self.view.frame.width, contentView.frame.height))
        tableBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "Login")!)
        view.insertSubview(tableBackgroundView, belowSubview: contentView)
    }
    
    func displayCurrentTab(tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            
            vc.view.frame = self.contentView.bounds
            contentView.addSubview(vc.view)
            currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.FirstChildTab.rawValue:
            vc = firstChildTabVC
        case TabIndex.SecondChildTab.rawValue:
            vc = secondChildTabVC
        case TabIndex.ThirdChildTab.rawValue:
            vc = thirdChildTabVC
        default:
            return nil
        }
        
        return vc
    }
}
