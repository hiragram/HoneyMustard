//
//  GlobalController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import SplitViewController

class GlobalController: UIViewController {

  private var rootViewController: UIViewController!

  override func loadView() {
    super.loadView()

    let editVC = TweetEditViewController.instantiateFromStoryboard()
    let timelineVC = TimelineViewController.instantiateFromStoryboard()
    let splitVC = SplitViewController.init(upperViewController: timelineVC, lowerViewController: editVC)

    addChildViewController(splitVC)
    view.addSubview(splitVC.view)
    splitVC.view.translatesAutoresizingMaskIntoConstraints = false
    splitVC.didMove(toParentViewController: self)
    rootViewController = splitVC
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()

    let constraints = [NSLayoutAttribute.top, .bottom, .right, .left].map { (attribute) -> NSLayoutConstraint in
      return NSLayoutConstraint.init(item: view, attribute: attribute, relatedBy: .equal, toItem: rootViewController.view, attribute: attribute, multiplier: 1, constant: 0)
    }

    view.addConstraints(constraints)
  }
}

