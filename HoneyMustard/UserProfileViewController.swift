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
      }
    }).addDisposableTo(bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    vm.fetchRecentPost.subscribe().addDisposableTo(bag)
    vm.fetchRelationship.subscribe().addDisposableTo(bag)
  }
}
