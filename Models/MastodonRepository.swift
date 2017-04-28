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
  private static let host = "https://pawoo.net"
  private static let clientID = "ec05ea3e8fc85efe30e60441443c65081cb30cf1970d1e8b2732ce03835cb2d3"
  private static let clientSecret = "53eb3320a80da0dd31a8a500b72802f755405cf7a679519e62a0fb6b5021e77b"

  private static func url(forPath path: String) -> String {
    return host + path
  }

  private static func apiURL(forPath path: String, params: [String: String] = [:]) -> String {
    return url(forPath: "/api/v1/") + path + "?" + params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
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
    oauthSwift.authorizeURLHandler = SafariURLHandler.init(viewController: parentVC, oauthSwift: oauthSwift)
    oauthSwift.authorize(withCallbackURL: "honeymustard://oauth-callback/mastodon", scope: "read write follow", state: "a", success: { (credential, response, parameters) in
      Keychain.set(accessToken: credential.oauthToken, accessTokenSecret: credential.oauthTokenSecret)
    }) { (error) in
      print(error)
    }
  }

  public static func post(text: String) {
    oauthSwift.client.post(apiURL(forPath: "statuses"), parameters: ["status": text], success: { (response) in
      print(response)
    }) { (error) in
      print(error)
    }
  }

  public static func timeline() -> Observable<[MastodonStatusEntity]> {
    return Observable.create({ (observer) -> Disposable in
      oauthSwift.client.get(apiURL(forPath: "/timelines/home"), success: { (response) in
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

  public static func home() -> ObservableCursor<[MastodonStatusEntity]> {

    var firstID: Int? = nil
    var lastID: Int? = nil

    let observableGenerator = { (params: [String: String]) -> Observable<[MastodonStatusEntity]> in
      return Observable.create({ (observer) -> Disposable in
        _ = oauthSwift.client.get(apiURL(forPath: "/timelines/home", params: params), success: { (response) in
          do {
            guard let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] else {
              observer.onError(NSError.init()) // todo
              return
            }
            let statuses = try json.map { try MastodonStatusEntity.init(json: $0) }
            firstID = statuses.first?.id
            lastID = statuses.last?.id
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

    return ObservableCursor<[MastodonStatusEntity]>.init(nextPage: { (_) -> Observable<[MastodonStatusEntity]> in
      guard let lastID = lastID else {
        return observableGenerator([:])
      }
      return observableGenerator(["since_id": "\(lastID)"])
    }, previousPage: { (_) -> Observable<[MastodonStatusEntity]> in
      guard let firstID = firstID else {
        return observableGenerator([:])
      }
      return observableGenerator(["max_id": "\(firstID)"])
    })
  }

  public static var isAuthorized: Observable<Bool> {
    guard let _ = Keychain.accessToken(), let _ = Keychain.accessTokenSecret() else {
      return Observable.just(false)
    }
    return Observable.just(true)
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
