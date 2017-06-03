//
//  UserProfileViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/05.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Models
import RxDataSources

final class UserProfileViewModel: TweetCellRepresentable {
  private let bag = DisposeBag.init()
  fileprivate let user: MastodonAccountEntity
  fileprivate let _transition = PublishSubject<Transition>.init()
  var transition: Observable<Transition> {
    return _transition.asObservable()
  }

  let statuses = EntityStorage<MastodonStatusEntity>.init()
  fileprivate let relationship = Variable<MastodonRelationshipEntity?>.init(nil)

  private let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()

  var items: Observable<[Section]> {
    let user = Observable.just(self.user)
      .map { (user) -> [Section] in
        [Section.user(user)]
    }
//    let statuses = self.statuses.items.map { (statuses) -> [Row] in
//      [Row.sectionHeader(title: "最近の投稿")] + statuses.map { Row.status($0) }
//    }.map { (rows) -> [Section] in
//      [Section.recentPosts(rows)]
//    }
    let statuses = Observable<[Section]>.just([])

    let operations = [Section.userOperations()]

    return Observable.combineLatest(user, statuses) { (userSection, statusesSection) -> [Section] in
      return userSection + statusesSection + operations
    }
  }

  init(user: MastodonAccountEntity) {
    self.user = user
    dataSource.configureCell = { [unowned self] (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch row {
      case .follower(let count):
        let cell: SimpleTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title = "フォロワー"
        cell.content = "\(count)"
        cell.accessoryType = .disclosureIndicator
        return cell
      case .following(let count):
        let cell: SimpleTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title = "フォロー"
        cell.content = "\(count)"
        cell.accessoryType = .disclosureIndicator
        return cell
      case .header(let user):
        let cell: UserProfileHeaderCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.displayName = user.displayName
        cell.screenName = user.acct
        user.attributedNote.asAttributedString().subscribe(onNext: { (note) in
          cell.note = note
        }).addDisposableTo(cell.bag)
        self.relationship.asObservable().subscribe(onNext: { (relationship) in
          guard let relationship = relationship else {
            return
          }
          cell.relationshipDescription = relationship.blocking ? "ブロックしています" : relationship.followedBy ? "フォローされています" : "フォローされていません"
          cell.set(followButtonStyle: relationship.blocking ? .blocking : relationship.following ? .unfollow : .follow)
          cell.rx.tapFollowButton.subscribe(onNext: { [unowned self] (_) in
            if relationship.blocking {
              self.unblock.subscribe().addDisposableTo(self.bag)
            } else if relationship.following {
              MastodonRepository.unfollow(userID: user.id).bindTo(self.relationship).addDisposableTo(cell.bag)
            } else {
              MastodonRepository.follow(userID: user.id).bindTo(self.relationship).addDisposableTo(cell.bag)
            }
          }).addDisposableTo(cell.bag)
        }).addDisposableTo(cell.bag)
        cell.tapLink.flatMap({ (url) -> Observable<URL> in
          guard let url = url else {
            return .empty()
          }
          return .just(url)
        })
          .map {
            return Transition.safari($0)
        }
        .bindTo(self._transition).addDisposableTo(cell.bag)
        cell.set(userIconURL: user.avatar)
        cell.set(headerImageURL: user.header)
        return cell
      case .status(let status):
        let cell: TweetCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        self.setup(cell: cell, status: status)
        return cell
      case .statusCount(let count):
        let cell: SimpleTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title = "投稿数"
        cell.content = "\(count)"
        cell.accessoryType = .disclosureIndicator
        return cell
      case .sectionHeader(title: let title):
        let cell: SectionHeaderCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title = title
        return cell
      case .block:
        let cell: SimpleTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title = "ブロック"
        return cell
      }
    }
  }

  func setup(tableView: UITableView) {
    tableView.estimatedRowHeight = 100 // FIXME
    tableView.registerNib(cellType: UserProfileHeaderCell.self)
    tableView.registerNib(cellType: SimpleTextCell.self)
    tableView.registerNib(cellType: TweetCell.self)
    tableView.registerNib(cellType: SectionHeaderCell.self)
    items.bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)
    tableView.rx.modelSelected(Row.self).subscribe(onNext: { [weak self] (row) in
      guard let _self = self else {
        return
      }
      switch row {
      case .statusCount:
        _self._transition.onNext(.statuses(userID: _self.user.id))
      case .follower:
        _self._transition.onNext(.followers(user: _self.user))
      case .following:
        _self._transition.onNext(.followings(user: _self.user))
      case .block:
        guard let relationship = _self.relationship.value else {
          return
        }
        if relationship.blocking {
          _self._transition.onNext(.unblock)
        } else {
          _self._transition.onNext(.block)
        }
      default:
        break
      }
    }).addDisposableTo(bag)
  }

  enum Transition {
    case statuses(userID: Int)
    case followers(user: MastodonAccountEntity)
    case followings(user: MastodonAccountEntity)
    case safari(URL)
    case block
    case unblock
  }
}

// MARK: - API for VC

extension UserProfileViewModel {
  var fetchRecentPost: Observable<Void> {
    return MastodonRepository.statuses(userID: user.id, excludeReplies: true)
      .map({ (statuses) -> [MastodonStatusEntity] in
        guard let first = statuses.first else {
          return []
        }
        return [first]
      })
      .do(onNext: { [weak self] (statuses) in
        self?.statuses.refresh(statuses)
      })
      .map { _ in () }
  }

  var fetchRelationship: Observable<Void> {
    return MastodonRepository.relashinship(userID: user.id)
      .do(onNext: { [weak self] (relationship) in
        self?.relationship.value = relationship
      })
      .map { _ in () }
  }

  var block: Observable<Void> {
    return MastodonRepository.block(userID: user.id)
      .do(onNext: { [weak self] (relationship) in
        self?.relationship.value = relationship
      })
      .map { _ in () }
  }

  var unblock: Observable<Void> {
    return MastodonRepository.unblock(userID: user.id)
      .do(onNext: { [weak self] (relationship) in
        self?.relationship.value = relationship
      })
      .map { _ in () }
  }
}

// MARK: - RxDataSources

extension UserProfileViewModel {
  enum Section: SectionModelType {
    case userProfile([Row])
    case recentPosts([Row])
    case operations([Row])

    typealias Item = Row

    var items: [UserProfileViewModel.Row] {
      switch self {
      case .recentPosts(let rows):
        return rows
      case .userProfile(let rows):
        return rows
      case .operations(let rows):
        return rows
      }
    }

    init(original: Section, items: [Row]) {
      switch original {
      case .recentPosts:
        self = .recentPosts(items)
      case .userProfile:
        self = .userProfile(items)
      case .operations:
        self = .operations(items)
      }
    }

    static func user(_ user: MastodonAccountEntity) -> Section {
      let rows: [Row] = [
        .header(user),
        .statusCount(user.statusesCount),
        .following(user.followingCount),
        .follower(user.followersCount),
      ]
      return Section.userProfile(rows)
    }

    static func userOperations() -> Section {
      return Section.operations([
        .sectionHeader(title: "操作"),
        .block
        ])
    }
  }

  enum Row {
    case sectionHeader(title: String)

    case header(MastodonAccountEntity)
    case following(Int)
    case follower(Int)
    case statusCount(Int)
    case status(MastodonStatusEntity)

    case block
  }
}
