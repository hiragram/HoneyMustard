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

  var vm: NotificationViewModel!
}
