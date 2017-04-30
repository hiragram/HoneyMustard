//
//  UIImageView.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView {
  func setImage(url: URL) {
    sd_setImage(with: url, placeholderImage: nil, options: []) { [weak self] (image, error, cacheType, url) in
      if let error = error {
        print(error)
        return
      }
      self?.alpha = 0
      switch cacheType {
      case .none:
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: { [weak self] _ in
          self?.alpha = 1
        })
      case .disk, .memory:
        self?.alpha = 1
      }
    }
  }
}
