//
//  StatusContainer.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

struct StatusContainer<T: Identified> {
  private var contents: [T] = []

  mutating func append(newContents _newContents: [T]) {
    var newContents = _newContents
    guard let lastID = contents.last?.id else {
      contents = newContents
      return
    }

    guard let startIndex = contents.index(where: { $0.id == lastID }) else {
      contents += newContents
      return
    }

    newContents.removeSubrange(Range<Int>.init(uncheckedBounds: (lower: 0, upper: startIndex)))
    contents += newContents
  }

  mutating func prepend(newContents: [T]) {
    guard let firstID = contents.first?.id else {
      contents = newContents
      return
    }


  }
}

public protocol Identified: Equatable {
  var id: Int { get }
}

public func ==<T: Identified>(lhs: T, rhs: T) -> Bool {
  return lhs.id == rhs.id
}
