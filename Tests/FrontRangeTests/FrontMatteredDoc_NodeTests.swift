//
//  FrontMatteredDoc_NodeTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-02.
//

import CustomDump
import Foundation
import IssueReporting
import Testing
import Yams
@testable import FrontRange

@Suite struct FrontMatteredDoc_NodeTests {
  let docString = """
---
author: Jane Doe
date: 2023-10-01 00:00:00 +0000
age: 42
tags:
- swift
- parsing
- yaml
title: Sample Document
---
This is the body of the document. It contains multiple lines of text.  
It can also include **Markdown** formatting.
"""
  
  let expectedNode: Yams.Node.Mapping = [
    "author": "Jane Doe",
    "date": "2023-10-01 00:00:00 +0000",
    "age": 42,
    "tags": ["swift", "parsing", "yaml"],
    "title": "Sample Document",
  ]
  
  let expectedBody = """
This is the body of the document. It contains multiple lines of text.  
It can also include **Markdown** formatting.
"""
  
  @Test func `has key`() throws {
    let doc = try FrontMatteredDoc_Node(parsing: docString)
    #expect(doc.hasKey("title"))
    #expect(!doc.hasKey("nonexistent"))
  }
  
  @Test func `parsing`() throws {
    let doc = try FrontMatteredDoc_Node(parsing: docString)
    #expect(doc.frontMatter == expectedNode)
    #expect(doc.body == expectedBody)
    let expectedFrontMatterString = """
      author: Jane Doe
      date: 2023-10-01 00:00:00 +0000
      age: 42
      tags:
      - swift
      - parsing
      - yaml
      title: Sample Document
      """
    #expect(doc.frontMatterAsString == expectedFrontMatterString)
  }
  
  @Test func `printing` () throws {
    let doc = try FrontMatteredDoc_Node(
      parsing: docString,
    )
    let printed = try FrontMatteredDoc_Node.Parser().print(doc)
    
    expectNoDifference(docString, String(printed))
  }
  
  @Test func `mutating front matter` () throws {
    var doc = try FrontMatteredDoc_Node(parsing: docString)
    #expect(doc.getValue(forKey: "author") == "Jane Doe")
    #expect(doc.getValue(forKey: "date") == "2023-10-01 00:00:00 +0000")
    #expect(doc.getValue(forKey: "age") == 42)
    #expect(doc.getValue(forKey: "tags") == ["swift", "parsing", "yaml"])
    #expect(doc.getValue(forKey: .scalar(.init("title"))) == "Sample Document")
    
    doc.setValue(.scalar(.init("Updated Document")), forKey: "title")
    #expect(doc.getValue(forKey: "title") == "Updated Document")
    doc.setValue(nil, forKey: "age")
    #expect(doc.getValue(forKey: "age") == nil)
    doc.setValue(100, forKey: "newKey")
    #expect(doc.getValue(forKey: "newKey") == 100)
    doc.setValue("dog", forKey: "favoriteAnimal")
    #expect(doc.getValue(forKey: "favoriteAnimal") == "dog")
  }
  
  @Test func `Invalid String`() throws {
    let invalidDocString = """
                           ---
                           []
                           ---
                           
                           """
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc_Node(parsing: invalidDocString)
    }
  }
  
  @Test func `reverse order`() throws {
    var doc = try FrontMatteredDoc_Node(parsing: docString)
    doc.frontMatter.reverse()
    let expected: Node.Mapping = [
      "title": "Sample Document",
      "tags": ["swift", "parsing", "yaml"],
      "age": 42,
      "date": "2023-10-01 00:00:00 +0000",
      "author": "Jane Doe",
    ]
    #expect(doc.frontMatter == expected)
  }
  
  @Test func `sort by`() throws {
    var doc = try FrontMatteredDoc_Node(parsing: docString)
    doc.frontMatter.sort(by: { $0.key < $1.key })
    let expected: Node.Mapping = [
      "age": 42,
      "author": "Jane Doe",
      "date": "2023-10-01 00:00:00 +0000",
      "tags": ["swift", "parsing", "yaml"],
      "title": "Sample Document",
    ]
    #expect(doc.frontMatter == expected)
  }
  
  @Test func `remove item for key`() throws {
    var doc = try FrontMatteredDoc_Node(parsing: docString)
    doc.frontMatter.removeItem(forKey: "age")
    #expect(doc.getValue(forKey: "age") == nil)
    let expected: Node.Mapping = [
      "author": "Jane Doe",
      "date": "2023-10-01 00:00:00 +0000",
      "tags": ["swift", "parsing", "yaml"],
      "title": "Sample Document",
    ]
    #expect(doc.frontMatter == expected)
  }
  
  @Test func `removeLast`() throws {
    var doc = try FrontMatteredDoc_Node(parsing: docString)
    doc.frontMatter.removeLast()
    let expected: Node.Mapping = [
      "author": "Jane Doe",
      "date": "2023-10-01 00:00:00 +0000",
      "age": 42,
      "tags": ["swift", "parsing", "yaml"],
    ]
    #expect(doc.frontMatter == expected)
  }
  
  @Test func `remove at index`() throws {
    var doc = try FrontMatteredDoc_Node(parsing: docString)
    if let index = doc.frontMatter.index(forKey: "age") {
      doc.frontMatter.remove(at: index)
    } else {
      reportIssue("Could not find index for key 'age'")
    }
    let expected: Node.Mapping = [
      "author": "Jane Doe",
      "date": "2023-10-01 00:00:00 +0000",
      "tags": ["swift", "parsing", "yaml"],
      "title": "Sample Document",
    ]
    #expect(doc.frontMatter == expected)
  }
}
