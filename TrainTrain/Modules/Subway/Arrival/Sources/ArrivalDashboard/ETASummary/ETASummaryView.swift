//
//  ETASummaryView.swift
//  Arrival
//
//  Created by Geonhee on 2023/04/01.
//

import ComposableArchitecture
import SwiftUI
import TTDesignSystem

struct ETASummaryView: View {
  let store: StoreOf<ETASummaryFeature>

  struct ViewState: Equatable {
    static let isAboutToArriveText = "곧 도착"
    var formattedPrimaryETA: String?
    var formattedSecondaryETA: String?

    init(from state: ETASummaryFeature.State) {
      if let primaryETA = state.primaryTrain?.eta, primaryETA <= 30 {
        self.formattedPrimaryETA = Self.isAboutToArriveText
      } else {
        self.formattedPrimaryETA = state.primaryTrain?.eta.asClock
      }

      if let secondaryETA = state.secondaryTrain?.eta {
        self.formattedSecondaryETA = "\(secondaryETA / 60)"
      }
    }
  }

  var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      VStack(spacing: 0) {
        if let primaryETA = viewStore.formattedPrimaryETA {
          primaryETAText(primaryETA)
        } else {
          noUpcomingTrainText()
            .font(.body)
            .foregroundColor(.additionalGray4)
        }

        if let secondaryETA = viewStore.formattedSecondaryETA {
          secondaryETAText(secondaryETA)
        } else if viewStore.formattedPrimaryETA != nil {
          noUpcomingTrainText()
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .padding(.vertical, 12)
      .frame(height: 86)
      .frame(maxWidth: .infinity, alignment: .center)
      .backgroundColor(.accessibleSystemGray6)
      .cornerRadius(20.0, corners: [.bottomLeft, .bottomRight])
    }
  }

  @ViewBuilder
  private func primaryETAText(_ formattedETA: String) -> some View {
    if formattedETA == ViewState.isAboutToArriveText {
      Text(formattedETA)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.accessibleSystemIndigo)
        .padding(.bottom, 6.0)
    } else {
      HStack(spacing: 4.0) {
        Text("도착예정")
          .font(.title2)
          .foregroundColor(.additionalGray5)

        Text(formattedETA)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.accessibleSystemIndigo)

        Text("후")
          .font(.title2)
          .foregroundColor(.additionalGray5)
      }
      .padding(.bottom, 6.0)
    }
  }

  private func secondaryETAText(_ formattedETA: String) -> some View {
    Text("다음열차 약 \(formattedETA)분 후")
      .font(.subheadline)
      .foregroundColor(.secondary)
  }

  private func noUpcomingTrainText() -> some View {
    Text("도착예정 열차가 없습니다.")
  }
}
