//
//  SelectionFeature.swift
//  Arrival
//
//  Created by Geonhee on 2023/04/02.
//

import ComposableArchitecture
import StationInfoClient
import SubwayModels
import UserDefaultsClient

public struct SelectionFeature: Reducer {

  @Dependency(\.userDefaultsClient) var userDefaultsClient
  @Dependency(\.stationInfoClient) var stationInfoClient

  public init() {}

  public struct State: Equatable {

    public enum SelectionStep: CaseIterable {
      case pre
      case lineNumber
      case station
      case direction

      static var maxIndex: Int {
        SelectionStep.allCases.count - 1
      }
    }

    public enum Field: Hashable {
      case searchStationField
    }

    public var selectedStation: StationInfo
    public var directionStation: StationInfo
    public var selectedSubwayLine: SubwayLine
    public var isFirstSetting: Bool
    @BindingState public var focus: Field?

    public var selectionState: Selection = Selection()
    @BindingState public var selectionStep: SelectionStep = .pre
    public var stationList: [StationInfo] = []
    @BindingState public var searchText: String = ""
    @BindingState public var confetti: Int = .zero

    public var upper1DirectionStation: StationInfo?
    public var lower1DirectionStation: StationInfo?
    public var upper2DirectionStation: StationInfo?
    public var lower2DirectionStation: StationInfo?

    public init() {
      @Dependency(\.userDefaultsClient) var userDefaultsClient
      @Dependency(\.stationInfoClient) var stationInfoClient
      self.selectedStation = stationInfoClient.findStationInfo(from: userDefaultsClient.selectedStationID)
      self.directionStation = stationInfoClient.findStationInfo(from: userDefaultsClient.directionStationID)
      self.selectedSubwayLine = SubwayLine(rawValue: userDefaultsClient.subwayLine) ?? .line2
      self.isFirstSetting = userDefaultsClient.firstSetting
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case commitSelection
    case resetSelection
    case changeFocus(SelectionFeature.State.Field?)

    case startSelectionButtonTapped

    case selectSubwayLineBackButtonTapped
    case subwayLineTapped(SubwayLine)

    case selectStationBackButtonTapped
    case stationTapped(StationInfo)

    case selectDirectionStationBackButtonTapped
    case directionStationTapped(StationInfo)
  }

  public var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .commitSelection:
        if let selectedLine = state.selectionState.selectedLine,
           let selectedStation = state.selectionState.selectedStation,
           let selectedDirectionStationID = state.selectionState.directionStationID {
          state.selectedSubwayLine = selectedLine
          state.selectedStation = selectedStation
          state.directionStation = stationInfoClient.findStationInfo(from: selectedDirectionStationID)
          userDefaultsClient.subwayLine = selectedLine.id
          userDefaultsClient.selectedStationID = selectedStation.stationID
          userDefaultsClient.directionStationID = selectedDirectionStationID
        }
        return .send(.resetSelection)

      case .resetSelection:
        if state.selectionState.isSelectionCompleted {
          state.selectionState.removeAllSelection()
        }
        return .none

      case let .changeFocus(field):
        state.focus = field
        return .none

      case .startSelectionButtonTapped:
        state.selectionStep = .lineNumber
        return .none

      case .selectSubwayLineBackButtonTapped:
        state.selectionStep = .pre
        return .send(.changeFocus(nil))

      case let .subwayLineTapped(selectedSubwayLine):
        state.selectionState.selectedLine = selectedSubwayLine
        state.stationList = stationInfoClient.stationList(on: selectedSubwayLine)
        state.selectionStep = .station
        return .send(.changeFocus(.searchStationField))

      case .selectStationBackButtonTapped:
        state.selectionStep = .lineNumber
        return .send(.changeFocus(nil))

      case let .stationTapped(selectedStationInfo):
        state.selectionState.selectedStation = selectedStationInfo
        state.selectionStep = .direction
        state.searchText = ""

        state.upper1DirectionStation = nil
        state.lower1DirectionStation = nil
        state.upper2DirectionStation = nil
        state.lower2DirectionStation = nil

        if let upper1StationID = selectedStationInfo.upperStationID_1 {
          state.upper1DirectionStation = stationInfoClient.findStationInfo(from: upper1StationID)
        }

        if let lower1StationID = selectedStationInfo.lowerStationID_1 {
          state.lower1DirectionStation =  stationInfoClient.findStationInfo(from: lower1StationID)
        }

        if let upper2StationID = selectedStationInfo.upperStationID_2 {
          state.upper2DirectionStation = stationInfoClient.findStationInfo(from: upper2StationID)
        }

        if let lower2StationID = selectedStationInfo.lowerStationID_2 {
          state.lower2DirectionStation = stationInfoClient.findStationInfo(from: lower2StationID)
        }
        return .send(.changeFocus(nil))

      case .selectDirectionStationBackButtonTapped:
        state.selectionStep = .station
        return .send(.changeFocus(nil))

      case let .directionStationTapped(selectedStation):
        state.selectionState.directionStationID = selectedStation.stationID
        state.selectionStep = .pre
        state.confetti += 1
        return .none
      }
    }
  }
}
