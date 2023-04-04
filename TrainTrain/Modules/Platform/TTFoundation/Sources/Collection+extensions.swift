//
//  Collection+extensions.swift
//  TTFoundation
//
//  Created by Geonhee on 2023/02/11.
//

extension Collection {
  public var isNotEmpty: Bool {
    return !isEmpty
  }

  public func notContains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    return try !contains(where: predicate)
  }
}
