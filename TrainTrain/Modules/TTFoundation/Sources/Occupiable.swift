//
//  Occupiable.swift
//  TrainTrain
//
//  Created by Geonhee on 2023/01/29.
//

public protocol Occupiable {
  var isEmpty: Bool { get }
  var isNotEmpty: Bool { get }
}

extension Occupiable {
  public var isNotEmpty: Bool {
    return !isEmpty
  }
}

extension Array: Occupiable {}
