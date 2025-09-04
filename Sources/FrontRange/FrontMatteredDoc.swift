// The Swift Programming Language
// https://docs.swift.org/swift-book

import Yams
import Parsing

public typealias FrontMatter = [String: Any]
public struct FrontMatteredDoc {
  public init(frontMatter: FrontMatter, body: String, schema: [(String, Any.Type)] = []) {
    self.frontMatter = frontMatter
    self.body = body
    self.schema = schema
  }
  
  
  public var frontMatter: FrontMatter
  public var body: String
  public var schema: [(String, Any.Type)] = []
  
  public func validateSchema() -> [String] {
    var errors: [String] = []
    for (key, type) in schema {
      guard let value = frontMatter[key] else {
        errors.append("Missing required key '\(key)'.")
        continue
      }
      if type == String.self, !(value is String) {
        errors.append("Key '\(key)' is not a String.")
      } else if type == Int.self, !(value is Int) {
        errors.append("Key '\(key)' is not an Int.")
      } else if type == Double.self, !(value is Double) {
        errors.append("Key '\(key)' is not a Double.")
      } else if type == Bool.self, !(value is Bool) {
        errors.append("Key '\(key)' is not a Bool.")
      } else if type == [String].self, !(value is [String]) {
        errors.append("Key '\(key)' is not an Array of Strings.")
      } else if type == [Int].self, !(value is [Int]) {
        errors.append("Key '\(key)' is not an Array of Ints.")
      } else if type == [Double].self, !(value is [Double]) {
        errors.append("Key '\(key)' is not an Array of Doubles.")
      } else if type == [Bool].self, !(value is [Bool]) {
        errors.append("Key '\(key)' is not an Array of Bools.")
      } else if type == [String: Any].self, !(value is [String: Any]) {
        errors.append("Key '\(key)' is not a Dictionary.")
      }
    }
    return errors
  }
  
  public func renderFullText() throws -> String {
    let printer = YamsParser()
    var frontMatterSubstring = Substring()
    try printer.print(frontMatter, into: &frontMatterSubstring)
    return """
      ---
      \(frontMatterSubstring)
      ---
      \(body)
      """
  }
  
  public func getValue(forKey key: String) -> Any? {
    frontMatter[key]
  }
  mutating public func setValue(_ value: Any, forKey key: String) {
    frontMatter[key] = value
  }
}

// MARK: Convenience Initializers
extension FrontMatteredDoc {
  public init(parsing input: Substring, schema: [(String, Any.Type)] = []) throws {
    var input = input
    self = try Self.Parser().parse(&input)
    self.schema = schema
  }
  
  public init(parsing input: String, schema: [(String, Any.Type)] = []) throws {
    try self.init(parsing: Substring(input), schema: schema)
  }
}

extension [FrontMatteredDoc] {
  public func getValue(forKey key: String) -> [Any?] {
    self.map { $0.getValue(forKey: key) }
  }
   
  mutating public func setValue(_ value: Any, forKey key: String) {
    for index in self.indices {
      self[index].setValue(value, forKey: key)
    }
  }
}

extension FrontMatteredDoc {
  public struct Parser: Parsing.Parser {
    public var body: some Parsing.Parser<Substring, FrontMatteredDoc> {
      Parse(input: Substring.self) {
        FrontMatteredDoc(frontMatter: $0, body: String($1))
      } with: {
        "---\n"
        PrefixUpTo("---\n")
          .map(YAMLSubstringToDictionaryConversion()) // Substring -> [String: Any]
        "---\n"
        Rest() // Substring -> Substring
      }
    }
  }
}

public struct YAMLSubstringToDictionaryConversion: Conversion {
  public func apply(_ input: Substring) throws -> FrontMatter {
    var input = input
    return try YamsParser().parse(&input)
  }
  
  public func unapply(_ output: FrontMatter) throws -> Substring {
    let string = try Yams.dump(objects: output)
    return Substring(string)
  }
  
  public typealias Input = Substring
  public typealias Output = FrontMatter
}
