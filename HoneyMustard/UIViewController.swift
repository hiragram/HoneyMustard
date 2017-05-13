//
//  UIViewController.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/05/13.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

extension Observable {
  func showProgress() -> Observable<Element> {
    return self.do(onError: { error in
      SVProgressHUD.showError(withStatus: "\(error)")
    }, onCompleted: { _ in
      SVProgressHUD.dismiss()
    }, onSubscribe: { _ in
      SVProgressHUD.show()
    }, onDispose: { _ in
      SVProgressHUD.dismiss()
    })
  }
}
