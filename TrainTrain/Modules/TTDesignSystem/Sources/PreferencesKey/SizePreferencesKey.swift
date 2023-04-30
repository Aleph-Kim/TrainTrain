//
//  SizePreferencesKey.swift
//  TTDesignSystem
//
//  Created by Geonhee on 2023/04/01.
//

import SwiftUI

public struct SizePreferencesKey: PreferenceKey {
  public static var defaultValue: CGSize = .zero
  public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
