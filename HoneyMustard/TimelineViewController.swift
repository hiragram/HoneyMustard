//
//  TimelineViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Models
import SafariServices

final class TimelineViewController: UIViewController, StoryboardInstantiatable {

  private let bag = DisposeBag.init()

  var vm: TimelineViewModel!

  @IBOutlet private weak var composeButton: UIBarButtonItem! {
    didSet {
      composeButton.rx.tap.asObservable().subscribe(onNext: { [weak self] (_) in
        let editVC = TweetEditViewController.instantiateFromStoryboard()
        editVC.vm = TweetEditViewModel.init()
        editVC.vm.submitted.flatMap({ [weak self] (_) -> Observable<Void> in
          self?.vm.refresh ?? Observable.empty()
        }).subscribe().addDisposableTo(editVC.bag)
        let editNav = UINavigationController.init(rootViewController: editVC)
        self?.present(editNav, animated: true, completion: nil)
      }).addDisposableTo(bag)
    }
  }
  @IBOutlet fileprivate weak var tableView: UITableView! {
    didSet {
      vm.setup(tableView: tableView)
    }
  }
  @IBOutlet weak var refreshControl: UIRefreshControl! {
    didSet {
      refreshControl.rx.controlEvent(.valueChanged).asObservable()
        .flatMapFirst { [unowned self] _ in
          self.vm.refresh
          .do(onError: { [weak self] (_) in
            self?.refreshControl.endRefreshing()
          }, onCompleted: { [weak self] _ in
            self?.refreshControl.endRefreshing()
          })
        }
        .subscribe()
        .addDisposableTo(bag)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//    vm.refresh.subscribe().addDisposableTo(bag)
    vm.transition.subscribe(onNext: { [weak self] (transition) in
      guard let _self = self else {
        return
      }
      switch transition {
      case .safari(let url):
        let safari = SFSafariViewController.init(url: url)
        self?.present(safari, animated: true, completion: nil)
      case .reply(let _status):
        let status = _status.reblog ?? _status
        status.attributedBody.asAttributedString().subscribe(onNext: { (body) in
          let editVC = TweetEditViewController.instantiateFromStoryboard()
          editVC.vm = TweetEditViewModel.init(inReplyTo: (statusID: status.id, iconURL: status.account.avatar, displayName: status.account.displayName, screenName: status.account.acct, body: body))
          let editNav = UINavigationController.init(rootViewController: editVC)
          _self.present(editNav, animated: true, completion: nil)
        }).addDisposableTo(_self.bag)
      case .user(let user):
        let userVC = UserProfileViewController.instantiateFromStoryboard()
        userVC.vm = UserProfileViewModel.init(user: user)
        _self.show(userVC, sender: nil)
      }
    }).addDisposableTo(bag)
  }
}
