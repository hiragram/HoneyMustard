//
//  MastodonStatusEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonStatusEntity: JSONMappable, Identified {
  public var id: Int
  public var uri: String
  public var url: String
  public var account: MastodonAccountEntity
  public var inReplyToID: Int?
  public var inReplyToAccountID: Int?
// public var reblog: MastodonStatusEntity?
  public var content: String
  public var createdAt: Date
  public var reblogsCount: Int
  public var favouritesCount: Int
  public var reblogged: Bool
  public var favourited: Bool
  public var sensitive: Bool?
  public var spoilerText: String?
  public var visibility: Visibility?
  public var mediaAttachments: [MastodonAttachmentEntity]
  public var mentions: [MastodonMentionEntity]
  public var tags: [MastodonTagEntity]
  public var application: MastodonApplicationEntity?

  public init(json: [String : Any]) throws {
    id = try json.get(valueForKey: "id")
    uri = try json.get(valueForKey: "uri")
    url = try json.get(valueForKey: "url")
    account = try MastodonAccountEntity.init(json: try json.get(valueForKey: "account"))
    inReplyToID = try json.get(valueForKey: "in_reply_to_id")
    inReplyToAccountID = try json.get(valueForKey: "in_reply_to_account_id")
    content = try json.get(valueForKey: "content")
    createdAt = try json.getMastodonDate(valueForKey: "created_at")
    reblogsCount = try json.get(valueForKey: "reblogs_count")
    favouritesCount = try json.get(valueForKey: "favourites_count")
    reblogged = try json.get(valueForKey: "reblogged") ?? false
    favourited = try json.get(valueForKey: "favourited") ?? false
    sensitive = try json.get(valueForKey: "sensitive")
    spoilerText = try json.get(valueForKey: "spoiler_text")
    visibility = Visibility.init(rawValue: try json.get(valueForKey: "visibility"))
    mediaAttachments = try (json["media_attachments"] as! [[String: Any]]).map {
      return try MastodonAttachmentEntity.init(json: $0)
    }
    mentions = try (json["mentions"] as! [[String: Any]]).map {
      return try MastodonMentionEntity.init(json: $0)
    }
    tags = try (json["tags"] as! [[String: Any]]).map {
      return try MastodonTagEntity.init(json: $0)
    }
    application = try { _ -> MastodonApplicationEntity? in
      if let applicationDict: [String: Any] = try? json.get(valueForKey: "application") {
        return try MastodonApplicationEntity.init(json: applicationDict)
      } else {
        return nil
      }
    }()
  }
}

public enum Visibility: String {
  case `public`
  case unlisted
  case `private`
  case direct
}

private struct StatusBox {
  var entity: MastodonStatusEntity
}
