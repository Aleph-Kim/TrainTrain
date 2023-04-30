//
//  TrainLaneFeature.swift
//  Arrival
//
//  Created by Geonhee on 2023/03/31.
//

import ComposableArchitecture
import Foundation
import SubwayModels
import UserDefaultsClient

public struct TrainLaneFeature: Reducer {

  @Dependency(\.userDefaultsClient) var userDefaultsClient

  public init() {}

  public struct State: Equatable {
    public typealias TrainID = String

    public var trains: IdentifiedArrayOf<TrainFeature.State> = []
    public var selectedSubwayLine: SubwayLine
    public var selectedStationID: String
    public var directionStationID: String
    public var hasArrivedTrain: Bool = false

    public var laneWidth: CGFloat?
    public var remainingDistances: [TrainID: CGFloat] = [:]
    public var distancePerTics: [TrainID: CGFloat] = [:]
    public var xOffsets: [TrainID: CGFloat] = [:]

    public init(
      trains: IdentifiedArrayOf<TrainFeature.State>
    ) {
      @Dependency(\.userDefaultsClient) var userDefaultsClient

      self.selectedSubwayLine = SubwayLine(rawValue: userDefaultsClient.subwayLine) ?? .line2
      self.selectedStationID = userDefaultsClient.selectedStationID
      self.directionStationID = userDefaultsClient.directionStationID
      self.trains = trains
    }
  }

  public enum Action {
    case train(id: TrainFeature.State.ID, action: TrainFeature.Action)
    case timerTicked
    case updateLaneWidth(CGFloat)
    case updateTrains([TrainInfo])
    case updateHasArrivedTrain(Bool)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .train:
        return .none

      case let .updateLaneWidth(laneWidth):
        state.laneWidth = laneWidth
        return .none

      case .timerTicked:
        updateTrainsViewProperties(with: &state)
        return .run { [ids = state.trains.ids] send in
          for id in ids {
            await send(.train(id: id, action: .timerTicked))
          }
        }

      case let .updateTrains(newTrains):
        let trains = newTrains
          .map { trainInfo in
            TrainFeature.State(
              id: trainInfo.id,
              selectedSubwayLine: state.selectedSubwayLine,
              trainInfo: trainInfo,
              // SubwayInfoClient에서 ETA 기준으로 정렬하였으므로 첫번째가 가장 가까운 열차임
              isNearestTrain: newTrains.first == trainInfo
            )
          }
        let identifiedTrains = IdentifiedArrayOf(uniqueElements: trains)

        let selectedSubwayLine = SubwayLine(rawValue: userDefaultsClient.subwayLine) ?? .line2
        let selectedStationID = userDefaultsClient.selectedStationID
        let selectedDirectionStationID = userDefaultsClient.directionStationID
        let shouldRefresh = state.trains.isEmpty ||
          state.selectedSubwayLine != selectedSubwayLine ||
          state.selectedStationID != selectedStationID ||
          state.directionStationID != selectedDirectionStationID

        if shouldRefresh {
          state.selectedSubwayLine = selectedSubwayLine
          state.selectedStationID = selectedStationID
          state.directionStationID = selectedDirectionStationID
          state.trains = identifiedTrains
        } else {
          state.trains = updateExistingTrains(state: state, with: identifiedTrains)
        }
        return .run { [ids = state.trains.ids] send in
          for id in ids {
            await send(.train(id: id, action: .updateSelection(selectedSubwayLine)))
          }
        }

      case let .updateHasArrivedTrain(hasArrivedTrain):
        state.hasArrivedTrain = hasArrivedTrain
        return .none
      }
    }
    .forEach(\.trains, action: /Action.train) {
      TrainFeature()
    }
  }

  private func updateExistingTrains(
    state: TrainLaneFeature.State,
    with newTrains: IdentifiedArrayOf<TrainFeature.State>
  ) -> IdentifiedArrayOf<TrainFeature.State> {
    var trains = state.trains

    for newTrain in newTrains {
      let isNewTrain = newTrains
        .notContains { $0.id == newTrain.id || newTrain.trainInfo.previousStationID == state.selectedStationID }

      if isNewTrain {
        trains.append(newTrain)
      }

      if let existingTrain = trains[id: newTrain.id],
         existingTrain.trainInfo.createdAt != newTrain.trainInfo.createdAt,
         existingTrain.trainInfo.eta != newTrain.trainInfo.eta {
        trains[id: newTrain.id] = newTrain
      }
    }

    for train in trains {
      let hasDeparted = newTrains.notContains { $0.id == train.id }

      if hasDeparted {
        trains.removeAll { $0.id == train.id }
      }
    }
    return trains
  }

  private func updateTrainsViewProperties(with state: inout TrainLaneFeature.State) {
    guard let laneWidth = state.laneWidth else { return }

    for train in state.trains where train.eta <= 300 {
      let eta = CGFloat(train.eta)
      let trainID = train.trainInfo.trainID
      var remainingDistance: CGFloat

      if let existingRemainingDistance: CGFloat = state.remainingDistances[trainID] {
        remainingDistance = existingRemainingDistance
      } else {
        remainingDistance = (eta > 0) ? eta / 300 * 100 : 0
      }

      var distancePerTic: CGFloat

      if let existingDistancePerTic: CGFloat = state.distancePerTics[trainID] {
        distancePerTic = existingDistancePerTic
      } else {
        distancePerTic = 100 / 300
      }

      distancePerTic = remainingDistance / eta
      state.distancePerTics[trainID] = distancePerTic

      remainingDistance -= distancePerTic
      state.remainingDistances[trainID] = remainingDistance

      let startOffset: CGFloat = laneWidth / 2
      let actualLaneWidth: CGFloat = laneWidth * 0.905
      var xOffset: CGFloat = actualLaneWidth * (1 - remainingDistance / 100) - startOffset + 7
      xOffset -= distancePerTic
      state.xOffsets[trainID] = xOffset
    }
  }
}
