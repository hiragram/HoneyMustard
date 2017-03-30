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

  let dataSource = RxTableViewSectionedAnimatedDataSource<Section>.init()

  private let _streamingIsConnected = BehaviorSubject.init(value: false)
  var streamingIsConnected: ControlProperty<Bool>! = nil

  private let tweets = Variable<[TweetEntity]>.init([])

  var items: Observable<[Section]> {
    return tweets.asObservable().map({ (tweets) -> [Section] in
      let rows = tweets.reversed().map { Row.tweet($0) }
      return [Section.tweets(rows)]
    })
  }

  private var userstreamDisposable: Disposable?

  private var friendIDs: [Int] = []

  init() {
    streamingIsConnected = ControlProperty<Bool>.init(values: _streamingIsConnected.asObservable(), valueSink: _streamingIsConnected.asObserver())

    _streamingIsConnected.subscribe(onNext: { [unowned self] (value) in
      if value == true {
        guard self.userstreamDisposable == nil else {
          return
        }
        self.userstreamDisposable = try! TweetRepository.userstream()
          .subscribe({ [unowned self] (event) in
            switch event {
            case .next(let event):
              switch event {
              case .newStatus(rawEvent: let raw):
                do {
                  let tweet = try TweetEntity.init(json: raw)
                  self.tweets.value.append(tweet)
                } catch let e {
                  print(e)
                }
              case .deleteStatus(rawEvent: let raw):
                let delete: [String: Any] = try! raw.get(valueForKey: "delete")
                let status: [String: Any] = try! delete.get(valueForKey: "status")
                let id: Int = try! status.get(valueForKey: "id")
                let tweets = self.tweets.value
                self.tweets.value = tweets.filter { $0.id != id }
              case .friends(rawEvent: let raw):
                self.friendIDs = try! raw.get(valueForKey: "friends") ?? []
              default:
                break
              }
            case .error(let error):
              print(error.localizedDescription)
            case .completed:
              print("completed")
            }
          })
      } else {
        self.userstreamDisposable?.dispose()
        self.userstreamDisposable = nil
      }
    }).addDisposableTo(bag)

    dataSource.configureCell = { [unowned self] (dataSource, tableView, indexPath, row) -> UITableViewCell in
      switch row {
      case .tweet(let tweet):
        let cell: TweetCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(tweet: tweet)
        cell.colorRibbon = self.friendIDs.contains(tweet.user.id) ? nil : .notFriend
        return cell
      }
    }
  }
}

// - MARK: RxDataSources

extension TimelineViewModel {
  enum Section: AnimatableSectionModelType {
    case tweets([Row])

    typealias Item = Row
    typealias Identity = Int

    var identity: Int {
      switch self {
      case .tweets:
        return 1
      }
    }

    var items: [Row] {
      switch self {
      case .tweets(let rows):
        return rows
      }
    }

    init(original: Section, items: [Item]) {
      switch original {
      case .tweets:
        self = .tweets(items)
      }
    }
  }

  enum Row: IdentifiableType, Equatable {
    case tweet(TweetEntity)

    typealias Identity = Int

    var identity: Int {
      switch self {
      case .tweet(let tweet):
        return tweet.id
      }
    }

    static func ==(lhs: TimelineViewModel.Row, rhs: TimelineViewModel.Row) -> Bool {
      return lhs.identity == rhs.identity
    }
  }
}
