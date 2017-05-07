//
//  NotificationCell.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/03.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationCell: UITableViewCell {
  var bag = DisposeBag.init()

  @IBOutlet fileprivate weak var titleLabel: DesignedLabel! {
    didSet {
      titleLabel.text = " "
      titleLabel.typography = Style.current.accessoryText
    }
  }
  @IBOutlet fileprivate weak var usernameLabel: DesignedLabel! {
    didSet {
      usernameLabel.typography = Style.current.usernameText
    }
  }
  @IBOutlet fileprivate weak var screennameLabel: DesignedLabel! {
    didSet {
      screennameLabel.typography = Style.current.screennameText
    }
  }
  @IBOutlet fileprivate weak var contentTextLabel: DesignedLabel! {
    didSet {
      contentTextLabel.typography = Style.current.generalText
    }
  }
  @IBOutlet fileprivate weak var userIconImageView: UIImageView! {
    didSet {
      userIconImageView.layer.cornerRadius = 5
      userIconImageView.layer.borderColor = UIColor.darkGray.cgColor
      userIconImageView.layer.borderWidth = 0.5
      userIconImageView.layer.masksToBounds = true
    }
  }

  override func prepareForReuse() {
    bag = DisposeBag.init()
    super.prepareForReuse()
  }
}

// MARK: - API

extension NotificationCell {
  var username: String? {
    get {
      return usernameLabel.text
    }
    set {
      guard newValue != "" else {
        usernameLabel.text = " "
        return
      }
      usernameLabel.text = newValue
    }
  }

  var screenname: String? {
    get {
      return screennameLabel.text
    }
    set {
      screennameLabel.text = newValue
    }
  }

  var attributedBody: NSAttributedString? {
    get {
      return contentTextLabel.attributedText
    }
    set {
      guard newValue?.string != "" else {
        contentTextLabel.text = " "
        return
      }
      contentTextLabel.attributedText = newValue
    }
  }

  var title: String? {
    get {
      return titleLabel.text
    }
    set {
      titleLabel.text = newValue
    }
  }

  func set(imageURL: URL?) {
    guard let url = imageURL else {
      userIconImageView.image = nil
      return
    }
    userIconImageView.setImage(url: url)
  }
}
