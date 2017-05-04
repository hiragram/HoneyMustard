//
//  StyleDefinition.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

protocol StyleDefinition {
  // text color
  var generalText: Typography { get }
  var clickableText: Typography { get }
  var usernameText: Typography { get }
  var screennameText: Typography { get }
  var dateTimeText: Typography { get }
  var accessoryText: Typography { get }
}
