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
  @IBOutlet fileprivate weak var tableView: UITableView! {
    didSet {
      tableView.registerNib(cellType: TweetCell.self)
    }
  }
}
