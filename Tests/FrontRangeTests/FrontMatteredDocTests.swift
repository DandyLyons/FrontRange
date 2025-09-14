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
  func hasKey() throws {
    let doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.hasKey("title"))
    #expect(!doc.hasKey("nonexistent"))
  }
  
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
  
  @Test
  func mutatingFrontMatter() throws {
    var doc = try FrontMatteredDoc(parsing: docString)
    #expect(doc.getValue(forKey: "title") as? String == "Sample Document")
    
    doc.setValue("New Title", forKey: "title")
    #expect(doc.getValue(forKey: "title") as? String == "New Title")
    
    doc.setValue(["foo", "bar", "baz"], forKey: "tags")
    #expect((doc.getValue(forKey: "tags") as? [String]) == ["foo", "bar", "baz"])
  }
  
  @Suite
  struct ArrayTests {
    let docString1 = """
---
author: Jane Smith
date: 2024-01-15 12:30:00 +0000
tags: [swift, yaml, testing]
title: Another Document
starred: true
---
This document has a different body. It also uses a different format for the tags.
"""
    let docString2 = """
---
author: John Smith
date: 2025-01-15 12:30:00 +0000
tags: [swift, yaml, testing]
title: Another Document
starred: false
---
This document has a different body. It also uses a different format for the tags.
"""
    @Test
    func testParsingMultipleYAMLStrings() throws {
      let doc1 = try FrontMatteredDoc(parsing: docString1)
      let doc2 = try FrontMatteredDoc(parsing: docString2)
      let docs = [doc1, doc2]
      let expectedDocs = [
        FrontMatteredDoc(
          frontMatter: [
            "author": "Jane Smith",
            "date": "2024-01-15 12:30:00 +0000",
            "tags": ["swift", "yaml", "testing"],
            "title": "Another Document",
            "starred": true
          ],
          body: "This document has a different body. It also uses a different format for the tags."
        ),
        FrontMatteredDoc(
          frontMatter: [
            "author": "John Smith",
            "date": "2025-01-15 12:30:00 +0000",
            "tags": ["swift", "yaml", "testing"],
            "title": "Another Document",
            "starred": false
            ],
          body: "This document has a different body. It also uses a different format for the tags."
        )
      ]
      for (doc, expectedDoc) in zip(docs, expectedDocs) {
        #expect(doc.contentIsEqual(to: expectedDoc))
      }
    }
    
  }
}
