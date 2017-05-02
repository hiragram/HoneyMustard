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
  @IBOutlet fileprivate weak var dateLabel: DesignedLabel! {
    didSet {
      dateLabel.typography = Style.current.dateTimeText
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
  @IBOutlet fileprivate weak var replyButton: UIButton!
  @IBOutlet fileprivate weak var reblogButton: UIButton!
  @IBOutlet fileprivate weak var favoriteButton: UIButton!

  @IBOutlet fileprivate weak var previewImage1: UIImageView!
  @IBOutlet fileprivate weak var previewImage2: UIImageView!
  @IBOutlet fileprivate weak var previewImage3: UIImageView!
  @IBOutlet fileprivate weak var previewImage4: UIImageView!
//  @IBOutlet fileprivate weak var colorRibbonView: UIView! {
//    didSet {
//      _colorRibbon.asObservable().subscribe(onNext: { [weak self] (ribbon) in
//        self?.colorRibbonView.backgroundColor = ribbon?.color ?? UIColor.clear
//      }).addDisposableTo(bag)
//    }
//  }
  @IBOutlet private weak var controlContainer: UIView!
  @IBOutlet private weak var controlContainerHeight: NSLayoutConstraint!
  @IBOutlet fileprivate weak var mediaContainerHeight: NSLayoutConstraint!
  private let _colorRibbon = Variable<Ribbon?>.init(nil)
  fileprivate let _linkTapped = PublishSubject<URL>.init()

  @IBOutlet fileprivate weak var mediaContainer: UIView! {
    didSet {
      mediaContainer.layer.cornerRadius = 10
      mediaContainer.layer.masksToBounds = true
      mediaContainer.layer.borderWidth = 0.5
      mediaContainer.layer.borderColor = UIColor.lightGray.cgColor
    }
  }
  @IBOutlet fileprivate weak var preview1Height: NSLayoutConstraint!
  @IBOutlet fileprivate weak var preview1Width: NSLayoutConstraint!
  // MARK: - Appearance properties

//  var colorRibbon: Ribbon? {
//    set {
//      _colorRibbon.value = newValue
//    }
//
//    get {
//      return _colorRibbon.value
//    }
//  }

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
    let constant: CGFloat = selected ? 30 : 0
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { [weak self] in
      self?.controlContainerHeight.constant = constant
      self?.layoutIfNeeded()
    }) { [weak self] (_) in
//      self?.controlContainer.isHidden = !selected
    }
    super.setSelected(selected, animated: animated)
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

  func set(reblogged: Bool) {
    reblogButton.backgroundColor = reblogged ? .red : .clear
  }

  func set(favorited: Bool) {
    favoriteButton.backgroundColor = favorited ? .red : .clear
  }

  func set(attachments: AttachedImage) {
    let mediaContainerSize = mediaContainer.bounds.size
    switch attachments {
    case .none:
      mediaContainerHeight.constant = 0
      previewImage1.image = nil
      previewImage2.image = nil
      previewImage3.image = nil
      previewImage4.image = nil
    case .one(let url):
      mediaContainerHeight.constant = 200
      preview1Height.constant = 200
      preview1Width.constant = mediaContainerSize.width
      previewImage1.setImage(url: url)
      previewImage2.image = nil
      previewImage3.image = nil
      previewImage4.image = nil
    case .two(let url1, let url2):
      mediaContainerHeight.constant = 200
      preview1Height.constant = 200
      preview1Width.constant = mediaContainerSize.width / 2
      previewImage1.setImage(url: url1)
      previewImage2.setImage(url: url2)
      previewImage3.image = nil
      previewImage4.image = nil
    case .three(let url1, let url2, let url3):
      mediaContainerHeight.constant = 300
      preview1Height.constant = 150
      preview1Width.constant = mediaContainerSize.width / 2
      previewImage1.setImage(url: url1)
      previewImage2.setImage(url: url2)
      previewImage3.setImage(url: url3)
      previewImage4.image = nil
    case .four(let url1, let url2, let url3, let url4):
      mediaContainerHeight.constant = 300
      preview1Height.constant = 150
      preview1Width.constant = mediaContainerSize.width / 2
      previewImage1.setImage(url: url1)
      previewImage2.setImage(url: url2)
      previewImage3.setImage(url: url3)
      previewImage4.setImage(url: url4)
    }
    setNeedsLayout()
  }
}

// MARK: - Reactive

extension Reactive where Base: TweetCell {
  var tapReply: ControlEvent<Void> {
    return base.replyButton.rx.tap
  }

  var tapReblog: ControlEvent<Void> {
    return base.reblogButton.rx.tap
  }

  var tapFavorite: ControlEvent<Void> {
    return base.favoriteButton.rx.tap
  }

  var date: AnyObserver<DateTimeExpression> {
    return AnyObserver.init(eventHandler: { (event) in
      switch event {
      case .next(let datetime):
        self.base.dateLabel.text = datetime.description
      default:
        break
      }
    })
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

enum DateTimeExpression: CustomStringConvertible {
  case seconds(Int)
  case minutes(Int)
  case hours(Int)
  case absolute(timestamp: TimeInterval)

  var description: String {
    switch self {
    case .seconds(let seconds):
      return "\(seconds)秒前" // TODO ローカライズ
    case .minutes(let minutes):
      return "\(minutes)分前" // TODO ローカライズ
    case .hours(let hours):
      return "\(hours)時間前" // TODO ローカライズ
    case .absolute(timestamp: let timestamp):
      return "\(Date.init(timeIntervalSince1970: timestamp))"
    }
  }
}

enum AttachedImage {
  case one(URL)
  case two(URL, URL)
  case three(URL, URL, URL)
  case four(URL, URL, URL, URL)
  case none
}
