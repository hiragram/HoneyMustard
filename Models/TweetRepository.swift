//
//  TweetRepository.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/03/18.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import Somen
import OAuthSwift

public struct TweetRepository {
  static let consumerKey = "C518wxiwwHsfUWORezGgnM1MH"
  static let consumerSecret = "fnuzGVK61pjPm3TgeWeTS4BpgiNkOlffFntYPxV7aJFJaipyY2"

  fileprivate static let oauthswift = OAuth1Swift.init(consumerKey: consumerKey, consumerSecret: consumerSecret, requestTokenUrl: "https://api.twitter.com/oauth/request_token", authorizeUrl: "https://api.twitter.com/oauth/authorize", accessTokenUrl: "https://api.twitter.com/oauth/access_token")

  static let bag = DisposeBag.init()

  fileprivate static let somen: Variable<Somen?> = { _ -> Variable<Somen?> in

    let variable: Variable<Somen?>

    if let accessToken = Keychain.accessToken(), let accessTokenSecret = Keychain.accessTokenSecret() {
      let somen = Somen.init(
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        accessToken: accessToken,
        accessTokenSecret: accessTokenSecret
      )
      variable = Variable.init(somen)
    } else {
      variable = Variable.init(nil)
    }

    Keychain.credential.map { credential -> Somen in
      return Somen.init(
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        accessToken: credential.accessToken,
        accessTokenSecret: credential.accessTokenSecret
      )
    }.bindTo(variable).addDisposableTo(bag)

    return variable
  }()
}

// - MARK: API Observables

public extension TweetRepository {
  public static func userstream() throws -> Observable<SomenEvent> {
    guard let somen = somen.value else {
      throw TweetRepositoryError.authorizationIsNotProvided
    }

    return somen.userstream()
  }
}

// - MARK: Other API

public extension TweetRepository {
  public static func oauth() {
    oauthswift.authorize(withCallbackURL: "honeymustard://oauth-callback/twitter", success: { (credential, response, parameters) in
      Keychain.set(accessToken: credential.oauthToken, accessTokenSecret: credential.oauthTokenSecret)
    }, failure: { (error) in
      print(error.localizedDescription)
    })
  }
}

// - MARK: States

public extension TweetRepository {
  public static var isAuthorized: Observable<Bool> {
    return somen.asObservable().map { $0 != nil }
  }
}

enum TweetRepositoryError: Error {
  case authorizationIsNotProvided
}
