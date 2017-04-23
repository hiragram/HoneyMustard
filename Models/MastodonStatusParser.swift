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

public struct MastodonStatusParser {

  private var parser: Parser

  public init(xml: Data) {
    parser = Parser.init(xml: xml)
  }

  public func parse() -> Observable<[TextRepresentation]> {
    return parser.parse().map { (element) -> [TextRepresentation] in
      return element.textRepresentation()
    }
  }
}

private class Parser: NSObject {
  private let parser: XMLParser

  fileprivate var elementStack: [Element] = []

  fileprivate let _parsedElements = ReplaySubject<Element>.create(bufferSize: 1)
  private var parsedElements: Observable<Element> {
    return _parsedElements.asObservable()
  }

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
      default:
        print("unsupported tag")
        return []
      }
    }
  }

  fileprivate init(xml: Data) {
    parser = XMLParser.init(data: xml)
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
    print("Start parsing xml")
    elementStack = []
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    print("Finished parsing")
    print(elementStack)
    assert(elementStack.count == 1)
    _parsedElements.onNext(elementStack.first!)
  }

  func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
    print("foundNotationDeclarationWithName", name, publicID, systemID)
  }

  func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
    print("foundUnparsedEntityDeclarationWithName", name, publicID, systemID, notationName)
  }

  func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
    print("foundAttributeDeclarationWithName", attributeName, elementName, type, defaultValue)
  }

  func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
    print("foundElementDeclarationWithName", elementName, model)
  }

  func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
    print("foundInternalEntityDeclarationWithName", name, value)
  }

  func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
    print("foundExternalEntityDeclarationWithName", name, publicID, systemID)
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    print("didStartElement", elementName, namespaceURI, qName, attributeDict)
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
    print("didEndElement", elementName, namespaceURI, qName)
    if let last = elementStack.last, let parent = elementStack.dropLast().last {
      parent.children.append(last)
      elementStack.removeLast()
    }
  }

  func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
    print("didStartMappingPrefix", prefix, namespaceURI)
  }

  func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
    print("didEndMappingPrefix", prefix)
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    print("foundCharacters", string)
    elementStack.last?.children.append(string)
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("foundIgnorableWhitespace", whitespaceString)
  }

  func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    print("foundProcessingInstructionWithTarget", target, data)
  }

  func parser(_ parser: XMLParser, foundComment comment: String) {
    print("foundComment", comment)
  }

  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    print("foundCDATA", CDATABlock)
  }

  func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
    print("resolveExternalEntityName", name, systemID)
    return nil
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("parseErrorOccurred", parseError)
  }

  func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
    print("validationErrorOccurred", validationError)
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
        $0.underlineStyle(.styleSingle)
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
