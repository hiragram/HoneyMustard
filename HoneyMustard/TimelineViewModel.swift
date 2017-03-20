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

class TimelineViewModel {

  private let bag = DisposeBag.init()

  private let _streamingIsConnected = BehaviorSubject.init(value: false)
  var streamingIsConnected: ControlProperty<Bool>! = nil

  private let tweets = Variable<[TweetEntity]>.init([])

  private var userstreamDisposable: Disposable?

  init() {
    streamingIsConnected = ControlProperty<Bool>.init(values: _streamingIsConnected.asObservable(), valueSink: _streamingIsConnected.asObserver())

    _streamingIsConnected.subscribe(onNext: { [unowned self] (value) in
      if value == true {
        guard self.userstreamDisposable == nil else {
          return
        }
        self.userstreamDisposable = try! TweetRepository.userstream().subscribe({ (event) in
          switch event {
          case .next(let event):
            print(event)
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
  }
}

enum TimelineEvent {
  case newStatus(TweetEntity)
  case deleteStatus
}
