//
//  SectionHeaderCell.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/07.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SectionHeaderCell: UITableViewCell {
  @IBOutlet fileprivate weak var titleLabel: DesignedLabel! {
    didSet {
      titleLabel.typography = Style.current.sectionHeaderText
    }
  }
}

// MARK: - API

extension SectionHeaderCell {
  var title: String? {
    set {
      titleLabel.text = newValue
    }
    get {
      return titleLabel.text
    }
  }
}
