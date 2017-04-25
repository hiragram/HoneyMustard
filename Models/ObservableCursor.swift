//
//  ObservableCursor.swift
//  HoneyMustard
//
//  Created by hiragram on 2017/04/25.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

public struct ObservableCursor<T> {

  typealias ObservableGenerator = (Void) -> Observable<T>

  private var next: ObservableGenerator
  private var previous: ObservableGenerator

  init(nextPage: @escaping ObservableGenerator, previousPage: @escaping ObservableGenerator) {
    next = nextPage
    previous = previousPage
  }
}
