//
//  MastodonRepository.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import OAuthSwift
import UIKit
import RxSwift

public struct MastodonRepository {
  fileprivate static let host = "https://pawoo.net"
  private static let clientID = "ec05ea3e8fc85efe30e60441443c65081cb30cf1970d1e8b2732ce03835cb2d3"
  private static let clientSecret = "53eb3320a80da0dd31a8a500b72802f755405cf7a679519e62a0fb6b5021e77b"

  private static func url(forPath path: String) -> String {
    return host + path
  }

  private static func apiURL(forPath path: String, params: [String: String] = [:]) -> String {
    return url(forPath: "/api/v1/") + path + "?" + params.map { "\($0.key)=\($0.value.urlEncoded)" }.joined(separator: "&")
  }

  private static let oauthSwift = { _ -> OAuth2Swift in
    let oauthSwift = OAuth2Swift.init(consumerKey: clientID, consumerSecret: clientSecret, authorizeUrl: url(forPath: "/oauth/authorize"), accessTokenUrl: url(forPath: "/oauth/token"), responseType: "code")
    if let accessToken = Keychain.accessToken(), let accessTokenSecret = Keychain.accessTokenSecret() {
      oauthSwift.client.credential.oauthToken = accessToken
      oauthSwift.client.credential.oauthTokenSecret = accessTokenSecret
    }

    return oauthSwift
  }()


  public static func oauth(parentVC: UIViewController) {
    let handler = SafariURLHandler.init(viewController: parentVC, oauthSwift: oauthSwift)
    oauthSwift.authorizeURLHandler = handler
    oauthSwift.authorize(withCallbackURL: "honeymustard://oauth-callback/mastodon", scope: "read write follow", state: "a", success: { (credential, response, parameters) in
      Keychain.set(accessToken: credential.oauthToken, accessTokenSecret: credential.oauthTokenSecret)
    }) { (error) in
      print(error)
    }
  }

  public static func postStatus(text: String, inReplyTo inReplyToStatusID: Int? = nil, mediaIDs: [Int] = []) -> Observable<MastodonStatusEntity> {
    return Observable.create({ (observer) -> Disposable in
      var params: [String: Any] = [:]
      params["status"] = text
      if let id = inReplyToStatusID {
        params["in_reply_to_id"] = "\(id)"
      }
      params["media_ids"] = mediaIDs
      oauthSwift.client.post(apiURL(forPath: "/statuses"), parameters: params, headers: ["Content-Type": "application/json"], success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let status = try MastodonStatusEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func upload(image: UIImage) -> Observable<MastodonAttachmentEntity> {
    guard let imageData = UIImageJPEGRepresentation(image, 1) else {
      return Observable.error(NSError.init()) // TODO
    }
    return Observable.create({ (observer) -> Disposable in
      var params: [String: String] = [:]
      let imageMultipart = OAuthSwiftMultipartData.init(name: "file", data: imageData, fileName: "hoge.jpg", mimeType: "image/jpeg")
      oauthSwift.client.postMultiPartRequest(apiURL(forPath: "/media"), method: .POST, parameters: [:], headers: nil, multiparts: [imageMultipart], checkTokenExpiration: false, success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let media = try MastodonAttachmentEntity.init(json: json)
          observer.onNext(media)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func follower(userID: Int, minID: Int? = nil) -> Observable<[MastodonAccountEntity]> {
    return Observable.create({ (observer) -> Disposable in
      var params: [String: String] = [:]
      params["since_id"] = minID == nil ? nil : "\(minID!)"
      oauthSwift.client.get(apiURL(forPath: "/accounts/\(userID)/followers", params: params), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let users = try json.map { try MastodonAccountEntity.init(json: $0) }
          observer.onNext(users)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func following(userID: Int, minID: Int? = nil) -> Observable<[MastodonAccountEntity]> {
    return Observable.create({ (observer) -> Disposable in
      var params: [String: String] = [:]
      params["since_id"] = minID == nil ? nil : "\(minID!)"
      oauthSwift.client.get(apiURL(forPath: "/accounts/\(userID)/following", params: params), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let users = try json.map { try MastodonAccountEntity.init(json: $0) }
          observer.onNext(users)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func home(maxID: Int? = nil, minID: Int? = nil) -> Observable<[MastodonStatusEntity]> {
    return Observable.create({ (observer) -> Disposable in
      var params: [String: String] = [:]
      params["since_id"] = minID == nil ? nil : "\(minID!)"
      params["max_id"] = maxID == nil ? nil : "\(maxID!)"
      oauthSwift.client.get(apiURL(forPath: "/timelines/home", params: params), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let statuses = try json.map { try MastodonStatusEntity.init(json: $0) }
          observer.onNext(statuses)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func publicTimeline(maxID: Int? = nil, minID: Int? = nil, params _params: [String: String] = [:]) -> Observable<[MastodonStatusEntity]> {
    return Observable.create({ (observer) -> Disposable in
      var params = _params
      params["since_id"] = minID == nil ? nil : "\(minID!)"
      params["max_id"] = maxID == nil ? nil : "\(maxID!)"
      oauthSwift.client.get(apiURL(forPath: "/timelines/public", params: params), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let statuses = try json.map { try MastodonStatusEntity.init(json: $0) }
          observer.onNext(statuses)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func statuses(userID: Int, excludeReplies: Bool = false, maxID: Int? = nil, minID: Int? = nil, params _params: [String: String] = [:]) -> Observable<[MastodonStatusEntity]> {
    return Observable.create({ (observer) -> Disposable in
      var params = _params
      params["since_id"] = minID == nil ? nil : "\(minID!)"
      params["max_id"] = maxID == nil ? nil : "\(maxID!)"
      params["exclude_replies"] = "\(excludeReplies)"
      oauthSwift.client.get(apiURL(forPath: "/accounts/\(userID)/statuses", params: params), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let statuses = try json.map { try MastodonStatusEntity.init(json: $0) }
          observer.onNext(statuses)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func relashinship(userID: Int) -> Observable<MastodonRelationshipEntity> {
    return Observable.create({ (observer) -> Disposable in
      var params: [String: String] = [:]
      params["id"] = "\(userID)"

      oauthSwift.client.get(apiURL(forPath: "/accounts/relationships", params: params), success: { (response) in
        do {
          guard let _json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          guard let json = _json.first else {
            observer.onError(NSError.init()) // todo
            return
          }
          let relationship = try MastodonRelationshipEntity.init(json: json)
          observer.onNext(relationship)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func localTimeline(maxID: Int? = nil, minID: Int? = nil) -> Observable<[MastodonStatusEntity]> {
    return publicTimeline(maxID: maxID, minID: minID, params: ["local": "true"])
  }

  public static func verifyCredentials() -> Observable<MastodonAccountEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.get(apiURL(forPath: "/accounts/verify_credentials"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonAccountEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func follow(userID: Int) -> Observable<MastodonRelationshipEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.post(apiURL(forPath: "/accounts/\(userID)/follow"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonRelationshipEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func unfollow(userID: Int) -> Observable<MastodonRelationshipEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.post(apiURL(forPath: "/accounts/\(userID)/unfollow"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonRelationshipEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func reblog(statusID: Int) -> Observable<MastodonStatusEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.post(apiURL(forPath: "/statuses/\(statusID)/reblog"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonStatusEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func unreblog(statusID: Int) -> Observable<MastodonStatusEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.post(apiURL(forPath: "/statuses/\(statusID)/unreblog"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonStatusEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func favorite(statusID: Int) -> Observable<MastodonStatusEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.post(apiURL(forPath: "/statuses/\(statusID)/favourite"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonStatusEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func unfavorite(statusID: Int) -> Observable<MastodonStatusEntity> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.post(apiURL(forPath: "/statuses/\(statusID)/unfavourite"), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            observer.onError(NSError.init()) // TODO
            return
          }
          let status = try MastodonStatusEntity.init(json: json)
          observer.onNext(status)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static func notifications(maxID: Int? = nil, minID: Int? = nil) -> Observable<[MastodonNotificationEntity]> {
    return Observable.create({ (observer) -> Disposable in
      var params: [String: String] = [:]
      params["since_id"] = minID == nil ? nil : "\(minID!)"
      params["max_id"] = maxID == nil ? nil : "\(maxID!)"
      oauthSwift.client.get(apiURL(forPath: "/notifications", params: params), success: { (response) in
        do {
          guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
            observer.onError(NSError.init()) // todo
            return
          }
          let notifications = try json.map { try MastodonNotificationEntity.init(json: $0) }
          observer.onNext(notifications)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      }, failure: { (error) in
        observer.onError(error)
      })
      return Disposables.create()
    })
  }

  public static var isAuthorized: Observable<Bool> {
    let current: Observable<Bool>
    if let _ = Keychain.accessToken(), let _ = Keychain.accessTokenSecret() {
      current = Observable.just(true)
    } else {
      current = Observable.just(false)
    }

    return Observable.of(current, Keychain.credential.map { _,_ in true }.delay(0.5, scheduler: MainScheduler.instance)).merge()

//    return Observable.combineLatest(current, Keychain.credential.map { _,_ in true }, resultSelector: { current, delayed in
//      if current == true {
//        return true
//      }
//      return delayed
//    })
  }

  /*
  {
    "id": 10809,
    "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
    "client_id":"3cff0ae6db595a7ad1479902c1f9c489252fd59d8396df773d7bc89c4057c627",
    "client_secret":"7ed056fa87d52087f95f211d88e54d9c43674c5643c2862062e6d6a1c866497e"
   }

   {"id":10880,"redirect_uri":"honeymustard://oauth-callback/mastodon","client_id":"ec05ea3e8fc85efe30e60441443c65081cb30cf1970d1e8b2732ce03835cb2d3","client_secret":"53eb3320a80da0dd31a8a500b72802f755405cf7a679519e62a0fb6b5021e77b"}
 */
}

// MARK: - Internal API

internal extension MastodonRepository {
  static func getURLFrom(_ path: URL) -> URL {
    return URL.init(string: host)!.appendingPathComponent(path.absoluteString)
  }
}
