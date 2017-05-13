//
//  SimpleTextCell.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/07.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SimpleTextCell: UITableViewCell {
  @IBOutlet fileprivate weak var titleLabel: DesignedLabel! {
    didSet {
      titleLabel.typography = Style.current.cellContentText
    }
  }
  @IBOutlet fileprivate weak var contentLabel: DesignedLabel! {
    didSet {
      contentLabel.typography = Style.current.cellContentText
    }
  }
}

// MARK: - API

extension SimpleTextCell {
  var title: String? {
    set {
      titleLabel.text = newValue
    }
    get {
      return titleLabel.text
    }
  }

  var content: String? {
    set {
      contentLabel.text = newValue
    }
    get {
      return contentLabel.text
    }
  }
}
