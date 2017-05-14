//
//  UserCell.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/13.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift

final class UserCell: UITableViewCell {
  @IBOutlet fileprivate weak var nameLabel: DesignedLabel! {
    didSet {
      nameLabel.typography = Style.current.usernameText
    }
  }
  @IBOutlet fileprivate weak var screenNameLabel: DesignedLabel! {
    didSet {
      screenNameLabel.typography = Style.current.screennameText
    }
  }
  @IBOutlet weak var followingLabel: DesignedLabel! {
    didSet {
      followingLabel.typography = Style.current.accessoryText
    }
  }
  @IBOutlet fileprivate weak var followingCountLabel: DesignedLabel! {
    didSet {
      followingCountLabel.typography = Style.current.accessoryText
    }
  }
  @IBOutlet weak var followerLabel: DesignedLabel! {
    didSet {
      followerLabel.typography = Style.current.accessoryText
    }
  }
  @IBOutlet fileprivate weak var followerCountLabel: DesignedLabel! {
    didSet {
      followerCountLabel.typography = Style.current.accessoryText
    }
  }
  @IBOutlet fileprivate weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.layer.cornerRadius = 5
      iconImageView.layer.borderColor = UIColor.darkGray.cgColor
      iconImageView.layer.borderWidth = 0.5
      iconImageView.layer.masksToBounds = true
    }
  }

  var followingCount: Int = 0 {
    didSet {
      followingCountLabel.text = "\(followingCount)"
    }
  }

  var followerCount: Int = 0 {
    didSet {
      followerCountLabel.text = "\(followerCount)"
    }
  }
}

extension UserCell: UserRepresentable {
  var displayName: String {
    set {
      nameLabel.text = newValue
    }
    get {
      return nameLabel.text ?? ""
    }
  }

  var screenName: String {
    set {
      screenNameLabel.text = newValue
    }
    get {
      return screenNameLabel.text ?? ""
    }
  }

  func set(imageURL url: URL) {
    iconImageView.setImage(url: url)
  }
}
