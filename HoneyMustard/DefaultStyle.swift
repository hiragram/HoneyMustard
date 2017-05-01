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
  let generalText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 14), color: UIColor.black)
  let clickableText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 14), color: UIColor.black)
  let usernameText: Typography = Typography.init(font: UIFont.boldSystemFont(ofSize: 14), color: UIColor.black)
  let screennameText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 13), color: UIColor.darkGray)
  let dateTimeText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 12), color: UIColor.darkGray)
}
