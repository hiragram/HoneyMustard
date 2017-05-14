//
//  UserListViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/14.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserListViewController: UIViewController, StoryboardInstantiatable {
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      vm.setup(tableView: tableView)
    }
  }

  private let bag = DisposeBag.init()
  var vm: UserListViewModel<UserCell>!

  override func viewDidLoad() {
    super.viewDidLoad()
    title = vm.title
    vm.refresh.subscribe().addDisposableTo(bag)
    vm.event.subscribe(onNext: { [weak self] (event) in
      switch event {
      case .userSelected(let user):
        let vm = UserProfileViewModel.init(user: user)
        let vc = UserProfileViewController.instantiateFromStoryboard()
        vc.vm = vm
        self?.show(vc, sender: nil)
      }
    }).addDisposableTo(bag)
  }
}
