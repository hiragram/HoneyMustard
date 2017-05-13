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
import Models

class TweetEditViewModel {
  private let bag = DisposeBag.init()

  let images = Variable<[UIImage]>.init([])
  let text = Variable.init("")

  typealias InReplyTo = (statusID: Int, iconURL: URL, displayName: String, screenName: String, body: NSAttributedString)

  let inReplyTo: InReplyTo?

  // MARK: - delegates
  let imagePickerDelegate = ImagePickerDelegate.init()

  fileprivate let submittedSubject = PublishSubject<Void>.init()

  init(inReplyTo: InReplyTo? = nil) {
    self.inReplyTo = inReplyTo
    if let screenName = inReplyTo?.screenName {
      text.value = "@\(screenName) "
    }
    imagePickerDelegate.selectedImage.subscribe(onNext: { [weak self] (image) in
      self?.images.value.append(image)
    }).addDisposableTo(bag)
  }
}

// MARK: - API for VC

extension TweetEditViewModel {
  var submit: Observable<Void> {
    let imageUpload = images.asObservable().map { images -> [Observable<UIImage>] in
      print(images.count)
      return images.map({ (image) -> Observable<UIImage> in
        Observable.just(image)
      })
      }.flatMap { (observables) -> Observable<[MastodonAttachmentEntity]> in
        guard !observables.isEmpty else {
          return Observable.just([])
        }
        let o = observables.map({ (observable) -> Observable<MastodonAttachmentEntity> in
          return observable.flatMap({ (image) -> Observable<MastodonAttachmentEntity> in
            MastodonRepository.upload(image: image)
          })
        })
        return Observable.zip(o)
    }

//    return images.asObservable().map { $0.first }.flatMap { (image) -> Observable<UIImage> in
//      if let image = image {
//        return Observable.just(image)
//      } else {
//        return Observable.empty()
//      }
//      }.flatMap { (image) -> Observable<MastodonAttachmentEntity> in
//        MastodonRepository.upload(image: image)
//      }.map { _ in () }
    return imageUpload.flatMap { [unowned self] (attachments) -> Observable<Void> in
      print(attachments)
      return self.text.asObservable().flatMap({ [unowned self] (text) -> Observable<MastodonStatusEntity> in
        MastodonRepository.postStatus(text: text, inReplyTo: self.inReplyTo?.statusID, mediaIDs: attachments.map { $0.id })
      })
        .do(onNext: { [weak self] _ in
          self?.submittedSubject.onNext(())
        })
        .map { _ in () }
    }
  }
}

// MARK: - API for other VC

extension TweetEditViewModel {
  var submitted: Observable<Void> {
    return submittedSubject.asObservable().take(1)
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
