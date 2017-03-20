//
//  DesignedLabel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit

class DesignedLabel: UILabel {
  override var text: String? {
    get {
      return super.text
    }

    set {
      let text = newValue ?? ""
      let paragraphStyle = NSMutableParagraphStyle.init()
      paragraphStyle.alignment = self.textAlignment
      paragraphStyle.lineBreakMode = .byTruncatingTail

      let attributedText = NSMutableAttributedString.init(string: text)
      attributedText.addAttribute(NSParagraphStyleAttributeName,
                                  value: paragraphStyle,
                                  range: NSRange.init(location: 0, length: text.characters.count))
      self.attributedText = attributedText
    }
  }

  var typography: Typography? {
    didSet {
      font = typography?.font
      textColor = typography?.color
    }
  }
}

private extension UIColor {
  static var undesigned: UIColor {
    get {
      print("[WARN] Undesigned color is used.")
      return UIColor.red
    }
  }
}
