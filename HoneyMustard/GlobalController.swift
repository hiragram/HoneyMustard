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

  private var oauth: OAuth1Swift!

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
        self.updateViewConstraints()
      }).addDisposableTo(bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    TweetRepository.isAuthorized.take(1).subscribe(onNext: { [unowned self] (isAuthorized) in
      if !isAuthorized {
        self.oauth = OAuth1Swift.init(consumerKey: "C518wxiwwHsfUWORezGgnM1MH", consumerSecret: "fnuzGVK61pjPm3TgeWeTS4BpgiNkOlffFntYPxV7aJFJaipyY2", requestTokenUrl: "https://api.twitter.com/oauth/request_token", authorizeUrl: "https://api.twitter.com/oauth/authorize", accessTokenUrl: "https://api.twitter.com/oauth/access_token")
        self.oauth.authorize(withCallbackURL: "honeymustard://oauth-callback/twitter", success: { (credential, response, parameters) in
          Keychain.set(accessToken: credential.oauthToken, accessTokenSecret: credential.oauthTokenSecret)
        }, failure: { (error) in
          print(error.localizedDescription)
        })
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

