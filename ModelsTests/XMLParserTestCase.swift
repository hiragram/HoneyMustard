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

  func test_異常ないデータ() {
    let xml = "<p>にゃんこを愛するクリエイター nyanco! スタッフのつぶやき。 猫のことや日々のことについて語ります。LINEスタンプ多数発売中!! <a href=\"https://store.line.me/stickershop/author/21171/\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">store.line.me/stickershop/auth</span><span class=\"invisible\">or/21171/</span></a>  </p>"
    let expected = "にゃんこを愛するクリエイター nyanco! スタッフのつぶやき。 猫のことや日々のことについて語ります。LINEスタンプ多数発売中!! store.line.me/stickershop/auth  "
    let actual = try! MastodonStatusParser.parse(xml: xml).asAttributedString().map { $0.string }.toBlocking(timeout: 1).first()
    expect(actual).to(equal(expected))
  }

  func test_brをちゃんと処理できる() {
    let xml = "<p><a href=\"https://www.patreon.com/user?u=619786\"><span class=\"invisible\">https://www.</span><span class=\"\">patreon.com/user?u=619786</span><span class=\"invisible\"></span></a><br>税金払おう</p>"
    let expected = "patreon.com/user?u=619786\n税金払おう"
    let actual = try! MastodonStatusParser.parse(xml: xml).asAttributedString().map { $0.string }.toBlocking(timeout: 1).first()
    expect(actual).to(equal(expected))
  }

  func test_はぐれたAmpersandを処理できる() {
    let xml = "<p>うあぁぁぁぁっ！リョナらないでくださーいっ | D&apos;s Production <a href=\"https://pawoo.net/tags/pixiv\" class=\"mention hashtag\">#<span>pixiv</span></a> <a href=\"https://pawoo.net/tags/r\" class=\"mention hashtag\">#<span>R</span></a>-18G <a href=\"https://pawoo.net/tags/%E3%81%91%E3%82%82%E3%81%AE%E3%83%95%E3%83%AC%E3%83%B3%E3%82%BA\" class=\"mention hashtag\">#<span>けものフレンズ</span></a> <a href=\"https://pawoo.net/tags/%E3%81%91%E3%82%82%E3%83%95%E3%83%AC\" class=\"mention hashtag\">#<span>けもフレ</span></a> <a href=\"https://pawoo.net/tags/%E3%81%8B%E3%81%B0%E3%82%93\" class=\"mention hashtag\">#<span>かばん</span></a> <a href=\"https://pawoo.net/tags/%E3%83%AA%E3%83%A7%E3%83%8A\" class=\"mention hashtag\">#<span>リョナ</span></a> <a href=\"https://www.pixiv.net/member_illust.php?mode=medium&amp;illust_id=62023654\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">pixiv.net/member_illust.php?mo</span><span class=\"invisible\">de=medium&illust_id=62023654</span></a></p>"
    let expected = "うあぁぁぁぁっ！リョナらないでくださーいっ | D\'s Production #pixiv #R-18G #けものフレンズ #けもフレ #かばん #リョナ pixiv.net/member_illust.php?mo"
    let actual = try! MastodonStatusParser.parse(xml: xml).asAttributedString().map { $0.string }.toBlocking(timeout: 1).first()
    expect(actual).to(equal(expected))
  }

  func test_ampersandの正規表現間違ってたのでテストケース追加() {
    let xml = "<p>pixivでブックマークしました [R-18]Marked-girls Collection vol.4 | スガヒデオ <a href=\"https://pawoo.net/tags/pixiv\" class=\"mention hashtag\">#<span>pixiv</span></a> <a href=\"https://www.pixiv.net/member_illust.php?illust_id=62561668&amp;mode=medium\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">pixiv.net/member_illust.php?il</span><span class=\"invisible\">lust_id=62561668&mode=medium</span></a></p>"
    let actual = try! MastodonStatusParser.parse(xml: xml).asAttributedString().map { $0.string }.toBlocking().first()
    print(actual)
  }
}
