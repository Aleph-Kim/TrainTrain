//
//  RealtimeStationArrivalFeature.swift
//  TrainTrainApp
//
//  Created by Geonhee on 2023/04/03.
//

import Arrival
import ComposableArchitecture
import Selection

struct RealtimeStationArrivalFeature: Reducer {

  struct State: Equatable {
    var arrivalDashboard: ArrivalDashboardFeature.State
    var selection: SelectionFeature.State
    var isKeyboardShowing: Bool = false

    init(
      arrivalDashboard: ArrivalDashboardFeature.State = .init(),
      selection: SelectionFeature.State = .init()
    ) {
      self.arrivalDashboard = arrivalDashboard
      self.selection = selection
    }
  }

  enum Action {
    case arrivalDashboard(ArrivalDashboardFeature.Action)
    case selection(SelectionFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.arrivalDashboard, action: /RealtimeStationArrivalFeature.Action.arrivalDashboard) {
      ArrivalDashboardFeature()
    }
    Scope(state: \.selection, action: /RealtimeStationArrivalFeature.Action.selection) {
      SelectionFeature()
    }
    Reduce { state, action in
      switch action {
      case .arrivalDashboard:
        return .none

      case .selection(.commitSelection):
        return .send(.arrivalDashboard(.updateSelection))

      case let .selection(.changeFocus(field)):
        state.isKeyboardShowing = (field != nil)
        return .none

      case .selection:
        return .none
      }
    }
  }
}
