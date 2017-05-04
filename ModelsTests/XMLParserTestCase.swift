//
//  XMLParserTestCase.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/21.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import XCTest
import Nimble
@testable import Models
import RxSwift
import RxBlocking

private let testHTML = "<p>だいぶしんどいぞこれ<a href=\"https://pawoo.net/media/oqL1KDbdJggzvXDwyGA\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">pawoo.net/media/oqL1KDbdJggzvX</span><span class=\"invisible\">DwyGA</span></a></p>"

class XMLParserTestCase: XCTestCase {
  private let bag = DisposeBag.init()

  func test_プロフィールをパースできる() {
    let xml = "<p>にゃんこを愛するクリエイター nyanco! スタッフのつぶやき。 猫のことや日々のことについて語ります。LINEスタンプ多数発売中!! <a href=\"https://store.line.me/stickershop/author/21171/\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">store.line.me/stickershop/auth</span><span class=\"invisible\">or/21171/</span></a>  </p>"
    let expected = "にゃんこを愛するクリエイター nyanco! スタッフのつぶやき。 猫のことや日々のことについて語ります。LINEスタンプ多数発売中!! store.line.me/stickershop/auth  "
    let actual = try! MastodonStatusParser.parse(xml: xml).asAttributedString().map { $0.string }.toBlocking(timeout: 1).first()
    expect(actual).to(equal(expected))
  }

  func test_テスト() {
    let xml = "<p><a href=\"https://www.patreon.com/user?u=619786\"><span class=\"invisible\">https://www.</span><span class=\"\">patreon.com/user?u=619786</span><span class=\"invisible\"></span></a><br>税金払おう</p>"
    let expected = "patreon.com/user?u=619786\n税金払おう"
    let actual = try! MastodonStatusParser.parse(xml: xml).asAttributedString().map { $0.string }.toBlocking(timeout: 1).first()
    expect(actual).to(equal(expected))
  }
}
