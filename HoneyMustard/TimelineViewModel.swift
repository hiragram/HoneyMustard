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
  private let _openURL = PublishSubject<URLOpenStyle>.init()
  var openURL: Observable<URLOpenStyle> {
    return _openURL.asObservable()
  }

  enum URLOpenStyle {
    case modally(URL)
    case push(URL)
  }

  let dataSource = RxTableViewSectionedReloadDataSource<Section>.init()
//  let dataSource = TableViewDataSource<Section>.init()

  fileprivate let statuses = EntityStorage<MastodonStatusEntity>.init()

  private var clock: Observable<TimeInterval> = Observable<Observable<Int>>.of(Observable<Int>.interval(1.0, scheduler: MainScheduler.instance), Observable<Int>.just(1)).merge()
    .map { (_) -> TimeInterval in
      Date.init().timeIntervalSince1970
    }.shareReplay(1)

  var items: Observable<[Section]> {
    return statuses.items.map({ (statuses) -> [Section] in
      let rows = statuses.map { Row.status($0) }
      return [Section.statuses(rows)]
    })
  }

  private var selectedIndexPath: IndexPath?

  private var userstreamDisposable: Disposable?

  private var friendIDs: [Int] = []

  init() {
    dataSource.configureCell = { [unowned self] (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch row {
      case .status(let _status):
        let status = _status.reblog ?? _status
        let cell: TweetCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        MastodonStatusParser.parse(xml: status.content.data(using: .utf8)!).subscribe(onNext: { (texts) in
          let attributedString = texts.map { $0.attributedString }.reduce(NSMutableAttributedString.init(string: ""), { (attributedString, current) -> NSMutableAttributedString in
            attributedString.append(current)
            return attributedString
          })
          cell.attributedBody = attributedString
        }).addDisposableTo(self.bag)
        cell.screenname = status.account.acct
        cell.name = status.account.displayName
        cell.set(imageURL: status.account.avatar)
        cell.set(favorited: status.favourited)
        cell.set(reblogged: status.reblogged)

        cell.tapLink.subscribe(onNext: { [weak self] (url) in
          self?._openURL.onNext(.modally(url))
        }).addDisposableTo(cell.bag)

        cell.rx.tapReblog.flatMap({ (_) -> Observable<MastodonStatusEntity> in
          if status.reblogged {
            return MastodonRepository.unreblog(statusID: status.id)
              .do(onNext: { [weak self] (status) in
                self?.statuses.update(status)
              })

          } else {
            return MastodonRepository.reblog(statusID: status.id)
              .do(onNext: { [weak self] (status) in
                self?.statuses.prepend(status)
              })
          }
        }).subscribe().addDisposableTo(cell.bag)

        cell.rx.tapFavorite.flatMap({ (_) -> Observable<MastodonStatusEntity> in
          if status.favourited {
            return MastodonRepository.unfavorite(statusID: status.id)
          } else {
            return MastodonRepository.favorite(statusID: status.id)
          }
        }).subscribe(onNext: { [weak self] (status) in
          self?.statuses.update(status)
        }).addDisposableTo(cell.bag)

        let urls = status.mediaAttachments.map { $0.previewURL }
        let attachments: AttachedImage
        switch urls.count {
        case 1:
          attachments = .one(urls.first!)
        case 2:
          attachments = .two(urls.first!, urls.dropFirst().first!)
        case 3:
          attachments = .three(urls.first!, urls.dropFirst(1).first!, urls.dropFirst(2).first!)
        case 4:
          attachments = .four(urls.first!, urls.dropFirst(1).first!, urls.dropFirst(2).first!, urls.dropFirst(3).first!)
        default:
          attachments = .none
        }
        cell.set(attachments: attachments)

        self.clock.map({ (timestamp) -> DateTimeExpression in
          let createdTimestamp = status.createdAt.timeIntervalSince1970
          let diff = timestamp - createdTimestamp
          switch diff {
          case 0..<60:
            return .seconds(Int.init(diff))
          case 60..<3_600:
            return .minutes(Int.init(diff / 60))
          case 3_600..<86_400:
            return .hours(Int.init(diff / 60 / 24))
          default:
            return .absolute(timestamp: createdTimestamp)
          }
        }).bindTo(cell.rx.date).addDisposableTo(cell.bag)

        return cell
      }
    }
  }

  func setup(tableView: UITableView) {
    tableView.registerNib(cellType: TweetCell.self)
    items.bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)
    tableView.estimatedRowHeight = 100 // FIXME
    tableView.rx.scrolledToBottom.flatMap { [weak self] (_) -> Observable<Void> in
      return self?.fetchOlder ?? Observable.empty()
      }.subscribe().addDisposableTo(bag)

    tableView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
      tableView.beginUpdates()
      tableView.endUpdates()
      self?.selectedIndexPath = indexPath
    }).addDisposableTo(bag)

    tableView.rx.itemDeselected.asObservable().subscribe(onNext: { (_) in
      tableView.beginUpdates()
      tableView.endUpdates()
    }).addDisposableTo(bag)
  }
}

// - MARK: Fetch from REST API

extension TimelineViewModel {
  var refresh: Observable<Void> {
    return MastodonRepository.timeline()
      .do(onNext: { [weak self] (statuses) in
        self?.statuses.refresh(statuses)
      })
      .map { _ in () }
  }

  var fetchNewer: Observable<Void> {
    return MastodonRepository.timeline(minID: statuses.first?.id)
      .map { _ in () }
  }

  var fetchOlder: Observable<Void> {
    return MastodonRepository.timeline(maxID: statuses.last?.id)
      .do(onNext: { [weak self] (statuses) in
        let lastID = self?.statuses.last?.id
        let appendingStatuses = statuses.split(whereSeparator: { (status) -> Bool in
          status.id == lastID
        }).last.map { Array($0) } ?? []
        appendingStatuses.forEach {
          self?.statuses.append($0)
        }
      })
      .map { _ in () }
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
