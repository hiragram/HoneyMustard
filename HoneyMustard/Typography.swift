//
//  Typography.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit

struct Typography {
  let font: UIFont
  let color: UIColor
  private let colorForDarkBackground: UIColor?

  init(font: UIFont, color: UIColor, colorForDarkBackground: UIColor? = nil) {
    self.font = font
    self.color = color
    self.colorForDarkBackground = colorForDarkBackground
  }

  var darkBackground: Typography {
    return Typography.init(font: font, color: colorForDarkBackground ?? color)
  }
}
