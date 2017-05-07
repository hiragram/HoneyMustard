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
    try! Keychain.initialize()

    MastodonRepository.isAuthorized
      .filter { $0 == true }
      .take(1)
      .subscribe(onNext: { [unowned self] (_) in
        let homeVC = TimelineViewController.instantiateFromStoryboard()
        homeVC.vm = TimelineViewModel.init(source: .home)
        homeVC.vm.refresh.subscribe().addDisposableTo(self.bag)
        homeVC.title = "ホーム"
        let homeNav = UINavigationController.init(rootViewController: homeVC)
        homeNav.tabBarItem.image = #imageLiteral(resourceName: "Home")

        let publicVC = TimelineViewController.instantiateFromStoryboard()
        publicVC.vm = TimelineViewModel.init(source: .public)
        publicVC.vm.refresh.subscribe().addDisposableTo(self.bag)
        publicVC.title = "連合"
        let publicNav = UINavigationController.init(rootViewController: publicVC)
        publicNav.tabBarItem.image = #imageLiteral(resourceName: "Internet")

        let localVC = TimelineViewController.instantiateFromStoryboard()
        localVC.vm = TimelineViewModel.init(source: .local)
        localVC.vm.refresh.subscribe().addDisposableTo(self.bag)
        localVC.title = "ローカル"
        let localNav = UINavigationController.init(rootViewController: localVC)
        localNav.tabBarItem.image = #imageLiteral(resourceName: "Server")

        let notificationVC = NotificationViewController.instantiateFromStoryboard()
        notificationVC.vm = NotificationViewModel.init()
        notificationVC.vm.refresh.subscribe().addDisposableTo(self.bag)
        let notificationNav = UINavigationController.init(rootViewController: notificationVC)
        notificationNav.tabBarItem.image = #imageLiteral(resourceName: "Notification")

        let tabVC = UITabBarController.init()
        tabVC.viewControllers = [homeNav, localNav, publicNav, notificationNav]

        self.addChildViewController(tabVC)
        self.view.addSubview(tabVC.view)
        tabVC.view.translatesAutoresizingMaskIntoConstraints = false
        tabVC.didMove(toParentViewController: self)

        let constraints = [NSLayoutAttribute.top, .right, .left].map { (attribute) -> NSLayoutConstraint in
          return NSLayoutConstraint.init(item: self.view, attribute: attribute, relatedBy: .equal, toItem: tabVC.view, attribute: attribute, multiplier: 1, constant: 0)
        }
        self.view.addConstraints(constraints)

        let bottomMarginConstraints = NSLayoutConstraint.init(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: tabVC.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(bottomMarginConstraints)
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (height) in
          bottomMarginConstraints.constant = height
          self?.view.setNeedsLayout()
          self?.view.layoutIfNeeded()
        }).addDisposableTo(self.bag)

        self.rootViewController = tabVC
        self.updateViewConstraints()
      }).addDisposableTo(bag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    MastodonRepository.isAuthorized.take(1).subscribe(onNext: { [unowned self] (isAuthorized) in
      if !isAuthorized {
        DispatchQueue.main.async {
          MastodonRepository.oauth(parentVC: self)
        }
      }
    }).addDisposableTo(bag)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

