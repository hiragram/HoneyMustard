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

  func get<T: JSONPrimitive>(valueForKey key: Key) throws -> T? {
    return self[key] as? T
  }

  func get<T: JSONPrimitive>(valueForKey key: Key) throws -> [T] {
    guard let array = self[key] as? [T] else {
      throw DictionaryExtractionError.castFailed(key: String.init(describing: key), actualValue: self[key])
    }
    return array
  }

  func get<T: JSONMappable>(valueForKey key: Key) throws -> T {
    let dict: [String: Any] = try get(valueForKey: key)
    return try T.init(json: dict)
  }

  func get<T: JSONMappable>(valueForKey key: Key) throws -> T? {
    return try? get(valueForKey: key)
  }

  func get<T: JSONMappable>(valueForKey key: Key) throws -> [T] {
    guard let array = self[key] as? [[String: Any]] else {
      throw DictionaryExtractionError.castFailed(key: String.init(describing: key), actualValue: self[key])
    }

    return try array.map({ (dict) -> T in
      return try T.init(json: dict)
    })
  }

  func get(valueForKey key: Key) throws -> [String: Any] {
    guard let dict = self[key] as? [String: Any] else {
      throw JSONMappingError.mappingFailed(message: "Failed to extract dictionary. key: \(key) value: \(self[key])")
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

  func getMastodonDate(valueForKey key: Key) throws -> Date {
    let dateStr: String = try get(valueForKey: key)
    guard let date = Date.init(mastodonDateString: dateStr) else {
      throw JSONMappingError.mappingFailed(message: "Failed to parse date string. actual value: (\(dateStr))")
    }
    return date
  }

  func get(valueForKey key: Key) throws -> URL {
    guard let url = try get(valueForKey: key) as URL? else {
      throw JSONMappingError.mappingFailed(message: "Failed to parse url. actual: \(self[key]) self: \(self) key: \(key)")
    }

    return url
  }

  func get(valueForKey key: Key) throws -> URL? {
    guard let urlStr: String = try? get(valueForKey: key) else {
      return nil
    }
    guard let url = URL.init(string: urlStr) else {
      return nil
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
extension Array: JSONPrimitive {}
extension Bool: JSONPrimitive {}
extension Dictionary: JSONPrimitive {}
