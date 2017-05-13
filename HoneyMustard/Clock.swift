//
//  Clock.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/07.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

struct Clock {
  static var current: Observable<TimeInterval> = Observable<Observable<Int>>.of(Observable<Int>.interval(1.0, scheduler: MainScheduler.instance), Observable<Int>.just(1)).merge()
    .map { (_) -> TimeInterval in
      Date.init().timeIntervalSince1970
    }.shareReplay(1)
}
