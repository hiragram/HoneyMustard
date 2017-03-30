//
//  TimelineStatusView.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/31.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TimelineStatusView: UIView, NibInstantiatable {
  private let bag = DisposeBag.init()

  @IBOutlet private weak var statusLabel: DesignedLabel! {
    didSet {
      statusLabel.typography = Style.current.generalText
      status.asObservable().map { $0.description }.bindTo(statusLabel.rx.text).addDisposableTo(bag)
    }
  }
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
    didSet {
      status.asObservable().map { $0 == .streamingIsEstablished }.bindTo(activityIndicator.rx.isAnimating).addDisposableTo(bag)
    }
  }

  let status = Variable<Status>.init(.notConnected)
}

enum Status: CustomStringConvertible {
  case streamingIsEstablished
  case notConnected

  var description: String {
    switch self {
    case .streamingIsEstablished:
      return "ストリーミング中"
    case .notConnected:
      return "接続されていません"
    }
  }
}
