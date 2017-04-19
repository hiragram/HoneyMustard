//
//  Date.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation

extension Date {
  init?(twitterDateString dateString: String) {
    let formatter = DateFormatter.init()
    // Wed Aug 27 13:08:45 +0000 2008
    formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    formatter.locale = Locale.init(identifier: "en-US")
    if let timestamp = formatter.date(from: dateString)?.timeIntervalSince1970 {
      self.init(timeIntervalSince1970: timestamp)
    } else {
      return nil
    }
  }

  init?(mastodonDateString dateString: String) {
    let formatter = DateFormatter.init()
    //                      2017-04-16T06:37:45.215Z
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    formatter.locale = Locale.init(identifier: "en-US")
    if let timestamp = formatter.date(from: dateString)?.timeIntervalSince1970 {
      self.init(timeIntervalSince1970: timestamp)
    } else {
      return nil
    }
  }
}
