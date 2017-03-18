//
//  GlobalController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import SplitViewController
import Models
import RxSwift
import OAuthSwift

class GlobalController: UIViewController {

  private let bag = DisposeBag.init()

  private var rootViewController: UIViewController!

  override func loadView() {
    super.loadView()

    TweetRepository.isAuthorized
      .filter { $0 == true }
      .subscribe(onNext: { [unowned self] (_) in
        let editVC = TweetEditViewController.instantiateFromStoryboard()
        let timelineVC = TimelineViewController.instantiateFromStoryboard()
        let splitVC = SplitViewController.init(upperViewController: timelineVC, lowerViewController: editVC)

        self.addChildViewController(splitVC)
        self.view.addSubview(splitVC.view)
        splitVC.view.translatesAutoresizingMaskIntoConstraints = false
        splitVC.didMove(toParentViewController: self)
        self.rootViewController = splitVC
      }).addDisposableTo(bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    TweetRepository.isAuthorized.subscribe(onNext: { (isAuthorized) in
      if !isAuthorized {
        // OAuthSwiftの実装やる
      }
    }).addDisposableTo(bag)
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()

    if let rootViewController = rootViewController {
      let constraints = [NSLayoutAttribute.top, .bottom, .right, .left].map { (attribute) -> NSLayoutConstraint in
        return NSLayoutConstraint.init(item: view, attribute: attribute, relatedBy: .equal, toItem: rootViewController.view, attribute: attribute, multiplier: 1, constant: 0)
      }
      view.addConstraints(constraints)
    }
  }
}

