//
//  DefaultStyle.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit

struct DefaultStyle: StyleDefinition {
  // text color
  let generalText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 14), color: #colorLiteral(red: 0.132778734, green: 0.132778734, blue: 0.132778734, alpha: 1), colorForDarkBackground: UIColor.white)
  let clickableText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 14), color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
  let usernameText: Typography = Typography.init(font: UIFont.boldSystemFont(ofSize: 14), color: UIColor.black, colorForDarkBackground: UIColor.white)
  let screennameText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 13), color: UIColor.darkGray, colorForDarkBackground: UIColor.lightGray)
  let dateTimeText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 12), color: UIColor.darkGray)
  let accessoryText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 13), color: UIColor.darkGray, colorForDarkBackground: UIColor.lightGray)
  let cellContentText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 13), color: #colorLiteral(red: 0.2694122791, green: 0.2694122791, blue: 0.2694122791, alpha: 1))
  let sectionHeaderText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 12), color: UIColor.darkGray)
}
