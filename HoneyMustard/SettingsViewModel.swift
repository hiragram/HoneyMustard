//
//  SettingsViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/22.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SettingsViewModel: TableViewModel {
  let items = Observable.just([Section.development([.feedback])])
  let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()

  private let bag = DisposeBag.init()

  enum Section: SectionModelType {
    case development([Row])

    typealias Item = Row

    init(original: Section, items: [Row]) {
      switch original {
      case .development(let items):
        self = .development(items)
      }
    }

    var items: [Row] {
      switch self {
      case .development(let rows):
        return rows
      }
    }
  }

  enum Row {
    case feedback
  }

  init() {
    dataSource.configureCell = { [unowned self] (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch dataSource[indexPath] {
      case .feedback:
        let cell: SimpleTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.title = "不具合報告/フィードバック"
        return cell
      }
    }
  }

  func setup(tableView: UITableView) {
    tableView.registerNib(cellType: SimpleTextCell.self)
    items.bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)
  }
}
