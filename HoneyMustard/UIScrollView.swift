//
//  UIScrollView.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/11.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
  var scrolledToBottom: Observable<Void> {
    var previousValue: CGFloat = 0
    return contentOffset
      .map { $0.y }
      .map {
        $0 / (self.base.contentSize.height - self.base.bounds.height)
      }
      .throttle(0.2, scheduler: MainScheduler.asyncInstance)
      .filter {
        let result = previousValue <= 1 && $0 >= 1
        previousValue = $0

        return result
      }
      .map { _ in () }
      .retry() 
  }
}
