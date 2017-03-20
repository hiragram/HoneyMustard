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

final class TimelineViewController: UIViewController, StoryboardInstantiatable {

  private let bag = DisposeBag.init()

  private let vm = TimelineViewModel.init()

  @IBOutlet fileprivate weak var tableView: UITableView! {
    didSet {
      tableView.registerNib(cellType: TweetCell.self)
      vm.items.bindTo(tableView.rx.items(dataSource: vm.dataSource)).addDisposableTo(bag)
      tableView.estimatedRowHeight = 100 // FIXME
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Observable.just(true).bindTo(vm.streamingIsConnected).addDisposableTo(bag)
  }
}
