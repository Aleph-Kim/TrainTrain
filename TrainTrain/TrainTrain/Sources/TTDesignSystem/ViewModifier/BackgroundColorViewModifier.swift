//
//  BackgroundColorViewModifier.swift
//  TrainTrain
//
//  Created by Geonhee on 2023/01/14.
//

import SwiftUI

struct BackgroundColorViewModifier: ViewModifier {

  let color: Color

  func body(content: Content) -> some View {
    content
      .background(color)
  }
}

extension View {
  func backgroundColor(_ color: Color) -> some View {
    modifier(BackgroundColorViewModifier(color: color))
  }
}
