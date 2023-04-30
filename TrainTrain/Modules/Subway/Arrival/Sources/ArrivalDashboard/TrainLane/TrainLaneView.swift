//
//  TrainLaneView.swift
//  Arrival
//
//  Created by Geonhee on 2023/03/31.
//

import ComposableArchitecture
import SubwayModels
import SwiftUI
import TTDesignSystem

struct TrainLaneView: View {
  let store: StoreOf<TrainLaneFeature>
  @State var laneWidth: CGFloat?

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        GeometryReader { proxy in
          HStack(spacing: 4.0) {
            laneLineView()
            arrivalStationCircle(
              selectedSubwayLine: viewStore.selectedSubwayLine,
              hasArrivedTrain: viewStore.hasArrivedTrain
            )
          }
          .preference(key: SizePreferencesKey.self, value: proxy.size)
        }
        if let laneWidth {
          trainInfoStack(viewStore: viewStore, laneWidth: laneWidth)
        }
      }
      .onPreferenceChange(SizePreferencesKey.self) { newSize in
        let newLaneWidth = newSize.width
        laneWidth = newLaneWidth
        viewStore.send(.updateLaneWidth(newLaneWidth))
      }
    }
  }

  private func laneLineView() -> some View {
    Line()
      .stroke(style: StrokeStyle(lineWidth: 2.0, dash: [5.0], dashPhase: 2.0))
      .foregroundColor(.systemGray5)
  }

  private func arrivalStationCircle(
    selectedSubwayLine: SubwayLine,
    hasArrivedTrain: Bool
  ) -> some View {
    let circleSize: CGFloat = 16.0

    return HStack(spacing: 4.0) {
      if hasArrivedTrain {
        ZStack {
          Circle()
            .frame(width: circleSize, height: circleSize)
            .foregroundColor(selectedSubwayLine.color)
          Text("도착")
            .font(.caption2)
            .foregroundColor(.secondary)
            .offset(y: -18)
        }
      } else {
        Circle()
          .strokeBorder(lineWidth: 3.0)
          .frame(width: circleSize, height: circleSize)
          .foregroundColor(selectedSubwayLine.color)
      }
      Line()
        .stroke(style: StrokeStyle(lineWidth: 2.0))
        .foregroundColor(.systemGray5)
        .frame(width: 12.0)
    }
  }

  private func trainInfoStack(
    viewStore: ViewStoreOf<TrainLaneFeature>,
    laneWidth: CGFloat
  ) -> some View {
    ForEachStore(store.scope(state: \.trains, action: TrainLaneFeature.Action.train)) { trainStore in
      WithViewStore(trainStore, observe: { $0 }) { trainViewStore in
        if let xOffset = viewStore.xOffsets[trainViewStore.trainInfo.trainID] {
          TrainView(store: trainStore)
            .offset(x: xOffset)
            .opacity(trainViewStore.eta <= 300 ? 1 : 0)
        }
      }
    }
  }
}
