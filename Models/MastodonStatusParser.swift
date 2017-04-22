//
//  MastodonStatusParser.swift
//  HoneyMustard
//
//  Created by Yuya Hirayama on 2017/04/21.
//  Copyright © 2017年 Yuya Hirayama. All rights reserved.
//

import Foundation
import RxSwift

public struct MastodonStatusParser {

  private static var processingParser: Parser? = nil
  public static func parse(xml: Data) {
    guard processingParser == nil else {
      return
    }
    let parser = Parser.init(xml: xml)
    parser.parse()
    processingParser = parser
  }
}

private class Parser: NSObject {
  private let parser: XMLParser

  fileprivate var elementStack: [Element] = []

  fileprivate class Element: CustomStringConvertible {
    var name: String
    var children: [CustomStringConvertible] = []
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
  }

  fileprivate init(xml: Data) {
    parser = XMLParser.init(data: xml)
    super.init()
    parser.delegate = self
  }

  fileprivate func parse() {
    parser.parse()
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
