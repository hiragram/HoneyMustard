//
//  TableViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/22.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class TableViewController: UIViewController, StoryboardInstantiatable {
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      vm.setup(tableView: tableView)
    }
  }

  var vm: TableViewModel!
}

protocol TableViewModel {
  func setup(tableView: UITableView)
}
