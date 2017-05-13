//
//  MastodonTagEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public struct MastodonTagEntity: JSONMappable {
  public var name: String
  public var url: URL

  public init(json: [String : Any]) throws {
    name = try json.get(valueForKey: "name")
    url = try json.get(valueForKey: "url")
  }
}
