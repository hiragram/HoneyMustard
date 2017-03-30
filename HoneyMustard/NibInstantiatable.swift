//
//  NibInstantiatable.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/31.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit

protocol NibInstantiatable {

}

extension NibInstantiatable where Self: UIView {
  static func instantiate(withOwner owner: Any?, options: [AnyHashable: Any]?) -> Self {
    let className = String.init(describing: Self.self)
    return UINib.init(nibName: className, bundle: nil).instantiate(withOwner: owner, options: options).first as! Self
  }
}
