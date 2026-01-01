//
//  FrontMatteredDocTests.swift
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

@Suite struct FrontMatteredDocTests {
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
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.hasKey("title"))
    #expect(!doc.hasKey("nonexistent"))
  }
  
  @Test func `parsing`() throws {
    let doc = try FrontMatteredDoc(parsing: docString)
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
    let doc = try FrontMatteredDoc(
      parsing: docString,
    )
    let printed = try FrontMatteredDoc.Parser().print(doc)
    
    expectNoDifference(docString, String(printed))
  }
  
  @Test func `mutating front matter` () throws {
    var doc = try FrontMatteredDoc(parsing: docString)
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
    // Invalid frontmatter (array instead of mapping) should throw an error
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: invalidDocString)
    }
  }
  
  @Test func `reverse order`() throws {
    var doc = try FrontMatteredDoc(parsing: docString)
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
    var doc = try FrontMatteredDoc(parsing: docString)
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
    var doc = try FrontMatteredDoc(parsing: docString)
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
    var doc = try FrontMatteredDoc(parsing: docString)
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
    var doc = try FrontMatteredDoc(parsing: docString)
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

  // MARK: - Valid Edge Cases

  @Test func `frontmatter without body`() throws {
    let docString = """
---
title: Test
author: John
---
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.getValue(forKey: "title") == "Test")
    #expect(doc.getValue(forKey: "author") == "John")
    #expect(doc.body == "")
  }

  @Test func `empty frontmatter with body`() throws {
    let docString = """
---
---
Body content here
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "Body content here")
  }

  @Test func `empty frontmatter with whitespace`() throws {
    let docString = """
---

---
Body content
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "Body content")
  }

  @Test func `body contains delimiter`() throws {
    let docString = """
---
title: Test
---
Some text
---
More text
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.getValue(forKey: "title") == "Test")
    #expect(doc.body == "Some text\n---\nMore text")
  }

  @Test func `complex nested YAML`() throws {
    let docString = """
---
nested:
  deep:
    value: 42
list: [1, 2, 3]
metadata:
  author: Jane
  tags:
    - swift
    - yaml
---
Body
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    let nested = doc.getValue(forKey: "nested")
    #expect(nested != nil)
    let list = doc.getValue(forKey: "list")
    #expect(list == [1, 2, 3])
    #expect(doc.body == "Body")
  }

  // MARK: - Invalid Cases (should throw)

  @Test func `frontmatter is array`() throws {
    let docString = """
---
[]
---
Body
"""
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: docString)
    }
  }

  @Test func `frontmatter is scalar string`() throws {
    let docString = """
---
"just a string"
---
Body
"""
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: docString)
    }
  }

  @Test func `frontmatter is boolean`() throws {
    let docString = """
---
true
---
Body
"""
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: docString)
    }
  }

  @Test func `frontmatter is number`() throws {
    let docString = """
---
42
---
Body
"""
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: docString)
    }
  }

  @Test func `frontmatter has invalid YAML syntax`() throws {
    let docString = """
---
invalid: yaml: syntax:
---
Body
"""
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: docString)
    }
  }

  @Test func `frontmatter is YAML list`() throws {
    let docString = """
---
- item1
- item2
---
Body
"""
    #expect(throws: (any Error).self) {
      try FrontMatteredDoc(parsing: docString)
    }
  }

  // MARK: - Edge Cases
  @Test func `no frontmatter`() throws {
    let docString = """
    This is the body without any front matter.
    """
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "This is the body without any front matter.")
  }

  @Test func `single delimiter only`() throws {
    let docString = """
---
This should be treated as body text
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "---\nThis should be treated as body text")
  }

  @Test func `delimiter not on first line`() throws {
    let docString = """
Some text
---
title: Test
---
More text
"""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "Some text\n---\ntitle: Test\n---\nMore text")
  }

  @Test func `empty document`() throws {
    let docString = ""
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "")
  }

  @Test func `only whitespace`() throws {
    let docString = "   \n  "
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "   \n  ")
  }

  @Test func `windows line endings unsupported`() throws {
    let docString = "---\r\ntitle: Test\r\n---\r\nBody"
    let doc = try FrontMatteredDoc(parsing: docString)
    // Windows line endings not supported, so no frontmatter detected
    #expect(doc.frontMatter.isEmpty)
    #expect(doc.body == "---\r\ntitle: Test\r\n---\r\nBody")
  }
}
