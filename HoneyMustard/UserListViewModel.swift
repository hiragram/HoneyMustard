//
//  UserListViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/13.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Models

final class UserListViewModel<T: UITableViewCell> where T: UserRepresentable {
  typealias User = MastodonAccountEntity

  struct Source {
    typealias Stream = Observable<[MastodonAccountEntity]>

    var refresh: Stream
    var fetchOlder: (Int?) -> Stream

    static func follower(ofUserID userID: Int) -> Source {
      return Source.init(refresh: MastodonRepository.follower(userID: userID), fetchOlder: { (minID) -> UserListViewModel.Source.Stream in
        return MastodonRepository.follower(userID: userID, minID: minID)
      })
    }

    static func following(ofUserID userID: Int) -> Source {
      return Source.init(refresh: MastodonRepository.following(userID: userID), fetchOlder: { (minID) -> UserListViewModel.Source.Stream in
        return MastodonRepository.following(userID: userID, minID: minID)
      })
    }
  }

  enum Section: SectionModelType {
    typealias Item = Row

    case users([Row])

    init(original: Section, items: [Row]) {
      switch original {
      case .users:
        self = .users(items)
      }
    }

    var items: [Row] {
      switch self {
      case .users(let rows):
        return rows
      }
    }
  }

  enum Row {
    case user(User)
  }

  enum Event {
    case userSelected(User)
  }

  fileprivate let source: Source
  private let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()
  fileprivate let users = EntityStorage<User>.init()
  fileprivate let bag = DisposeBag.init()
  fileprivate let _event = PublishSubject<Event>.init()
  let title: String?

  init(source: Source, title: String? = nil) {
    self.source = source
    self.title = title

    dataSource.configureCell = { [unowned self] (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch row {
      case .user(let user):
        let cell: T = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.displayName = user.displayName
        cell.screenName = user.acct
        cell.followerCount = user.followersCount
        cell.followingCount = user.followingCount
        cell.set(imageURL: user.avatar)
        return cell
      }
    }
  }

  func setup(tableView: UITableView) {
    tableView.registerNib(cellType: T.self)
    items.bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)
    tableView.estimatedRowHeight = 100 // FIXME
    tableView.rx.scrolledToBottom.flatMap { [weak self] (_) -> Observable<Void> in
      return self?.fetchOlder ?? Observable.empty()
    }.subscribe().addDisposableTo(bag)

    tableView.rx.modelSelected(Row.self).subscribe(onNext: { [weak self] (row) in
      switch row {
      case .user(let user):
        self?._event.onNext(.userSelected(user))
      }
    }).addDisposableTo(bag)
  }
}

extension UserListViewModel {
  var items: Observable<[Section]> {
    return users.items.map({ (users) -> [Row] in
      return users.map {
        Row.user($0)
      }
    }).map({ (rows) -> [Section] in
      return [Section.users(rows)]
    })
  }

  var refresh: Observable<Void> {
    return source.refresh
      .do(onNext: { [weak self] (users) in
        self?.users.refresh(users)
      })
      .map { _ in () }
  }

  var fetchOlder: Observable<Void> {
    return source.fetchOlder(users.last?.id)
      .do(onNext: { [weak self] (users) in
        let lastID = self?.users.last?.id
        let appendingUsers = users.split(whereSeparator: { (user) -> Bool in
          user.id == lastID
        }).last.map { Array($0) } ?? []
        appendingUsers.forEach {
          self?.users.append($0)
        }
      })
      .map { _ in () }
  }

  var event: Observable<Event> {
    return _event.asObservable()
  }
}

protocol UserRepresentable: class {
  var displayName: String { get set }
  var screenName: String { get set }
  var followingCount: Int { get set }
  var followerCount: Int { get set }
  func set(imageURL: URL)
}
