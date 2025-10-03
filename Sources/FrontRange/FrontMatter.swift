//
//  FrontMatter.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/13/25.
//

import OrderedCollections
import Foundation

@available(*, deprecated, message: "Use `Yams.Node.Mapping` instead")
public typealias FrontMatter = OrderedDictionary<String, Any>

extension FrontMatter {
  public func isEqual(to other: Self) -> Bool {
    guard self.count == other.count else { return false }
    guard self.keys.sorted() == other.keys.sorted() else { return false }
    
    for (key, value1) in self {
      // Unwrap value2 from the same key
      guard let value2 = other[key] else { return false }
      
      guard anyValuesAreEqual(value1, value2) else {
        return false
      }
    }
    return true
  }
  
  func anyValuesAreEqual(_ value1: Any, _ value2: Any) -> Bool {
    // Compare integers
    if let int1 = value1 as? Int, let int2 = value2 as? Int {
      return int1 == int2
    }
    
    // Compare strings
    if let str1 = value1 as? String, let str2 = value2 as? String {
      return str1 == str2
    }
    
    // Compare arrays
    if let arr1 = value1 as? [Any], let arr2 = value2 as? [Any] {
      guard arr1.count == arr2.count else { return false }
      for (a1, a2) in zip(arr1, arr2) {
        guard anyValuesAreEqual(a1, a2) else { return false }
      }
      return true
    }
    
    // Compare Frontmatter recursively
    if let f1 = value1 as? FrontMatter, let f2 = value2 as? FrontMatter {
      return f1.isEqual(to: f2)
    }

  #if canImport(Foundation) // Check if NSObject is available
    // For other types, try using NSObject comparison as fallback
    if let obj1 = value1 as? NSObject, let obj2 = value2 as? NSObject {
      return obj1 == obj2
    }
  #endif
    
    return false
  }
}
