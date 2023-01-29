//
//  Occupiable.swift
//  TrainTrain
//
//  Created by Geonhee on 2023/01/29.
//

protocol Occupiable {
  var isEmpty: Bool { get }
  var isNotEmpty: Bool { get }
}

extension Occupiable {
  var isNotEmpty: Bool {
    return !isEmpty
  }
}

extension Array: Occupiable {}
