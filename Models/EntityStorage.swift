//
//  EntityStorage.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/30.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

public class EntityStorage<T: Equatable> {
  fileprivate let _items = Variable<[T]>.init([])

  public init() {
    
  }
}

// MARK: - API

public extension EntityStorage {
  public var items: Observable<[T]> {
    return _items.asObservable()
  }

  public func append(_ entity: T) {
    var items = _items.value
    items.append(entity)
    _items.value = items
  }

  public func prepend(_ entity: T) {
    var items = _items.value
    items.insert(entity, at: 0)
    _items.value = items
  }

  public func update(_ entity: T) {
    var items = _items.value
    guard let index = items.index(where: { (contained) -> Bool in
      contained == entity
    }) else {
      return
    }
    items[index] = entity
    _items.value = items
  }

  public func refresh(_ entities: [T]) {
    _items.value = entities
  }

  var first: T? {
    return _items.value.first
  }

  var last: T? {
    return _items.value.last
  }
}
