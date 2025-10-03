//
//  Node.Mapping Support.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-01.
//

import Foundation
import Yams

extension Yams.Node.Mapping {
  /// A public copy of the private `
  public struct _Pair<Value: Comparable & Equatable>: Comparable, Equatable {
    public let key: Value
    public let value: Value
    
    public init(_ key: Value, _ value: Value) {
      self.key = key
      self.value = value
    }
    
    public static func < (lhs:_Pair<Value>, rhs:_Pair<Value>) -> Bool {
      return lhs.key < rhs.key
    }
    
    public static func toTuple(pair:_Pair) -> (key: Value, value: Value) {
      return (key: pair.key, value: pair.value)
    }
  }
}

extension Yams.Node.Mapping._Pair: Hashable where Value: Hashable {}

// MARK: - Yams.Node.Mapping + _pairs
public extension Yams.Node.Mapping {
  var _pairs: [_Pair<Node>] {
    get {
      zip(self.keys, self.values)
        .map { _Pair($0, $1) }
    }
    set {
      self = Self.init(
        newValue.map { ($0.key, $0.value) },
        tag,
        style,
        mark,
        anchor
      )
    }
  }
}

// MARK: Methods
public extension Yams.Node.Mapping {
  mutating func reverse() {
    self._pairs.reverse()
  }
  
  mutating func sort(by areInIncreasingOrder: (_Pair<Node>, _Pair<Node>) -> Bool) {
    let sortedPairs = self._pairs.sorted(by: { areInIncreasingOrder($0, $1) })
    self._pairs = sortedPairs
  }
  
  mutating func removeItem(forKey keyString: String) {
    var pairs = self._pairs
    if let index = pairs.firstIndex(where: { $0.key.string == keyString }) {
      pairs.remove(at: index)
      self._pairs = pairs
    }
  }
  
  mutating func removeLast() {
    var pairs = self._pairs
    pairs.removeLast()
    self._pairs = pairs
  }
  
  mutating func remove(at int: Int) {
    var pairs = self._pairs
    pairs.remove(at: int)
    self._pairs = pairs
  }
}
