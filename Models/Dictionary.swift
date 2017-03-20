//
//  Dictionary.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

public extension Dictionary {
  func get<T: JSONPrimitive>(valueForKey key: Key) throws -> T {
    guard let value = self[key] as? T else {
      throw DictionaryExtractionError.castFailed(key: String.init(describing: key), actualValue: self[key])
    }
    return value
  }

  func get<T>(valueForKey key: Key) throws -> Optional<T> {
    return self[key] as? T
  }

  func get<T: JSONMappable>(valueForKey key: Key) throws -> T {
    let dict: [String: Any] = try get(valueForKey: key)
    return try T.init(json: dict)
  }

  func get(valueForKey key: Key) throws -> [String: Any] {
    guard let dict = self[key] as? [String: Any] else {
      throw JSONMappingError.mappingFailed(message: "Failed to extract dictionary.")
    }
    return dict
  }

  func getTwitterDate(valueForKey key: Key) throws -> Date {
    let dateStr: String = try get(valueForKey: key)
    guard let date = Date.init(twitterDateString: dateStr) else {
      throw JSONMappingError.mappingFailed(message: "Failed to parse date string. actual value: (\(dateStr))")
    }
    return date
  }

  func get(valueForKey key: Key) throws -> URL {
    let urlStr: String = try get(valueForKey: key)
    guard let url = URL.init(string: urlStr) else {
      throw JSONMappingError.mappingFailed(message: "Failed to parse url. actual value: (\(urlStr))")
    }
    return url
  }
}

enum DictionaryExtractionError: Error {
  case castFailed(key: String, actualValue: Any?)
}

public protocol JSONPrimitive {}

extension String: JSONPrimitive {}
extension Int: JSONPrimitive {}
extension Double: JSONPrimitive {}
