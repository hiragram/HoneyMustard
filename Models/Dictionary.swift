//
//  Dictionary.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public extension Dictionary {
  func get<T>(valueForKey key: Key) throws -> T {
    guard let value = self[key] as? T else {
      throw DictionaryExtractionError.castFailed(key: String.init(describing: key), actualValue: self[key])
    }
    return value
  }
}

enum DictionaryExtractionError: Error {
  case castFailed(key: String, actualValue: Any?)
}
