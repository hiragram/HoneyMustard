//
//  JSONMappable.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public protocol JSONMappable {
  init(json: [String: Any]) throws
}

enum JSONMappingError: Error {
  case mappingFailed(message: String)
}
