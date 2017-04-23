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

private let testHTML = "<p>だいぶしんどいぞこれ<a href=\"https://pawoo.net/media/oqL1KDbdJggzvXDwyGA\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">pawoo.net/media/oqL1KDbdJggzvX</span><span class=\"invisible\">DwyGA</span></a></p>"

class XMLParserTestCase: XCTestCase {
  private let bag = DisposeBag.init()

  func test_statusをパースできる() {
//    MastodonStatusParser.init().parse(xml: testHTML.data(using: .utf8)!)
//    .subscribe(onNext: { (representations) in
//      print(representations)
//    }).addDisposableTo(bag)
  }
}
