//
//  MastodonStatusEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

struct MastodonStatusEntity {
  var id: Int
  var uri: String
  var url: String
  var account: MastodonAccountEntity
  var inReplyToID: Int?
  var inReplyToAccountID: Int?
//  var reblog: MastodonStatusEntity? 
  var content: String
  var createdAt: Date
  var reblogsCount: Int
  var favouritesCount: Int
  var reblogged: Bool
  var favourited: Bool
  var sensitive: Bool
  var spoilerText: String?
  var visibility: Visibility
  var mediaAttachments: [MastodonAttachmentEntity]
  var mentions: [MastodonMentionEntity]
  var tags: [MastodonTagEntity]
  var application: MastodonApplicationEntity
}

enum Visibility {
  case `public`
  case unlisted
  case `private`
  case direct
}
