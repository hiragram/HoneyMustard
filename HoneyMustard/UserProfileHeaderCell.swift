//
//  UserProfileHeaderCell.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/05.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserProfileHeaderCell: UITableViewCell {
  @IBOutlet fileprivate weak var headerImage: UIImageView!
  @IBOutlet fileprivate weak var userIconImage: UIImageView! {
    didSet {
      userIconImage.layer.cornerRadius = 5
      userIconImage.layer.borderColor = UIColor.darkGray.cgColor
      userIconImage.layer.borderWidth = 0.5
      userIconImage.layer.masksToBounds = true
    }
  }
  @IBOutlet fileprivate weak var displayNameLabel: DesignedLabel! {
    didSet {
      displayNameLabel.typography = Style.current.usernameText.darkBackground
    }
  }
  @IBOutlet fileprivate weak var screenNameLabel: DesignedLabel! {
    didSet {
      screenNameLabel.typography = Style.current.screennameText.darkBackground
    }
  }
  @IBOutlet fileprivate weak var followButton: UIButton! {
    didSet {
      followButton.layer.cornerRadius = 5
      followButton.layer.borderWidth = 0.5
      followButton.layer.borderColor = UIColor.white.cgColor
    }
  }
  @IBOutlet fileprivate weak var followStatusLabel: DesignedLabel! {
    didSet {
      followStatusLabel.typography = Style.current.accessoryText.darkBackground
    }
  }
  @IBOutlet fileprivate weak var descriptionLabel: DesignedLabel! {
    didSet {
      descriptionLabel.typography = Style.current.generalText.darkBackground
    }
  }

  var bag = DisposeBag.init()

  override func prepareForReuse() {
    bag = DisposeBag.init()
    super.prepareForReuse()
  }

}

// MARK: - API

extension UserProfileHeaderCell {
  func set(headerImageURL url: URL) {
    headerImage.setImage(url: url)
  }

  var displayName: String? {
    set {
      displayNameLabel.text = newValue
    }
    get {
      return displayNameLabel.text
    }
  }

  var screenName: String? {
    set {
      screenNameLabel.text = newValue
    }
    get {
      return screenNameLabel.text
    }
  }

  func set(followsMe: Bool) {
    fatalError()
  }

  func set(following: Bool) {
    fatalError()
  }

  var note: NSAttributedString? {
    set {
      descriptionLabel.attributedText = newValue
    }
    get {
      return descriptionLabel.attributedText
    }
  }

  func set(userIconURL url: URL) {
    userIconImage.setImage(url: url)
  }
}
