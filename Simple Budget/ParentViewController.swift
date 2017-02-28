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
        case firstChildTab = 0
        case secondChildTab = 1
        case thirdChildTab = 2
    }
    
// MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: SegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
// MARK: - Variables
    
    var currentViewController: UIViewController?
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "Budget")
        return firstChildTabVC
    }()
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "Spent")
        return secondChildTabVC
    }()
    lazy var thirdChildTabVC : UIViewController? = {
        let thirdChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "Remaining")
        return thirdChildTabVC
    }()
    
// MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initBackgroundGradient()
        initBackgroundImage()
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.firstChildTab.rawValue
        displayCurrentTab(TabIndex.firstChildTab.rawValue)
        
        // Set variables from NSUserDefaults data
        monthArray = UserDefaults.standard.object(forKey: "monthArray") as! [Int]
        currentMonth = UserDefaults.standard.value(forKey: "currentMonth") as! String
        currentYear = UserDefaults.standard.value(forKey: "currentYear") as! Int
        
        // Set up title view and month drop down view
        initNavigationItemTitleView()
        initCollectionView(self, delegate: self)
        monthDropDown.reloadData()
        
        // Initially hide the month drop down
        monthDropDown.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Scroll to current month collection view cell
        let indexPath = IndexPath(item: 12, section: 0)
        monthDropDown.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
// MARK: - Actions
    
    @IBAction func changeSegmentTab(_ sender: UISegmentedControl) {
        currentViewController!.view.removeFromSuperview()
        currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
}

extension ParentViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return monthArray.count
    }
}

extension ParentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! CustomMonthCell
        
        configureCell(cell, indexPath: indexPath, monthArray: monthArray, currentYear: currentYear)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedIndex != nil {
            collectionView.deselectItem(at: selectedIndex! as IndexPath, animated: true)
        }
        
        changeVisualSelection(selectedIndex, indexPath: indexPath, collectionView: collectionView, titleView: titleView)
        
        adjustTitleView(titleView, accessoryView: accessoryView, parentView: self.view)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cellToDeselect = collectionView.cellForItem(at: indexPath)
        cellToDeselect?.alpha = 0.75
    }
}

    
// MARK: Changing segment tab functions

extension ParentViewController {
    
    func initBackgroundGradient() {
        var backgroundGradient: CAGradientLayer
        let colorTop = UIColor(red: 0, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        let colorBottom = UIColor.white.cgColor
        backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 2)
    }
    
    func initBackgroundImage() {
        let titleBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        titleBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "Login")!)
        view.addSubview(titleBackgroundView)
        view.sendSubview(toBack: titleBackgroundView)
        
        let tableBackgroundView = UIView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: contentView.frame.height))
        tableBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "Login")!)
        view.insertSubview(tableBackgroundView, belowSubview: contentView)
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.contentView.bounds
            contentView.addSubview(vc.view)
            currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.firstChildTab.rawValue:
            vc = firstChildTabVC
        case TabIndex.secondChildTab.rawValue:
            vc = secondChildTabVC
        case TabIndex.thirdChildTab.rawValue:
            vc = thirdChildTabVC
        default:
            return nil
        }
        
        return vc
    }
}
