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
  private var bag = DisposeBag.init()

  @IBOutlet private weak var nameLabel: DesignedLabel! {
    didSet {
      nameLabel.typography = Style.current.usernameText
    }
  }
  @IBOutlet private weak var screennameLabel: DesignedLabel! {
    didSet {
      screennameLabel.typography = Style.current.screennameText
    }
  }
  @IBOutlet private weak var bodyLabel: DesignedLabel! {
    didSet {
      bodyLabel.typography = Style.current.generalText
    }
  }
  @IBOutlet private weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.layer.cornerRadius = 5
      iconImageView.layer.masksToBounds = true
      iconImageView.layer.borderColor = UIColor.lightGray.cgColor
      iconImageView.layer.borderWidth = 0.5
    }
  }
  @IBOutlet private weak var colorRibbonView: UIView! {
    didSet {
      _colorRibbon.asObservable().subscribe(onNext: { [weak self] (ribbon) in
        self?.colorRibbonView.backgroundColor = ribbon?.color ?? UIColor.clear
      }).addDisposableTo(bag)
    }
  }
  private let _colorRibbon = Variable<Ribbon?>.init(nil)

  func setup(tweet: TweetEntity) {
    nameLabel.text = tweet.user.name
    screennameLabel.text = tweet.user.screenname
    bodyLabel.text = tweet.text
    iconImageView.setImage(url: tweet.user.iconImageURL)
  }

  // MARK: - Appearance properties

  var colorRibbon: Ribbon? {
    set {
      _colorRibbon.value = newValue
    }

    get {
      return _colorRibbon.value
    }
  }

  // MARK: - Lifecycle

  override func prepareForReuse() {
    bag = DisposeBag.init()
    super.prepareForReuse()
  }
}

enum Ribbon {
  case notFriend

  var color: UIColor {
    switch self {
    case .notFriend:
      return #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
    }
  }
}
