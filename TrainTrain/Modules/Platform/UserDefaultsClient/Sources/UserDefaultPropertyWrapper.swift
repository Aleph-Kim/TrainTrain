//
//  UserDefaultPropertyWrapper.swift
//  TTUserDefaults
//
//  Created by Geonhee on 2023/02/08.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
  let key: UserDefaultsKey
  let defaultValue: T
  let userDefaults: UserDefaults

  init(
    _ key: UserDefaultsKey,
    defaultValue: T,
    userDefaults: UserDefaults = .standard
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
  }

  public var wrappedValue: T {
    get {
      return userDefaults.object(forKey: key.rawValue) as? T ?? defaultValue
    }
    set {
      userDefaults.set(newValue, forKey: key.rawValue)
    }
  }
}
