//
//  TextRepresentation.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/07.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import Models
import Attributed
import RxSwift

extension TextRepresentation {
  public var attributedString: NSAttributedString {
    switch self {
    case .text(let text):
      return NSAttributedString.init(string: text)
    case .link(text: let children, url: let url):
      let text = children.map { $0.attributedString.string }.joined(separator: "")
      return text.at.attributed {
        $0
          .foreground(color: Style.current.clickableText.color)
          .link(url.absoluteString)
      }
    case .attachment(url: let url):
      return NSAttributedString.init(string: url.absoluteString) // TODO
    }
  }
}

extension Observable where Element == [TextRepresentation] {
  func asAttributedString() -> Observable<NSAttributedString> {
    return map({ (texts) -> NSAttributedString in
      return texts.map { $0.attributedString }.reduce(NSMutableAttributedString.init(string: ""), { (attributedString, current) -> NSMutableAttributedString in
        attributedString.append(current)
        return attributedString
      })
    })
  }
}
