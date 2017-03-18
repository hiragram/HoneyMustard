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

final class TweetEditViewController: UIViewController, StoryboardInstantiatable {
  @IBOutlet fileprivate weak var textField: UITextView!
  @IBOutlet fileprivate weak var submitButton: UIButton!
  
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
