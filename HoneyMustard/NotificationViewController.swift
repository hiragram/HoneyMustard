//
//  NotificationViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/02.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationViewController: UIViewController, StoryboardInstantiatable {
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      vm.setup(tableView: tableView)
    }
  }
  @IBOutlet weak var refreshControl: UIRefreshControl! {
    didSet {
      refreshControl.rx.controlEvent(.valueChanged)
      .flatMapFirst { [unowned self] (_) -> Observable<Void> in
        self.vm.refresh.do(onError: { [weak self] (_) in
          self?.refreshControl.endRefreshing()
        }, onCompleted: { [weak self] in
          self?.refreshControl.endRefreshing()
        })
      }
      .subscribe().addDisposableTo(bag)
    }
  }

  var vm: NotificationViewModel!
  private let bag = DisposeBag.init()
}
