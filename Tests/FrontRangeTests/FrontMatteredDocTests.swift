import CustomDump
import Foundation
import IssueReporting
import Testing
@testable import FrontRange

@Suite
struct FrontMatteredDocTests {
  let docString = """
---
author: Jane Doe
date: 2023-10-01 00:00:00 +0000
tags:
- swift
- parsing
- yaml
title: Sample Document
---
This is the body of the document. It contains multiple lines of text.  
It can also include **Markdown** formatting.
"""
  
  let expectedFrontMatter: FrontMatter = [
    "title": "Sample Document",
    "author": "Jane Doe",
    "date": "2023-10-01 00:00:00 +0000",
    "tags": ["swift", "parsing", "yaml"]
  ]
  
  let expectedBody = """
This is the body of the document. It contains multiple lines of text.  
It can also include **Markdown** formatting.
"""
  
  @Test
  func testParsing() throws {
    let doc = try FrontMatteredDoc(parsing: docString)
    // Use custom comparison for dictionaries
    #expect(doc.frontMatter.isEqual(to: expectedFrontMatter))
    #expect(doc.body == expectedBody)
  }
  
  @Test
  func testRendering() throws {
    var doc = try FrontMatteredDoc(
      parsing: docString,
      formatting: FrontMatteredDoc.Formatting()
    )
    let rendered = try doc.renderFullText()
    
    expectNoDifference(rendered, docString)
    
    // Modify front matter and body, then re-render
    doc.setValue("Updated Document", forKey: "title")
    doc.body = "Updated body content."
    doc.setValue(Date.distantPast, forKey: "date")
    
    let updatedDocString = """
---
author: Jane Doe
date: 0001-01-01T00:00:00Z
tags:
- swift
- parsing
- yaml
title: Updated Document
---
Updated body content.
"""
    let reRendered = try doc.renderFullText()
    expectNoDifference(reRendered, updatedDocString)
  }
}
