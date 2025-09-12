//
//  compare.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/3/25.
//

import Foundation

import FrontRange

// Helper function to compare [String: Any] dictionaries
func compareDictionaries(_ dict1: [String: Any], _ dict2: [String: Any]) -> Bool {
  guard dict1.count == dict2.count else { return false }
  
  for (key, value1) in dict1 {
    guard let value2 = dict2[key] else { return false }
    
    if !compareAnyValues(value1, value2) {
      return false
    }
  }
  return true
}

// Helper function to compare Any values recursively
func compareAnyValues(_ value1: Any, _ value2: Any) -> Bool {
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
      if !compareAnyValues(a1, a2) { return false }
    }
    return true
  }
  
  // Compare dictionaries recursively
  if let dict1 = value1 as? FrontMatter, let dict2 = value2 as? FrontMatter {
    return compareDictionaries(dict1, dict2)
  }

#if canImport(AppKit)
  // For other types, try using NSObject comparison as fallback
  if let obj1 = value1 as? NSObject, let obj2 = value2 as? NSObject {
    return obj1 == obj2
  }
#endif
  
  return false
}
