//
//  ArrivalDashboardFeature.swift
//  Arrival
//
//  Created by Geonhee on 2023/04/01.
//

import ComposableArchitecture
import StationInfoClient
import SubwayInfoClient
import SubwayModels
import UserDefaultsClient
import TTFoundation

public struct ArrivalDashboardFeature: Reducer {

  @Dependency(\.mainQueue) private var mainQueue
  @Dependency(\.stationInfoClient) private var stationInfoClient
  @Dependency(\.subwayInfoClient) private var subwayInfoClient
  @Dependency(\.userDefaultsClient) private var userDefaultsClient

  public init() {}

  public struct State: Equatable {
    public var trainLane: TrainLaneFeature.State
    public var etaSummary: ETASummaryFeature.State

    var selectedSubwayLine: SubwayLine
    var selectedStationInfo: StationInfo
    var directionStationID: String
    var directionStationName: String

    public init(
      trainLane: TrainLaneFeature.State = .init(trains: []),
      etaSummary: ETASummaryFeature.State = .init()
    ) {
      @Dependency(\.stationInfoClient) var stationInfoClient
      @Dependency(\.userDefaultsClient) var userDefaultsClient
      self.trainLane = trainLane
      self.etaSummary = etaSummary
      self.selectedSubwayLine = SubwayLine(rawValue: userDefaultsClient.subwayLine) ?? .line2
      self.selectedStationInfo = stationInfoClient.findStationInfo(from: userDefaultsClient.selectedStationID)
      self.directionStationID = userDefaultsClient.directionStationID
      self.directionStationName = stationInfoClient.findStationName(from: directionStationID)
    }
  }

  public enum Action {
    case trainLane(TrainLaneFeature.Action)
    case etaSummary(ETASummaryFeature.Action)
    case fetchTrains
    case startMovingTimer
    case startRefreshingTimer
    case movingTimerTicked
    case refreshingTimerTicked
    case updateSelection
    case onSceneBecomeActive
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.trainLane, action: /ArrivalDashboardFeature.Action.trainLane) {
      TrainLaneFeature()
    }
    Scope(state: \.etaSummary, action: /ArrivalDashboardFeature.Action.etaSummary) {
      ETASummaryFeature()
    }
    Reduce { state, action in
      struct MovingTimerID: Hashable {}
      struct RefreshingTimerID: Hashable {}

      switch action {
      case .trainLane:
        return .none

      case .etaSummary:
        return .none

      case .fetchTrains:
        return .run { [state] send in
          var newTrains = try await subwayInfoClient.fetchTrainInfos(
            targetStation: state.selectedStationInfo,
            directionStationID: state.directionStationID
          )
          var hasArrivedTrain: Bool = false

          newTrains.filter(\.isArrived)
            .forEach { arrivedTrain in
              hasArrivedTrain = true
              newTrains.removeAll { $0.trainID == arrivedTrain.trainID }
            }

          await send(.trainLane(.updateTrains(newTrains)))
          await send(.trainLane(.updateHasArrivedTrain(hasArrivedTrain)))
          await send(.etaSummary(.updateETAs(newTrains: newTrains)))
        }

      case .startMovingTimer:
        // clock.timer는 iOS 16부터 사용 가능하므로 deprecated method 이용
        return Effect.timer(
          id: MovingTimerID(),
          every: 1,
          on: mainQueue
        )
        .map { _ in .movingTimerTicked }

      case .startRefreshingTimer:
        return Effect.timer(
          id: RefreshingTimerID(),
          every: 10,
          on: mainQueue
        )
        .map { _ in .refreshingTimerTicked }

      case .movingTimerTicked:
        return .run { send in
          await send(.trainLane(.timerTicked))
          await send(.etaSummary(.timerTicked))
        }

      case .refreshingTimerTicked:
        return .task { .fetchTrains }

      case .updateSelection:
        state.selectedSubwayLine = SubwayLine(rawValue: userDefaultsClient.subwayLine) ?? .line2
        state.selectedStationInfo = stationInfoClient.findStationInfo(from: userDefaultsClient.selectedStationID)
        state.directionStationID = userDefaultsClient.directionStationID
        state.directionStationName = stationInfoClient.findStationName(from: userDefaultsClient.directionStationID)
        return .task { .fetchTrains }

      case .onSceneBecomeActive:
        return .run { send in
          await send(.fetchTrains)
          await send(.startMovingTimer)
          await send(.startRefreshingTimer)
        }
      }
    }
  }
}
