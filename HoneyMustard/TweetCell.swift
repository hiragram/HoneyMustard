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
  var bag = DisposeBag.init()

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
      bodyLabel.isUserInteractionEnabled = true
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
  @IBOutlet private weak var controlContainerHeight: NSLayoutConstraint!

  private let _colorRibbon = Variable<Ribbon?>.init(nil)
  fileprivate let _linkTapped = PublishSubject<URL>.init()

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
    setLinkTapRecognizer()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setLinkTapRecognizer()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    let constant: CGFloat = selected ? 50 : 0
    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { [weak self] in
      self?.controlContainerHeight.constant = constant
      self?.layoutIfNeeded()
    }) { (_) in

    }
  }

  private func setLinkTapRecognizer() {
    let bodyTapGesture = UITapGestureRecognizer.init()
    let layoutManager = NSLayoutManager.init()
    let textContainer = NSTextContainer.init(size: .zero)
    layoutManager.addTextContainer(textContainer)
    bodyLabel.addGestureRecognizer(bodyTapGesture)
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
      }.flatMap { optionalURL -> Observable<URL> in
        if let url = optionalURL {
          return Observable.just(url)
        } else {
          return Observable<URL>.empty()
        }
    }.bindTo(_linkTapped).addDisposableTo(bag)
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

  var attributedBody: NSAttributedString? {
    get {
      return bodyLabel.attributedText
    }

    set {
      bodyLabel.attributedText = newValue
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

  var tapLink: Observable<URL> {
    return _linkTapped.asObservable()
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
