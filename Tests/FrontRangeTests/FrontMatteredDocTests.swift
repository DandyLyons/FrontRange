import CustomDump
import IssueReporting
import Testing
@testable import FrontRange

@Suite
struct FrontMatteredDocTests {
  let docString = """
---
title: Sample Document
author: Jane Doe
date: 2023-10-01 00:00:00 +0000
tags: 
  - swift
  - parsing
  - yaml
---
This is the body of the document. It contains multiple lines of text.  
It can also include **Markdown** formatting.
"""
  
  let expectedMetadata: [String: Any] = [
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
    #expect(compareDictionaries(doc.frontMatter, expectedMetadata))
    #expect(doc.body == expectedBody)
  }
  
  @Test
  func testRendering() throws {
    var doc = try FrontMatteredDoc(parsing: docString)
    let rendered = try doc.renderFullText()
    #expect(rendered == docString)
    reportIssue(diff(rendered, docString))
    
//    // Modify front matter and body, then re-render
//    doc.setValue("Updated Document", forKey: "title")
//    doc.body = "Updated body content."
//    
//    let updatedDocString = """
//---
//title: Updated Document
//author: Jane Doe
//date: 2023-10-01 00:00:00 +0000
//tags:
//  - swift
//  - parsing
//  - yaml
//---
//Updated body content.
//"""
//    let reRendered = try doc.renderFullText()
//    #expect(reRendered == updatedDocString)
  }
}
