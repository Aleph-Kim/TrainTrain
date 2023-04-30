//
//  RealtimeStationArrivalView.swift
//  TrainTrainApp
//
//  Created by Geonhee on 2023/04/03.
//

import Arrival
import ComposableArchitecture
import Selection
import SwiftUI

struct RealtimeStationArrivalView: View {
  let store: StoreOf<RealtimeStationArrivalFeature>

  var body: some View {
    WithViewStore(store, observe: \.isKeyboardShowing) { isKeyboardShowingViewStore in
      VStack {
        arrivalDashboardView()
        selectionView()

        if !isKeyboardShowingViewStore.state {
          noticeView()
        }
      }
    }
  }

  @ViewBuilder
  private func arrivalDashboardView() -> some View {
    ArrivalDashboardView(
      store: store.scope(
        state: \.arrivalDashboard,
        action: RealtimeStationArrivalFeature.Action.arrivalDashboard
      )
    )
    .dynamicTypeSize(.medium)
    .padding()

    Divider()
      .padding(.horizontal)
  }

  private func selectionView() -> some View {
    SelectionView(
      store: store.scope(
        state: \.selection,
        action: RealtimeStationArrivalFeature.Action.selection
      )
    )
    .padding(.top)
    .padding(.bottom, 5)
  }

  private func noticeView() -> some View {
    Group {
      Text("NOTICE")
        .font(.system(size: 12))
        .bold()
        .padding(.vertical, 5)
      Text("실시간 정보는 서울시만 제공하는 공공데이터로,")
      Text("서울을 제외한 지역의 실시간 정보는 아직 제공되지 않습니다.")
      Text("빠르게 타 지자체도 제공해주시기를 바라고 있습니다.🙏🏻")
    }
    .foregroundColor(.secondary)
    .font(.system(size: 10))
  }
}
