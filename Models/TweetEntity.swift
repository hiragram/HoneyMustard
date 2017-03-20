//
//  TweetEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct TweetEntity {
  public let id: Int
  public let createdAt: Date
  public let text: String

  public init(json: [String: Any]) throws {
    id = try json.get(valueForKey: "id")
    let createdAtStr: String = try json.get(valueForKey: "created_at")
    guard let date = Date.init(twitterDateString: createdAtStr) else {
      throw JSONMappingError.mappingFailed(message: "Failed to parse date string \(createdAtStr))")
    }
    createdAt = date
    text = try json.get(valueForKey: "text")
  }
}
