//
//  MastodonAccountEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonAccountEntity: JSONMappable {
  public var id: Int
  public var username: String
  public var acct: String
  public var displayName: String
  public var locked: Bool
  public var createdAt: Date
  public var followersCount: Int
  public var followingCount: Int
  public var statusesCount: Int
  public var note: String
  public var url: URL
  public var avatar: URL
  public var avatarStatic: URL
  public var header: URL
  public var headerStatic: URL

  public init(json: [String : Any]) throws {
    id = try json.get(valueForKey: "id")
    username = try json.get(valueForKey: "username")
    acct = try json.get(valueForKey: "acct")
    displayName = try json.get(valueForKey: "display_name")
    locked = try json.get(valueForKey: "locked")
    createdAt = try json.getMastodonDate(valueForKey: "created_at")
    followersCount = try json.get(valueForKey: "followers_count")
    followingCount = try json.get(valueForKey: "following_count")
    statusesCount = try json.get(valueForKey: "statuses_count")
    note = try json.get(valueForKey: "note")
    url = try json.get(valueForKey: "url")
    avatar = try json.get(valueForKey: "avatar")
    avatarStatic = try json.get(valueForKey: "avatar_static")
    header = try json.get(valueForKey: "header")
    headerStatic = try json.get(valueForKey: "header_static")
  }
}
