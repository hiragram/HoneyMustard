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
  let generalText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 15), color: UIColor.black)
  let clickableText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 15), color: UIColor.red)
  let usernameText: Typography = Typography.init(font: UIFont.boldSystemFont(ofSize: 15), color: UIColor.black)
  let screennameText: Typography = Typography.init(font: UIFont.systemFont(ofSize: 13), color: UIColor.cyan)
}
