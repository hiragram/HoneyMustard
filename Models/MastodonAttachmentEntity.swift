//
//  MastodonAttachmentEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

struct MastodonAttachmentEntity {
  var id: Int
  var type: Attachment
  var url: URL
  var remoteurl: URL
  var previewURL: URL
  var textURL: URL
}

enum Attachment {
  case image
  case video
  case gifv
}
