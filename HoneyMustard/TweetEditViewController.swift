//
//  TweetEditViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Models

final class TweetEditViewController: UIViewController, StoryboardInstantiatable {
  @IBOutlet fileprivate weak var textField: UITextView! {
    didSet {
      textField.layer.cornerRadius = 3
      textField.layer.borderColor = UIColor.lightGray.cgColor
      textField.layer.borderWidth = 0.5
    }
  }
  @IBOutlet fileprivate weak var submitButton: UIButton! {
    didSet {
      submitButton.rx.tap.asObservable()
        .map { [unowned self] _ in self.textField.text ?? "" }
        .filter { !$0.isEmpty }
        .filter { $0.characters.count <= 140 }
        .flatMap { (text) -> Observable<TweetEntity> in
          TweetRepository.postUpdate(body: text)
        }
        .subscribe(onNext: { [unowned self] (_) in
          self.textField.text = ""
        }).addDisposableTo(bag)
    }
  }
  @IBOutlet private weak var photo1: UIImageView!
  @IBOutlet private weak var photo2: UIImageView!
  @IBOutlet private weak var photo3: UIImageView!
  @IBOutlet private weak var photo4: UIImageView!
  @IBOutlet private weak var attachmentContainerHeight: NSLayoutConstraint!

  @IBOutlet private weak var photo1Width: NSLayoutConstraint!
  @IBOutlet private weak var photo2Width: NSLayoutConstraint!
  @IBOutlet private weak var photo3Width: NSLayoutConstraint!
  @IBOutlet private weak var photo4Width: NSLayoutConstraint!

  private let bag = DisposeBag.init()
  private let vm = TweetEditViewModel.init()

  override func viewDidLoad() {
    super.viewDidLoad()

    submitButton.rx.tap.asObservable().subscribe(onNext: { (_) in
      print("たっぷ")
    }).addDisposableTo(bag)

    vm.images.asObservable().subscribe(onNext: { [weak self] (images) in
      let image1 = images.first
      let image2 = images.dropFirst(1).first
      let image3 = images.dropFirst(2).first
      let image4 = images.dropFirst(3).first

      guard image1 != nil else {
        self?.attachmentContainerHeight.constant = 0
        return
      }
      self?.attachmentContainerHeight.constant = 60

      if let image = image1 {
        self?.photo1.image = image
        self?.photo1Width.constant = 50
      } else {
        self?.photo1Width.constant = 0
      }

      if let image = image2 {
        self?.photo2.image = image
        self?.photo2Width.constant = 50
      } else {
        self?.photo2Width.constant = 0
      }

      if let image = image3 {
        self?.photo3.image = image
        self?.photo3Width.constant = 50
      } else {
        self?.photo3Width.constant = 0
      }

      if let image = image4 {
        self?.photo4.image = image
        self?.photo4Width.constant = 50
      } else {
        self?.photo4Width.constant = 0
      }
    }).addDisposableTo(bag)
  }
}

// - MARK: Observables

extension TweetEditViewController {
  var text: Observable<String> {
    return textField.rx.text.map { $0 ?? "" }
  }

  var submitButtonTap: Observable<String> {
    return submitButton.rx.tap.asObservable()
      .map { [unowned self] _ -> String in
        self.textField.text ?? ""
    }
  }
}
