//
//  TweetCell.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Models

final class TweetCell: UITableViewCell {
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var screennameLabel: UILabel!
  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.layer.cornerRadius = 5
      iconImageView.layer.masksToBounds = true
    }
  }

  func setup(tweet: TweetEntity) {
    nameLabel.text = tweet.user.name
    screennameLabel.text = tweet.user.screenname
    bodyLabel.text = tweet.text
    iconImageView.setImage(url: tweet.user.iconImageURL)
  }
}
