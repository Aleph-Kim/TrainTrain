//
//  TrainView.swift
//  Arrival
//
//  Created by Geonhee on 2023/03/31.
//

import ComposableArchitecture
import SwiftUI

struct TrainView: View {
  let store: StoreOf<TrainFeature>
  @State private var isPulsating: Bool = false

  struct ViewState: Equatable {
    var trainID: String
    var subwayLineColor: Color
    var formattedETA: String
    var isNearestTrain: Bool

    init(from state: TrainFeature.State) {
      self.trainID = state.trainInfo.id
      self.subwayLineColor = state.selectedSubwayLine.color

      let eta = state.eta

      if eta <= 30 {
        self.formattedETA = "곧 도착"
      } else if eta <= 0 {
        self.formattedETA = "도착"
      } else {
        self.formattedETA = eta.asClock
      }
      self.isNearestTrain = state.isNearestTrain
    }
  }

  var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      ZStack {
        trainCircle(subwayLineColor: viewStore.subwayLineColor)

        pulsatingLayers(
          subwayLineColor: viewStore.subwayLineColor,
          delayedSeconds: [0.0, 0.8]
        )

        etaText(viewStore.formattedETA)
          .offset(y: -18)
      }
      .onAppear {
        isPulsating = viewStore.isNearestTrain
      }
      .onChange(of: viewStore.isNearestTrain) { newValue in
        isPulsating = newValue
      }
    }
  }

  private func trainCircle(subwayLineColor: Color) -> some View {
    Circle()
      .foregroundColor(subwayLineColor)
      .frame(width: 12, height: 12)
  }

  private func pulsatingLayers(
    subwayLineColor: Color,
    delayedSeconds: [Double]
  ) -> some View {
    ForEach(delayedSeconds, id: \.self) { delayedSecond in
      Circle()
        .foregroundColor(subwayLineColor)
        .frame(width: 50, height: 50)
        .scaleEffect(isPulsating ? 1 : 0.001)
        .opacity(isPulsating ? 0 : 0.7)
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: false).delay(delayedSecond), value: isPulsating)
    }
  }

  private func etaText(_ text: String) -> some View {
    Text(text)
      .font(.caption2)
      .foregroundColor(.secondary)
  }
}
