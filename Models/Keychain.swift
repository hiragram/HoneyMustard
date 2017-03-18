//
//  Keychain.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import KeychainAccess

struct Keychain {
  private static let keychain = KeychainAccess.Keychain.init(service: "me.yura.HoneyMustard")

  static func accessToken() -> String? {
    return get(key: "accessToken")
  }

  static func accessTokenSecret() -> String? {
    return get(key: "accessTokenSecret")
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
