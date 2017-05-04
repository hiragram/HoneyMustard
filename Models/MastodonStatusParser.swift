//
//  MastodonStatusParser.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/21.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift
import Attributed

public class MastodonStatusParser {

  private var parser: Parser

  private static var processingParserRefs: [MastodonStatusParser] = []

  public static func parse(xml: String) -> Observable<[TextRepresentation]> {
    let xmlData = xml
      .replacingOccurrences(of: "<br>", with: "<br />")
      .data(using: .utf8)!

    let parser = MastodonStatusParser.init(xml: xmlData)
    processingParserRefs.append(parser)

    return parser.parse().do(onError: { (error) in
      print(error)
      if let index = processingParserRefs.index(where: { $0 === parser }) {
        processingParserRefs.remove(at: index)
      } else {
        print("なんか消えてるぞ")
      }
    }, onCompleted: { 
      if let index = processingParserRefs.index(where: { $0 === parser }) {
        processingParserRefs.remove(at: index)
      } else {
        print("なんか消えてるぞ")
      } // TODO コピペ直す
    })
  }

  private init(xml: Data) {
    parser = Parser.init(xml: xml)
  }

  private func parse() -> Observable<[TextRepresentation]> {
    return parser.parse().map { (element) -> [TextRepresentation] in
      return element.textRepresentation()
    }
  }
}

extension Observable where Element == [TextRepresentation] {
  func asAttributedString() -> Observable<NSAttributedString> {
    return map({ (texts) -> NSAttributedString in
      return texts.map { $0.attributedString }.reduce(NSMutableAttributedString.init(string: ""), { (attributedString, current) -> NSMutableAttributedString in
        attributedString.append(current)
        return attributedString
      })
    })
  }
}

private class Parser: NSObject {
  private let parser: XMLParser

  fileprivate var elementStack: [Element] = []

  fileprivate let _parsedElements = ReplaySubject<Element>.create(bufferSize: 1)
  private var parsedElements: Observable<Element> {
    return _parsedElements.asObservable()
  }

  fileprivate var rawData: Data

  class Element: CustomStringConvertible, ParserElement {
    var name: String
    var children: [ParserElement] = []
    var attributes: [String: [String]] = [:]

    init(name: String) {
      self.name = name
    }

    var description: String {
      let childrenStr = children.map { "\($0)" }.joined(separator: "\n")
      let attributesStr = attributes.map { (key: String, value: [String]) -> String in
        return "\"\(key)\"=\"\(value.joined(separator: " "))\""
      }.joined(separator: " ")
      return "<\(name)\(attributesStr.isEmpty ? "" : " \(attributesStr)")>\(childrenStr)</\(name)>"
    }

    func `is`(`class` className: String) -> Bool {
      guard let classes = attributes["class"] else {
        return false
      }
      return classes.contains(className)
    }

    func textRepresentation() -> [TextRepresentation] {
      guard !self.is(class: "invisible") else {
        return []
      }

      let childrenRepresentation = children.map({ (child) -> [TextRepresentation] in
        return child.textRepresentation()
      }).reduce([], +)


      switch name {
      case "p":
        return childrenRepresentation
      case "a":
        if let urlStr = (attributes["href"] ?? []).first, let url = URL.init(string: urlStr) {
          return [.link(text: childrenRepresentation, url: url)]
        } else {
          return childrenRepresentation
        }
      case "span":
        return childrenRepresentation
      case "br":
        return [.text("\n")]
      default:
        print("unsupported tag: \(name)")
        return []
      }
    }
  }

  fileprivate init(xml: Data) {
    let pXML = "<p>".data(using: .utf8)! + xml + "</p>".data(using: .utf8)! // FIXME workaround
    parser = XMLParser.init(data: pXML)
    rawData = pXML
    super.init()
    parser.delegate = self
  }

  fileprivate func parse() -> Observable<Element> {
    parser.parse()
    return parsedElements
  }
}

extension Parser: XMLParserDelegate {
  func parserDidStartDocument(_ parser: XMLParser) {
    elementStack = []
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    assert(elementStack.count == 1, "\(elementStack), \(String.init(data: rawData, encoding: .utf8))")
    _parsedElements.onNext(elementStack.first!)
    _parsedElements.onCompleted()
  }

  func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
  }

  func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
  }

  func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
  }

  func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
  }

  func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
  }

  func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    let element = Element.init(name: elementName)
    element.attributes = attributeDict.map { (key: String, value: String) -> (key: String, values: [String]) in
      return (key: key, values: value.components(separatedBy: " "))
      }.reduce([:]) { (attributes, current) -> [String: [String]] in
        var _attributes = attributes
        _attributes[current.key] = current.values
        return _attributes
    }
    elementStack.append(element)
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let last = elementStack.last, let parent = elementStack.dropLast().last {
      parent.children.append(last)
      elementStack.removeLast()
    }
  }

  func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
  }

  func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    elementStack.last?.children.append(string)
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
  }

  func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
  }

  func parser(_ parser: XMLParser, foundComment comment: String) {
  }

  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
  }

  func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
    return nil
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    _parsedElements.onError(parseError)
    print(parseError)
  }

  func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
    _parsedElements.onError(validationError)
    print(validationError)
  }
}

public enum TextRepresentation {
  case text(String)
  case link(text: [TextRepresentation], url: URL)
  case attachment(url: URL)

  fileprivate static func generateRepresentations(fromElement element: Parser.Element) {

  }

  public var attributedString: NSAttributedString {
    switch self {
    case .text(let text):
      return NSAttributedString.init(string: text)
    case .link(text: let children, url: let url):
      let text = children.map { $0.attributedString.string }.joined(separator: "")
      return text.at.attributed {
        $0
          .underlineStyle(.styleSingle)
          .link(url.absoluteString)
      }
    case .attachment(url: let url):
      return NSAttributedString.init(string: url.absoluteString) // TODO
    }
  }
}

protocol ParserElement: CustomStringConvertible {
  func textRepresentation() -> [TextRepresentation]
}

extension String: ParserElement {
  func textRepresentation() -> [TextRepresentation] {
    return [.text(self)]
  }
}
