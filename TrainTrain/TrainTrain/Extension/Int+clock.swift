//
//  Int+clock.swift
//  TrainTrain
//
//  Created by daco daco on 2022/11/27.
//

import Foundation

extension Int {

  var asClock: String {
    if self < 60 {
      return "\(self)초"
    } else if (self % 60) == 0 {
      return "\(self / 60)분"
    } else {
      return "\(self / 60)분 \(self % 60)초"
    }
  }
}
