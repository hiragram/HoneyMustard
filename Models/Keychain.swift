//
//  Keychain.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import KeychainAccess
import RxSwift

public struct Keychain {

  private static let _credential = PublishSubject<(accessToken: String, accessTokenSecret: String)>.init()
  static var credential: Observable<(accessToken: String, accessTokenSecret: String)> {
    return _credential.asObservable()
  }

  private static let keychain = KeychainAccess.Keychain.init(service: "me.yura.HoneyMustard")

  public static func initialize() throws {
    let userDefaults = UserDefaults.standard
    let key = "keychainInitialized"
    if userDefaults.value(forKey: key) == nil {
      try keychain.removeAll()
      userDefaults.set(true, forKey: key)
      userDefaults.synchronize()
    }
  }

  static func accessToken() -> String? {
    return get(key: "accessToken")
  }

  static func accessTokenSecret() -> String? {
    return get(key: "accessTokenSecret")
  }

  public static func set(accessToken: String, accessTokenSecret: String) {
    set(value: accessToken, forKey: "accessToken")
    set(value: accessTokenSecret, forKey: "accessTokenSecret")
    _credential.onNext((accessToken: accessToken, accessTokenSecret: accessTokenSecret))
  }

  private static func set(value: String, forKey key: String) {
    do {
      try keychain.set(value, key: key)
    } catch let error {
      print(error)
    }
  }

  private static func get(key: String) -> String? {
    do {
      return try keychain.get(key)
    } catch let error {
      print(error)
      return nil
    }
  }
}
