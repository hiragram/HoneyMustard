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

public struct MastodonRepository {
  private static let host = "https://pawoo.net"
  private static let clientID = "ec05ea3e8fc85efe30e60441443c65081cb30cf1970d1e8b2732ce03835cb2d3"
  private static let clientSecret = "53eb3320a80da0dd31a8a500b72802f755405cf7a679519e62a0fb6b5021e77b"

  private static func url(forPath path: String) -> String {
    return host + path
  }

  private static let oauthSwift = OAuth2Swift.init(consumerKey: clientID, consumerSecret: clientSecret, authorizeUrl: url(forPath: "/oauth/authorize"), accessTokenUrl: url(forPath: "/oauth/token"), responseType: "code")


  public static func oauth(parentVC: UIViewController) {
    oauthSwift.authorizeURLHandler = SafariURLHandler.init(viewController: parentVC, oauthSwift: oauthSwift)
    oauthSwift.authorize(withCallbackURL: "honeymustard://oauth-callback/mastodon", scope: "read write follow", state: "a", success: { (credential, response, parameters) in
      print(credential)
      print(response)
      print(parameters)
    }) { (error) in
      print(error)
    }
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
