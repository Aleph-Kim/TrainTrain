//
//  ETASummaryFeature.swift
//  Arrival
//
//  Created by Geonhee on 2023/04/01.
//

import ComposableArchitecture
import SubwayModels
import TTFoundation

public struct ETASummaryFeature: Reducer {

  public struct State: Equatable {
    public var primaryTrain: TrainInfo?
    public var secondaryTrain: TrainInfo?
    public var receivedPrimaryTrainETA: Int?
    public var receivedSecondaryTrainETA: Int?

    public init() {}
  }

  public enum Action {
    case timerTicked
    case updateETAs(newTrains: [TrainInfo])
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .timerTicked:
      state.primaryTrain?.eta -= 1
      state.secondaryTrain?.eta -= 1
      return .none

    case let .updateETAs(newTrains):
      if let primaryTrain = newTrains[safe: 0] {
        if primaryTrain.createdAt != state.primaryTrain?.createdAt,
           primaryTrain.eta != state.receivedPrimaryTrainETA {
          state.primaryTrain = primaryTrain
          state.receivedPrimaryTrainETA = primaryTrain.eta
        }
      } else {
        state.primaryTrain = nil
        state.receivedPrimaryTrainETA = nil
      }

      if let secondaryTrain = newTrains[safe: 1] {
        if secondaryTrain.createdAt != state.secondaryTrain?.createdAt,
           secondaryTrain.eta != state.receivedSecondaryTrainETA {
          state.secondaryTrain = secondaryTrain
          state.receivedSecondaryTrainETA = secondaryTrain.eta
        }
      } else {
        state.secondaryTrain = nil
        state.receivedSecondaryTrainETA = nil
      }
      return .none
    }
  }
}
