//
//  TrainFeature.swift
//  Arrival
//
//  Created by Geonhee on 2023/03/31.
//

import ComposableArchitecture
import Foundation
import SubwayModels

public struct TrainFeature: Reducer {

  public struct State: Equatable, Identifiable {
    public var id: String
    public var selectedSubwayLine: SubwayLine
    public var trainInfo: TrainInfo
    public var isNearestTrain: Bool
    public var isPulsating: Bool = false
    public var eta: Int

    public init(
      id: String,
      selectedSubwayLine: SubwayLine,
      trainInfo: TrainInfo,
      isNearestTrain: Bool
    ) {
      self.id = id
      self.selectedSubwayLine = selectedSubwayLine
      self.trainInfo = trainInfo
      self.isNearestTrain = isNearestTrain
      self.eta = trainInfo.eta
    }
  }

  public enum Action {
    case startPulsatingIfNearestTrain
    case stopPulsating
    case timerTicked
    case updateSelection(SubwayLine)
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .startPulsatingIfNearestTrain:
      if state.isNearestTrain {
        state.isPulsating = true
      }
      return .none

    case .stopPulsating:
      state.isPulsating = false
      return .none

    case .timerTicked:
      if state.eta <= 0 {
        state.isPulsating = false
      }
      state.eta -= 1
      return .none

    case let .updateSelection(selectedSubwayLine):
      state.selectedSubwayLine = selectedSubwayLine
      return .none
    }
  }
}
