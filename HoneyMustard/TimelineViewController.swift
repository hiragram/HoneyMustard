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

  private let vm = TimelineViewModel.init()

  @IBOutlet fileprivate weak var tableView: UITableView! {
    didSet {
      tableView.registerNib(cellType: TweetCell.self)
      vm.items.bindTo(tableView.rx.items(dataSource: vm.dataSource)).addDisposableTo(bag)
      tableView.estimatedRowHeight = 100 // FIXME
//      tableView.rx.scrolledToBottom.subscribe(onNext: { (_) in
//        print("一番下")
//      }).addDisposableTo(bag)
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
    vm.refresh.subscribe().addDisposableTo(bag)
    vm.openURL.subscribe(onNext: { [weak self] (transition) in
      switch transition {
      case .modally(let url):
        let safari = SFSafariViewController.init(url: url)
        self?.present(safari, animated: true, completion: nil)
      case .push(let url):
        let safari = SFSafariViewController.init(url: url)
        self?.show(safari, sender: nil)
      }
    }).addDisposableTo(bag)
  }
}
