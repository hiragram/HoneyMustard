//
//  MastodonAttachmentEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonAttachmentEntity: JSONMappable {
  public var id: Int
  public var type: Attachment?
  public var url: URL
  public var remoteURL: URL?
  public var previewURL: URL
  public var textURL: URL

  public init(json: [String : Any]) throws {
    id = try json.get(valueForKey: "id")
    type = Attachment.init(rawValue: try json.get(valueForKey: "type"))
    url = try json.get(valueForKey: "url")
    remoteURL = try json.get(valueForKey: "remote_url")
    previewURL = try json.get(valueForKey: "preview_url")
    textURL = try json.get(valueForKey: "text_url")
  }
}

public enum Attachment: String {
  case image
  case video
  case gifv
}
