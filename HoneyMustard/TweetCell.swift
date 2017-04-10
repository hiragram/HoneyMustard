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

final class TweetCell: UITableViewCell {
  private var bag = DisposeBag.init()

  @IBOutlet fileprivate weak var nameLabel: DesignedLabel! {
    didSet {
      nameLabel.typography = Style.current.usernameText
    }
  }
  @IBOutlet fileprivate weak var screennameLabel: DesignedLabel! {
    didSet {
      screennameLabel.typography = Style.current.screennameText
    }
  }
  @IBOutlet fileprivate weak var bodyLabel: DesignedLabel! {
    didSet {
      bodyLabel.typography = Style.current.generalText
    }
  }
  @IBOutlet fileprivate weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.layer.cornerRadius = 5
      iconImageView.layer.masksToBounds = true
      iconImageView.layer.borderColor = UIColor.lightGray.cgColor
      iconImageView.layer.borderWidth = 0.5
    }
  }
  @IBOutlet fileprivate weak var colorRibbonView: UIView! {
    didSet {
      _colorRibbon.asObservable().subscribe(onNext: { [weak self] (ribbon) in
        self?.colorRibbonView.backgroundColor = ribbon?.color ?? UIColor.clear
      }).addDisposableTo(bag)
    }
  }
  private let _colorRibbon = Variable<Ribbon?>.init(nil)

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

// MARK - api

extension TweetCell {
  var name: String? {
    get {
      return nameLabel.text
    }
    set {
      nameLabel.text = newValue
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

  var body: String? {
    get {
      return bodyLabel.text
    }
    set {
      bodyLabel.text = newValue
    }
  }

  func set(imageURL: URL) {
    iconImageView.setImage(url: imageURL)
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
