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

final class TimelineViewController: UIViewController, StoryboardInstantiatable {

  private let bag = DisposeBag.init()

  private let vm = TimelineViewModel.init()

  @IBOutlet fileprivate weak var tableView: UITableView! {
    didSet {
      tableView.registerNib(cellType: TweetCell.self)
      vm.items.bindTo(tableView.rx.items(dataSource: vm.dataSource)).addDisposableTo(bag)
      tableView.estimatedRowHeight = 100 // FIXME
      tableView.tableFooterView = UIView.init(frame: CGRect.zero)
      tableView.rx.scrolledToBottom.subscribe(onNext: { (_) in
        print("一番下")
      }).addDisposableTo(bag)
    }
  }

  private var statusView: TimelineStatusView! {
    didSet {
      vm.streamingIsConnected.map {
        $0 ? Status.streamingIsEstablished : .notConnected
      }.bindTo(statusView.status).addDisposableTo(bag)
    }
  }

  override func loadView() {
    super.loadView()

    statusView = TimelineStatusView.instantiate(withOwner: self, options: nil)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    tableView.addSubview(statusView)
    let constraints = [NSLayoutAttribute.centerX, .width].map {
      NSLayoutConstraint.init(item: tableView, attribute: $0, relatedBy: .equal, toItem: statusView, attribute: $0, multiplier: 1, constant: 0)
    }
    tableView.addConstraints(constraints)
    tableView.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: .top, relatedBy: .equal, toItem: statusView, attribute: .bottom, multiplier: 1, constant: 0))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//    Observable.just(true).bindTo(vm.streamingIsConnected).addDisposableTo(bag)
    MastodonRepository.oauth(parentVC: self)
  }
}
