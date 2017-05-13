//
//  TweetCellRepresentable.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/07.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Models

protocol TweetCellRepresentable: class {
  var statuses: EntityStorage<MastodonStatusEntity> { get }
}

extension TweetCellRepresentable {
  func setup(cell: TweetCell, status _status: MastodonStatusEntity) {
    let status = _status.reblog ?? _status
    status.attributedBody.asAttributedString()
      .subscribe({ (event) in
        switch event {
        case .next(let attributedString):
          cell.attributedBody = attributedString
        case .error(let error):
          print(error)
          print("Parse error: \(status.content)")
          cell.body = status.content
        case .completed:
          break
        }
      }).addDisposableTo(cell.bag)
    cell.screenname = status.account.acct
    cell.name = status.account.displayName
    cell.set(imageURL: status.account.avatar)
    cell.set(favorited: status.favourited)
    cell.set(reblogged: status.reblogged)

    cell.rx.tapReblog.flatMap({ (_) -> Observable<MastodonStatusEntity> in
      if status.reblogged {
        return MastodonRepository.unreblog(statusID: status.id)
      } else {
        return MastodonRepository.reblog(statusID: status.id)
      }
    }).subscribe(onNext: { [weak self] (status) in
      self?.statuses.update(status)
    }).addDisposableTo(cell.bag)

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

    if let reblogUserName = (_status.reblog != nil ? _status.account : nil)?.displayName {
      cell.title = "\(reblogUserName)がブースト"
    } else {
      cell.title = nil
    }

    Clock.current.map({ (timestamp) -> DateTimeExpression in
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
  }
}
