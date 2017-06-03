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
      set(followButtonStyle: .fetching)
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

  fileprivate let _linkTapped = PublishSubject<URL?>.init()

  override func prepareForReuse() {
    bag = DisposeBag.init()
    super.prepareForReuse()
    setLinkTapRecognizer()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setLinkTapRecognizer()
  }

  private func setLinkTapRecognizer() {
    let bodyTapGesture = UITapGestureRecognizer.init()

    let layoutManager = NSLayoutManager.init()
    let textContainer = NSTextContainer.init(size: .zero)
    layoutManager.addTextContainer(textContainer)
    descriptionLabel.addGestureRecognizer(bodyTapGesture)
    bodyTapGesture.rx.event.map { (gesture) -> URL? in
      guard let bodyLabel = gesture.view as? DesignedLabel else {
        return nil
      }
      guard let attributedText = bodyLabel.attributedText else {
        return nil
      }
      let textStorage = NSTextStorage.init(attributedString: attributedText)
      textStorage.addLayoutManager(layoutManager)
      textContainer.lineFragmentPadding = 0.0
      textContainer.lineBreakMode = bodyLabel.lineBreakMode
      textContainer.maximumNumberOfLines = bodyLabel.numberOfLines
      textContainer.size = bodyLabel.bounds.size

      let position = gesture.location(in: bodyLabel)
      let labelSize = bodyLabel.bounds.size
      let textBoundingBox = layoutManager.usedRect(for: textContainer)
      let textContainerOffset = CGPoint.init(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
      let locationOfTouchInTextContainer = CGPoint.init(x: position.x - textContainerOffset.x, y: position.y - textContainerOffset.y)
      let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
      let attributesOfTappedCharacter = attributedText.attributes(at: indexOfCharacter, effectiveRange: nil)
      if let urlStr = attributesOfTappedCharacter[NSLinkAttributeName] as? String, let url = URL.init(string: urlStr) {
        return url
      }
      return nil
      }.flatMap { [weak self] optionalURL -> Observable<URL?> in
        if let url = optionalURL {
          return Observable.just(url)
        } else {
          return Observable.just(nil)
        }
      }.bindTo(_linkTapped).addDisposableTo(bag)
  }

}

// MARK: - API

extension UserProfileHeaderCell {
  var tapLink: Observable<URL?> {
    return _linkTapped.asObservable()
  }

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

  var relationshipDescription: String? {
    set {
      followStatusLabel.text = newValue
    }
    get {
      return followStatusLabel.text
    }
  }

  func set(followButtonStyle style: FollowButtonStyle) {
    let tintColor: UIColor
    let text: String
    let backgroundColor: UIColor
    let borderColor: CGColor
    switch style {
    case .fetching:
      tintColor = UIColor.lightGray
      text = "フォロー状態を取得中"
      backgroundColor = UIColor.clear
      borderColor = UIColor.lightGray.cgColor
    case .follow:
      tintColor = UIColor.white
      text = "フォローする"
      backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
      borderColor = backgroundColor.cgColor
    case .unfollow:
      tintColor = UIColor.white
      text = "フォローを解除する"
      backgroundColor = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
      borderColor = backgroundColor.cgColor
    case .blocking:
      tintColor = UIColor.white
      text = "ブロックを解除する"
      backgroundColor = .darkGray
      borderColor = backgroundColor.cgColor
    }
    followButton.tintColor = tintColor
    followButton.backgroundColor = backgroundColor
    followButton.setTitle(text, for: .normal)
    followButton.layer.borderColor = borderColor
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

// MARK: - Reactive API

extension Reactive where Base: UserProfileHeaderCell {
  var tapFollowButton: ControlEvent<Void> {
    return base.followButton.rx.tap
  }
}

extension UserProfileHeaderCell {
  enum FollowButtonStyle {
    case follow
    case unfollow
    case blocking
    case fetching
  }
}
