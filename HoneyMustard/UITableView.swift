//
//  UITableView.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit

extension UITableView {
  func registerNib(cellType: UITableViewCell.Type) {
    let className = String.init(describing: cellType)
    register(UINib.init(nibName: className, bundle: nil), forCellReuseIdentifier: className)
  }

  func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: String.init(describing: T.self), for: indexPath) as! T
  }
}
