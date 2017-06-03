//
//  UserProfileViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/05.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

final class UserProfileViewController: UIViewController, StoryboardInstantiatable {
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      vm.setup(tableView: tableView)
    }
  }

  var vm: UserProfileViewModel!
  private let bag = DisposeBag.init()

  override func viewDidLoad() {
    super.viewDidLoad()

    vm.transition.subscribe(onNext: { [weak self] (transition) in
      guard let _self = self else {
        return
      }
      switch transition {
      case .statuses(userID: let userID):
        let statusVC = TimelineViewController.instantiateFromStoryboard()
        statusVC.vm = TimelineViewModel.init(source: .user(id: userID))
        statusVC.vm.refresh.subscribe().addDisposableTo(_self.bag)
        _self.show(statusVC, sender: nil)
      case .followers(user: let user):
        let vm = UserListViewModel<UserCell>.init(source: .follower(ofUserID: user.id), title: "\(user.username)のフォロワー")
        let vc = UserListViewController.instantiateFromStoryboard()
        vc.vm = vm
        self?.show(vc, sender: nil)
      case .followings(user: let user):
        let vm = UserListViewModel<UserCell>.init(source: .following(ofUserID: user.id), title: "\(user.username)のフォロー")
        let vc = UserListViewController.instantiateFromStoryboard()
        vc.vm = vm
        self?.show(vc, sender: nil)
      case .safari(let url):
        let safari = SFSafariViewController.init(url: url)
        self?.present(safari, animated: true, completion: nil)
      case .block:
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let ok = UIAlertAction.init(title: "ブロック", style: .destructive, handler: { [weak self] (_) in
          guard let _self = self else {
            return
          }
          _self.vm.block.subscribe().addDisposableTo(_self.bag)
        })
        let cancel = UIAlertAction.init(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self?.present(alert, animated: true, completion: nil)
      case .unblock:
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let ok = UIAlertAction.init(title: "ブロック解除", style: .destructive, handler: { [weak self] (_) in
          guard let _self = self else {
            return
          }
          _self.vm.unblock.subscribe().addDisposableTo(_self.bag)
        })
        let cancel = UIAlertAction.init(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self?.present(alert, animated: true, completion: nil)
      }
    }).addDisposableTo(bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    vm.fetchRecentPost.subscribe().addDisposableTo(bag)
    vm.fetchRelationship.subscribe().addDisposableTo(bag)
  }
}
