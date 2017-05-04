//
//  String.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/04.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

extension String {
  var urlEncoded: String {
    return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
  }
}
