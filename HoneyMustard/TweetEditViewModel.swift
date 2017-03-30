//
//  TweetEditViewModel.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/20.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TweetEditViewModel {
  private let bag = DisposeBag.init()

  let images = Variable<[UIImage]>.init([])

  // MARK: - delegates
  let imagePickerDelegate = ImagePickerDelegate.init()

  init() {
    imagePickerDelegate.selectedImage.subscribe(onNext: { [weak self] (image) in
      self?.images.value.append(image)
    }).addDisposableTo(bag)
  }
}

// MARK: - UIImagePickerControllerDelegate

extension TweetEditViewModel {
  class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let _selectedImage = PublishSubject<UIImage>.init()
    var selectedImage: Observable<UIImage> {
      return _selectedImage.asObservable()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      let image = info[UIImagePickerControllerOriginalImage] as! UIImage
      _selectedImage.onNext(image)
      picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
    }
  }
}
