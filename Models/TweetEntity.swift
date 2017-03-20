//
//  TweetEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct TweetEntity: JSONMappable {
  public let id: Int
  public let createdAt: Date
  public let text: String
  public let user: UserEntity

  public init(json: [String: Any]) throws {
    id = try json.get(valueForKey: "id")
    createdAt = try json.getTwitterDate(valueForKey: "created_at")
    text = try json.get(valueForKey: "text")
    user = try json.get(valueForKey: "user")
  }
}
