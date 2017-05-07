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

  var statuses = EntityStorage<MastodonStatusEntity>.init()

  private let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()

  var items: Observable<[Section]> {
    let user = Observable.just(self.user)
      .map { (user) -> [Section] in
        [Section.user(user)]
    }
    let statuses = self.statuses.items.map { (statuses) -> [Row] in
      [Row.sectionHeader(title: "最近の投稿")] + statuses.map { Row.status($0) }
    }.map { (rows) -> [Section] in
      [Section.recentPosts(rows)]
    }

    return Observable.combineLatest(user, statuses) { (userSection, statusesSection) -> [Section] in
      return userSection + statusesSection
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
        cell.screenName = user.username
        user.attributedNote.subscribe(onNext: { (note) in
          cell.note = note
        }).addDisposableTo(cell.bag)
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
  }
}

// MARK: - API for VC

extension UserProfileViewModel {
  var fetchRecentPost: Observable<Void> {
    return MastodonRepository.statuses(userID: user.id, excludeReplies: true)
      .do(onNext: { [weak self] (statuses) in
        self?.statuses.refresh(statuses)
      })
      .map { _ in () }
  }
}

// MARK: - RxDataSources

extension UserProfileViewModel {
  enum Section: SectionModelType {
    case userProfile([Row])
    case recentPosts([Row])

    typealias Item = Row

    var items: [UserProfileViewModel.Row] {
      switch self {
      case .recentPosts(let rows):
        return rows
      case .userProfile(let rows):
        return rows
      }
    }

    init(original: Section, items: [Row]) {
      switch original {
      case .recentPosts:
        self = .recentPosts(items)
      case .userProfile:
        self = .userProfile(items)
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
  }

  enum Row {
    case sectionHeader(title: String)

    case header(MastodonAccountEntity)
    case following(Int)
    case follower(Int)
    case statusCount(Int)
    case status(MastodonStatusEntity)
  }
}