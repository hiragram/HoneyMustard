//
//  TweetRepository.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import Somen

public struct TweetRepository {
  static let consumerKey = "C518wxiwwHsfUWORezGgnM1MH"
  static let consumerSecret = "fnuzGVK61pjPm3TgeWeTS4BpgiNkOlffFntYPxV7aJFJaipyY2"

  fileprivate static let somen: Variable<Somen?> = { _ -> Variable<Somen?> in
    guard let accessToken = Keychain.accessToken() else {
      return Variable.init(nil)
    }

    guard let accessTokenSecret = Keychain.accessTokenSecret() else {
      return Variable.init(nil)
    }

    let somen = Somen.init(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      accessToken: accessToken,
      accessTokenSecret: accessTokenSecret
    )

    return Variable.init(somen)
  }()
}

public extension TweetRepository {
  public static var isAuthorized: Observable<Bool> {
    return somen.asObservable().map { $0 != nil }
  }
}
