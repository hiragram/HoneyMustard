//
//  TimelineViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Models
import RxDataSources

class TimelineViewModel {

  private let bag = DisposeBag.init()

//  let dataSource = TableViewDataSource<Section>.init()
  let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()

  fileprivate let statuses = Variable<[MastodonStatusEntity]>.init([])

  var items: Observable<[Section]> {
    return statuses.asObservable().map({ (statuses) -> [Section] in
      let rows = statuses.map { Row.status($0) }
      return [Section.statuses(rows)]
    })
  }

  private var userstreamDisposable: Disposable?

  private var friendIDs: [Int] = []

  init() {
    dataSource.configureCell = { (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch row {
      case .status(let status):
        let cell: TweetCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.body = status.content
        cell.screenname = status.account.acct
        cell.name = status.account.displayName
        cell.set(imageURL: status.account.avatar)
        return cell
      }
    }
  }
}

// - MARK: Fetch from REST API

extension TimelineViewModel {
  var refresh: Observable<[MastodonStatusEntity]> {
    return MastodonRepository.timeline()
    .do(onNext: { [weak self] (statuses) in
      self?.statuses.value = statuses
    })
  }
}

// - MARK: RxDataSources

extension TimelineViewModel {
  enum Section: AnimatableSectionModelType {
    case statuses([Row])

    typealias Item = Row
    typealias Identity = Int

    var identity: Int {
      switch self {
      case .statuses:
        return 1
      }
    }

    var items: [Row] {
      switch self {
      case .statuses(let rows):
        return rows
      }
    }

    init(original: Section, items: [Item]) {
      switch original {
      case .statuses:
        self = .statuses(items)
      }
    }
  }

  enum Row: IdentifiableType, Equatable {
    case status(MastodonStatusEntity)

    typealias Identity = Int

    var identity: Int {
      switch self {
      case .status(let tweet):
        return tweet.id
      }
    }

    static func ==(lhs: TimelineViewModel.Row, rhs: TimelineViewModel.Row) -> Bool {
      return lhs.identity == rhs.identity
    }
  }
}
