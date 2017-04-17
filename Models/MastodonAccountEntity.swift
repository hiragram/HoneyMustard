//
//  MastodonAccountEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

struct MastodonAccountEntity {
  var id: Int
  var username: String
  var acct: String
  var displayName: String
  var locked: Bool
  var createdAt: Date
  var followersCount: Int
  var followingCount: Int
  var statusesCount: Int
  var note: String
  var url: URL
  var avatar: URL
  var avatarStatic: URL
  var header: URL
  var headerStatic: URL
}
