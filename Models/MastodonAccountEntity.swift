//
//  MastodonAccountEntity.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/17.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

public struct MastodonAccountEntity: JSONMappable {
  public var id: Int
  public var username: String
  public var acct: String
  public var displayName: String
  public var locked: Bool
  public var createdAt: Date
  public var followersCount: Int
  public var followingCount: Int
  public var statusesCount: Int
  public var note: String
  public var url: URL
  public var avatar: URL
  public var avatarStatic: URL
  public var header: URL
  public var headerStatic: URL

  public init(json: [String : Any]) throws {
    id = try json.get(valueForKey: "id")
    username = try json.get(valueForKey: "username")
    acct = try json.get(valueForKey: "acct")
    displayName = try json.get(valueForKey: "display_name")
    locked = try json.get(valueForKey: "locked")
    createdAt = try json.getMastodonDate(valueForKey: "created_at")
    followersCount = try json.get(valueForKey: "followers_count")
    followingCount = try json.get(valueForKey: "following_count")
    statusesCount = try json.get(valueForKey: "statuses_count")
    note = try json.get(valueForKey: "note")
    url = try json.get(valueForKey: "url")
    let avatar: URL = try json.get(valueForKey: "avatar")
    if avatar.scheme != "http" && avatar.scheme != "https" {
      let url = MastodonRepository.getURLFrom(avatar)
      self.avatar = url
    } else {
      self.avatar = avatar
    }

    let avatarStatic: URL = try json.get(valueForKey: "avatar_static")
    if avatarStatic.scheme != "http" && avatarStatic.scheme != "https" {
      let url = MastodonRepository.getURLFrom(avatarStatic)
      self.avatarStatic = url
    } else {
      self.avatarStatic = avatarStatic
    }
    let header: URL = try json.get(valueForKey: "header")
    if header.scheme != "http" && header.scheme != "https" {
      let url = MastodonRepository.getURLFrom(header)
      self.header = url
    } else {
      self.header = header
    }
    let headerStatic: URL = try json.get(valueForKey: "header_static")
    if headerStatic.scheme != "http" && headerStatic.scheme != "https" {
      let url = MastodonRepository.getURLFrom(headerStatic)
      self.headerStatic = url
    } else {
      self.headerStatic = headerStatic
    }
  }

  fileprivate var _textRepresentation = Variable<[TextRepresentation]?>.init(nil)
}

// MARK: - Extended APIs

public extension MastodonAccountEntity {
  public var attributedNote: Observable<[TextRepresentation]> {
    if let textRepresentation = _textRepresentation.value {
      return Observable.just(textRepresentation)
    }
    return MastodonStatusParser.parse(xml: note)
      .do(onNext: { (textRepresentation) in
        self._textRepresentation.value = textRepresentation
      })
  }

}
