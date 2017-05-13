//
//  ObservablePaging.swift
//  HoneyMustard
//
//  Created by hiragram on 2017/04/25.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

public enum ObservablePaging<T> {
  case single(Observable<T>)
  case multiple((Int) -> Observable<T>)

  func observable(`for` page: Int) -> Observable<T> {
    switch self {
    case .single(let observable):
      return observable
    case .multiple(let get):
      return get(page)
    }
  }
}
