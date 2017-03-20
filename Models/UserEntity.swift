//
//  UserEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct UserEntity: JSONMappable {
  public let id: Int
  public let name: String
  public let screenname: String
  public let iconImageURL: URL
  public let bannerImageURL: URL
  public let createdAt: Date
  public let description: String
  public let following: Bool?
  public let followersCount: Int
  public let friendsCount: Int
  public let protected: Bool?

  public init(json: [String: Any]) throws {
    createdAt = try json.getTwitterDate(valueForKey: "created_at")
    description = try json.get(valueForKey: "description")
    following = try json.get(valueForKey: "following")
    followersCount = try json.get(valueForKey: "followers_count")
    friendsCount = try json.get(valueForKey: "friends_count")
    id = try json.get(valueForKey: "id")
    name = try json.get(valueForKey: "name")
    iconImageURL = try json.get(valueForKey: "profile_image_url_https")
    bannerImageURL = try json.get(valueForKey: "profile_banner_url")
    protected = try json.get(valueForKey: "protected")
    screenname = try json.get(valueForKey: "screen_name")
  }
}
