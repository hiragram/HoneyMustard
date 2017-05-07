//
//  MastodonRelationshipEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/07.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonRelationshipEntity: JSONMappable, Identified {
  public var id: Int
  public var following: Bool
  public var followedBy: Bool
  public var blocking: Bool
  public var muting: Bool
  public var requested: Bool

  public init(json: [String : Any]) throws {
    id = try json.get(valueForKey: "id")
    following = try json.get(valueForKey: "following")
    followedBy = try json.get(valueForKey: "followed_by")
    blocking = try json.get(valueForKey: "blocking")
    muting = try json.get(valueForKey: "muting")
    requested = try json.get(valueForKey: "requested")
  }
}
