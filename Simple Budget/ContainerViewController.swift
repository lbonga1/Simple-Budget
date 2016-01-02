//
//  ContainerViewController.swift
//  Simple Budget
//
//  Created by Lauren Bongartz on 1/1/16.
//  Copyright © 2016 Lauren Bongartz. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    enum DropDownState {
        case Collapsed
        case Expanded
    }

    var parentNavigationController: UINavigationController!
    var parentVC: ParentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentVC = UIStoryboard.parentVC()
        parentVC.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        parentNavigationController = UINavigationController(rootViewController: parentVC)
        view.addSubview(parentNavigationController.view)
        addChildViewController(parentNavigationController)
        
        parentNavigationController.didMoveToParentViewController(self)
    }
}

extension ContainerViewController: ParentViewControllerDelegate {
    
//    func toggleDropDown() {
//        let notAlreadyExpanded = (DropDownState != .Expanded)
//        
//        if notAlreadyExpanded {
//            addMonthDropDown()
//        }
//        
//        animateMonthDropDown(shouldExpand: notAlreadyExpanded)
//    }
//    
//    func collapseDropDown() {
//        
//    }
    
    func addMonthDropDown(monthDropDown: UICollectionViewController) {
//        monthDropDown.delegate = parentVC
        
        view.insertSubview(monthDropDown.view, atIndex: 0)
        
        addChildViewController(monthDropDown)
        monthDropDown.didMoveToParentViewController(self)
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }

    class func parentVC() -> ParentViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ParentViewController") as? ParentViewController
    }
}
