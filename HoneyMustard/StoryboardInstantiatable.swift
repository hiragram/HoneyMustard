//
//  StoryboardInstantiatable.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit

protocol StoryboardInstantiatable {
  static var storyboardName: String { get }

  static func instantiateFromStoryboard() -> Self
}

extension StoryboardInstantiatable where Self: UIViewController {
  static var storyboardName: String {
    return String.init(describing: Self.self)
  }

  static func instantiateFromStoryboard() -> Self {
    let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
    return storyboard.instantiateInitialViewController() as! Self
  }
}
