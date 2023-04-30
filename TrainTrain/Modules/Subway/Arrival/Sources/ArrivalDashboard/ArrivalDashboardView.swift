//
//  NewArrivalView.swift
//  Arrival
//
//  Created by Geonhee on 2023/04/01.
//

import ActivityKit
import ComposableArchitecture
import SubwayModels
import SwiftUI
import TTDesignSystem
import WidgetHelper

public struct ArrivalDashboardView: View {
  public let store: StoreOf<ArrivalDashboardFeature>
  @Environment(\.scenePhase) var scenePhase

  public init(store: StoreOf<ArrivalDashboardFeature>) {
    self.store = store
  }

  struct ViewState: Equatable {
    var subwayLineColor: Color
    var subwayLineNamePrefix: String
    var currentStationName: String
    var nextStationName: String

    var liveETA: Int?
    var directionStationName: String
    var selectedSubwayLineName: String

    init(from state: ArrivalDashboardFeature.State) {
      self.subwayLineColor = state.selectedSubwayLine.color
      self.subwayLineNamePrefix = "\(state.selectedSubwayLine.name.prefix(1))"
      self.currentStationName = state.selectedStationInfo.stationName
      self.nextStationName = state.directionStationName

      self.liveETA = state.trainLane.trains.first(where: { $0.eta > 30 })?.eta
      self.directionStationName = state.directionStationName
      self.selectedSubwayLineName = String(state.selectedSubwayLine.name.prefix(1))
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in

      VStack(spacing: 0) {
        infographicView(viewState: viewStore.state)
          .padding(.horizontal, 16)
          .backgroundColor(.secondarySystemBackground)
          .cornerRadius(20.0, corners: [.topLeft, .topRight])

        ETASummaryView(
          store: store.scope(
            state: \.etaSummary,
            action: ArrivalDashboardFeature.Action.etaSummary
          )
        )
      }
      .onChange(of: scenePhase) { newScenePhase in
        switch newScenePhase {
        case .active:
          viewStore.send(.onSceneBecomeActive)
        case .background:
          if #available(iOS 16.1, *) {
            Task { await handleLiveActivity(viewStore: viewStore) }
          }
        default: return
        }
      }
    }
  }

  private func infographicView(viewState: ViewState) -> some View {
    return VStack(spacing: 0) {
      lineStationView()
        .padding(.top, 16)
        .padding(.bottom, 17.5)

      TrainLaneView(
        store: store.scope(
          state: \.trainLane,
          action: ArrivalDashboardFeature.Action.trainLane
        )
      )
    }
    .frame(height: 108)

    func lineStationView() -> some View {
      HStack {
        currentStationView()
        Spacer()
        nextStationView()
      }
    }

    func currentStationView() -> some View {
      HStack(spacing: 6.0) {
        subwayLineCircle()
        currentStationNameText()
      }
    }

    func subwayLineCircle() -> some View {
      let borderWidth: CGFloat = 4.0
      let frameSize: CGFloat = 28.0

      return Circle()
        .strokeBorder(lineWidth: borderWidth)
        .frame(width: frameSize, height: frameSize)
        .foregroundColor(viewState.subwayLineColor)
        .overlay {
          Text(viewState.subwayLineNamePrefix)
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(.additionalGray4)
        }
    }

    func currentStationNameText() -> some View {
      Text(viewState.currentStationName)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.additionalGray4)
    }

    func nextStationView() -> some View {
      HStack(spacing: 2) {
        Text("다음역")

        Text(viewState.nextStationName)
          .fontWeight(.bold)
      }
      .font(.footnote)
      .foregroundColor(.additionalGray3)
      .padding(.horizontal, 4)
      .padding(.vertical, 2)
      .backgroundColor(.systemGray5)
    }
  }

  @available(iOS 16.1, *)
  private func handleLiveActivity(viewStore: ViewStore<ArrivalDashboardView.ViewState, ArrivalDashboardFeature.Action>) async {
    guard let eta = viewStore.liveETA else { return }

    let attributes = TrainTrainWidgetAttributes()
    let contentState = TrainTrainWidgetAttributes.ContentState(
      eta: eta,
      selectedStationName: viewStore.currentStationName,
      directionStationName: viewStore.directionStationName,
      subwayLineName: viewStore.selectedSubwayLineName
    )
    let existingActivities = Activity<TrainTrainWidgetAttributes>.activities
    let hasExistingActivity = existingActivities.isNotEmpty

    if hasExistingActivity {
      await updateActivity(existingActivities: existingActivities, contentState: contentState)
    } else {
      _ = createActivity(attributes: attributes, contentState: contentState)
    }
  }

  @available(iOS 16.1, *)
  private func updateActivity(
    existingActivities: [Activity<TrainTrainWidgetAttributes>],
    contentState: Activity<TrainTrainWidgetAttributes>.ContentState
  ) async {
    // Activity는 하나 이상 생성하지 않으므로 유일한 업데이트 대상임
    await existingActivities.first?.update(using: contentState)
  }

  @available(iOS 16.1, *)
  private func createActivity(
    attributes: TrainTrainWidgetAttributes,
    contentState: Activity<TrainTrainWidgetAttributes>.ContentState
  ) -> Activity<TrainTrainWidgetAttributes>? {
    do {
      return try Activity<TrainTrainWidgetAttributes>.request(
        attributes: attributes,
        contentState: contentState,
        pushType: nil
      )
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}
