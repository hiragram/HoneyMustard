//
//  TimelineViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import Models

class TimelineViewModel {
  private let tweets = Variable<[TweetEntity]>.init([])
}

enum TimelineEvent {
  case newStatus(TweetEntity)
  case deleteStatus
}
