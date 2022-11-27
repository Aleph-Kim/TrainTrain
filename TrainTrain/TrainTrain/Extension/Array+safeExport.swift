//
//  Array+safeExport.swift
//  TrainTrain
//
//  Created by daco daco on 2022/11/06.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
      // iOS 9 or later
        return indices ~= index ? self[index] : nil
    }
}
