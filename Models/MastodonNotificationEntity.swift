//
//  MastodonNotificationEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/02.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonNotificationEntity: JSONMappable, Identified {
  public var id: Int
  public var type: NotificationType?
  public var createdAt: Date
  public var account: MastodonAccountEntity
  public var status: MastodonStatusEntity?

  public init(json: [String : Any]) throws {
    id = try json.get(valueForKey: "id")
    createdAt = try json.getMastodonDate(valueForKey: "created_at")
    account = try MastodonAccountEntity.init(json: try json.get(valueForKey: "account"))
    let _statusDict: [String: Any]? = try? json.get(valueForKey: "status")
    if let statusDict = _statusDict {
      status = try MastodonStatusEntity.init(json: statusDict)
    }

    let typeString: String = try json.get(valueForKey: "type")
    type = NotificationType.init(rawValue: typeString)
  }
}

public enum NotificationType: String {
  case mention
  case reblog
  case favorite = "favourite"
  case follow
}
