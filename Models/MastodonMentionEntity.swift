//
//  MastodonMentionEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonMentionEntity: JSONMappable {
  public var url: URL
  public var username: String
  public var acct: String
  public var id: Int

  public init(json: [String : Any]) throws {
    url = try json.get(valueForKey: "url")
    username = try json.get(valueForKey: "username")
    acct = try json.get(valueForKey: "acct")
    id = try json.get(valueForKey: "id")
  }
}
