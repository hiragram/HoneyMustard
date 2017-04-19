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
import RxKeyboard

class GlobalController: UIViewController {

  private let bag = DisposeBag.init()

  private var rootViewController: UIViewController!

  override func loadView() {
    super.loadView()

    MastodonRepository.isAuthorized
      .filter { $0 == true }
      .subscribe(onNext: { [unowned self] (_) in
        let editVC = TweetEditViewController.instantiateFromStoryboard()
        let timelineVC = TimelineViewController.instantiateFromStoryboard()
        let splitVC = SplitViewController.init(upperViewController: timelineVC, lowerViewController: editVC)

        self.addChildViewController(splitVC)
        self.view.addSubview(splitVC.view)
        splitVC.view.translatesAutoresizingMaskIntoConstraints = false
        splitVC.didMove(toParentViewController: self)

        let constraints = [NSLayoutAttribute.top, .right, .left].map { (attribute) -> NSLayoutConstraint in
          return NSLayoutConstraint.init(item: self.view, attribute: attribute, relatedBy: .equal, toItem: splitVC.view, attribute: attribute, multiplier: 1, constant: 0)
        }
        self.view.addConstraints(constraints)

        let bottomMarginConstraints = NSLayoutConstraint.init(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: splitVC.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(bottomMarginConstraints)
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (height) in
          bottomMarginConstraints.constant = height
          self?.view.setNeedsLayout()
          self?.view.layoutIfNeeded()
        }).addDisposableTo(self.bag)

        self.rootViewController = splitVC
        self.updateViewConstraints()
      }).addDisposableTo(bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    MastodonRepository.isAuthorized.take(1).subscribe(onNext: { [unowned self] (isAuthorized) in
      if !isAuthorized {
        MastodonRepository.oauth(parentVC: self)
      }
    }).addDisposableTo(bag)
  }
}

