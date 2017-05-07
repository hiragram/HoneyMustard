//
//  NotificationViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/03.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Models
import RxDataSources
import Attributed

final class NotificationViewModel {
  private let bag = DisposeBag.init()
  fileprivate let notifications = EntityStorage<MastodonNotificationEntity>.init()
  private let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()

  var items: Observable<[Section]> {
    return notifications.items.map({ (notifications) -> [Section] in
      let rows = notifications.map { Row.notification($0) }
      return [Section.notifications(rows)]
    })
  }

  init() {
    dataSource.configureCell = { [unowned self] (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch row {
      case .notification(let notification):
        let cell: NotificationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        if let type = notification.type {
          let user = notification.account
          switch type {
          case .favorite:
            cell.title = "\(user.displayName)がお気に入りに追加"
            cell.username = notification.status?.account.displayName
            cell.screenname = notification.status?.account.username
            cell.set(imageURL: notification.status?.account.avatar)
            notification.status?.attributedBody.asAttributedString().subscribe(onNext: { (attributedString) in
              cell.attributedBody = attributedString
            }).addDisposableTo(cell.bag)
          case .follow:
            cell.title = "新しいフォロワー"
            cell.set(imageURL: user.avatar)
            cell.username = user.displayName
            cell.screenname = user.username
            user.attributedNote.asAttributedString().subscribe(onNext: { (attributedString) in
              cell.attributedBody = attributedString
            }).addDisposableTo(self.bag)
          case .mention:
            cell.title = "あなた宛のトゥート"
            cell.set(imageURL: user.avatar)
            cell.username = user.displayName
            cell.screenname = user.username
            notification.status?.attributedBody.asAttributedString().subscribe(onNext: { (attributedString) in
              cell.attributedBody = attributedString
            }).addDisposableTo(cell.bag)
          case .reblog:
            cell.title = "\(user.displayName)がブースト"
            cell.set(imageURL: notification.status?.account.avatar)
            cell.username = notification.status?.account.displayName
            cell.screenname = notification.status?.account.username
            notification.status?.attributedBody.asAttributedString().subscribe(onNext: { (attributedString) in
              cell.attributedBody = attributedString
            }).addDisposableTo(cell.bag)
          }
        }
        return cell
      }
    }
  }

  func setup(tableView: UITableView) {
    tableView.registerNib(cellType: NotificationCell.self)
    items.bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)
    tableView.estimatedRowHeight = 100 // FIXME
    tableView.rx.scrolledToBottom
      .flatMap { [unowned self] in self.fetchOlder }
      .subscribe().addDisposableTo(bag)
  }
}

// MARK: - Fetch from REST API

extension NotificationViewModel {
  var refresh: Observable<Void> {
    return MastodonRepository.notifications()
      .do(onNext: { [weak self] (notifications) in
        self?.notifications.refresh(notifications)
      })
      .map { _ in () }
  }

  var fetchOlder: Observable<Void> {
    return MastodonRepository.notifications(maxID: notifications.last?.id)
      .do(onNext: { [weak self] (notifications) in
        let lastID = self?.notifications.last?.id
        let appendingNotifications = notifications.split(whereSeparator: { (notification) -> Bool in
          notification.id == lastID
        }).last.map { Array($0) } ?? []
        appendingNotifications.forEach {
          self?.notifications.append($0)
        }
      })
      .map { _ in () }
  }
}

// MARK: - RxDataSources

extension NotificationViewModel {
  enum Section: SectionModelType {
    typealias Item = Row

    case notifications([Row])

    init(original: Section, items: [Row]) {
      switch original {
      case .notifications:
        self = .notifications(items)
      }
    }

    var items: [Row] {
      switch self {
      case .notifications(let items):
        return items
      }
    }
  }

  enum Row {
    case notification(MastodonNotificationEntity)
  }
}
